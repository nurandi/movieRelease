library(rtweet)
library(jsonlite)
library(mongolite)

app <- Sys.getenv('TWITTER_APP_NAME')
ck <- Sys.getenv('TWITTER_CONSUMER_API_KEY')
cs <- Sys.getenv('TWITTER_CONSUMER_API_SECRET')
at <- Sys.getenv('TWITTER_ACCESS_TOKEN')
as <- Sys.getenv('TWITTER_ACCESS_TOKEN_SECRET')

cat(app, ck, sc, at, as, '\n')

twitter_token <- rtweet::create_token(
  app              = app,
  consumer_key     = ck,
  consumer_secret  = cs,
  access_token     = at,
  access_secret    = as
)

search_tweets("indonesia", n=1, token = twitter_token)

