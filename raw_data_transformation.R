#launch local mongo db

library(mongolite)
library(tidyverse)

con <- mongo(
  collection = "test",
  db = "test",
  url = "mongodb://localhost",
  verbose = FALSE,
  options = ssl_options()
)

#to import the bson file to the local database, do not to be loaded each time
#.bson file to be download at this address : https://static.openfoodfacts.org/data/openfoodfacts-mongodbdump.tar.gz
con$import(file("data/products.bson"), bson = TRUE)


#show the first line
# con$find(limit = 1)

#count n of lines
# con$count() #1m lines

# alternative use of dplyr for request pas possible, query nécessaire en javascript json

echantillon <- con$find(limit = 10000)

# echantillon with key var

# each line is a product

e <- echantillon %>%
  select(code, #unique item id
         creator, #id creator
         countries_lc, #id country
         scans_n, #tally scan
         #created_t, #date wrong info
         entry_dates_tags, #date entry to off database
         categories_tags, #categorie tag product >>> need to unnest >>> presence of char and list
         # nutrition_grades, #nutrition grade product >>> need to be unnest
         product_name
         )

f <- e %>%
  # unnest_wider(col = entry_dates_tags) %>% #unnest date var 
  # mutate_at(entry_dates_tags = lubridate::as_date(...1)) %>%  #changement variable format to date
  select(code, creator, countries_lc, scans_n, entry_dates_tags, categories_hierarchy, product_name) %>% #unnest data var cleaning 
  mutate_if(is.character, as.factor)

save(f, file = "data/raw_data_mutate/f.rds")

