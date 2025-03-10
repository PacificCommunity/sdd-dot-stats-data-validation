#Load libraries needed to run the scripts

library(rsdmx)
library(dplyr)
library(RSQLite)
library(openxlsx)
library(readxl)
library(lubridate)
library(tidyr)

#Establish connection to the PDH .STATS
providers <- as.data.frame(getSDMXServiceProviders())
dfList <- as.data.frame(readSDMX(providerId = "PDH", resource = "dataflow"))



