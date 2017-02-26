# Approaches to survey weighting as described in the `survey` R package

# Set up
library(survey)
library(dplyr)
library(ggplot2)
data(api)

# How many schools are in the full dataset?


# How many districts are there in the dataset (dnum)?




###############################################################
################# Stratified sample, apistrat #################
###############################################################



# Use the `table` function to see how many schools are selected by school type (stype)


# How does this compare the to breakdown of the fractions of school type in the full dataset?


# Given that we sample by strata, what are the *probability weights* for each observation?


# What is the sum of probability weights column in the dataset?


# Use the `table` function to see how probability weight varies by stype


# Specify a stratified design 
# We need to know stype, pw, AND fpc (# of schools of that type in pop)


# Specify a design without the finite population correction
# We don't really need to know the fpc to calculate the mean, it only affects the standard error

# Compute the mean academic performance index (api) in 2000 in the full dataset


# Using the stratified dataset, compute the unweighted mean api in 2000 


# Compute the survey weighted mean api (using designs with/without FPC)



############################################################
################# Cluster sample, apiclus1 #################
############################################################


# Here, we sample *districts*, and take all schools in those districts

# Use the `table` function to see which district numbers (dnum) are present in the full dataset


# Use the `table` function to see which district numbers are present in apiclus1


# What is the distribution of person weights in this sample?


# Specify multiple cluster designs: try with/without weights/fpc
# We need to know the primary sampling unit (id) for each observation


# Compute the survey weighted mean for each design specified above



############################################################
################# Cluster sample, apiclus2 #################
############################################################



# Two-stage cluster sample, weights are computed via sample sizes (fpc)

# How many districts are sampled?


# What is the *distribution* of the number of schools from each district?



# What is the proportion of each district (cluster) that is sampled in apiclus2?



# What is the relationship between number of schools in a district and the number sampled?


# Specify a multi-level cluster design
# The id needs to capture *both* levels of clustering, as does the fpc
# Weights get computed via fpc using the survey package
# Note, fpc1 is # of districts in the dataset, fpc2 is the number of schools in each district


# Compute the survey weighted mean for your design


# If we try to use the weights directly, the mean is the same, but the SE is inaccurately low

