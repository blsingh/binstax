# PowerShell 5.1 Mastery Syllabus

This guide is designed for you to copy, paste, and adapt as prompts to navigate your learning journey with Gemini. It focuses on shifting from a procedural (mouse-click) mindset to an algorithmic (CLI-driven) workflow using **Windows PowerShell 5.1**. Fill in the bracketed information `[...]` before sending your prompts to Gemini.

Move through the phases in order. Time to completion is not the measure — mastery of the concepts is. Do not advance past a phase until you can explain the material in your own words and apply it without referring to your notes.

---

## How to Use This Syllabus

### One Dedicated Gemini Thread

Create a single Gemini thread named **"PowerShell Learning"** and use it for the entire syllabus. Paste the Standing Preamble below as the first message and reuse the thread so the constraints stay in context. If you ever start a fresh thread, paste the preamble again.

### Standing Preamble for Gemini

> "I am learning Windows PowerShell 5.1 running on .NET Framework 4.x. Constrain all answers to features available in this environment. If a cleaner solution exists in PowerShell 7+ but cannot be used here, flag it explicitly and give me the 5.1-compatible version.
>
> Do not give me finished code on the first response. Ask me guiding questions and let me write the code myself. When you do suggest an approach, identify every dependency: PowerShell version, .NET class, external module, COM dependency, file-system permission, execution policy, network assumption, and whether admin rights are required.
>
> Before I accept any generated code, ask me to identify which line or assumption is most likely to fail in 5.1 and why.
>
> Verify your suggestions by reasoning about whether they will actually run in 5.1."

### Decomposition Rubric (complete before writing code on any project)

For every project in this syllabus, write a one-paragraph plain-English algorithm and answer these six questions before you open the editor:

1. **Inputs:** What are they? Types, sources, expected volumes.
2. **Outputs:** What format, what destination, what defines success?
3. **Invariants:** What must always hold true? (idempotency, ordering, uniqueness)
4. **Failure modes:** What can go wrong? How should each failure be handled?
5. **Composable units:** What is the smallest reusable piece? Is it a function? A pipeline stage?
6. **Complexity:** Will this scale to 10x the data? Where is the bottleneck?

If you cannot answer a question, that is the work to do next — not more typing.

### Explain Twice

For every project, explain the task to me twice before writing code:

1. **First, without naming any PowerShell commands.** "Traverse a directory tree, keep files matching a predicate, project each file into a normalized record, group records by extension, calculate summary statistics, and serialize the results."
2. **Then as a PowerShell pipeline or script design.**

If you cannot do step one, you do not yet understand the algorithm. The shell is the implementation; the algorithm is the work.

---

## 📂 Part 1: Foundations & Decomposition

### ⌨️ Phase 1: Windows OS Velocity & Keyboard Navigation
> **Prompt for Gemini:**
> "I am transitioning to a keyboard-centric workflow in Windows to increase my efficiency. Walk me through the essential keyboard shortcuts for window management and application launching. Ask me guiding questions to test my understanding of:
> 1. **Task Switching:** The operational differences and best use cases for `Alt+Tab` versus `Windows Key+Tab` (Task View).
> 2. **Global Hotkeys:** The exact steps to create a Windows desktop shortcut for an application (like PowerShell) and assign a custom keyboard shortcut to it (e.g., configuring `Ctrl+Alt+P` as its launcher) so I can open it instantly from any context.
> 3. **Virtual Desktops:** How `Win+Ctrl+D`, `Win+Ctrl+Left/Right`, and `Win+Ctrl+F4` let me separate research contexts without alt-tabbing through clutter."

