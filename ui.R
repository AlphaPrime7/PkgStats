#library(shiny)
library(shinythemes)
library(DT)
library(plotly)
library(Hmisc)
library(lubridate)

#Pkgs
package_names = httr::GET("http://crandb.r-pkg.org/-/desc")
package_names = names(jsonlite::fromJSON(rawToChar(package_names$content)))
cran_inception = 26

#shiny ui
shinyUI(
  navbarPage(theme = shinytheme("cerulean"),
    "R Package Stats Hub",
    tabPanel("R PKG STATS",
                            
    sidebarLayout(
                                
        sidebarPanel(
                                    
            selectInput('pkgs', 'Packages:',
            selected = sample(package_names, 2),
            choices = package_names,
            multiple = TRUE),
            
            dateRangeInput("date_range", "Period you want to see:",
                           min   = Sys.Date()- (Hmisc::yearDays(lubridate::year(Sys.Date())) * cran_inception),
                           max   = Sys.Date()),
            
            sliderInput(inputId = "year_range", 
                        label = "Number of Years(CRAN in 1997):",
                        min = 0.00, 
                        value = 0.00,
                        max = 26,
                        step = 1),
            
            sliderInput(inputId = "time_range", 
                        label = "Number of Weeks:",
                        min = 0.00, 
                        value = 0.00,
                        max = round(Hmisc::yearDays(lubridate::year(Sys.Date()))/7),
                        step = 1),
                                    
            radioButtons('plot_freq', 'Frequency:', c('Daily' = 'day', 'Weekly' = 'week', 'Trailing_week' = 'tw', 'Cumulative' = 'ytd') ),
            
            radioButtons('theme', 'Plot Theme:', c('Dark' = 'dark', 'Light' = 'light') ),
            
            actionButton("plot_button","Plot Stats"),
            
            checkboxInput('smoothen', 'Smoothen the Lines', value = FALSE)
                                    
    ),
                                
        mainPanel(
            plotlyOutput("interactive_ggplot"),
            downloadButton("download_plot", "Download Plot"),
            DT::dataTableOutput("mytable")
            ))),
    
    tabPanel("Help",
             
             HTML("Welcome to The Adeck's Package Statistics Hub", 
                  "This is a beefed up version of the App",
             "Inspired by the dgrtwo's stats package for more practice on using Shiny, APIs, 
                  httr and an added component jsonlite.",
                  "Unaffiliated with RStudio or CRAN.",
                  "Check dgrtwo's repo at <a href='https://github.com/dgrtwo/cranview'> for the original work.</a>,")
      
    )
                   
    )
)