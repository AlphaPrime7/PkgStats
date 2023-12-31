#library(shiny)
library(shinythemes)
library(plotly)
library(Hmisc)
library(lubridate)

#Pkgs
package_names = httr::GET("http://crandb.r-pkg.org/-/desc")
package_names = names(jsonlite::fromJSON(rawToChar(package_names$content)))
cran_inception = 26

#shiny ui
shinyUI(navbarPage(theme = "mytheme.css",
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
                                    
            radioButtons('plot_freq', 'Frequency:', c('Daily' = 'day', 'Weekly' = 'week', 'Cumulative' = 'ytd') ),
            
            actionButton("plot_button","Plot Stats")
                                    
    ),
                                
        mainPanel(
            plotlyOutput("interactive_ggplot")
            )))
                   
    )
)