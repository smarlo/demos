# Approaches to survey weighting as described in the `survey` R package

# Set up
library(survey)
library(dplyr)
library(ggplot2)
data(api)

# How many schools are in the full dataset?
nrow(apipop) # 6194

# How many districts are there in the dataset (dnum)?
length(unique(apipop$dnum)) # 757



###############################################################
################# Stratified sample, apistrat #################
###############################################################



# Use the `table` function to see how many schools are selected by school type (stype)
table(apistrat$stype) # 100 elementary, 50 high school, 50 middle school

# How does this compare the to breakdown of the fractions of school type in the full dataset?
table(apipop$stype) # 4421 elementary, 755 high school , 1018 middle school

# Given that we sample by strata, what are the *probability weights* for each observation?
probability.weights <- table(apipop$stype)/table(apistrat$stype)

# What is the sum of probability weights column in the dataset?
sum(apistrat$pw) # 6194, same as population

# Use the `table` function to see how probability weight varies by stype
table(apistrat$pw, apistrat$stype)

# Specify a stratified design 
# We need to know stype, pw, AND fpc (# of schools of that type in pop)
stratified.design <- svydesign(id=~1,           # Sample directly (no clusters)
                               strata=~stype,   # Stratified by school type
                               weights=~pw,     # Computed sample weights (based on prob. of selection)
                               fpc=~fpc,        # Finite population correction (optional: reduces variance)
                               data=apistrat)

# Specify a design without the finite population correction
# We don't really need to know the fpc to calculate the mean, it only affects the standard error
design.no.fpc <- svydesign(id=~1,strata=~stype, weights=~pw, data=apistrat)

# Compute the mean academic performance index (api) in 2000 in the full dataset
mean(apipop$api00) # 664

# Using the stratified dataset, compute the unweighted mean api in 2000 
mean(apistrat$api00) # 652

# Compute the survey weighted mean api (using designs with/without FPC)
svymean(~api00, stratified.design) #662
svymean(~api00, design.no.fpc) #662



############################################################
################# Cluster sample, apiclus1 #################
############################################################


# Here, we sample *districts*, and take all schools in those districts

# Use the `table` function to see which district numbers (dnum) are present in the full dataset
table(apipop$dnum)
length(unique(apipop$dnum)) # 757

# Use the `table` function to see which district numbers are present in apiclus1
table(apiclus1$dnum)
length(unique(apiclus1$dnum)) # 15

# What is the distribution of person weights in this sample?
hist(apiclus1$pw)
unique(apiclus1$pw) # Assumes clusters (districts) are the same

# Specify multiple cluster designs: try with/without weights/fpc
# We need to know the primary sampling unit (id) for each observation
dclus1<-svydesign(id=~dnum, weights=~pw, fpc=~fpc, data=apiclus1) # Use weight and fpc (this is redundant)
dclus1.no.weights <-svydesign(id=~dnum, fpc=~fpc, data=apiclus1)  # Use only fpc (weight computed from fpc)
dclus1.no.fpc <-svydesign(id=~dnum, weights=~pw, data=apiclus1)   # Use only weight (lose information for variation)  

# Compute the survey weighted mean for each design specified above
svymean(~api00, dclus1) # 644
svymean(~api00, dclus1.no.weights) # 644 - these are the same, weights are redundant
svymean(~api00, dclus1.no.fpc) # 644, slightly higher SE b/c fpc is more accurate


############################################################
################# Cluster sample, apiclus2 #################
############################################################



# Two-stage cluster sample, weights are computed via sample sizes (fpc)

# How many districts are sampled?
length(unique(apiclus2$dnum)) # 40

# What is the *distribution* of the number of schools from each district?
schools.per.district <- apiclus2 %>% 
    group_by(dnum, fpc2) %>% 
    summarize(num.schools = n())

sum(schools.per.district$num.schools) # 126 schools

# What is the proportion of each district (cluster) that is sampled in apiclus2?
sampling.proportion <- apipop %>% group_by(dnum) %>% 
                          summarize(total.schools = n()) %>% 
                          right_join(schools.per.district, by='dnum') %>% 
                          mutate(prop.sampled = num.schools / total.schools)

hist(sampling.proportion$prop.sampled)
hist(sampling.proportion$num.schools)
plot(sampling.proportion$total.schools, sampling.proportion$fpc2)


# What is the relationship between number of schools in a district and the number sampled?
ggplot(data=sampling.proportion, aes(x=total.schools, y=prop.sampled)) +
    geom_point() + 
    ylim(0, 1)

# Specify a multi-level cluster design
# The id needs to capture *both* levels of clustering, as does the fpc
# Weights get computed via fpc using the survey package
# Note, fpc1 is # of districts in the dataset, fpc2 is the number of schools in each district
dclus2 <- svydesign(id=~dnum+snum, fpc=~fpc1+fpc2, data=apiclus2)

# Compute the survey weighted mean for your design
svymean(~api00, dclus2) # 670

# If we try to use the weights directly, the mean is the same, but the SE is inaccurately low
dclus3 <-svydesign(id=~1, weight=~pw, data=apiclus2)
svymean(~api00, dclus3)
