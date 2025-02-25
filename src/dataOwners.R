#Dynamic directory path mapping
repository <- file.path(dirname(rstudioapi::getSourceEditorContext()$path))
setwd(repository)

#Load libraries and read list of dataflows
source("setup.R")

#Read in the previous updates
updateList <- read.csv("../raw_data/updateList.csv")


#### ************************** Generate dataflow owners list ************************************ ####

updateList$id <- updateList$template
updateList <- updateList |> select(id, Label, ownInd)

pdh_df_list <- dfList |> select(id, Name.en) |> rename(Label = Name.en)

df_owners <- merge(updateList, pdh_df_list, all = TRUE)
df_owners <- df_owners |>
  mutate(ownInd = ifelse(is.na(ownInd), "No owner", ownInd)) |>
  rename(dataOwner = ownInd)

#Write df_owners table to output folder
write.csv(df_owners, "../output/data owners list.csv", row.names = FALSE)

#### ************************** Data Owners processing ************************************ ####

datOwners <- read.csv("../raw_data/dataOwners.csv")

datOwners <- datOwners |>
  select(id, Label, respDept, respSect, respTopic, contactPerson)








