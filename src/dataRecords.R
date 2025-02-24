# ***************************** Generate annual data cap **************************************** #
#Dynamic directory path mapping
repository <- file.path(dirname(rstudioapi::getSourceEditorContext()$path))
setwd(repository)

source("setup.R")

#Annual data cap workbook
workBook <- createWorkbook()
wb <- createWorkbook()

dfList <- dfList |> select(id, Name.en)
dfList <- dfList |> distinct()

finList <- read.csv("../raw_data/finList.csv")
sheetName = "df_records"

#Initialize counter
counter = 1
#Date = Sys.Date()

#Loop to extract the number of records per dataflow
list <- nrow(dfList)

while (counter <= list){
  selected_df <- dfList[counter, ]
  #Collecting the number of records
  
  df_rec <- as.data.frame(readSDMX(providerId="PDH", resource="data", flowRef= selected_df$id))
  
  df_rec <- df_rec |> 
    mutate(id = selected_df$id,
           Date = paste0(day(Sys.Date()),"/",month(Sys.Date()),"/",year(Sys.Date())),
           Label = ""
           ) |>
    group_by(id, Date, Label) |>
    summarise(records = n())
  
  finList <- rbind(finList, df_rec)  
  
  counter <- counter + 1 
}

#Add data to excel workbook
addWorksheet(wb, sheetName)
writeData(wb, sheet = sheetName, finList)

#Write final file to output folder
saveWorkbook(wb, file = "../output/dataflow_records_trend.xlsx", overwrite = TRUE)


