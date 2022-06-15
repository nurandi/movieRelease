library(rtweet)
library(jsonlite)
library(mongolite)

conn_string <- Sys.getenv('MONGO_CONNECTION_STRING')
mongo_movie <- mongo(collection = 'id',
                     db = 'imdb_movie',
                     url = conn_string)

twitter_token <- rtweet::create_token(
  app              = Sys.getenv('TWITTER_APP_NAME'),
  consumer_key     = Sys.getenv('TWITTER_CONSUMER_API_KEY'),
  consumer_secret  = Sys.getenv('TWITTER_CONSUMER_API_SECRET'),
  access_token     = Sys.getenv('TWITTER_ACCESS_TOKEN'),
  access_secret    = Sys.getenv('TWITTER_ACCESS_TOKEN_SECRET')
)

todayDate <- format(Sys.Date(), '%d %B %Y')
todayDate <- '16 June 2022'
query <- list(releaseDate = todayDate)

releaseToday <- mongo_movie$find(toJSON(query, auto_unbox = T))
nReleaseToday <- nrow(releaseToday)

if(nReleaseToday > 0){
  
  cat('Found', nReleaseToday, 'new movie release today', '\n')
  cat('Preparing to post to twitter', '\n')
  
  for(i in 1:nReleaseToday){
    movie <- releaseToday[i,]
    title <- movie['name']
    description <- movie['description']
    url <- paste0('https://www.imdb.com', movie['url'])
    imageUrl <- movie['image']
    actor <- paste(movie['actor']$actor[[1]]$name, collapse = ', ')
    genre <- paste( movie['genre']$genre[[1]], collapse = ', ')
    
    text <- sprintf('[%s]\n%s\n%s\nActors: %s\nGenre: %s\n%s', todayDate, title, description, actor, genre, url) 
    
    cat('Posting to twitter:', title, '\n')
    
    rtweet::post_tweet(
      status = text,
      media = imageUrl,
      token = twitter_token
    )
  } else {
    cat('No movie release today!')
  }
  
}





