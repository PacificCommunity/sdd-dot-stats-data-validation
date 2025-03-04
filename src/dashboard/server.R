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

#### *********************** Load datasets ****************************** ####

dfList <- as.data.frame(readSDMX(providerId = "PDH", resource = "dataflow"))

datOwners <- read.csv("dataOwners.csv")

datOwners <- datOwners |>
  select(id, Label, respDept, respSect, respTopic, contactPerson, colType, status)

dataManual <- read.csv("dataManual.csv")
dataManual <- dataManual |>
  select(id, colDate, upDate, totRec, newRec, editRec)

dataHarvest <- read.csv("dataharvesting.csv")
dataHarvest <- dataHarvest |>
  select(id, colDate, upDate, totRec, newRec, editRec)

dataManual_Harvest <- rbind(dataManual, dataHarvest)
dataManual_Harvest_Owner <- merge(datOwners, dataManual_Harvest, by = "id")

dataManual_Harvest_Owner <- dataManual_Harvest_Owner |>
  mutate(totRec = as.numeric(totRec),
         newRec = as.numeric(newRec),
         editRec = as.numeric(editRec),
         colDate = dmy(colDate),
         upDate = dmy(upDate)
  )
dataManual_Harvest_Owner <- na.omit(dataManual_Harvest_Owner)

collection <- sum(dataManual_Harvest_Owner$totRec)
newRec <- sum(dataManual_Harvest_Owner$newRec)
editRec <- sum(dataManual_Harvest_Owner$editRec)

# Data owner groupings sub-tables

#deptGroup <- dataOwners |> filter(respDept !="") |> group_by(respDept) |> summarise(numDF = n())
sectGroup <- datOwners |> filter(respSect !="") |> group_by(respSect) |> summarise(numDF = n())
indvGroup <- datOwners |> filter(contactPerson !="") |> group_by(contactPerson) |> summarise(numDF = n())



#### *********************** Server section ************************************ ####

# Server: Backend logic
server <- function(input, output) {
  
  #Calculate the percentage of new collections
  output$newCollection <- renderInfoBox({
    precentageNew <- round(newRec/collection * 100, digits = 2)
    
    infoBox(
      "Overall Percentage of New records", paste0(precentageNew, "%"), icon = icon("list"),
      color = "green"
    )
    
  })  
  
  #Calculate the percentage of edited collections
  output$editCollection <- renderInfoBox({
    precentageNew <- round(editRec/collection * 100, digits = 2)
    
    infoBox(
      "Percentage of Edited records", paste0(precentageNew, "%"), icon = icon("list"),
      color = "purple"
    )
    
  })
  
  
  #Harvesting Collections rate
  output$harvestNewCollection <- renderInfoBox({
    harvestNewRec <- dataManual_Harvest_Owner |>
      filter(colType == 1) |> summarise(tot = sum(newRec))
    harvestTotal <- dataManual_Harvest_Owner |>
      filter(colType == 1) |> summarise(tot = sum(totRec))
    
    precentageNew <- round(harvestNewRec$tot/harvestTotal$tot * 100, digits = 2)
    
    infoBox(
      "Percentage of New records", paste0(precentageNew, "%"), icon = icon("list"),
      color = "green"
    )
    
  })
  
  
  output$harvestEditCollection <- renderInfoBox({
    harvestEditRec <- dataManual_Harvest_Owner |>
      filter(colType == 1) |> summarise(tot = sum(editRec))
    harvestTotal <- dataManual_Harvest_Owner |>
      filter(colType == 1) |> summarise(tot = sum(totRec))
    
    precentageEdit <- round(harvestEditRec$tot/harvestTotal$tot * 100, digits = 2)
    
    infoBox(
      "Percentage of Edited records", paste0(precentageEdit, "%"), icon = icon("list"),
      color = "purple"
    )
    
  })
  
  
  #Manual Collections rate
  output$manualNewCollection <- renderInfoBox({
    manualNewRec <- dataManual_Harvest_Owner |>
      filter(colType == 2) |> summarise(tot = sum(newRec))
    manualTotal <- dataManual_Harvest_Owner |>
      filter(colType == 2) |> summarise(tot = sum(totRec))
    
    precentageNew <- round(manualNewRec$tot/manualTotal$tot * 100, digits = 2)
    
    infoBox(
      "Percentage of New records", paste0(precentageNew, "%"), icon = icon("list"),
      color = "green"
    )
    
  })
  
  
  output$manualEditCollection <- renderInfoBox({
    manualEditRec <- dataManual_Harvest_Owner |>
      filter(colType == 2) |> summarise(tot = sum(editRec))
    manualTotal <- dataManual_Harvest_Owner |>
      filter(colType == 2) |> summarise(tot = sum(totRec))
    
    precentageEdit <- round(manualEditRec$tot/manualTotal$tot * 100, digits = 2)
    
    infoBox(
      "Percentage of Edited records", paste0(precentageEdit, "%"), icon = icon("list"),
      color = "purple"
    )
    
  })
  
  output$dataGap <- renderDataTable({
    #colTrend <- read.csv("../../raw_data/finList.csv")
    
    #df <- colTrend |> filter(id == input$datFlow)
    
    dataTrend <- dataManual_Harvest_Owner %>%
      filter(provid == input$datFlow)
    
    provSelectedSummary <<- provSelected
    
    plot_ly(provSelectedSummary, x = ~acname, y = ~frHouseholds, type = 'bar', name = 'Baseline') %>%
      add_trace(y = ~colHouseholds, name='Collection')
    
  })
  
  
  output$dataTrend <- DT::renderDataTable({
    
    dataTrend_DT <- dataManual_Harvest_Owner |>
      filter(id == input$datFlow) |>
      select(respDept, respSect, respTopic, colDate, upDate, totRec, newRec, editRec)
    
    datatable(dataTrend_DT)
  })
  
  
  output$sectDataOwner <- DT::renderDataTable({
    sectDF <- dataOwners
    
    sectDF <- sectDF |>
      filter(respSect == input$section) |>
      
      datatable(sectDF)
  })
  
  output$indvDataOwner <- DT::renderDataTable({
    indvDF <- dataOwners
    
    indvDF <- indvDF |>
      filter(contactPerson == input$owner) |>
      
      datatable(indvDF)
  })
  
  
  output$histRecords <- DT::renderDataTable({
    histRecs <- read.csv("finList.csv")
    
    histRecs <- histRecs |>
      select(-total) |>
      rename("2022" = X2022, "2023" = X2023, "2025" = X2025)
    
    datatable(histRecs)
  })
  
  
  dfName <- reactive({
    df <- input$dfName
    dfData <- as.data.frame(readSDMX(providerId="PDH", resource="data", flowRef= df))
    
    dfData <- dfData |>
      filter(nchar(obsTime) == 4) |>
      group_by(GEO_PICT, obsTime) |>
      summarise(totRec = n())
    
    #contract pivot-wider table
    dfSummary <- pivot_wider(
      dfData,
      names_from = GEO_PICT,
      values_from = totRec
    )
    
    dfSummary <- dfSummary |> 
      mutate(across(-obsTime, ~ ifelse(is.na(.), "No data", "Data"))) |>
      rename(Year = obsTime)
    
  })
  
  #Function to produce the data gap table
  
    output$dataGap <- DT::renderDataTable({
      
      datTable <- dfName()
      
      datatable(datTable) %>%
        formatStyle(
          columns = colnames(datTable),                # Apply styling to all columns
          target = "cell",
          backgroundColor = styleEqual("No data", "red", "green") # Set red background if cell equals "No Data"
        )
      
    })
    
  
} #End server funtion

