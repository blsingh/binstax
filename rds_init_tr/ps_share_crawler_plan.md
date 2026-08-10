# I:\ Share Crawler -- Investigation Plan

Status: strategy only. No code written. Target console access: on return to the work
machine (author away as of 2026-08-09).

Goal: crawl the I:\ network share, determine every document type that can be scraped
into CSV, extract them, and expose the result through ODBC for ad-hoc query.

Constraints already fixed:
- Windows PowerShell 5.1 only. No pwsh, no Core.
- No third-party installs except modules from the PowerShell Gallery.
- Microsoft Office is installed on the target machine (COM available).
- Scale is tens of thousands of files, not millions.
- Output CSV defaults to the user's Documents folder, with path and base name
  overridable by parameter.

---

## Items

1. Environment probe
2. Share inventory walk
3. File family clustering
4. Family viability scoring
5. OOXML fast lane
6. COM lane for legacy formats
7. PDF lane
8. Plain-text and structured-text lane
9. Unified output contract
10. CSV emission and output location
11. ODBC mount over the CSVs
12. Presentation layer
13. Resume state and incremental runs

---

## 1. Environment probe

Establish what the machine can actually do before any design is finalized. Everything
downstream branches on the answers, and none of them can be confirmed from off-site.

Check:
- ODBC text drivers present. Enumerate with `Get-OdbcDriver`. The legacy
  `Microsoft Text Driver (*.txt, *.csv)` is 32-bit only; the ACE-based
  `Microsoft Access Text Driver (*.txt, *.csv)` is the one that appears in 64-bit.
  Which of the two exists decides item 11 entirely.
- ACE OLEDB provider present and its bitness, for any `.mdb` / `.accdb` found later.
- Office COM registration confirmed by actually instantiating `Word.Application` and
  `Excel.Application`, not by checking for an installed-products registry key.
- Gallery reachability from the corporate network: `Find-Module ImportExcel`. Confirm
  whether `Install-Module -Scope CurrentUser` succeeds without elevation or a proxy
  configuration, since the whole module strategy fails if the Gallery is blocked.
- `$PSVersionTable` and the installed .NET Framework version, recorded for the file.
- Whether `robocopy.exe` is present in `%SystemRoot%\System32`. It ships with Windows
  and needs no install, but confirm it is not blocked by policy.

Output: `probe_summary.csv`, one row per capability with a pass/fail and the detail.

## 2. Share inventory walk

Walk I:\ once and record what exists. This is the dataset that item 3 and item 4 operate
on, and it is the only stage whose cost scales with the whole share rather than with the
extraction targets.

Use `robocopy /L /S /NJH /NJS /FP /NS /NC /NDL` as the walker rather than
`Get-ChildItem -Recurse`. Robocopy handles paths beyond the 260-character `MAX_PATH`
limit that PowerShell 5.1 and .NET Framework 4.x will hard-fail on, and a mature
departmental share reliably contains some. Robocopy also continues past access-denied
directories instead of terminating.

Check:
- Actual wall-clock duration of a full walk, to decide whether item 13 needs to be
  built before anything else or can follow.
- Whether the share has DFS junctions or symlinks that could send the walk into a loop.
  Robocopy's `/XJ` excludes junction points if so.
- How many directories come back access-denied. Log them explicitly to a separate file;
  do not suppress them with `-ErrorAction SilentlyContinue`.
- Whether file owner is worth capturing. `Get-Acl` per file over SMB is slow enough that
  it likely belongs in a separate optional pass, if at all.

Fields per row: `FullPath, Name, Extension, DirectoryPath, SizeBytes, LastWriteTime, Depth`.

Output: `inventory.csv`, `denied_paths.csv`, and an extension histogram.

## 3. File family clustering

Viability is not a property of a file type. It is a property of a family of files
produced by the same recurring process against the same template. One memo in `.docx` is
not worth an extractor; nine hundred daily reports sharing a table layout are the entire
point of the project. This stage turns an unbounded problem into a ranked list.

