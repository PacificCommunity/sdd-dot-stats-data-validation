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
      menuItem("Data Gaps", tabName = "dataGaps", icon = icon("bar-chart-o")),
      menuItem("Historical updates", tabName = "histUpdates", icon = icon("bar-chart-o"))#,
      #menuItem("Interviewer", tabName = "interviewer", icon = icon("bar-chart-o")),
      #menuItem("interviews", tabName = "interviews", icon = icon("bar-chart-o"))
      
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
              #fluidRow(plotlyOutput("plotProvince")),
              fluidRow(hr(h2("Table showing the Collections by Province"))),
              fluidRow(dataTableOutput("provinceDataTable"))  
              
      ),
      
      tabItem(tabName = "dataGaps", h2("Data Gaps"),
              fluidRow(
                selectInput("datFlow", "Select Data Flow:", choices = dfList$id, selected = 1)
              ),
              fluidRow(
                plotlyOutput("selac")),
              fluidRow(hr(h2("Table showing the provincial collections by Area Council"))),
              fluidRow(dataTableOutput("selProvinceAC"))
              
      ),
      
      tabItem(tabName = "provinceInterviewStatuses",
              fluidRow(hr(h2("Iinterview Statuses BY Province"))),
              fluidRow(plotOutput("interviewStatusGGPlot"))
              
              
      ),
      
      tabItem(tabName = "areacouncil",
              fluidRow(hr(h2("Over Area Council Collections status"))),
              #fluidRow(plotlyOutput("plotAC")),
              
              fluidRow(
                selectInput("aclist", "Area Council:",  choices = c(
                  "torres" = 101,
                  "ureparapara" = 102,
                  "motalava" = 103,
                  "vanua lava" = 104,
                  "mota" = 105,
                  "gaua" = 106,
                  "merelava" = 107,
                  "north west santo" = 201,
                  "north santo" = 202,
                  "west santo" = 203,
                  "south santo" = 204,
                  "east santo" = 205,
                  "south east santo" = 206,
                  "canal - fanafo" = 207,
                  "luganville" = 208,
                  "west malo" = 209,
                  "east malo" = 210,
                  "west ambae" = 301,
                  "north ambae" = 302,
                  "east ambae" = 303,
                  "south ambae" = 304,
                  "north maewo" = 305,
                  "south maewo" = 306,
                  "north pentecost" = 307,
                  "central pentecost 1" = 308,
                  "central pentecost 2" = 309,
                  "south pentecost" = 310,
                  "north west malekula" = 401,
                  "north east malekula" = 402,
                  "central malekula" = 403,
                  "south west malekula" = 404,
                  "south east malekula" = 405,
                  "south malekula" = 406,
                  "north ambrym" = 407,
                  "west ambrym" = 408,
                  "south east ambrym" = 409,
                  "paama" = 410,
                  "vermali" = 501,
                  "vermaul" = 502,
                  "varisu" = 503,
                  "south epi" = 504,
                  "north tongoa" = 505,
                  "tongariki" = 506,
                  "makimae" = 507,
                  "nguna" = 508,
                  "emau" = 509,
                  "malorua" = 510,
                  "north efate" = 511,
                  "mele" = 512,
                  "port vila" = 513,
                  "ifira" = 514,
                  "pango" = 515,
                  "erakor" = 516,
                  "eratap" = 517,
                  "eton" = 518,
                  "tanvasoko" = 519,
                  "north erromango" = 601,
                  "south erromango" = 602,
                  "aniwa" = 603,
                  "north tanna" = 604,
                  "west tanna" = 605,
                  "middle bush tanna" = 606,
                  "south west tanna" = 607,
                  "whitesands" = 608,
                  "south tanna" = 609,
                  "futuna" = 610,
                  "aneityum" = 611
                  
                ), selected = 101)
              ),
              
              fluidRow(
                plotlyOutput("selea"))
              
              
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
  
  