### 🚀 Phase 2: PowerShell Shell Velocity
> **Prompt for Gemini:**
> "I want to operate inside the PowerShell 5.1 console at typing speed, without reaching for the mouse. Ask me guiding questions to test my understanding of:
> 1. **Tab Completion:** How tab completion works for cmdlets, parameters, paths, and property names after a `.` on an object.
> 2. **History Navigation:** Using PSReadLine to search history with `Ctrl+R`, prefix-search with `F8`, and how to inspect and edit prior commands without retyping.
> 3. **Discovery Cmdlets:** Using `Get-Help -ShowWindow`, `Show-Command`, and `Get-Command -Module` as discovery tools that bridge GUI habits into CLI fluency.
> 4. **GUI-to-CLI Bridge:** When `Out-GridView -PassThru` is a legitimate tool for filtering and selecting objects interactively from a pipeline.
> 5. **Profile Customization:** How `$PROFILE` works, what belongs in it (aliases, helper functions, prompt customization), and how to keep it under version control."

### 🛠️ Phase 3: The CLI Mindset & Foundational PowerShell
> **Prompt for Gemini:**
> "I am a new Research Data Specialist I learning to transition from a GUI-dependent workflow to a CLI-first workflow using **PowerShell 5.1**. Help me learn the foundational mechanics step-by-step. Do not give me code solutions immediately; instead, explain the concepts and ask me a guiding question to test my understanding of:
> 1. **Cmdlet Structure:** How Verb-Noun syntax works and how to use `Get-Help`, `Get-Command`, and `Get-Member`.
> 2. **Paths & Navigation:** Managing providers using `Set-Location` and `Get-ChildItem`.
> 3. **The Object Pipeline:** Why PowerShell passes structured data objects rather than plain text strings, and why this is the central algorithmic primitive of the shell.
> 4. **Composition over Procedure:** Why chaining small, single-purpose cmdlets through the pipeline is functionally equivalent to composing functions, and why this is the opposite of writing one long procedural block.
> 5. **Aliases in Scripts:** Why `gci | ? { ... } | % { ... }` is acceptable interactively but unacceptable in saved scripts, and what self-documenting code looks like."

### 🧮 Phase 4: Algorithmic Primitives
> **Prompt for Gemini:**
> "Before I learn more PowerShell syntax, I want to understand the universal algorithmic primitives that underlie almost every data task. Use this concept-to-PowerShell map as a starting point:
>
> | Algorithmic concept | PowerShell concept |
> |---|---|
> | Traverse | enumerate files, rows, records, or API results |
> | Filter | keep only records matching a predicate |
> | Map / transform | convert each input object into another shape |
> | Project | select only needed properties |
> | Reduce | summarize many records into fewer results |
> | Group | partition records by key |
> | Sort | order records by one or more properties |
> | Join / enrich | add data using a shared key or lookup table |
> | Serialize | export objects to CSV, JSON, XML, or text |
> | Stream | process one item at a time |
> | Materialize | store full results in memory |
>
> Ask me to classify small data tasks according to which primitives they require. For each task, make me explain the algorithm first **without naming any PowerShell commands**, then map it to the shell. Do not give me finished scripts.
>
> I want to leave this phase able to look at any messy operational request and decompose it into this vocabulary before writing a single line of code."

### 🧱 Phase 5: Variables, Types, and Data Structures
> **Prompt for Gemini:**
> "I need to understand how PowerShell 5.1 represents and manipulates data in memory before I can think algorithmically about it. Ask me guiding questions about:
> 1. **The Type System:** How PowerShell handles typing, when to declare types explicitly (e.g., `[int]$count = 0`), and what `Get-Member` tells me about an object.
> 2. **Hashtables and Ordered Dictionaries:** When to use `@{}` versus `[ordered]@{}`, and why hashtables are the right structure for lookups, counters, and grouping.
> 3. **Arrays vs. ArrayList vs. Generic List:** Why `$array += $item` is O(n²) in a loop, and when to reach for `[System.Collections.Generic.List[object]]::new()` instead.
> 4. **Custom Objects:** How to construct a `[PSCustomObject]` and why it is the idiomatic way to produce structured pipeline output.
> 5. **Splatting:** How to pass a hashtable of parameters to a cmdlet using `@params` and why this beats long line-continuation chains."

