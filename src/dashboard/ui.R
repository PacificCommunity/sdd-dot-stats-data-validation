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
              fluidRow(tags$hr(style = "height: 2px; border-width: 0; background-color: #FF0000; margin-top: 20px; margin-bottom: 20px;")),
              fluidRow(
                column(12,
                       tags$table(
                         tags$tr(
                           tags$td("Select dataflow:"),
                           tags$td(selectInput("recFlow", label = NULL, choices = dfList$id, selected = 1))
                           ),
                         tags$tr(
                           tags$td("Enter date received:"),
                           tags$td(dateInput("recDate", label = NULL, format = "yyyy-mm-dd"))
                         ),
                         tags$tr(
                           tags$td("Enter name of sender:"),
                           tags$td(textInput("sender", label = NULL))
                         ),
                         tags$tr(
                           tags$td("Select where the data is coming from:"),
                           tags$td(selectInput("producer", label = NULL, choices = datProducers$producerDesc))
                         ),
                         tags$tr(
                           tags$td("Select channel through data was received:"),
                           tags$td(selectInput("chanType", label = NULL, choices = c("Email" = 1, "Web harvesting" = 2, "File transfer" = 3)))
                         ),
                         tags$tr(
                           tags$td("Actions:"),
                           tags$td(
                             div(
                               actionButton("submit", "Submit", style = "margin-right: 10px;"),
                               actionButton("clear", "Clear")
                             )
                           )
                         )
                        )
                      )
                    ),
              fluidRow(tags$hr(style = "height: 2px; border-width: 0; background-color: #FF0000; margin-top: 20px; margin-bottom: 20px;")),
              fluidRow(DTOutput("tableReg")),
              fluidRow(downloadButton("downloadReg", "Download Data"))
              ),
                

      tabItem(tabName = "dataEntry", h2("Manual Uploaded register update"),
              fluidRow(tags$hr(style = "height: 2px; border-width: 0; background-color: #FF0000; margin-top: 20px; margin-bottom: 20px;")),
              fluidRow(
                column(12, 
                       tags$table(
                         tags$tr(
                           tags$td("Select Dataflow:"),
                           tags$td(selectInput("dataFlow", label = NULL, choices = dfList$id, selected = 1))
                           ),
                         tags$tr(
                           tags$td("Select collection type:"),
                           tags$td(selectInput("colType", label = NULL, choices = c("Manual Collection" = 2, "Harvesting" = 1)))
                         ),
                         tags$tr(
                           tags$td("Select collection date:"),
                           tags$td(dateInput("colDate", label = NULL, format = "yyyy-mm-dd"))
                         ),
                         tags$tr(
                           tags$td("Select upload date:"),
                           tags$td(dateInput("upDate", label = NULL, format = "yyyy-mm-dd"))
                         ),
                         tags$tr(
                           tags$td("Total records:"),
                           tags$td(numericInput("totRec", label = NULL, 0))
                         ),
                         tags$tr(
                           tags$td("New records:"),
                           tags$td(numericInput("newRec", label = NULL, 0))
                         ),
                         tags$tr(
                           tags$td("Edited records"),
                           tags$td(numericInput("editRec", label = NULL, 0))
                         ),
                         tags$tr(
                           tags$td("Actions:"),
                           tags$td(
                             div(
                               actionButton("submit", "Submit", style = "margin-right: 10px;"),
                               actionButton("clear", "Clear")
                             )
                           )
                         )
                        )
                      )
                    ),
              fluidRow(tags$hr(style = "height: 2px; border-width: 0; background-color: #FF0000; margin-top: 20px; margin-bottom: 20px;")),
              fluidRow(DTOutput("table")),
              fluidRow(downloadButton("download", "Download Data"))
            )
        )
    )
  )
)

