library(rtweet)
library(jsonlite)
library(mongolite)

conn_string <- Sys.getenv("MONGO_CONNECTION_STRING")
mongo_movie <- mongo(collection = 'id',
                     db = 'imdb_movie',
                     url = conn_string)

twitter_token <- rtweet::create_token(
  app              = Sys.getenv("TWITTER_APP_NAME"),
  consumer_key     = Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret  = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token     = Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret    = Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

todayDate <- format(Sys.Date(), '%d %B %Y')
todayDate <- '16 June 2022'
query <- list(releaseDate = todayDate)

releaseToday <- mongo_movie$find(toJSON(query, auto_unbox = T))
nReleaseToday <- nrow(releaseToday)

if(nReleaseToday > 0){
  
  cat('Found', nReleaseToday, 'new movie release today', '\n')

  for(i in 1:nReleaseToday){
    movie <- releaseToday[i,]
    title <- movie$name
    description <- movie$description
    url <- paste0('https://www.imdb.com', movie$url)
    actor <- paste(movie$actor[[1]]$name, collapse = ', ')
    genre <- paste( movie$genre[[1]], collapse = ', ')
    
    cat('Preparing to post to twitter:', title, '\n')
    
    cat('Composing status text', '\n')
    text <- sprintf('[%s]\n%s\n%s\nActors: %s\nGenre: %s\n%s', todayDate, title, description, actor, genre, url) 
    
    cat('Downloading movie poster', '\n')
    imageUrl <- movie$image
    download.file(imageUrl,'image.jpg', mode = 'wb')
    
    cat('Posting to twitter', '\n')
    rtweet::post_tweet(
      status = text,
      #media = 'image.jpg',
      token = twitter_token
    )
    
    Sys.sleep(5)
  }
  
} else {
  cat('No movie release today!', '\n')
}