### 🔁 Phase 6: Control Flow & Iteration
> **Prompt for Gemini:**
> "I need to understand iteration and conditional logic in PowerShell 5.1 well enough to make deliberate algorithmic choices. Ask me guiding questions about:
> 1. **`foreach` Statement vs. `ForEach-Object` Cmdlet:** The difference between eager and streaming evaluation, and how that affects memory usage on large datasets.
> 2. **Filtering at the Source:** Why `Get-ChildItem -Filter '*.log'` is dramatically faster than `Get-ChildItem | Where-Object { $_.Name -like '*.log' }`, and what 'pushing the predicate down' means.
> 3. **Conditional Flow:** When to use `if/elseif/else`, when `switch` is the better choice, and when both are a sign that I should be using a hashtable lookup instead.
> 4. **Strict Mode:** What `Set-StrictMode` catches, and why pinning to a specific version (e.g., `-Version 3.0`) is better for reproducibility than `-Version Latest`, which can change behavior across PowerShell versions."

### 🔤 Phase 7: Regular Expressions & Pattern Matching
> **Prompt for Gemini:**
> "I need to clean and validate unstructured text data using PowerShell 5.1. Help me understand how to use Regular Expressions (Regex) algorithmically. Ask me guiding questions about:
> 1. **Match Operators:** How to use `-match`, `-replace`, and `-split` directly within the pipeline.
> 2. **Capture Groups:** How to extract specific, structured data points from a larger string using the `$Matches` automatic variable and named captures.
> 3. **Anchors and Quantifiers:** Why `^`, `$`, `\b`, `*?`, and `+?` matter, and how greedy vs. lazy matching changes results.
> 4. **Test Sets First:** Why I should write positive and negative sample strings before writing the pattern.
> 5. **When Regex Is Wrong:** Why regex is the wrong tool for parsing HTML, nested structures, or malformed XML, and what to use instead."

### 📊 Phase 8: Learning Project — Network Drive Analytics
> **Prompt for Gemini:**
> "I need to build a PowerShell 5.1 script that crawls a system network directory `[Insert Network Drive Path Here]` recursively and generates data analytics. I have already completed the decomposition rubric for this project and will share it with you. I will also explain the algorithm in plain English before naming any PowerShell commands. Walk me through designing the logic algorithmically before writing the code. Ask me questions to help me figure out:
> 1. How to efficiently gather file metadata recursively without overloading system memory (streaming via the pipeline vs. collecting into a variable).
> 2. How to group and aggregate the data by file type count, total/average size, and utilization time windows using `Group-Object` and `Measure-Object`.
> 3. How to handle inaccessible folders, locked files, and long-running scans.
> 4. How to output these metrics into a clean, structured format using `[PSCustomObject]` and `Export-Csv`.
> 5. How to use `Measure-Command` to empirically test which of two approaches is faster on the real directory, rather than guessing."

---

## 🛡️ Part 2: Robust Scripts

