# ***************************** Generate annual data cap **************************************** #
#Dynamic directory path mapping
repository <- file.path(dirname(rstudioapi::getSourceEditorContext()$path))
setwd(repository)

source("setup.R")

#Annual data cap workbook
workBook <- createWorkbook()
wb <- createWorkbook()

dfList <- dfList |> select(id, Name.en) |> rename(Label = Name.en)
dfList <- dfList |> distinct()

finList <- read.csv("../raw_data/finList.csv")
#finList <- finList |> select(id, Date, records) 
  
sheetName = "df_records"

#Initialize counter
counter = 1
#Date = Sys.Date()

#Loop to extract the number of records per dataflow
list <- nrow(dfList)

#Declaration of an empty dataframe
df_records <- data.frame(
  id = "",
  Date = "",
  records = ""
  
)

while (counter <= list){
  selected_df <- dfList[counter, ]
  #Collecting the number of records
  
  df_rec <- as.data.frame(readSDMX(providerId="PDH", resource="data", flowRef= selected_df$id))
  
  df_rec <- df_rec |> 
    mutate(id = selected_df$id,
           Date = paste0(day(Sys.Date()),"/",month(Sys.Date()),"/",year(Sys.Date()))
           ) |>
    group_by(id, Date) |>
    summarise(records = n())
  
  #Populate the empty dataframe
  df_records <- rbind(df_records, df_rec)  
  
  counter <- counter + 1 
}

#get the data flow label
finList <- merge(finList, dfList, by = "id", all = TRUE)

mydate = Sys.Date()

finList$date = ""

finList <- finList |> replace(mydate = date)

#Add data to excel workbook
addWorksheet(wb, sheetName)
writeData(wb, sheet = sheetName, finList)

#Write final file to output folder
saveWorkbook(wb, file = "../output/dataflow_records_trend.xlsx", overwrite = TRUE)

#Replace existing finList.csv file
write.csv(finList, "../raw_data/finList.csv", row.names = FALSE)

