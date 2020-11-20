# ****************************************
#                Day 4 part 3
# ****************************************


# Applications of R in NSIs (4)

## Working with RJDemetra package

## Installation

# Install release version from CRAN
install.packages("RJDemetra")

# Install development version from GitHub
# install.packages("devtools")
devtools::install_github("jdemetra/rjdemetra")


## Basic example

# To seasonally adjust a time series with a pre-defined specification you can either use the `x13()` function for the `X-13ARIMA` method or the `tramoseats()` function for the `TRAMO-SEATS` method.
library(RJDemetra)
head(ipi_c_eu)
myseries <- ipi_c_eu[, "FR"]
x13_model <- x13(myseries) # X-13ARIMA method
ts_model <- tramoseats(myseries) # TRAMO-SEATS method


## Basic example - plot

# Basic plot with the original series, the trend and the SA series
plot(x13_model, type_chart = "sa-trend")


## Basic example

# S-I ratio
plot(x13_model$decomposition)


## RegARIMA examples

library(RJDemetra)
myseries <- ipi_c_eu[, "RO"]
regarima_model <- regarima_x13(myseries, spec = "RG4c")
regarima_model # Or summary(regarima_model) to have more details

myseries
class(myseries)
head(myseries)


## RegARIMA examples

layout(matrix(1:6, 3, 2));

par(mfrow = c(3,2))
plot(regarima_model, ask = FALSE)


## RegARIMA examples

# To select a specific graph which parameter:
plot(regarima_model, which = 6)


## Seasonal adjustment examples - 1

# A SA object is a list() of 5 elements:
#   
# 1. regarima: the RegArima model
# 2. decomposition: decomposition variables (6= for TRAMO-SEATS and
#                                            X-13-ARIMA)
# 3. final: time series main results
# 4. diagnostics: residuals tests, etc.
# 5. user_defined: other user_defined variables not exported by default
# (see ?user_defined_variables)
x13_usr_spec <- x13_spec(spec=c("RSA5c"),usrdef.outliersEnabled = TRUE,
                         usrdef.outliersType = c("LS","AO"),
                         usrdef.outliersDate=c("2008-10-01","2002-01-01"),
                         usrdef.outliersCoef = c(36000,14000),
                         transform.function = "None")
x13_mod <- x13(myseries, x13_usr_spec)
ts_mod <- tramoseats(myseries, spec = "RSAfull")


## Seasonal adjustment examples - 2

print(x13_mod$decomposition, enable_print_style = FALSE)


## Seasonal adjustment examples - 3

print(ts_mod$decomposition, enable_print_style = FALSE)


## Seasonal adjustment examples - 4

plot(x13_mod$decomposition)


## Seasonal adjustment examples - 5

x13_mod$final


## Seasonal adjustment examples - 6

par(mfrow = c(1,1))
plot(x13_mod$final, first_date = 2012, type_chart = "sa-trend")


## Seasonal adjustment examples - 7

print(x13_mod$diagnostics, enable_print_style = FALSE)