Method: normalize each file name by replacing digit runs with `#` and recognizable date
patterns with `<DATE>`, normalize the parent directory path the same way, then group by
the tuple `Extension + DirectoryPattern + NamePattern + SizeBand`. Rank families by
member count.

Check:
- Whether the date normalization catches the formats actually in use. Expect at least
  `yyyyMMdd`, `MM-dd-yyyy`, and month-name variants; tune against the real inventory.
- Whether size banding is helping or splitting real families apart. It is there to
  separate a template from its filled-in instances, and may prove unnecessary.
- Where the cutoff sits between a family worth building an extractor for and a one-off.
  Pick the number after seeing the distribution, not before.

Output: `families.csv`, ranked.

## 4. Family viability scoring

Sample each family and decide what can be pulled out of it. Extensions lie, routinely
and in both directions, so this stage verifies content before committing to a lane.

Read the first 8 bytes of three to five samples per family and match the signature:
`PK\x03\x04` is OOXML (a ZIP), `D0CF11E0` is an OLE2 compound file, `{\rtf` is RTF,
`%PDF` is PDF. Files named `.xls` that are actually HTML tables or tab-delimited text are
common enough in enterprise shares to plan for rather than treat as an exception.

Then trial-extract the samples and assign a rating:
- `Structured` -- a stable table or field set, fit for direct column mapping.
- `Semi` -- extractable but needs per-family parsing rules.
- `Text` -- only free text is recoverable; useful for search, not for columns.
- `Catalog-Only` -- record its existence and metadata, extract nothing.

Check:
- How many families disagree between declared extension and actual signature.
- Whether any samples are password-protected or corrupt. These are what hang the COM
  lane in item 6, so the count here sizes that risk.
- Whether apparently identical families actually share a template, or whether the
  template drifted mid-history and needs splitting by date range.

Output: `families_scored.csv`.

## 5. OOXML fast lane

`.docx`, `.xlsx`, and `.pptx` are ZIP archives containing XML. They can be read with
`System.IO.Compression.ZipFile` and `[xml]` with no COM, no Office dependency, and no
dialog boxes. This lane is safe inside a runspace pool and is roughly two orders of
magnitude faster than driving Word. It is the single most important architectural choice
in the project, and the reason the COM lane in item 6 is a quarantine rather than the
default.

For Word, tables live in `word/document.xml` as `w:tbl` containing `w:tr` rows and `w:tc`
cells. Text is at `w:p > w:r > w:t`. Reading this requires an `XmlNamespaceManager`; the
WordprocessingML namespace is not optional.

For Excel, prefer the `ImportExcel` module, which handles the shared-string table and
date-serial conversion. Hand-rolled ZIP and XML parsing is the fallback if the Gallery is
unreachable, in which case note that `t="s"` cells are indexes into `xl/sharedStrings.xml`
and that dates are numeric serials needing a `numFmt` lookup to render correctly.

Check:
- Whether the daily Word reports use real `w:tbl` tables or text laid out with tabs.
  This determines whether the extractor is a tree walk or a line parser.
- Whether merged cells appear in those tables, and how they should map to CSV.
- Whether `ImportExcel` installs and imports cleanly under `-Scope CurrentUser`.
- Optimal runspace pool size. The bottleneck is SMB round-trips, not CPU, so start at
  four to eight threads and measure rather than scaling to core count.

## 6. COM lane for legacy formats

`.doc`, `.xls`, `.rtf`, and `.msg` are OLE compound files with no practical pure-.NET
reader available under the no-install constraint. Office is present, so COM works, but it
must be isolated: it is strictly serial, roughly one to three seconds per document, leaks
`WINWORD.EXE` and `EXCEL.EXE` processes if not released, and will block indefinitely on a
repair prompt or a password dialog for a single bad file in the middle of a long run.

