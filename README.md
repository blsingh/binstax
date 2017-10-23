Local Working dir blsingh@js-169-81:~/Container1/My_Projects
This is repo is used to commit my projects(local dir is given above).

As I detail some of my thought process below, I have gotten use to making git servible enough to get my repo's up and running efficiently for my projects.
Just from from My_Projects and manages the files and folders in subfolders from here.

---


Is git configured, is this dir talking to the remote repo?
I want to learn also to commint changes the make to specific dir in the repo, for example:
For the initial project I will learn with `G_Glove` dir

What I have found works for sure as of now 09152017 is that just commit `G_Glove` dir from here My_Projects fol itself.  --force option allowed me to push changes to github by force.

```
#

git add G_Glove/ # try to add the dir alone in the 'My-Project' repo

git commit -m "pushing sub folders G_Glove from My_Projects folder" -- G_Glove

git push origin master

```

##### Below this is some rough notes about trying to copy Linux/tmux session
```
[SOLVED] Since I am using tmux, for my purposes I have settled on the using tmux command `capture-pane -S <# off lines>`.

So after I capture I/O from a session with `script` command into a xyz.txt file, from the terminal prompt I can issue `cat xyz.txt` to view the file without non-printable characters.  In tmux check how many lines are in my xyz.txt file with copy mode.  Finally from tmux command buffer issue the `capture-pane -S <# of lines>`command and then immediately give the following command from the tmux buffer and  save it to a file zyx.txt with `:save-buffer zyx.txt`.
```
