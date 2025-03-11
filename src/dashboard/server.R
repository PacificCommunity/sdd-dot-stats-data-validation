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

source("setup.R")

dfList <- as.data.frame(readSDMX(providerId = "PDH", resource = "dataflow"))

datProducers <- read.csv("../../raw_data/datProducers.csv")
datOwners <- read.csv("../../raw_data/dataOwners.csv")
colData <- read.csv("../../raw_data/colData.csv")


# Server: Backend logic
server <- function(input, output, session) {
  
#### *********************** Load datasets ****************************** ####
  #Get dataflow list from PDH .STAT
  
  datOwners <- datOwners |>
    select(id, Label, respDept, respSect, respTopic, contactPerson, colType, status)
  
  colData <- colData |> filter(!is.na(totRec) & !is.na(newRec) & !is.na(editRec)) 
  
  collection <- sum(colData$totRec)
  newRec <- sum(colData$newRec)
  editRec <- sum(colData$editRec)
  
  # Data owner groupings sub-tables
  
  #deptGroup <- dataOwners |> filter(respDept !="") |> group_by(respDept) |> summarise(numDF = n())
  sectGroup <- datOwners |> filter(respSect !="") |> group_by(respSect) |> summarise(numDF = n())
  indvGroup <- datOwners |> filter(contactPerson !="") |> group_by(contactPerson) |> summarise(numDF = n())
  
#### ********************************* Dashboard Section ******************************* ####
  
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
    harvestNewRec <- colData |>
      filter(collectType == 1) |> 
      summarise(tot = sum(newRec))
    
    harvestTotal <- colData |>
      filter(collectType == 1) |> 
      summarise(tot = sum(totRec))
    
    precentageNew <- round(harvestNewRec$tot/harvestTotal$tot * 100, digits = 2)
    
    infoBox(
      "Percentage of New records", paste0(precentageNew, "%"), icon = icon("list"),
      color = "green"
    )
    
  })
  
  
  output$harvestEditCollection <- renderInfoBox({
    harvestEditRec <- colData |>
      filter(collectType == 1) |> 
      summarise(tot = sum(editRec))
    
    harvestTotal <- colData |>
      filter(collectType == 1) |> 
      summarise(tot = sum(totRec))
    
    precentageEdit <- round(harvestEditRec$tot/harvestTotal$tot * 100, digits = 2)
    
    infoBox(
      "Percentage of Edited records", paste0(precentageEdit, "%"), icon = icon("list"),
      color = "purple"
    )
    
  })
  
  
  #Manual Collections rate
  output$manualNewCollection <- renderInfoBox({
    manualNewRec <- colData |>
      filter(collectType == 2) |> summarise(tot = sum(newRec))
    
    manualTotal <- colData |>
      filter(collectType == 2) |> summarise(tot = sum(totRec))
    
    precentageNew <- round(manualNewRec$tot/manualTotal$tot * 100, digits = 2)
    
    infoBox(
      "Percentage of New records", paste0(precentageNew, "%"), icon = icon("list"),
      color = "green"
    )
    
  })
  
  
  output$manualEditCollection <- renderInfoBox({
    manualEditRec <- colData |>
      filter(collectType == 2) |> summarise(tot = sum(editRec))
    
    manualTotal <- colData |>
      filter(collectType == 2) |> summarise(tot = sum(totRec))
    
    precentageEdit <- round(manualEditRec$tot/manualTotal$tot * 100, digits = 2)
    
    infoBox(
      "Percentage of Edited records", paste0(precentageEdit, "%"), icon = icon("list"),
      color = "purple"
    )
    
  })
  