Design the lane as a quarantine. Set `$app.Visible = $false` and
`$app.DisplayAlerts = $false`, open documents read-only with a password argument supplied
so the prompt never appears, release every COM object in a `finally` block via
`Marshal::ReleaseComObject`, and wrap each file in a timeout with a kill-by-PID watchdog
so one hang cannot end the run.

Check:
- How many files actually land in this lane. If the count is small, per-file process
  isolation becomes affordable and removes the hang risk entirely.
- Whether `.msg` files are present in volume. Outlook COM is a third application to
  manage; `.eml` by contrast is parseable directly and needs no COM at all.
- Whether the watchdog can reliably identify which Office PID belongs to this script and
  not to the user's own open documents. Getting this wrong closes the user's work.

## 7. PDF lane

Confirmed available. `working/PSWritePDF_Modules.txt` records PSWritePDF 0.0.20 already
installed on the work machine, exposing `Convert-PDFToText`, `Get-PDFFormField`,
`Get-PDFDetails`, and `Get-PDF`. PDF text extraction is therefore in scope rather than
deferred, and `Get-PDFFormField` means any fillable-form PDFs on the share may yield
clean key-value pairs rather than loose text.

Check:
- Whether the installed 0.0.20 is current, and whether updating is worth the risk of
  disturbing a module that already works.
- The split between text-layer PDFs and scanned images. Scans return empty text and must
  be routed to `Catalog-Only`; there is no OCR path under the constraints.
- Whether any PDFs on the share are fillable forms, which would make them a
  `Structured` family instead of `Text`.
- Throughput per document, to decide whether this lane needs parallelizing or can stay
  serial alongside the COM lane.

## 8. Plain-text and structured-text lane

`.csv`, `.txt`, `.tsv`, `.xml`, `.json`, `.html`, and `.log` are natively readable, but
the naive path is wrong often enough to matter. Delimiter and encoding must be sniffed
per family rather than assumed. PowerShell 5.1 defaults to UTF-16 LE on write and does
not reliably detect UTF-8 without a BOM on read, so encoding must be explicit in both
directions.

For `.html`, tables can be pulled without COM by parsing with `[xml]` after cleanup, or
by regex against `<tr>` and `<td>` when the markup is not well-formed. Avoid
`Invoke-WebRequest -UseBasicParsing` against local files for this; it is the wrong tool
and behaves inconsistently.

Check:
- Which encodings actually appear. Legacy exports from mainframe or clinical systems are
  frequently Windows-1252 and will corrupt silently if read as UTF-8.
- Whether any `.csv` files use embedded newlines inside quoted fields, which breaks
  line-based reading and forces `Import-Csv` or a real parser.
- Whether the `.xls`-named HTML files found in item 4 belong in this lane rather than
  the COM lane. They usually do, and routing them here avoids the slow path.

## 9. Unified output contract

Every extractor, regardless of source type or lane, returns the same shape. This keeps
the pipeline type-agnostic and means adding a new format later touches one extractor
rather than the whole chain.

Contract: `SourcePath, FileHash, Family, RecordIndex, FieldName, FieldValue`.

The format is deliberately long rather than wide. Report templates drift, and a column
added to the daily report at some point in the past will break a wide schema silently
while a long one simply gains a new `FieldName`. Pivot to wide per family at item 12,
where a mistake is cheap to correct.

Check:
- Which hash algorithm to use and whether hashing every file over SMB is affordable.
  MD5 is faster and adequate for change detection here; the alternative is to key on
  path plus size plus timestamp alone, as item 13 does.
- Whether `RecordIndex` needs to be compound, for example table number plus row number
  within a multi-table Word document.
- Whether provenance beyond `SourcePath` is needed, such as sheet name or page number.
  Adding it later means re-running everything.

## 10. CSV emission and output location

