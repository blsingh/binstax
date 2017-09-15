Local Working dir blsingh@js-169-81:~/Container1/My_Projects
This is repo is used to commit my projects(local dir is given above).

Is git configured, is this dir talking to the remote repo?
I want to learn also to commint changes the make to specific dir in the repo, for example:
For the initial project I will learn with G_Glove/ dir

What I have found works for sure as of now 09152017 is that --force, or commit G_Glove/ dir from\n here My_Projects itself

```

git add G_Glove/ # try to add the dir alone in the 'My-Project' repo

git commit -m "pushing sub folders G_Glove from My_Projects folder" -- G_Glove

git push origin master

