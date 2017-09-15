Working folder is blsingh@js-169-81:~/Container1/My_Projects/G_Glove

#### Predicting 2017 golden glove winner" project

### I am working from Bash prompt using vimux to run command from vim so I will be working from this README file initially issuing commands and creating a reproduciable script.

```

git init	 ## initialize local dir

git add README.md

git commit -m "README GIT exercise" README.md

git remote add origin https://github.com/blsingh/My-Projects/tree/master/G_Glove

git remote -v

git remote show origin # more info about remote ## fatal..not found

git status

git push -u origin master

```
FAIL: I attempted to add remote origin as the subfolder in `G_Glove` in `My-Projects` repo for link this `local` dir.  What I tried is shown above.

What does work is the readme in the of `My-Project`; shown here

```

cd ~/Container1/My_Projects

ls -all ## Here the pushing `G_Glove` will be used to update the readme(THIS one), so I will save this after writing the commands below and then run them to update the README.md under `My-Projects/G_Glove`

git init

git add G_Glove

git status

git commit -m 'Update the README in G_Glove sub repo' -- G_Glove