Write one long-format master CSV plus per-family wide pivots. Specify `-Encoding UTF8`
on every write without exception; the PowerShell 5.1 default of UTF-16 LE will break both
the ODBC mount in item 11 and anything downstream.

Parameters: `-OutputPath`, defaulting to `$env:USERPROFILE\Documents`, and `-BaseName`,
defaulting to `ShareCrawl_<yyyyMMdd>`. Both user-overridable, as specified.

Check:
- Whether the master CSV in long format grows large enough to be awkward. Tens of
  thousands of files at several hundred field-value rows each reaches the tens of
  millions of rows, which is past comfortable for the text ODBC driver and argues for
  querying the per-family pivots instead.
- Whether to split the master by family or by date range, and on what threshold.
- Whether a run should overwrite or version its output. Versioning by date in the base
  name already gives one run per day; decide what a second run on the same day does.

## 11. ODBC mount over the CSVs

Expose the emitted CSVs to ANSI SQL through the built-in text driver identified in
item 1. The driver has sharp edges that shape how item 10 must name its files.

Constraints to design around:
- The CSV file name becomes the SQL table name. No spaces, no extra dots, no leading
  digits.
- Column typing requires a `schema.ini` written alongside the data. Without it,
  everything is guessed from the first rows and long text fields get truncated.
- The connection string's `Dbq` is a directory, not a file, so all queryable CSVs must
  share one folder.

Check:
- Which of the two drivers is present, from item 1, and build the connection string for
  that one rather than hardcoding the legacy name.
- Column count limits and long-text handling against a real emitted file, particularly
  for any family exceeding 255 columns after pivoting.
- Whether SQL Server Express, LocalDB, or Access via ACE happens to be available on the
  machine. Any of them would be a better destination than CSV-plus-ODBC, and the check
  costs nothing.

## 12. Presentation layer

Two consumers, two outputs. `Out-GridView` for interactive filtering at the console,
since it is built in and needs nothing. A static HTML summary for handoff, showing
family counts, extraction success and failure rates, and the catalog-only list.

Check:
- Whether the audience wants an Excel workbook rather than HTML. If so, `ImportExcel`
  writes one without COM, but the decision changes the build.
- Whether the catalog-only list is itself a deliverable. A ranked inventory of what
  exists on the share but cannot be extracted may be more immediately useful than the
  extracted data.
- Whether per-family wide pivots should be produced on demand from the long master or
  written eagerly at item 10.

## 13. Resume state and incremental runs

A crawl of a network share will be interrupted. VPN drops, share maintenance, and laptop
sleep are all routine, and a run that cannot resume is a run that never finishes. Build
this into item 2 rather than retrofitting it.

Keep state on disk, checkpointed at an interval, keyed on `FullPath + SizeBytes +
LastWriteTime`. A re-run skips any file whose key is unchanged. This is also the endgame:
once the crawl is incremental, the same script runs nightly and picks up only the new
daily reports, which is the difference between a one-time extract and a live dataset.

Check:
- Checkpoint interval. Too frequent and the state file write dominates; too rare and an
  interruption loses meaningful work. Tune against the walk duration measured in item 2.
- Whether `LastWriteTime` is trustworthy on this share. Some copy and sync tools preserve
  it and some reset it, and if it is unreliable the key must fall back to a content hash.
- What happens to a file that is deleted from the share between runs. Decide whether the
  extracted rows are retained, tombstoned, or removed.
- Whether the state file should live with the output or in a fixed location independent
  of `-OutputPath`, given that the output path is user-overridable per run.

---

## Open questions still unanswered

- Whether the PowerShell Gallery is reachable from the corporate network at all. If it
  is not, item 5 loses `ImportExcel` and falls back to hand-rolled OOXML parsing, and
  item 7 depends entirely on the already-installed PSWritePDF 0.0.20.
- Whether the daily Word reports use real tables or tab-aligned text.
- Whether any better data destination than CSV exists on the machine, per item 11.
