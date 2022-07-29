suppressWarnings(suppressMessages({
  library(rtweet)
  library(jsonlite)
  library(mongolite)
  library(textutils)
}))

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
# myTimelines <- rtweet::get_my_timeline(token = twitter_token)$text # why this wont work??
myTimelines <- rtweet::get_timeline(Sys.getenv("TWITTER_USER_NAME"), token = twitter_token)
myTimelines <- myTimelines$text

tz <- 7
todayDate <- format(Sys.time() +tz*60*60, '%d %B %Y') #WIB+7

# get data from mongo
query <- list(releaseDate = todayDate)
releaseToday <- mongo_movie$find(toJSON(query, auto_unbox = T))
nReleaseToday <- nrow(releaseToday)

if(nReleaseToday > 0){
  
  cat('Found', nReleaseToday, 'new movie release today', todayDate, '\n')

  for(i in 1:nReleaseToday){
    movie <- releaseToday[i,]
    title <- toupper(HTMLdecode(movie$name))
    cat('\nChecking and preparing post for:', title,'\n')
    
    # post only if it hasnt posted before
    if(sum(grepl(sprintf('%s.+%s', title, todayDate), myTimelines)) == 0 ){
      description <- HTMLdecode(movie$description)
      url <- paste0('imdb.com', movie$url)
      text <- sprintf('🎦 %s (%s) 📒 %s', title, todayDate, description) 
      
      # if text too long (>280)
      max_text <- 280
      tags <- '#movie #imdb'
      if((nchar(text) + nchar(url) + nchar(tags) + 1) > max_text){
        text <- sprintf('%s~ %s %s', substr(text,1,(max_text-nchar(url)-nchar(tags)-2)), tags, url)
      } else {
        text <- sprintf('%s %s %s', text, tags, url)
      }
      
      cat('Posting to twitter:', text, '\n')
      
      tryCatch(
        expr = {
          # download image
          imageUrl <- movie$image
          
          cat('Download image from:', imageUrl, '\n')
          download.file(imageUrl,'image.jpg', mode = 'wb')
          
          rtweet::post_tweet(
            status = text,
            media = 'image.jpg',
            media_alt_text = title,
            token = twitter_token
          )
          message('Tweet posted with media!')
        },
        error = function(e){
          print(e)
          rtweet::post_tweet(
            status = text,
            token = twitter_token
          )
          message('Tweet posted without media!')
        },
        warning = function(w){
          message('Caught an warning!')
          print(w)
        },
        finally = {
          if(i < nReleaseToday){
            Sys.sleep(5*60)
          }
        }
      ) 
      
    } else {
      cat('No post for', title, 'as it has been posted before', '\n')
    }
  }
  
} else {
  cat('No movie release today', todayDate, '\n')
}
