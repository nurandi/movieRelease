# Movie Release Today 🤖

[![](https://img.shields.io/badge/Twitter-@newmoviebot-white?style=flat&labelColor=blue&logo=Twitter&logoColor=white)](https://twitter.com/newmoviebot)
[![Scrape and Tweet Today Movie Release](https://github.com/nurandi/movieRelease/actions/workflows/main.yml/badge.svg)](https://github.com/nurandi/movieRelease/actions/workflows/main.yml)

![Banner](https://pbs.twimg.com/profile_banners/1493425084908044288/1655330022/1500x500 "Banner")

Twitter bot [@newmoviebot](https://www.twitter.com/newmoviebot)'s source code. The bot tweets today movie release based on [IMDB](https://www.imdb.com) upcoming release [calendar](https://www.imdb.com/calendar?region=ID) (ed: currently for Indonesia only). Built in [{R}](https://www.r-project.org/) using [{rvest}](https://rvest.tidyverse.org/) to scrape data from IMDB, [{mongolite}](https://cran.r-project.org/web/packages/mongolite/index.html) to store data into [{MongoDB Cloud}](https://www.mongodb.com/cloud) and [{rtweet}](https://docs.ropensci.org/rtweet/) to post into twitter. The workflow and schedule are managed by [{GitHub Actions}](https://docs.github.com/en/actions). 

The bot has has two main functionalities that run serially:

+ **Scrape**: Check if there is new movie added into IMDB calendar. If so, scrape movie detail (up to 3 movies daily) and store the data into MongoDB collection.
+ **Tweet**: If there is movie that released today, post new twitter status consist of movie title, description and its IMDB URL.

Creator: [@nurandi](https://www.twitter.com/nurandi)

