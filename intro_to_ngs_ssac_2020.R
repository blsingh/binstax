# 2020 SSAC workshop: introduction to NGS data in R
# presented by Jacksonville Jaguars: Momin Ghaffar & Victor C. Li

# big thank you to Michael Lopez, NFL Director of Data & Analytics!
# resources:
# https://github.com/nfl-football-ops/Big-Data-Bowl
# https://github.com/nfl-football-ops/Big-Data-Bowl/blob/master/schema.md
# https://www.kaggle.com/statsbymichaellopez/nfl-tracking-wrangling-voronoi-and-sonars

# library load
{
  library(readr)
  library(dplyr)
  library(ggplot2)
  library(ggvoronoi)
  library(gganimate)
  library(cowplot)
}

# data load
{
  file_tracking <- "https://raw.githubusercontent.com/nfl-football-ops/Big-Data-Bowl/master/Data/tracking_gameId_2017090700.csv"
  tracking_full <- read_csv(file_tracking)
  
  file_games <- "https://raw.githubusercontent.com/nfl-football-ops/Big-Data-Bowl/master/Data/games.csv"
  games <- read_csv(file_games) 
  
  file_plays <- "https://raw.githubusercontent.com/nfl-football-ops/Big-Data-Bowl/master/Data/plays.csv"
  plays <- read_csv(file_plays)
}

# data exploration
{
  # quick look at the plays data
  View(head(plays))
  
  # quick look at the game data
  View(head(games))
  
  # let's focus on tracking data
  View(head(tracking_full))
  
  # quick basic plot of one frame in one play
  ggplot(tracking_full %>% filter(playId == 44, frame.id == 1), aes(x = x, y = y, color = team)) + geom_point()
  
  # data size (rows x columns)
  # note: "small" data set
  dim(tracking_full)

  # how many games are there?
  length(unique(tracking_full$gameId))
  # 2017 opening regular season game, KC @ NE
  
  # how many plays do we have?
  length(unique(tracking_full$playId))
  
  # sanity check: make sure there's 22 players per play
  View(aggregate(nflId ~ playId, data = tracking_full, function(x) length(unique(x))))
  # playId "3486" with only 21 players (further investigation?)
  
  # what kind of "events" are there?
  sort(table(tracking_full$event))
  aggregate(event ~ playId, data = tracking_full, unique)
  
  # any missing values?
  sort(colSums(is.na(tracking_full)))

  # what's accounting for those 13,743 NA's in nflId & jerseyNumber?
  table(tracking_full[is.na(tracking_full$nflId), "displayName"])
  
  # let's just work with players
  tracking <- tracking_full[which(tracking_full$displayName != "football"), ]
  sort(colSums(is.na(tracking)))
  
  # let's also remove rows without coordinate data
  View(tracking[is.na(tracking$x), ])
  tracking <- tracking[!is.na(tracking$x), ]
  sort(colSums(is.na(tracking)))
}

