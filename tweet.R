library(rtweet)
library(jsonlite)
library(mongolite)

conn_string <- Sys.getenv("MONGO_CONNECTION_STRING")
mongo_movie <- mongo(collection = Sys.getenv("MONGO_COLLECTION_NAME"),
                     db         = Sys.getenv("MONGO_DB_NAME"),
                     url        = conn_string)

twitter_token <- rtweet::create_token(
  app              = Sys.getenv("TWITTER_APP_NAME"),
  consumer_key     = Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret  = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token     = Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret    = Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET"),
  set_renv         = FALSE
)

todayDate <- format(Sys.Date(), '%d %B %Y')
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
    text <- sprintf('🎦️ %s (%s) 📒 %s\n%s', toupper(title), todayDate, description, url) 
    
    # if text too long
    if(nchar(text) > 280){
      text <- sprintf('%s~\n%s', substr(text,1,235), url)
    }
    
    cat('Posting to twitter:', text, '\n')
    rtweet::post_tweet(
      status = text,
      token = twitter_token
    )
    
    Sys.sleep(5)
  }
  
} else {
  cat('No movie release today!', '\n')
}
