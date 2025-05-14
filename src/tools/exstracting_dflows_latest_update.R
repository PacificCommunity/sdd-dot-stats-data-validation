#Load libraries
library(rsdmx)
library(dplyr)

providers <- as.data.frame(getSDMXServiceProviders())
dfList <- as.data.frame(readSDMX(providerId="PDH", resource="dataflow")) |> select(id)

dataFlows <- data.frame(
  INDICATOR = c(""),
  lastUpdate = c(""),
  dflow = c("")
)

dfCount <- nrow(dfList)
i = 1

while (i <= dfCount) {
  dfName <- dfList[i, 1]
  dfData <- as.data.frame(readSDMX(providerId="PDH", resource="data", flowRef= dfName))
  if(!"INDICATOR" %in% colnames(dfData)){
    message("Column 'INDICATOR' is missing from ", dfName)
  } else{
    dfData <- dfData |> group_by(INDICATOR) |> summarise(lastUpdate = max(obsTime))
    dfData$dflow <- dfName
    dataFlows <- rbind(dataFlows, dfData)  
  }
  
  i = i + 1
}

dataFlows_dt <- dataFlows |> group_by(dflow, lastUpdate) |> summarise(indicators = n()) 

dflows_last_update <- dataFlows_dt |> filter(dflow != "") |> group_by(dflow) |> summarise(lastupdated = max(substr(lastUpdate, 1, 4)))

write.csv(dflows_last_update, "../../raw_data/dflows_last_update.csv", row.names = FALSE)