# variable creation: distance between players
# our goal: for each player, at every frame, find the nearest opposing player and their distance
{
  # let's first work with just one play, for simplicity
  # selected play is the opening kickoff, at the frame the kickoff was received
  
  ###
  ### a simple approach (but still better than just a brute force for-loop)
  ### there are plenty of other ways using more efficient spatial data packages (sp, rgeos), sql pre-processing, etc.
  ###
  
  ko <- tracking[which(tracking$playId == 44 & tracking$event == "kick_received"),
                 c("x", "y", "nflId", "displayName", "gameId", "playId", "frame.id", "team")]
  View(ko)
  
  # sanity check: 22 players, 11 on each side of the ball
  nrow(ko)
  table(ko$team)
  plot(ko$x, ko$y, col = ifelse(ko$team == "away", "red", "blue"))
  ggplot(ko, aes(x = x, y = y, color = team)) + geom_point()
  
  ko$opp_team <- ifelse(ko$team == "away", "home", "away")
  table(ko$opp_team == ko$team) # check that the logic worked
  
  # self-join
  # joining on itself by only game & play, each player will get 11 rows (1 for every opposing player coordinate on the play)
  # we will arrive at a dataframe where there is a row for every pair of player-opponent
  ko_join <- left_join(ko,
                       ko[, c("gameId", "playId", "nflId", "displayName", "opp_team", "x", "y")],
                       by = c("gameId" = "gameId", "playId" = "playId", "team" = "opp_team"))
  View(ko_join)
  
  # calculate the distance between a player and their opponent pair
  ko_join$dist <- ((ko_join$x.x - ko_join$x.y)^2 + (ko_join$y.x - ko_join$y.y)^2)^0.5
  summary(ko_join$dist)
  
  # find the minimum for each player, and roll up the data frame so there's only one row per player per frame
  ko_join <- ko_join %>% group_by(displayName.x, gameId, playId) %>% slice(which.min(dist))
  
  # re-name columns
  names(ko_join) <- c("x", "y", "nflId", "displayName", "gameId", "playId", "frame.id", "team", "opp_team",
                      "nearest_nflId", "nearest_displayName", "nearest_x", "nearest_y", "dist")
  
  # we now have a way to append on nearest defender/distance to nearest defender via nflId, gameId, playId, frame.id
  View(ko_join)
  
  ###
  ### this approach works on a small scale, but for a larger dataset, storing N*(N/2) rows of data is impossible in RAM
  ### we can loop through our data *by play* to append on this info
  ### only needs to be done once, and then can be stored away (in a flat file, database, etc.)
  ### takes ~4 minutes; ~80 seconds per play
  ### 
  
  # note that since we only have one game, we only have to loop on playId & frame.id
  # for data with multiple games, will require another outside loop to loop through gameId befre playID & frame.id
  # first, initialize data frame
  # this data frame will map gameid, playid/frame.id/nflId to nearest player nflId/displayName/coordinates/distance
  nearest_df <- data.frame()
  for(pid in unique(tracking$playId)){
    for(fid in unique(tracking[which(tracking$playId == pid), ]$frame.id)){
      tmp <- tracking[which(tracking$playId == pid & tracking$frame.id == fid),
                      c("x", "y", "nflId", "displayName", "gameId", "playId", "frame.id", "team")]
      
      tmp$opp_team <- ifelse(tmp$team == "away", "home", "away")
      tmp <- left_join(tmp,
                       tmp[, c("gameId", "playId", "nflId", "displayName", "opp_team", "x", "y")],
                       by = c("gameId" = "gameId", "playId" = "playId", "team" = "opp_team"))
      tmp$dist <- ((tmp$x.x-tmp$x.y)^2 + (tmp$y.x-tmp$y.y)^2)^0.5
      tmp <- tmp %>% group_by(displayName.x, gameId, playId) %>% slice(which.min(dist))
      names(tmp) <- c("x", "y", "nflId", "displayName", "gameId", "playId", "frame.id", "team", "opp_team",
                      "nearest_nflId", "nearest_displayName", "nearest_x", "nearest_y", "dist")
      
      # store relevant info
      nearest_df <- rbind.data.frame(nearest_df,
                                     tmp[, c("gameId", "playId", "frame.id", "nflId", "nearest_nflId",
                                             "nearest_displayName", "nearest_x", "nearest_y", "dist")])
    }
  }
  View(nearest_df)
  #nearest_df <- read_csv("nearest_df.csv")
  
  # join on nearest opposing player columns
  tracking <- left_join(tracking, nearest_df)
  View(tracking[1:20,])
}

# quick exploratory analysis: yards of separation for targeted receivers at time of throw
{
  # join on relevant play-level variables
  tracking <- left_join(tracking, plays[, c("gameId", "playId", "possessionTeam", "PassLength", "PassResult", "playDescription")])
  table(tracking$PassResult) # Caught, Incomplete, Run, Sack
  
  # flag the players that are on offense
  tracking$offense <- ifelse((tracking$possessionTeam == "NE" & tracking$team == "home") |
                               (tracking$possessionTeam == "KC" & tracking$team == "away"),
                             1, 0)
  
  # filter:
  # only plays where a pass was Caught or Incomplete
  # only the frame at which the pass was thrown
  # only players on offense
  pass_attempt <- tracking %>% filter(PassResult %in% c("C", "I"), event == "pass_forward", offense == 1)

  # using play description and regular expressions, find the targeted player on each pass play
  pass_attempt$target <- NA
  pass_attempt$target_flag <- NA
  for(i in 1:nrow(pass_attempt)){
    # isolate the last name of the targeted receiver
    tmp <- strsplit(pass_attempt$playDescription[i], "pass.*to [A-Z]\\.")[[1]][2]
    tmp <- strsplit(tmp, " ")[[1]][1]
    
    # remove punctuation
    tmp <- gsub("\\.", "", tmp)
    pass_attempt$target[i] <- tmp
    
    # flag rows of targeted receivers
    name <- pass_attempt$displayName[i]
    pass_attempt$target_flag[i] <- grepl(tmp, name)
  }

  # visualize: distribution of targeted receiver separation on completed vs. incomplete passes
  pass_attempt$PassResult <- ifelse(pass_attempt$PassResult == "C", "Complete", "Incomplete")
  pass_attempt %>%
    filter(target_flag == 1) %>%
      ggplot(aes(x = PassResult, y = dist)) +
      geom_boxplot(notch = FALSE, aes(fill = PassResult)) +
      xlab("Pass Result") +
      ylab("Yards of Separation") +
      ggtitle("KC vs. NE 2017 Week 1") +
      theme(legend.position = "none")
}

