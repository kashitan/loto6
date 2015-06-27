# Delete Latest Time
library(RSQLite)
library(magrittr)
con <- dbDriver("SQLite") %>%
  dbConnect(dbname="loto6.sqlite")

latest_time <- dbGetQuery(con, "select max(time) from results")
latest_time <- dbGetQuery(con, "select max(time) from numbers")
rs <- dbSendPreparedQuery(con, "delete from results where time = ?", latest_time)
rs <- dbSendPreparedQuery(con, "delete from numbers where time = ?", latest_time)

q()
