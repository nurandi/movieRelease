library(rvest)
library(mongolite)

# step 1: get movie URL from release calendar

region <- 'ID'
calendarUrl <- paste('https://www.imdb.com/calendar?region', region, sep = '=')

movieUrls <- read_html(calendarUrl) %>%
  html_element('#main') %>%
  html_elements('ul') %>%
  html_elements('a') %>%
  html_attr('href') %>%
  gsub('\\?.+', '', .)


# step 2: check, scrape and insert
# if movie is not on mongo collection, then scrape and insert into the collection

# connect to mongo collection
# db and collection are pre-created

conn_string <- Sys.getenv('MONGO_CONNECTION_STRING')
mongo_movie <- mongo(collection = 'id',
                     db = 'imdb_movie',
                     url = conn_string)

# check

nScraped <- mongo_movie$count()
if(nScraped == 0){
  unscrapedUrls <- movieUrls
} else {
  scrapedUrls <- mongo_movie$find()$url
  unscrapedUrls <- movieUrls[!movieUrls %in% scrapedUrls]
}

# scrape and insert

maxScrape <- 3
nUnscraped <- length(unscrapedUrls)
nScrape <- min(nUrl, maxScrape)

if(nUnscraped > 0){
  cat('Found', nUnscraped, 'new movie to scrape', '\n')
  cat('Preparing to scrape', nScrape, 'new movies of', nUnscraped, '\n')
  for(movieUrl in unscrapedUrls[1:nScrape]){
    cat('Scraping:', movieUrl, '\n')
    movieFullUrl <- paste0('https://www.imdb.com', movieUrl)
    movieDetail <- read_html(movieFullUrl) %>%
      html_element('script') %>% 
      html_element(xpath = '//*[@type ="application/ld+json"]') %>% 
      html_text()
    mongo_movie$insert(movieDetail)
  }
} else {
  cat('No new movie to scrape', '\n')
}

