#library(rtweet)

app <- Sys.getenv('TWITTER_APP_NAME')
ck <- Sys.getenv('TWITTER_CONSUMER_API_KEY')
cs <- Sys.getenv('TWITTER_CONSUMER_API_SECRET')
at <- Sys.getenv('TWITTER_ACCESS_TOKEN')
as <- Sys.getenv('TWITTER_ACCESS_TOKEN_SECRET')

cat(app, ck, cs, at, as, '\n')