# visualizations
# credit to Michael Lopez

# visualization: animate a play
{
  ## playID 44 is a kickoff, playID 938 is a Kelce TD, and playID 345 is a Gillislee TD
  animation_playID <- 44
  
  tracking_full_merged <- tracking_full %>% inner_join(games) %>% inner_join(plays) 
  example_play <- tracking_full_merged %>% filter(playId == animation_playID)
  example_play %>% select(playDescription) %>% slice(1)
  
  ## this creates a reference for field boundaries
  xmin <- 0
  xmax <- 160/3
  hash_right <- 38.35
  hash_left <- 12
  hash_width <- 3.3
  
  ## this adapts the boundaries for a given play
  ymin <- max(round(min(example_play$x, na.rm = TRUE) - 10, -1), 0)
  ymax <- min(round(max(example_play$x, na.rm = TRUE) + 10, -1), 120)
  df_hash <- expand.grid(x = c(0, 23.36667, 29.96667, xmax), y = (10:110))
  df_hash <- df_hash %>% filter(!(floor(y %% 5) == 0))
  df_hash <- df_hash %>% filter(y < ymax, y > ymin)
  
  ## this is how we create the actual artwork!
  ## we're specifying colors and themes for the animation
  animate_play <- ggplot() +
    scale_size_manual(values = c(6, 4, 6), guide = FALSE) + 
    scale_shape_manual(values = c(21, 16, 21), guide = FALSE) +
    scale_fill_manual(values = c("#e31837", "#654321", "#002244"), guide = FALSE) + 
    scale_colour_manual(values = c("black", "#654321", "#c60c30"), guide = FALSE) + 
    annotate("text", x = df_hash$x[df_hash$x < 55/2], 
             y = df_hash$y[df_hash$x < 55/2], label = "_", hjust = 0, vjust = -0.2) + 
    annotate("text", x = df_hash$x[df_hash$x > 55/2], 
             y = df_hash$y[df_hash$x > 55/2], label = "_", hjust = 1, vjust = -0.2) + 
    annotate("segment", x = xmin, 
             y = seq(max(10, ymin), min(ymax, 110), by = 5), 
             xend =  xmax, 
             yend = seq(max(10, ymin), min(ymax, 110), by = 5)) + 
    annotate("text", x = rep(hash_left, 11), y = seq(10, 110, by = 10), 
             label = c("G   ", seq(10, 50, by = 10), rev(seq(10, 40, by = 10)), "   G"), 
             angle = 270, size = 4) + 
    annotate("text", x = rep((xmax - hash_left), 11), y = seq(10, 110, by = 10), 
             label = c("   G", seq(10, 50, by = 10), rev(seq(10, 40, by = 10)), "G   "), 
             angle = 90, size = 4) + 
    annotate("segment", x = c(xmin, xmin, xmax, xmax), 
             y = c(ymin, ymax, ymax, ymin), 
             xend = c(xmin, xmax, xmax, xmin), 
             yend = c(ymax, ymax, ymin, ymin), colour = "black") + 
    geom_point(data = example_play, aes(x = (xmax-y), y = x, shape = team,
                                        fill = team, group = nflId, size = team, colour = team), alpha = 0.7) + 
    geom_text(data = example_play, aes(x = (xmax-y), y = x, label = jerseyNumber), colour = "white", 
              vjust = 0.36, size = 3.5) + 
    ylim(ymin, ymax) + 
    coord_fixed() +  
    theme_nothing() + 
    transition_time(frame.id)  +
    ease_aes('linear') + 
    NULL
  
  ## ensure timing of play matches 10 frames-per-second
  ## the animate function will work its magic and take a few seconds to load the play
  play_length_ex <- length(unique(example_play$frame.id))
  animate(animate_play, fps = 10, nframe = play_length_ex)    
}

# visualization: voronoi diagram
{
  # set which playId and frame.id you want to get a voronoi of
  # example here is the opening score for NE (Mike Gillislee 2 yard TD run), at the point of hand-off
  # at 0:15 in this video https://youtu.be/6hYFmW18oNA?t=15
  pid <- 345
  fid <- 28
  
  ggplot(tracking_full %>% filter(playId == pid, frame.id == fid), aes(x = x, y = y, color = team)) + geom_point()
  
  tracking %>% 
    filter(playId == pid, frame.id == fid) %>% 
    ggplot(aes(x = x, y = y, fill = team)) + 
    stat_voronoi(geom="path") +
    geom_point(pch = 21, size = 3) + 
    scale_colour_brewer(palette = "Set2")+ 
    scale_x_continuous(breaks = c(0:10)*10) + 
    labs(x = "Yard Line", 
         y = "Y", title = "Voronoi Example") + 
    theme_bw(14) + 
    theme(panel.grid.minor = element_blank(), 
          panel.grid.major.y =element_blank())
}