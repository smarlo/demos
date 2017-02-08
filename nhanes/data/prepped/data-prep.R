library(Hmisc)
library(dplyr)
physicalActivity <- sasxport.get("./raw/PAQ_H.XPT")
demoData <- sasxport.get("./raw/DEMO_H.XPT")

myData <- full_join(physicalActivity, demoData, by="seqn")

