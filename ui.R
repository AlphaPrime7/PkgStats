library(shiny)
library(shinythemes)
library(shinycssloaders)
library(shinyjs)
library(DT)
library(plotly)
library(Hmisc)
library(lubridate)

cran_inception = 26

tagList(
  shinydisconnect::disconnectMessage2(),
  useShinyjs(),
  tags$head(
    shinythemes::themeSelector(),
    tags$link(href = "styles.css", rel = "stylesheet")
  ),
  div(id = "loading-content", "App Loading...",
      img(src = "ajax-loader-bar.gif")),
  
  navbarPage(
    title = tags$b("CRANstats"),
    windowTitle = "CRANstats",
    id = "main_nav",
    inverse = FALSE,
    fluid = TRUE,
    collapsible = FALSE,
    source(file.path("ui", "tab-analyze.R"),  local = TRUE)$value,
    source(file.path("ui", "tab-about.R"),  local = TRUE)$value,
    
  )
)

