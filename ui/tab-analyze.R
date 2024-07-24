tabPanel(
  title = "Analyze",
  id = "analyze",
  icon = icon("table"),
  sidebarLayout(
    sidebarPanel(
      selectizeInput("pkgs", "Select packages:", choices = NULL, multiple = TRUE),
      dateRangeInput("date_range", "Period you want to see:",
                     min = Sys.Date()- (Hmisc::yearDays(lubridate::year(Sys.Date())) * cran_inception),
                     max = Sys.Date()),
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
      downloadButton("download_plot", "Download Plot"),
      checkboxInput('smoothen', 'Smoothen the Lines', value = FALSE)
      ),
    mainPanel(
      plotlyOutput("interactive_ggplot"),
      withSpinner(DT::dataTableOutput("mytable"))
      
      )
    )
  )
