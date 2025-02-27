library(shinydashboard)
library(shiny)
library(plotly)
library(DT)
library(ggplot2)


repository <- file.path(dirname(rstudioapi::getSourceEditorContext()$path))
setwd(repository)


shinyUI(dashboardPage(
  dashboardHeader(title = "PDH .STATS Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem(actionButton("do", "Download Update"),
               shinycssloaders::withSpinner(textOutput("complete"))
      ),
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Data Owners", tabName = "datOwner", icon = icon("bar-chart-o"),
               startExpanded = TRUE,
               menuSubItem("Department Owner",
                           tabName = "deptOwner"),
               menuSubItem("Section Owner",
                           tabName = "secOwner"),
               menuSubItem("Individual Owner",
                           tabName = "intOwner"
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
      tabItem(tabName = "datOwner",
              fluidRow(hr(h2("Data Flows Data Owners"))),
              fluidRow(hr(h2("Table showing the Collections by Province"))),
              fluidRow(dataTableOutput("provinceDataTable"))  
              
      ),
      
      tabItem(tabName = "dataCol", h2("Data Collections / Harvesting"),
              fluidRow(
                selectInput("datFlow", "Select Data Flow:", choices = dfList$id, selected = 1)
              ),
              fluidRow(hr(h2("Table showing the provincial collections by Area Council"))),
              fluidRow(dataTableOutput("dataTrend"))
              
      ),
      
      tabItem(tabName = "provinceInterviewStatuses",
              fluidRow(hr(h2("Iinterview Statuses BY Province"))),
              fluidRow(plotOutput("interviewStatusGGPlot"))
              
              
      ),
      
      tabItem(tabName = "enumeration", h1("Check by Enumeration"),
              #fluidRow(selectInput("province", "Select province:", choices = c("Torba" = 1, "Sanma" = 2, "Penama" = 3, "Malampa" = 4, "Shefa" = 5, "Tafea" = 6), selected = 1))
              
              
      ),
      tabItem(tabName = "interviewer", h1("Check by Interviewer")
              
      ),
      
      
      tabItem(tabName = "interviews", h1("Check by Interviewer")
              
              
      )
      
    )
  )
)
)
  
  