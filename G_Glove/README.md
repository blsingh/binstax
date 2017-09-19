
Local Working folder is blsingh@js-169-81:~/Container1/My_Projects/G_Glove

#### Predicting 2017 golden glove winner project AND LEARN GIT

### I am working from Bash prompt using vimux to run command from vim so I will be working from this README file initially issuing commands and creating a reproduciable script.


## I will be working with MySQL server install on my laptop and accessing it from my Linux VM, the entire project script will be in this README.md file -- using Vimux I am will be running commands from this file, and this file will be used for reporducing my work but another user will have to keep in mind that this is aa much an exercise in querying data from Lahman's baseball database in MySQL server.

* Start R and connect it to the database
```{R}

start_rmote(port = 4324) ## This is feature of my enviroment (ignore in rr(reporduciable research) under differnt environtment
#Serving the directory /tmp/Rtmp638QX6/rmote_server at http://127.0.0.1:4324
#To stop the server, run servr::daemon_stop("52572384") or restart your R session

library(RMySQL)

con = dbConnect(dbDriver("MySQL"), user = "blsingh", password = "lqsymM7&", dbname = "lahman2016", host = "127.0.0.1", port = 33067) ## Used port forwarding to connect to MySQL server over local port 33067

# check the connection
dbListTables(con) ## Below is the output, all tables from the lahmans database.

```
    [1] "allstarfull"         "appearances"         "awardsmanagers"
    [4] "awardsplayers"       "awardssharemanagers" "awardsshareplayers"
    [7] "batting"             "battingpost"         "collegeplaying"
   [10] "fielding"            "fieldingof"          "fieldingofsplit"
   [13] "fieldingpost"        "halloffame"          "homegames"
   [16] "managers"            "managershalf"        "master"
   [19] "parks"               "pitching"            "pitchingpost"
   [22] "salaries"            "schools"             "seriespost"
   [25] "teams"               "teamsfranchises"     "teamshalf"
   [28] "user_details"

* How do I go about jumping right into this baseball analytics prediction?
- Use Classification prediction model

```{R}

```
