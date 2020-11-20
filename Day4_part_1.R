# ****************************************
#                Day 4 part 1
# ****************************************


# Applications of R in NSIs

## Working with large databases: dplyr package


# This is the change


## Warm-up (1)

# First, the package must be loaded
require(dplyr, quiet = TRUE)

# Some vignettes (short instructions) available
# help(pa = "dplyr")

# In the following we use the Cars93 data
data(Cars93, package="MASS") # ?Cars93


## Warm-up (2)

# A brief inspection of the data
print(head(Cars93, 3))


## Warm-up (3)

# Brief description of the first variables
summary(Cars93[,1:14])


## Local Data Frame (1)

# * With `tbl_df()`, a local data frame to be created
# * Why do we need this?
# + Improved, efficient output (__print__ -method)
# + No accidental print of huge data sets
# * Remember `Cars93` is a _data.frame_
class(Cars93)

# * We convert to a local data frame for dplyr…
Cars93 <- tbl_df(Cars93)
class(Cars93)


## Local Data Frame (2)

# class - methods for this class are implemented
print(Cars93)

# output of _*print()_ now looks different


## Extracting rows (1)

# Using function `slice()` you can select rows according to their line number
slice(Cars93, 1:2) # first two observations


## Extracting rows (2)

# Function `n()` returns the number of observations (rows)
slice(Cars93, n()) # shows the last observation


## Extracting rows (3)

# * You can also select multiple rows at once  
# * Note: `c()` creates a vector from the input numbers  
# * We select the 1,4,10,15 and last line of the data  
slice(Cars93, c(1,4,10,15,n()))


## Filtering using a condition

# * The function `filter()` can be selected rows that satisfy a condition:
# * Example: all observations where variable _Manufacturer_ == is Audi and at the same time the value of variable _Min.Price_ > 25 is.
filter(Cars93, Manufacturer=="Audi" & Min.Price > 25)
# Note: the condition can be arbitrarily complex ( & , | )


## Ordering (1)

# With `arrange()` you can sort the data by one or more variables
# By default is sorted in ascending order, with `desc()` descending
Cars93 <- arrange(Cars93, Price); head(Cars93, 15)


## Ordering (2)

# You can also sort by multiple variables
head(arrange(Cars93, desc(MPG.city), Max.Price), 15)


## Selection of variables (1)

# Function `select()` allows you to select variables from the data
head(select(Cars93, Manufacturer, Price), 3)
# Sequence of variables operator : selectable
head(select(Cars93, Manufacturer:Price), 3)


## Selection of variables (2)

# Negative indexing possible, while all variables letter prefix minus ( - ) away
head(select(Cars93, -Min.Price, -Max.Price), 3)


## Selection of variables (3)

# * Special functions within `select()` :
# + `starts_with()`, `ends_with()`
# + `contains()`
# + `matches()`
# + `num_range()`

## Selection of variables (4)

head(select(Cars93, starts_with("Man")), 2)
head(select(Cars93, contains("Price")), 2)
head(select(Cars93, -contains("Price")), 2)


## Renaming variables (1)

# * Both `select()` and `rename()` can be used to rename
# * Simple _new_ = _old_ syntax
# + `select()` returns only the specified variables
head(select(Cars93, myPrize = Price, Min.Price))


## Renaming variables (2)

# * `rename()` returns all variables
head(rename(Cars93, Manu2 = Manufacturer))


## Uniqueness (1)

# * `distinct()` can be used to keep only unique rows.
Cars93_1 <- select(Cars93, Manufacturer, EngineSize)
dim(Cars93_1)
Cars93_1 <- distinct(Cars93_1); dim(Cars93_1)
# By default, all variables are used to assess whether a _row multiple_ occurs in the data set


## Uniqueness (2)

# We can specify (calculated) variables that should be used as keys when calculating distinct data sets.
dim(Cars93)
dim(distinct(Cars93, Manufacturer))
dim(distinct(Cars93, Manufacturer, EngineSize)) # EngineSize as is
dim(distinct(Cars93, Manufacturer, rr=round(EngineSize))) # EngineSize is rounded


## Creating variables (1)

# * `mutate()`: adds new variables are added and retains the old
m <- mutate(Cars93, is_manu = Manufacturer == "Ford")
m[1:3, c(1,28)]
# * `transmute()`: retains only the listed variables
head(transmute(Cars93, is_manu = Manufacturer == "Ford", Manufacturer), 3)


## Creating variables (2)

# * Newly created variables can be used again in the same statement
head(transmute(Cars93, Manufacturer,
               is_manu = Manufacturer == "Ford",
               num = ifelse(is_manu, -1,1)), 15)


## Grouping and Aggregation (3)

# * Grouping by variable Manufacturer and calculation of:
# + group size
# + the minimum of the variables Prize
# + the maximum of the variable Prize
by_type <- group_by(Cars93, Type)
summarize(by_type, count = n(), min_es = min(EngineSize), max_es = max(EngineSize))


## Grouping and Aggregation (4)

# * via `group_by()` functions are applied on defined groups
# * note: `arrange()` and `select()` are independent of grouping
# * __Example__: report the first two observations per group
by_type <- group_by(Cars93, Type)
slice(by_type, 1:2)


## Pipes (1)

# * we have shown by example that `dplyr` provides a simple syntax
# * With the operator `%>%`, the syntax becomes easily readable
# * Makes it possible to provide commands like in a pipe together
# * Output of the previous is the first input to the command following
Cars93 %>% group_by(Type) %>% slice(1:2)


## Pipes (2)

# * Command strings can be any length
# * Are performed from left to right (in the direction of _arrow_!)
# * __Example__:
# + Compute new variable _EngineSize_ as the square of _EngineSize_
# + Compute for each group the minimum of the new variable
# + Sort the results in descending order accordingly to it
Cars93 %>% mutate(ES2 = EngineSize^2) %>% group_by(Type) %>% 
  summarize(min.ES2 = min(ES2)) %>% arrange(desc(min.ES2))


## Window Functions (2)

# * Simple example: calculate cumulative sum and average value within each group
Cars93 %>% group_by(Type) %>% arrange(Type) %>% 
  select(Manufacturer:Price) %>% mutate(cmean = cummean(Price), 
                                        csum = cumsum(Price))

