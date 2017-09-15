
Local Working folder is blsingh@js-169-81:~/Container1/My_Projects/G_Glove

#### Predicting 2017 golden glove winner project AND LEARN GIT

### I am working from Bash prompt using vimux to run command from vim so I will be working from this README file initially issuing commands and creating a reproduciable script.







```
### FAIL

git init	 ## initialize local dir

git add README.md

git commit -m "README GIT exercise" README.md

git remote add origin https://github.com/blsingh/My-Projects/tree/master/G_Glove

git remote -v

git remote show origin # more info about remote ## fatal..not found

git status

git push -u origin master

```
FAIL(above): I attempted to add remote origin as the subfolder in `G_Glove` in `My-Projects` repo for link this `local` dir.  What I tried is shown above.

What does work is the to upload or update the README.md in `My_Projects/G_Glove` to using the git protocal form the git link in `My_Project` to `My-Projects` under which the folder G_Glove. i.e. work from `My_Project` rather than `My-Project`.

```

cd ~/Container1/My_Projects

git commit -m 'Update something in G_Glove' -- G_Glove


```



