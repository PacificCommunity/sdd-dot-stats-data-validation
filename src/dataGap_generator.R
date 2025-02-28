# ***************************** Generate annual data cap **************************************** #
#Dynamic directory path mapping
repository <- file.path(dirname(rstudioapi::getSourceEditorContext()$path))
setwd(repository)

source("setup.R")

#Annual data cap workbook
workBook <- createWorkbook()
wb <- createWorkbook()

dfList <- dfList |> select(id)
dfList <- dfList |> distinct()

#Initialize counter
counter = 1
#Loop to extract the number of records per dataflow

list <- nrow(dfList)

while (counter <= list){
  selected_df <- dfList[counter, ]
  #Collecting the number of records
  
  df_rec <- as.data.frame(readSDMX(providerId="PDH", resource="data", flowRef= selected_df))
  
  if("GEO_PICT" %in% colnames(df_rec)){
    df_rec <- df_rec |>
      filter(nchar(obsTime) == 4) |>
      group_by(GEO_PICT, obsTime) |>
      summarise(totRec = n())
  
  #contract pivot-wider table
    df_rec_summary <- pivot_wider(
    df_rec,
    names_from = GEO_PICT,
    values_from = totRec
  )
  
    df_rec_summary <- df_rec_summary |> 
      mutate(across(-obsTime, ~ ifelse(is.na(.), "No data", "Data")))
  
  #Add data to excel workbook
  addWorksheet(wb, selected_df)
  writeData(wb, sheet = selected_df, df_rec_summary)
    
  } else{
      
    }
  
   counter <- counter + 1 
}

#Write final file to output folder
saveWorkbook(wb, file = "../output/data gaps matrix.xlsx", overwrite = TRUE)
