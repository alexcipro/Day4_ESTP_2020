# ****************************************
#                Day 4 part 4
# ****************************************


# Applications of R in NSIs (4)

## Working with complex surveys: survey package

## Survey Sampling (1)

# * We need a sampling frame containing basic variables like contact addresses, names, …
# * Let us assume we have this in data set `eusilcP` – it serves as our sampling frame and
# population.
require(simFrame)
data(eusilcP)
head(eusilcP[,1:3]) ## usually fewer variables in a sampling frame
# * We could do srs using `sample()`
# * We could reduce costs by drawing the sample in a clever way


## Survey Sampling (2)

# * draw a sample by region, equal sizes within groups
require(sampling)
x <- draw(eusilcP[, c("hid", "id", "region")],
          design = "region", grouping = "hid",
          size = rep(650, 9))
dim(x)
table(x$region)
summary(x$.weight)


## Survey Sampling (3)

# * draw a sample by __region__, sample sizes are proportional to group size
## stratified group sampling, proportional size
tab <- table(eusilcP$region[!duplicated(eusilcP$hid)])
x2 <- draw(eusilcP[, c("hid", "id", "region")],
           design = "region", grouping = "hid",
           size = as.numeric(tab/4))
dim(x2)
table(x2$region)
summary(x2$.weight)


## Survey Sampling (4)

par(mfrow = c(2,2))
barplot(table(eusilcP$region)); barplot(table(x$region))
barplot(table(eusilcP$region)); barplot(table(x2$region))


## Editing (4)

# an example using `editmatrix()`
library(editrules)
E <- editmatrix(c("x+3*y==2*z", "x >= z"))
summary(E)


## Editing (6)

# Look at (possibly) violated edits with `violatedEdits()`
dat <- data.frame(x=c(0,2,1), y=c(0,0,1), z=c(0,1,1))
dat
ve <- violatedEdits(E, dat)
ve


## Editing (7)

# show summary of violated edits
summary(ve, E) # plot(ve) is also implemented


## Editing (8)

# localize the errors with `localizeErrors()`
err <- localizeErrors(E,dat)
# what has to be adapted:
err$adapt


## Missing values (1)

# visualize missing values
library(VIM)
data(sleep, package="VIM")
## for missing values
a <- aggr(sleep, plot=TRUE)


## Missing values (2)

# The aim is to detect missing values structures
histMiss(log(sleep[, c("BodyWgt", "NonD")])) ## missing in non-dreaming only for big mammals


## Missing values (3)

# Observe the missing structure (multivariate)
matrixplot(sleep, sortby="Sleep")


## Imputation (4)

# * Hotdeck imputation:
x_hotdeck <- hotdeck(sleep, domain_var = "Danger")
# * kNN imputation:
x_knn <- kNN(sleep)
# * EM-based robust imputation:
x_irmi <- irmi(sleep) # function argument mi for multiple imputation
# * A lot of additional function parameters can be specified for each function


## Imputation (5)

# Evaluation of imputed values
ev <- x_knn[, c("BodyWgt", "NonD", "BodyWgt_imp", "NonD_imp")]
ev[, c("BodyWgt", "NonD")] <- log(ev[, c("BodyWgt", "NonD")] )
parcoordMiss(x_knn, delimiter = "_imp")


## Calibration

library(laeken)
data(eusilc)
aux <- calibVars(eusilc$rb090) # construct auxiliary 0/1 variables for genders
totals <- c(3990798, 4191431) # population totals
g <- calibWeights(aux, eusilc$rb050, totals) # compute g-weights
summary(eusilc$rb050) # original weights
weights <- g * eusilc$rb050 # compute final weights
summary(weights)
# See also packages `simPop` and `survey` for more calibration tools


## The survey-package (1)

# Package survey is useful in many situations
library(simFrame); library(survey)
x <- draw(eusilcP, design = "region", grouping = "hid", size = rep(650, 9))
# define the design
xs <- svydesign(id=~hid, strata=~region, weights=~.weight, data=x, nest=TRUE)
summary(xs)


## The survey-package (2)

# Horwitz-Thompson estimation of means
svymean(~eqIncome, xs, deff=TRUE)
data(eusilcP)
x <- draw(eusilcP,
design = "region", grouping = "hid",
size = rep(650, 9))
xs <- svydesign(id=~hid, strata=~region, weights=~.weight, data=x, nest=TRUE)
tt <- svyby(~eqIncome, ~region, xs, svymean, vartype="ci")
tt


## The survey-package (3)

# create a html-output table
require(knitr)
kable(tt)


## Complex indicators (1)

# * `R` can be used to calculate complex indicates such as the _at-risk-at-poverty rate_ 
# * we use package `laeken` for this task
library("laeken")
data(eusilc)
# values by region
arpr("eqIncome", weights="rb050", breakdown="db040", data=eusilc)


## Complex indicators (2)

# * in `laeken` it is assumed that the arp-threshold is also random!
# * Dispersion can be added around the at-risk-at-poverty-rate
arpr("eqIncome", weights="rb050", breakdown="db040", p=c(0.4, 0.7), data=eusilc)


## Complex indicators (3)

# Variances of indicators may be estimated using bootstrapping
res <- arpr("eqIncome", weights="rb050", design="db040", cluster="db030",
breakdown="db040", data=eusilc, var="bootstrap", bootType="naive", seed=12)
res$varByStratum


## Complex indicators (4)

# Variances of indicators may be estimated using a calibrated bootstrap approach
aux <- cbind(calibVars(eusilc$db040), calibVars(eusilc$rb090))
res <- arpr("eqIncome", weights = "rb050", design = "db040", cluster = "db030", 
            breakdown="db040", data=eusilc, var="bootstrap", X=aux, seed=1234)
res$varByStratum