#### ******************************* Data Gap *********************************** ####  
  
  output$dataTrend <- DT::renderDataTable({
    
    dataCollection <- read.csv("../../raw_data/colData.csv")
    dataManual_Harvest_Owner <- merge(dataCollection, datOwners)
    
    dataTrend_DT <- dataManual_Harvest_Owner |>
      filter(id == input$datFlow) |>
      select(respDept, respSect, respTopic, colDate, upDate, totRec, newRec, editRec)
    
    datatable(dataTrend_DT)
  })
  
  output$sectDataOwner <- DT::renderDataTable({
    sectDF <- datOwners
    
    sectDF <- sectDF |>
      filter(respSect == input$section) |>
      
      datatable(sectDF)
  })
  
  output$indvDataOwner <- DT::renderDataTable({
    indvDF <- datOwners
    
    indvDF <- indvDF |>
      filter(contactPerson == input$owner) |>
      
      datatable(indvDF)
  })
  
  output$histRecords <- DT::renderDataTable({
    histRecs <- read.csv("../../raw_data/finList.csv")
    
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
    
    
#### **************************** Data Registration ***************************** ####
    
    dataReg <- reactive(data.frame(recFlow = character(),
                                   recDate = as.Date(character()),
                                   sender = character(),
                                   producer = character(),
                                   chanType = character(),
                                   regDate = as.Date(character()),
                                   regOfficer = character(),
                                   stringsAsFactors = FALSE ))
    
    #Append data when submit button is clicked
    observeEvent(input$submitReg, {
      new_reg <- data.frame(
        recFlow = input$recFlow,
        recDate = input$recDate,
        sender = input$sender,
        producer = input$producer,
        chanType = input$chanType,
        regDate = date(),
        regOfficer = Sys.getenv("USERNAME"),
        stringsAsFactors = FALSE
      )
      
      data(rbind(dataReg(), new_reg))
      regdatafile <- rbind(data(), new_reg)
      regdatafile <- unique(regdatafile)
      
      write.csv(regdatafile, "../../output/regdatafile.csv", row.names = FALSE)
      
      # Reset input fields
      updateTextInput(session, "recFlow", value = "")
      updateTextInput(session, "recDate", value = NULL)
      updateTextInput(session, "sender", value = "")
      updateTextInput(session, "producer", value = "")
      updateTextInput(session, "chanType", value = "")
      
    })

    # Clear all data
    observeEvent(input$clearReg, {
      dataReg(data.frame(recFlow = character(), 
                      recDate = as.Date(character()), 
                      sender = character(), 
                      producer = character(), 
                      chanType = numeric(), 
                      stringsAsFactors = FALSE))
    })
    
    # Render table
    output$tableReg <- renderDT({
      datatable(data(), editable = TRUE)
    })
    
    # Download data
    output$downloadReg <- downloadHandler(
      filename = function() { "data_registration.csv" },
      content = function(file) {
        write.csv(data(), file, row.names = FALSE)
      }
    )
    
    
#### *************************** Data Entry Section **************************** ####

    # Reactive dataframe
     data <- reactiveVal(data.frame(dataFlow = character(),
                                    colType = numeric(),
                                    colDate = as.Date(character()), 
                                    upDate = as.Date(character()), 
                                    totRec = numeric(), 
                                    newRec = numeric(), 
                                    editRec = numeric(), 
                                    stringsAsFactors = FALSE))
    
    # Append data when Submit button is clicked
    observeEvent(input$submit, {
      new_entry <- data.frame(
        dataFlow = input$dataFlow,
        colType = input$colType,
        colDate = as.Date(input$colDate),
        upDate = as.Date(input$upDate),
        totRec = input$totRec,
        newRec = input$newRec,
        editRec = input$editRec,
        regDate = date(),
        regOfficer = Sys.getenv("USERNAME"),
        stringsAsFactors = FALSE
      )
      data(rbind(data(), new_entry))
      
      datafile <- rbind(data(), new_entry)
      datafile <- unique(datafile)
      datafile <- datafile |> 
        rename(id = dataFlow, collectType = colType)
      
      
      datafile$colDate <- format(datafile$colDate, "%d-%b-%Y")
      datafile$upDate <- format(datafile$upDate, "%d-%b-%Y")
      
      colData <- rbind(colData, datafile)
      
      
      #Check for common fields.
      #common_cols <- intersect(names(datafile), names(dataHarvest))
      #dataResult <- rbind(dataHarvest[common_cols], datafile[common_cols])
      
      
      #write.csv(dataResult, "../../raw_data/datafile.csv", row.names = FALSE)
      write.csv(colData, "../../raw_data/colData.csv", row.names = FALSE)
      
      # Reset input fields
      updateTextInput(session, "dataFlow", value = "")
      updateNumericInput(session, "colType", value = "")
      updateTextInput(session, "colDate", value = NULL)
      updateTextInput(session, "upDate", value = "")
      updateNumericInput(session, "totRec", value = "")
      updateNumericInput(session, "newRec", value = "")
      updateNumericInput(session, "editRec", value = "")
    })
    
    # Clear all data
    observeEvent(input$clear, {
      data(data.frame(id = character(), 
                      colDate = as.Date(character()), 
                      upDate = as.Date(character()), 
                      totRec = numeric(), 
                      newRec = numeric(), 
                      editRec = numeric(),  
                      stringsAsFactors = FALSE))
    })
    
    # Render table
    output$table <- renderDT({
      datatable(data(), editable = TRUE)
    })
    
    # Download data
    output$download <- downloadHandler(
      filename = function() { "data_entry.csv" },
      content = function(file) {
        write.csv(data(), file, row.names = FALSE)
      }
    )
  
} #End server funtion

