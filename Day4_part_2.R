# ****************************************
#                Day 4 part 2
# ****************************************


# Applications of R in NSIs (2)

## Working with large databases: data.table package

# * `data.table` is an `R` package that provides an enhanced version of 'data.frames'
# * `data.table()` function creates data
# * 'as.data.table()' convert existing objects
library(data.table)
DT <- data.table(ID = c("b","b","b","a","a","c"), a = 1:6, b = 7:12, c = 13:18)
DT
class(DT)
# * columns of character type are never converted to factors by default
# * when the number of rows to print exceeds the global option datatable.print.nrows (default = 100), it automatically prints only the top 5 and bottom 5 rows


## Data for example

# * [NYC-flights14](https://github.com/arunsrinivasan/flights/wiki/NYC-Flights-2014-data) data
# *  On-Time flights data from the Bureau of Transporation Statistics for all the flights that departed from New York City airports in 2014
# * the data is available only for Jan-Oct'14
flights <- fread("https://github.com/arunsrinivasan/flights/wiki/NYCflights14/flights14.csv")
flights
dim(flights)


## Indexing - general form

# * `DT[i, j, by]`
# * Take DT, subset rows using i, then calculate j, grouped by by.
# get the first two rows from flights
ans <- flights[1:2]
ans

var1[, 1:2]

## Sort, Select

# sort flights first by column origin in ascending order, and then by dest in descending order
ans <- flights[order(origin, -dest)]
head(ans)
# Select arr_delay column, but return it as a vector
ans <- flights[, arr_delay]
head(ans)


## Select (2)

# Select arr_delay column, but return as a data.table instead.
ans <- flights[, list(arr_delay)]
head(ans)
# Select both arr_delay and dep_delay columns
ans <- flights[, .(arr_delay, dep_delay)]
head(ans)
## alternatively
# ans <- flights[, list(arr_delay, dep_delay)]


## Select with rename

# Select both arr_delay and dep_delay columns and rename them to delay_arr and delay_de
ans <- flights[, .(delay_arr = arr_delay, delay_dep = dep_delay)]
head(ans)


## Compute or do

# How many trips have had total delay < 0?
ans <- flights[, sum((arr_delay + dep_delay) < 0)]
ans


## Subset

# Calculate the average arrival and departure delay for all flights with “JFK” 
# as the origin airport in the month of June
ans <- flights[origin == "JFK" & month == 6L,
               .(m_arr = mean(arr_delay), m_dep = mean(dep_delay))]
ans


## Subset (2)

# How many trips have been made in 2014 from “JFK” airport in the month of June?
ans <- flights[origin == "JFK" & month == 6L, length(dest)]
ans
# Special symbol .N
ans <- flights[origin == "JFK" & month == 6L, .N]
ans


## Aggregations (1)

# Grouping using by
ans <- flights[, .(.N), by = .(origin)]
ans
## or equivalently using a character vector in 'by'
# ans <- flights[, .(.N), by = "origin"]


## Aggregations (2)

# When there's only one column or expression to refer to in j and by, we can drop the .() notation
ans <- flights[, .N, by = origin]
ans

# How can we calculate the number of trips for each origin airport for carrier code “AA”?
ans <- flights[carrier == "AA", .N, by = origin]
ans


## Aggregations (3)

# How can we get the total number of trips for each origin, dest pair for carrier code “AA”?
ans <- flights[carrier == "AA", .N, by = .(origin,dest)]
head(ans)

# How can we get the average arrival and departure delay for each orig,dest pair for each month for carrier code “AA”? 
ans <- flights[carrier == "AA",
               .(mean(arr_delay), mean(dep_delay)),
               by = .(origin, dest, month)]
ans


## keyby

# So how can we directly order by all the grouping variables?
ans <- flights[carrier == "AA",
               .(mean_arr_delay=mean(arr_delay), mean_dep_delay=mean(dep_delay)),
               keyby = .(origin, dest, month)]
ans


## Chaining

# getting the total number of trips for each origin, dest pair for carrier “AA”.
ans <- flights[carrier == "AA", .N, by = .(origin, dest)]
ans


