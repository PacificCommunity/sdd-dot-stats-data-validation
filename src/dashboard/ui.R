library(shinydashboard)
library(shiny)
library(plotly)
library(DT)
library(ggplot2)
library(rsdmx)

repository <- file.path(dirname(rstudioapi::getSourceEditorContext()$path))
setwd(repository)

shinyUI(dashboardPage(
  dashboardHeader(title = "PDH .STAT Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Data Owners", tabName = "datOwner", icon = icon("bar-chart-o"),
               startExpanded = FALSE,
               menuSubItem("Section Owner",
                           tabName = "sectOwner"),
               menuSubItem("Individual Owner",
                           tabName = "indvOwner"
               )
      ),
      menuItem("Data Collections", tabName = "dataCol", icon = icon("bar-chart-o")),
      menuItem("Historical updates", tabName = "histUpdates", icon = icon("bar-chart-o")),
      menuItem("Data Gaps", tabName = "dataGap", icon = icon("bar-chart-o")),
      menuItem("Dataset Registration", tabName = "datReg", icon = icon("bar-chart-o")),
      menuItem("Data Entry", tabName = "dataEntry", icon = icon("bar-chart-o"))
      
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
              fluidRow(hr(h2("Overall Collections"))),
              fluidRow(
                infoBoxOutput("newCollection", width = 4),
                infoBoxOutput("editCollection", width = 4)
                
              ),
              
              fluidRow(hr(h2("Collections through Harvesting"))),
              fluidRow(
                infoBoxOutput("harvestNewCollection", width = 4),
                infoBoxOutput("harvestEditCollection", width = 4)
              ),
              
              fluidRow(hr(h2("Manual Collections through regional offices"))),
              fluidRow(
                infoBoxOutput("manualNewCollection", width = 4),
                infoBoxOutput("manualEditCollection", width = 4)
              ),
              
      ),
      tabItem(tabName = "sectOwner", h2("Section Data Flows Owners"),
              fluidRow(
              selectInput("section", "Select section:", choices = sectGroup$respSect, selected = 1)),
              fluidRow(hr(h2("Table showing the Data flows with ownership from selected section"))),
              fluidRow(dataTableOutput("sectDataOwner"))  
              
      ),
      
      tabItem(tabName = "indvOwner", h2("Individial data flow owners"),
              fluidRow(
              selectInput("owner", "Select Individual owner:", choices = indvGroup$contactPerson, selected = 1 )),
              fluidRow(hr(h2("Table showing the Data flows with ownership from the selected inidividual"))),
              fluidRow(dataTableOutput("indvDataOwner"))
              
      ),
      
      tabItem(tabName = "dataCol", h2("Data Collections / Harvesting"),
              fluidRow(
                selectInput("datFlow", "Select Data Flow:", choices = dfList$id, selected = 1)
              ),
              fluidRow(hr(h2("Table showing the collections overtime"))),
              fluidRow(dataTableOutput("dataTrend"))
              
      ),
      
      tabItem(tabName = "histUpdates",
              fluidRow(hr(h2("Historical DF Updates by Year"))),
              fluidRow(dataTableOutput("histRecords"))
              
      ),
      
      tabItem(tabName = "dataGap", h1("Data Gap Analysis"),
              fluidRow(
                selectInput("dfName", "Select Data Flow:", choices = dfList$id, selected = 1)
              ),
              fluidRow(hr(h2("Table showing data gaps in collections as per selected data flow"))),
              fluidRow(dataTableOutput("dataGap"))
              
      ),
      
      tabItem(tabName = "datReg", h2("Incoming dataset registration"),
              fluidRow(selectInput("recFlow", "Select data flow:", choices = dfList$id, selected = 1)),
              fluidRow(dateInput("recDate", "Enter date received:", format = "yyyy-mm-dd")),
              fluidRow(textInput("sender", "Enter the name of the Sender:")),
              fluidRow(selectInput("producer", "Select where the data is coming from:", choices = datProducers$producerID)),
              fluidRow(selectInput("chanType", "Select channel through data was received:", choices = c("Email" = 1, "Web harvesting" = 2, "File transfer" = 3))),
              fluidRow(hr()),
              fluidRow(actionButton("submitReg", "Submit")),
              fluidRow(actionButton("clearReg", "Clear Data")),
              fluidRow(DTOutput("tableReg")),
              fluidRow(downloadButton("downloadReg", "Download Data"))
              ),
      
      tabItem(tabName = "dataEntry", h2("Manual Uploaded register update"),
              fluidRow(hr()),
              fluidRow(selectInput("dataFlow", "Select data flow:", choices = dfList$id, selected = 1)),
              fluidRow(selectInput("colType", "Select the Collection type:", choices = c("Manual Collection" = 2, "Harvesting" = 1))),
              fluidRow(dateInput("colDate", "Collection Date", format = "yyyy-mm-dd"),
                       dateInput("upDate", "Upload Date", format = "yyyy-mm-dd")
                       ),
              fluidRow(numericInput("totRec", "Total records", 0)),
              fluidRow(numericInput("newRec", "New records", 0)),
              fluidRow(numericInput("editRec", "Edited records", 0)),
              fluidRow(hr()),
              fluidRow(actionButton("submit", "Submit")),
              fluidRow(actionButton("clear", "Clear Data")),
              fluidRow(DTOutput("table")),
              fluidRow(downloadButton("download", "Download Data"))
              )
    )
  )
)
)

