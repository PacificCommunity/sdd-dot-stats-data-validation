library(shinydashboard)
library(shiny)
library(plotly)
library(DT)
library(ggplot2)


repository <- file.path(dirname(rstudioapi::getSourceEditorContext()$path))
setwd(repository)

shinyUI(dashboardPage(
  dashboardHeader(title = "PDH .STAT Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem(actionButton("do", "Download Update"),
               shinycssloaders::withSpinner(textOutput("complete"))
      ),
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
      menuItem("Historical updates", tabName = "histUpdates", icon = icon("bar-chart-o"))#,
          
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
              fluidRow(hr(h2("Table showing the provincial collections by Area Council"))),
              fluidRow(dataTableOutput("dataTrend"))
              
      ),
      
      tabItem(tabName = "histUpdates",
              fluidRow(hr(h2("Historical DF Updates by Year"))),
              fluidRow(dataTableOutput("histRecords"))
              
      ),
      
      tabItem(tabName = "enumeration", h1("Check by Enumeration"),

      ),
      tabItem(tabName = "interviewer", h1("Check by Interviewer")
              
      ),
      
      tabItem(tabName = "interviews", h1("Check by Interviewer")
              
              
      )
      
    )
  )
)
)
  
  