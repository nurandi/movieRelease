library(rtweet)
library(jsonlite)
library(mongolite)
library(textutils)

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

# get timelines
myTimelines <- get_my_timeline()$text

todayDate <- format(Sys.Date(), '%d %B %Y')
query <- list(releaseDate = todayDate)

releaseToday <- mongo_movie$find(toJSON(query, auto_unbox = T))
nReleaseToday <- nrow(releaseToday)

if(nReleaseToday > 0){
  
  cat('Found', nReleaseToday, 'new movie release today', '\n')

  for(i in 1:nReleaseToday){
    movie <- releaseToday[i,]
    title <- toupper(HTMLdecode(movie$name))
    cat('\nChecking and preparing post for:', title,'\n')
    
    # post only if it hasnt posted before
    if(sum(grepl(sprintf('%s (%s)', title, todayDate), myTimelines)) > 0 ){
      description <- HTMLdecode(movie$description)
      url <- paste0('imdb.com', movie$url)
      text <- sprintf('🎦 %s (%s) 📒 %s', title, todayDate, description) 
      
      # if text too long (>280)
      max_text <- 280
      if((nchar(text) + nchar(url) + 1) > max_text){
        text <- sprintf('%s~ %s', substr(text,1,(max_text-nchar(url)-2)), url)
      } else {
        text <- sprintf('%s %s', text, url)
      }
      
      # download image
      imageUrl <- movie$image
      download.file(imageUrl,'image.jpg', mode = 'wb')
      
      cat('Posting to twitter:', text, '\n')
      rtweet::post_tweet(
        status = text,
        media = 'image.jpg',
        token = twitter_token
      )
    } else {
      cat('No post for', title, 'as it has been posted before', '\n')
    }
    Sys.sleep(5)
  }
  
} else {
  cat('No movie release today!', '\n')
}
