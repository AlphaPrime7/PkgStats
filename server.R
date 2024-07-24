library(shiny)
library(shinyjs)
library(shinycssloaders)
reactiveConsole(TRUE)
library(jsonlite)
library(cranlogs)
library(tidyverse)
library(zoo)
library(aweek)
library(ggplot2)
library(ggthemes)
library(ggdark)
library(scales)
library(plotly, lib.loc = Sys.getenv('lib.loc'))
library(lubridate)
library(profvis)

source(file.path("functions", "gird.R"),  local = TRUE)


shinyServer(function(input, output, session) {
  
  Sys.sleep(0.001)
  
  observe({
    removeUI(selector = "#loading-content")
    shinyjs::show("main_nav")
  })
  
  package_names = reactive({get_package_names()})
  updateSelectizeInput(session, "pkgs",choices = package_names(), selected = sample(package_names(),3), server = TRUE)
  source(file.path("server", "tab-analyze.R"),  local = TRUE)$value
  
})