### 🧩 Phase 9: Functions and Parameters
> **Prompt for Gemini:**
> "I want to turn ad-hoc PowerShell 5.1 commands into reusable functions. Ask me to define the function contract — name, purpose, inputs, outputs, errors — before discussing implementation. Then ask me guiding questions about:
> 1. **Function Definition:** The syntax for `function` declarations, typed parameters, default values, and the difference between simple and advanced functions.
> 2. **`[CmdletBinding()]`:** What it enables (common parameters, `$PSCmdlet`, write-streams) and why every non-trivial function should declare it.
> 3. **Parameter Validation:** How `[ValidateSet]`, `[ValidateRange]`, `[ValidateNotNullOrEmpty]`, `[ValidatePattern]`, and `[ValidateScript]` move error detection to the function boundary instead of the function body.
> 4. **Pipeline-Aware Parameters:** The mechanics of `ValueFromPipeline` and `ValueFromPipelineByPropertyName`, and how `begin / process / end` blocks let a function behave like a native cmdlet.
> 5. **Comment-Based Help:** How to write `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, and `.EXAMPLE` blocks above a function so `Get-Help` works natively from day one."

### 🚨 Phase 10: Error Handling
> **Prompt for Gemini:**
> "I need my PowerShell 5.1 scripts to fail predictably and informatively. Ask me guiding questions about:
> 1. **Terminating vs. Non-Terminating Errors:** Why some errors stop execution and others do not, and how this asymmetry is the source of most silent failures in PowerShell.
> 2. **`$ErrorActionPreference` and `-ErrorAction`:** When to set the preference globally, when to set it per-cmdlet, and what `Stop` actually does to a non-terminating error.
> 3. **`try / catch / finally`:** How to catch specific exception types, when to rethrow with `throw`, and why a bare `catch {}` is almost always a bug.
> 4. **The `$Error` Variable:** How to inspect prior errors during debugging without rerunning the script.
> 5. **Output Streams:** Why `Write-Error`, `Write-Warning`, `Write-Verbose`, and `Write-Information` exist as separate streams, why `Write-Host` should be reserved for human-facing console decoration, and why mixing data with logs is a design smell."

### 🧪 Phase 11: Test Data & Sanity Checks
> **Prompt for Gemini:**
> "Before I run any data script against real data, I need a discipline for proving it works on small controlled inputs. A script that runs successfully is not the same as a script that produced correct output. Ask me guiding questions about:
> 1. **Defining 'Correct' First:** Why I should write down what the output should look like *before* I run the script, not after — and why this is the only honest way to know if it worked.
> 2. **Small Representative Datasets:** How to construct a tiny test dataset (5 records, not 50,000) that deliberately includes edge cases: nulls, duplicates, malformed rows, missing fields, boundary dates, and Unicode characters.
> 3. **Row-Count Reconciliation:** Why every transformation should produce a 'rows in, rows out, rows rejected' summary, and why those numbers should add up.
> 4. **Spot Checks vs. Visual Inspection:** Why scrolling through output is not testing, and what cheap programmatic checks (`Group-Object`, `Where-Object`, `Measure-Object`) can catch instead.
> 5. **Negative Tests:** How to deliberately feed the script bad input and confirm it fails the way I expect, rather than silently producing nonsense.
> 6. **Preserving Raw Input:** Why the original input must never be overwritten by the cleaned output, and why test runs should write to disposable paths.
>
> Make me design the test set for my Phase 8 Network Drive Analytics script as a worked example before moving on."

### 🧹 Phase 12: Learning Project — CSV / Log Normalizer
> **Prompt for Gemini:**
> "I need to build a PowerShell 5.1 workflow that ingests a messy CSV, delimited file, or plain-text log `[Insert File Path Here]`, normalizes the fields, validates required values, rejects bad rows into a separate report, and exports clean output. This is my first real data-cleaning project — keep it focused on parsing and validation, not document extraction. I have completed the decomposition rubric. Guide me through designing:
> 1. **Input Structure Detection:** How to inspect a sample of the file before assuming its shape.
> 2. **Header Normalization:** How to standardize header names (case, whitespace, punctuation) before processing.
> 3. **Field Cleanup:** Trimming, casing, date parsing with `[datetime]::ParseExact`, and numeric coercion.
> 4. **Required-Field Validation:** How to define which fields are mandatory and what makes a value invalid.
> 5. **Rejection Handling:** How to route bad rows to a rejection report with the reason for rejection, rather than silently dropping them.
> 6. **Output:** How to export the clean dataset, the rejection dataset, and a brief run summary (rows read, rows written, rows rejected, warnings).
>
> Ask me to define what a valid row and an invalid row look like before I write any code."

### 📝 Phase 13: Learning Project — Word Document Table Harvester
> **Prompt for Gemini:**
> "I need to create a PowerShell 5.1 automation script that looks inside a directory of `.docx` documents `[Insert Directory Path Here]`, extracts data embedded inside tables, and aggregates it into a single CSV file. Before recommending an approach, ask me to consider what a `.docx` file actually is at the byte level and what that implies about how I could read it. Then guide me through two architectural paths so I can choose deliberately:
> 1. **The Word COM Path:** How to instantiate `New-Object -ComObject Word.Application`, the logic to open a document invisibly, iterate the tables collection, and loop through rows and cells. Discuss the trade-offs: requires Word installed, single-threaded, slow at scale, fragile on malformed documents, and must be released properly with `Marshal.ReleaseComObject` or Word processes accumulate.
> 2. **The ZIP/XML Path:** How `.docx` is a ZIP archive of XML files, how to load `System.IO.Compression.FileSystem` (which is not loaded by default in 5.1), how to read `word/document.xml` using `[System.IO.Compression.ZipFile]` and `[xml]`, and — critically — how OOXML uses XML namespaces that require an `XmlNamespaceManager` for XPath selection to work. Naive XPath without namespace handling will silently match nothing.
> 3. **Sanitization and Output:** How to clean raw cell text, cast it to a `[PSCustomObject]`, and export the final array to CSV using `Export-Csv -NoTypeInformation -Encoding UTF8`.
> 4. **Empirical Comparison:** How to use `Measure-Command` to test both approaches on a representative sample and make an evidence-based choice.
>
> Require me to choose an architecture and defend the choice before implementation."

---

## 📈 Part 3: Scale & Reusability

### ⚙️ Phase 14: Asynchronous Processing (Background Jobs)
> **Prompt for Gemini:**
> "My network drive analytics script takes a long time to run and locks up my PowerShell 5.1 console. I want to learn how to run tasks asynchronously. Guide me through background jobs without writing the full script for me. Ask me questions to test my understanding of:
> 1. **Job Management:** The lifecycle of a job using `Start-Job`, `Get-Job`, `Wait-Job`, and `Receive-Job`.
> 2. **Data Passing:** How passing variables into an isolated background job differs from a standard script, why `$using:` exists, and what gets serialized across the job boundary (and what becomes a deserialized object that has lost its methods).
> 3. **Resource Cleanup:** How to monitor job states and properly clear them from memory with `Remove-Job` once the data is retrieved.
> 4. **When Not to Use Jobs:** Why jobs are heavyweight (each is a separate PowerShell process), and when a runspace pool would be the right tool instead — even though that is more advanced.
> 5. **Suitability Check:** Make me explain whether my specific task is actually a good candidate for jobs before I implement them."

### 🗄️ Phase 15: Relational Database Extraction (Read-Only MSSQL)
> **Prompt for Gemini:**
> "I need to query data from a Microsoft SQL Server database `[Insert Read-Only MSSQL Server Name Here]` using PowerShell 5.1. I only have read access. Guide me through the architecture of connecting and extracting data natively. Ask me questions about:
> 1. **Module Availability:** Why the `SqlServer` module may not be installable on a locked-down machine, and why `System.Data.SqlClient` from .NET Framework is always available as a fallback.
> 2. **Connection Lifecycle:** How to construct a `SqlConnection`, open it, dispose of it properly via `try/finally`, and why connection strings should never be hardcoded.
> 3. **Memory Management:** How to handle massive SQL result sets using a `SqlDataReader` to stream rows algorithmically, instead of materializing the full result set with `DataAdapter.Fill()`.
> 4. **Parameterized Queries:** How to pass PowerShell variables into `SELECT` statements safely with `SqlParameter`, and why string concatenation into SQL is never acceptable even on a read-only connection.
> 5. **Row-Count Validation:** How to compare actual rows returned against an expected range, and what to do when the count is suspicious."

### 📦 Phase 16: Script Packaging & Reusability (Modules)
> **Prompt for Gemini:**
> "I have built functional PowerShell 5.1 scripts for data extraction and file analysis. I want to transition these from standalone `.ps1` files into a reusable module. Guide me through the architecture of module creation. Ask me to propose the module structure — name, public functions, private helpers — before implementation. Then ask me questions about:
> 1. **Module Structure:** How to organize my functions into a `.psm1` file, the convention of one function per `.ps1` file dot-sourced from the `.psm1`, and why I need a module manifest (`.psd1`).
> 2. **Scope & Visibility:** How to use `Export-ModuleMember` (or the `FunctionsToExport` manifest entry) to expose only my public tools while keeping helpers private.
> 3. **Module Discovery:** How `$env:PSModulePath` works, where to install a module for personal use versus all users, and how to verify it loads cleanly in a fresh session.
> 4. **Versioning:** How to set a version in the manifest and why even internal scripts deserve semantic versioning."

---

## 🌐 Part 4: Integration & Autonomy

### 📋 Phase 17: Data Provenance & Auditability
> **Prompt for Gemini:**
> "I work in a regulated environment where data outputs may need to be defended months from now. A CSV that nobody can trace back to its source, its script version, and its run parameters is a liability, not an asset. Help me design a minimum viable provenance discipline for my PowerShell 5.1 workflows. Ask me guiding questions about:
> 1. **The Six-Months Question:** If someone asks me where a specific output came from — which script, which version, which inputs, which run — can I answer without guessing? What metadata makes that possible?
> 2. **Run Manifests:** What belongs in a per-run manifest at minimum (run ID, start/end timestamps, script name and version, input source, output destination, rows read, rows written, rows rejected, error count) and what is over-engineering at my current scale.
> 3. **Output Traceability:** How to embed a run ID or timestamp into output filenames or sidecar metadata so an output and its manifest can never be separated.
> 4. **Rejected Records as Audit Evidence:** Why my Phase 12 rejection report is itself a piece of audit evidence, not a discardable byproduct, and how to retain it alongside the clean output.
> 5. **Log Hygiene:** What belongs in a log (decisions, counts, durations, failures) versus what must never appear in a log (secrets, full credential strings, protected information), and how to design logging so this distinction is automatic rather than something I have to remember every time.
> 6. **Retention and Retrieval:** Where manifests should live, how long they should be kept, and how to find one when I need it without grepping through a year of logs.
>
> Make me retrofit a minimum manifest onto one of my completed prior projects before designing one for a new project. For this exercise:
> 1. Pick one of my completed projects — Phase 8 Analytics, Phase 12 CSV Normalizer, or Phase 13 DOCX Harvester.
> 2. Modify it to emit a run manifest (JSON or CSV) as a sidecar file alongside each output, with the manifest name tied to the output name so the two cannot be separated.
> 3. Run the modified script against test data and produce both the output and its manifest.
> 4. Write a brief note listing what was not captured before the retrofit and what is now.
>
> When I bring you the result, attempt to answer this question using only the manifest, without reading the script: 'where did this output come from and what did the script do?' If you cannot answer cleanly, the retrofit is insufficient and I should revise it before bringing it to my reviewer."

### 🌐 Phase 18: API Integration & Web Requests
> **Prompt for Gemini:**
> "I need to extract data from an internal REST API `[Insert API Endpoint Here]` using PowerShell 5.1. Guide me through the architecture of making web requests algorithmically using `Invoke-RestMethod`. Ask me to describe the API contract and pagination model before writing code. Then ask me questions to test my understanding of:
> 1. **TLS 1.2:** Why PowerShell 5.1 defaults to older TLS versions, what `[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12` does, and why most modern APIs will silently fail without it.
> 2. **Authentication:** How to construct and pass custom headers (bearer tokens, API keys) securely within the request, and why credentials must come from a credential store and never from the script body.
> 3. **Pagination:** The logic required to detect whether an API response is paginated via body fields, cursor tokens, or HTTP `Link` headers — and how to build a loop that requests all pages without unbounded recursion.
> 4. **Header Capture:** How to use `-ResponseHeadersVariable` with `Invoke-RestMethod` (available in 5.1) to inspect rate-limit metadata and pagination links that live in headers rather than the body.
> 5. **Payload Translation:** How PowerShell automatically converts JSON payloads into native objects via `ConvertFrom-Json`, and the 2 MB default input limit in 5.1 (fixed in 6+) that will silently truncate large responses.
> 6. **Resilience:** How to implement retry-with-backoff for transient failures (HTTP 429, 503) without retrying on permanent failures (HTTP 401, 404)."

### 🔐 Phase 19: Secure Credential Management
> **Prompt for Gemini:**
> "I am writing PowerShell 5.1 scripts that connect to databases and APIs. Guide me through credential management without hardcoding passwords. Ask me to identify the execution context — interactive user, scheduled task account, service account — before choosing a credential approach. Then ask me questions about:
> 1. **Secure Strings:** The difference between a standard string and a `SecureString`, how to use `Read-Host -AsSecureString`, and what `SecureString` actually protects against (and what it does not).
> 2. **PSCredential Objects:** How to instantiate a `[pscredential]` object and pass it to cmdlets that accept `-Credential`.
> 3. **Encrypted Storage:** How `Export-Clixml` encrypts credentials using DPAPI, and why the resulting file is bound to **both the user account and the machine** that created it.
> 4. **DPAPI Implications for Automation:** If a credential file is created by my interactive account but the scheduled task runs under a service account, what happens — and how to design around it."

### ⏱️ Phase 20: Unattended Automation (Scheduled Tasks)
> **Prompt for Gemini:**
> "I have built a robust data harvesting PowerShell 5.1 script, and now I need it to run automatically every night at 2:00 AM. Guide me through scheduling this task natively from the CLI. Make me complete an execution-context checklist before implementation. Then ask me questions about:
> 1. **Task Architecture:** How to define Triggers (`New-ScheduledTaskTrigger`) and Actions (`New-ScheduledTaskAction`) using PowerShell.
> 2. **Execution Context:** The syntax required to launch PowerShell silently via an action (e.g., `powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File 'C:\path\script.ps1'`), and why `-NoProfile` matters for reproducibility.
> 3. **Working Directory:** Why scheduled tasks do not inherit the working directory I expect, why my script must `Set-Location` explicitly or use absolute paths everywhere, and what breaks otherwise.
> 4. **Mapped Drives vs. UNC Paths:** Why mapped drives (`Z:\`) often do not exist for the account running the task and why UNC paths (`\\server\share`) are safer for unattended scripts.
> 5. **Identity:** Which account the task should run as, the implications for credential files (see Phase 19), and how 'run whether user is logged on or not' changes behavior.
> 6. **Headless Troubleshooting:** Implementing structured logging — timestamps, levels, and `Start-Transcript` — so I have a physical text log to review the next morning. The log location must be writable by the task identity.
> 7. **Idempotency:** How to design the script so that two accidental concurrent runs do not corrupt output or double-count data."

### 🎓 Phase 21: Capstone
> **Prompt for Gemini:**
> "I am ready to design and build an end-to-end PowerShell 5.1 project that integrates everything I have learned. The project is: `[Describe the end-to-end task — e.g., 'nightly extraction of records from MSSQL, enrichment via an internal API, output to CSV, with full error logging and email notification on failure']`.
> 1. Ask me to complete the decomposition rubric for this project before discussing any code.
> 2. Ask me to explain the workflow in plain English without naming PowerShell commands, then again as a pipeline design.
> 3. Ask me to identify which phases of the syllabus apply to which parts of the project.
> 4. Ask me to propose a module structure (which functions, which files, which exports) before I write any of them.
> 5. Ask me to define test data, validation rules, logging, and idempotency before implementation.
> 6. Only after all of the above, walk through the implementation as guiding questions — not finished code."
