# Scrapying
library(rvest)
library(magrittr)
html <- read_html("http://www.mizuhobank.co.jp/takarakuji/loto/loto6/index.html")
result <- html %>% 
  html_nodes("table") %>% 
  html_table(header = FALSE, fill=TRUE) %>%
  extract2(1)
rm(html)

library(stringr)
time <- result[1, 2] %>% str_extract("[0-9]+")
nums <- as.numeric(result[3, 2:7])
first_hit <- result[5,2] %>% 
  str_extract("[0-9]+")
first <- result[5,5] %>% 
  str_replace_all(",", "") %>% 
  str_replace("円", "")
second_hit <- result[6,2] %>% 
  str_extract("[0-9]+")
second <- result[6,5] %>% 
  str_replace_all(",", "") %>% 
  str_replace("円", "")
third <- result[7,5] %>% 
  str_replace_all(",", "") %>% 
  str_replace("円", "")
fourth <- result[8,5] %>% 
  str_replace_all(",", "") %>% 
  str_replace("円", "")
over <- result[11,2] %>% 
  str_replace_all(",", "") %>% 
  str_replace("円", "")
rm(result)

# Update SQLite
library(RSQLite)
con <- dbDriver("SQLite") %>%
  dbConnect(dbname="loto6.sqlite")

## insert into results
q <- paste0("insert into results values(",
            time, ",", 
            first_hit, ",",
            first, ",",
            second_hit, ",",
            second, ",",
            third, ",",
            fourth, ",",
            over,
            ")"
)
rs <- dbSendQuery(con, q)

## insert into numbers
q <- paste0("insert into numbers values(",
            time, ", ?)"
)
rs <- dbSendPreparedQuery(con, q, as.data.frame(nums))

# Spool
dbGetQuery(con, "select * from results order by time desc") %>%
  write.csv(file="results.csv", row.names=FALSE)

dbGetQuery(con, "select * from numbers order by time desc, num") %>%
  write.csv(file="numbers.csv", row.names=FALSE)

q()