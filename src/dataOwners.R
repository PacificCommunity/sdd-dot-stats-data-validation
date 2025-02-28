#Dynamic directory path mapping
repository <- file.path(dirname(rstudioapi::getSourceEditorContext()$path))
setwd(repository)

#Load libraries and read list of dataflows
source("setup.R")

#Read in the previous updates
dataOwners <- read.csv("../raw_data/dataOwners.csv")

#### ************************** Generate dataflow owners list ************************************ ####

#updateList <- updateList |> rename(id = template)
dataOwners <- dataOwners |> select(id, Label, respDept, respSect, respTopic, contactPerson)

dfList <- dfList |> select(id, Name.en) |> rename(Label = Name.en)

df_owners <- merge(dataOwners, dfList, all = TRUE)

df_owners <- df_owners |>
  filter(!is.na(respDept)) |>
  mutate(ownInd = ifelse(is.na(contactPerson), "No owner", contactPerson))
  

#Write df_owners table to output folder
write.csv(df_owners, "../output/data owners list.csv", row.names = FALSE)

#### ************************** Data Owners processing ************************************ ####

datOwners <- read.csv("../raw_data/dataOwners.csv")

colType <- data.frame(
  id = c(1, 2),
  colTypeDesc = c("Web harvesting", "Manual collection") 
)

status <- data.frame(
  id = c(1, 2),
  statusDesc = c("Active", "archived")
)













