library(rvest)
library(mongolite)
library(jsonlite)

# step 1: get movie URL from release calendar

countryId <- 'ID'
coutryName <- 'Indonesia'

calendarUrl <- paste('https://www.imdb.com/calendar?region', countryId, sep = '=')

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
nScrape <- min(nUnscraped, maxScrape)

if(nUnscraped > 0){
  cat('Found', nUnscraped, 'new movie to scrape', '\n')
  cat('Preparing to scrape', nScrape, 'new movies of', nUnscraped, '\n')
  for(movieUrl in unscrapedUrls[1:nScrape]){
    cat('Scraping:', movieUrl, '\n')
    
    # movie detail
    movieFullUrl <- paste0('https://www.imdb.com', movieUrl)
    movieDetail <- read_html(movieFullUrl) %>%
      html_element('script') %>% 
      html_element(xpath = '//*[@type ="application/ld+json"]') %>% 
      html_text() %>%
      fromJSON()
    
    # release date
    movieReleaseUrl <- paste0(movieFullUrl, 'releaseinfo')
    movieReleaseDate <- read_html(movieReleaseUrl) %>%
      html_element('#releaseinfo_content') %>% 
      html_table() %>% 
      subset(X1 == coutryName) %>% `[[`(1,2)
    movieDetail$releaseDate <- movieReleaseDate
    
    # insert
    mongo_movie$insert(toJSON(movieDetail, auto_unbox = T))
  }
} else {
  cat('No new movie to scrape', '\n')
}

