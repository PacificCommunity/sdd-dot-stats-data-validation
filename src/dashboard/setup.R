library(RSQLite) #Use SQLite database to store and read data
library(dplyr) # Data manipulation
library(tidyverse) #Data science package
library(ggplot2) #Load ggplot2 library for graph generations
library(plotly) #Load plot library for interactive graph generations
library(shinydashboard) # Load shinydashboard library
library(shiny) # Load shiny library
library(DT) #Load Datatable library
library(chron) # Load shron library for date manipulation
library(shinycssloaders) #Load shiny css library
library(lubridate) #Data manipulation library
library(rsdmx)

#Map directory
repository <- file.path(dirname(rstudioapi::getSourceEditorContext()$path))
setwd(repository)

dfList <- as.data.frame(readSDMX(providerId = "PDH", resource = "dataflow"))

datProducers <- read.csv("../../raw_data/datProducers.csv")
datOwners <- read.csv("../../raw_data/dataOwners.csv")
colData <- read.csv("../../raw_data/colData.csv")
