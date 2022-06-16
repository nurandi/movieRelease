# Movie Release Today 🤖

[![](https://img.shields.io/badge/Twitter-@newmoviebot-white?style=flat&labelColor=blue&logo=Twitter&logoColor=white)](https://twitter.com/newmoviebot)
[![Scrape and Tweet Today Movie Release](https://github.com/nurandi/movieRelease/actions/workflows/main.yml/badge.svg)](https://github.com/nurandi/movieRelease/actions/workflows/main.yml)

![Banner](https://pbs.twimg.com/profile_banners/1493425084908044288/1655330022/1500x500 "Banner")

Twitter bot [@newmoviebot](https://www.twitter.com/newmoviebot)'s source code. The bot tweets today movie release based on [IMDB](https://www.imdb.com) upcoming release [calendar](https://www.imdb.com/calendar?region=ID) (ed: currently for Indonesia only). Built in [{R}](https://www.r-project.org/) using [{rvest}](https://rvest.tidyverse.org/) to scrape data from IMDB, [{mongolite}](https://cran.r-project.org/web/packages/mongolite/index.html) to store data into [{MongoDB Cloud}](https://www.mongodb.com/cloud) and [{rtweet}](https://docs.ropensci.org/rtweet/) to post into twitter. The workflow and schedule are managed by [{GitHub Actions}](https://docs.github.com/en/actions). 

The bot has has two main functionalities that run serially:

+ **Scrape**: Check if there is new movie added into IMDB calendar. If so, scrape movie detail (up to 3 movies once) and store the data into MongoDB collection.
+ **Tweet**: If there is movie that released today, post new twitter status consist of movie title, description and its IMDB URL.

Creator: [@nurandi](https://www.twitter.com/nurandi)

---

## Sample data stored on MongoDB

```
> toJSON(mongo_movie$find(limit = 1), auto_unbox = T)

[
  {
    "@context": "https://schema.org",
    "@type": "Movie",
    "url": "/title/tt13056052/",
    "name": "Broker",
    "image": "https://m.media-amazon.com/images/M/MV5BY2UxOTEwOGUtYmFmOS00NTc4LWI0MWMtNGJkZGViY2EwZTgyXkEyXkFqcGdeQXVyNDY5NTQyMDU@._V1_.jpg",
    "description": "Boxes that are left out for people to anonymously drop off their unwanted babies.",
    "review": {
      "@type": "Review",
      "itemReviewed": {
        "@type": "CreativeWork",
        "url": "/title/tt13056052/"
      },
      "author": {
        "@type": "Person",
        "name": "witra_as"
      },
      "dateCreated": "2022-06-15",
      "inLanguage": "English",
      "name": "Profound drama about new-found family",
      "reviewBody": "Profound drama with mostly likeable characters. Kore-eda picked up scattered parts in first half before put his own signature bittersweet story about humanity. Awesome cast strongly formed a new-found family that will tear us apart. The ferris wheel scene tho 😭",
      "reviewRating": {
        "@type": "Rating",
        "worstRating": 1,
        "bestRating": 10,
        "ratingValue": 8
      }
    },
    "aggregateRating": {
      "@type": "AggregateRating",
      "ratingCount": 307,
      "bestRating": 10,
      "worstRating": 1,
      "ratingValue": 7.2
    },
    "genre": "Drama",
    "datePublished": "2022-06-08",
    "keywords": "baby,laundry",
    "trailer": {
      "@type": "VideoObject",
      "name": "Official Trailer",
      "embedUrl": "/video/imdb/vi3170681369",
      "thumbnail": {
        "@type": "ImageObject",
        "contentUrl": "https://m.media-amazon.com/images/M/MV5BNWJmMTY2OWMtMDQ3ZC00OGU1LWE1ZWItYjE5NTI0ZWY1NDVhXkEyXkFqcGdeQWxiaWFtb250._V1_.jpg"
      },
      "thumbnailUrl": "https://m.media-amazon.com/images/M/MV5BNWJmMTY2OWMtMDQ3ZC00OGU1LWE1ZWItYjE5NTI0ZWY1NDVhXkEyXkFqcGdeQWxiaWFtb250._V1_.jpg",
      "description": "Boxes that are left out for people to anonymously drop off their unwanted babies."
    },
    "actor": [
      {
        "@type": "Person",
        "url": "/name/nm0046277/",
        "name": "Bae Doona"
      },
      {
        "@type": "Person",
        "url": "/name/nm0814280/",
        "name": "Song Kang-ho"
      },
      {
        "@type": "Person",
        "url": "/name/nm3889963/",
        "name": "Ji-eun Lee"
      }
    ],
    "director": [
      {
        "@type": "Person",
        "url": "/name/nm0466153/",
        "name": "Hirokazu Koreeda"
      }
    ],
    "creator": [
      {
        "@type": "Organization",
        "url": "/company/co0201812/"
      },
      {
        "@type": "Person",
        "url": "/name/nm0466153/",
        "name": "Hirokazu Koreeda"
      }
    ],
    "duration": "PT2H9M",
    "releaseDate": "16 June 2022"
  }
]
```
