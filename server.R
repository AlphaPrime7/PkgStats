library(shiny)
library(jsonlite)
library(cranlogs)
library(tidyverse)
library(zoo)
library(aweek)
library(ggplot2)
library(ggthemes)
library(ggdark)
library(scales)
library(plotly)
library(lubridate)

#get initial release date
get_initial_release_date = function(packages)
{
    min_date = Sys.Date() - 1
    
    for (pkg in packages)
    {
      
        pkg_data = httr::GET(paste0("http://crandb.r-pkg.org/", pkg, "/all"))
        pkg_data <- jsonlite::fromJSON(rawToChar(pkg_data$content))
        
        initial_release = pkg_data$timeline[[1]]
        min_date = min(min_date, as.Date(initial_release))
    }
    
    min_date
}

# SHINY SERVER
shinyServer(function(input, output) {
    
    downloads <- reactive({
        packages <- input$pkgs
        cran_downloads0 <- purrr::possibly(cran_downloads, otherwise = NULL, quiet = TRUE) #another error handling method in R
        cran_downloads0(package = packages, 
                        from    = get_initial_release_date(packages), 
                        to      = Sys.Date()-1)
    })
    
    #output$cal_init <- renderUI({
        #selectizeInput(inputId = "init_rel_date", label = "Initial release date", 
                       #as.Date(get_initial_release_date(packages) ), multiple = F) })
    
    #packages <- reactive({c(input$pkgs)})
    
    plot_container <- reactiveValues()
    
    #Plotting
    observeEvent(input$plot_button,{
      
      d <- downloads()
      
      if(isTRUE(input$smoothen)){
        
        d = d %>%
          group_by(package) %>%
          dplyr::mutate(count = zoo::rollmean(count, k = 3, fill='extend'))
        
        if (input$plot_freq == "week") {
          
          d$week_raw <- as.Date(lubridate::ceiling_date(d$date, "week"))
          date = as.data.frame(unique(d$week_raw))
          
          d = d %>% 
            group_by(year = year(date), week = week(date), package) %>% 
            summarise_if(is.numeric, sum)
          
          d = cbind(d, as.numeric(1))
          names(d)[ncol(d)] <- "control"
          
          suppressMessages ({
            date = as.data.frame(with(d, get_date(year = year, week = week, day = control)))
            d = cbind(d,date)
            names(d)[ncol(d)] <- "date"
            
          })
          
          
          d = janitor::clean_names(d) #some QC
          
          d = d %>%
            group_by(package) %>%
            dplyr::mutate(count = zoo::rollmean(count, k = 3, fill='extend'))
          
        } else if (input$plot_freq == "tw"){
          
          d$count= zoo::rollapply(d$count, 7, sum, fill=NA)
          
        } else if (input$plot_freq == "ytd") {
          
          d = d %>%
            group_by(package) %>%
            transmute(count=cumsum(count), date=date) 
          
          d = d %>%
            group_by(package) %>%
            dplyr::mutate(count = zoo::rollmean(count, k = 3, fill='extend'))
          
        }
        
      } else {
        
        if (input$plot_freq == "week") {
        
        d$week_raw <- as.Date(lubridate::ceiling_date(d$date, "week"))
        date = as.data.frame(unique(d$week_raw))
        
        d = d %>% 
          group_by(year = year(date), week = week(date), package) %>% 
          summarise_if(is.numeric, sum)
        
        d = cbind(d, as.numeric(1))
        names(d)[ncol(d)] <- "control"
        
        suppressMessages({
          date = as.data.frame(with(d, get_date(year = year, week = week, day = control)))
          d = cbind(d,date)
          names(d)[ncol(d)] <- "date"
        })
       
        
        d = janitor::clean_names(d) #some QC
        
      } else if (input$plot_freq == "tw"){
        
        d$count= zoo::rollapply(d$count, 7, sum, fill=NA)
        
      } else if (input$plot_freq == "ytd") {
        
        d = d %>%
          group_by(package) %>%
          transmute(count=cumsum(count), date=date)
        
        }
      }
      
      
      #packages <- input$pkgs
      #ird = get_initial_release_date(packages)
      
      if(input$theme == 'light'){
        
        if(is.vector(input$date_range) || input$time_range == 0 || input$year_range == 0){
          
          plot_container$plot = ggplot(d, aes(date, count, color = package)) + geom_line() + 
            xlab("Date") + scale_y_continuous(name="Number of downloads", labels = comma) + 
            scale_x_date( limits =  input$date_range )
          
        } else if (!is.vector(input$date_range) || input$time_range != 0 || input$year_range != 0){
          
          plot_container$plot = ggplot(d, aes(date, count, color = package)) + geom_line() + 
            xlab("Date") + scale_y_continuous(name="Number of downloads", labels = comma) + 
            scale_x_date( limits = c( (lubridate::today() - (input$time_range * 7 * input$year_range)),lubridate::today() ) )
          
        }
        
      } else {
        
        if(is.vector(input$date_range) || input$time_range == 0 || input$year_range == 0){
          
          plot_container$plot = ggplot(d, aes(date, count, color = package)) + geom_line() + dark_mode() +
            xlab("Date") + scale_y_continuous(name="Number of downloads", labels = comma) + 
            scale_x_date( limits =  input$date_range )
          
        } else if (!is.vector(input$date_range) || input$time_range != 0 || input$year_range != 0){
          
          plot_container$plot = ggplot(d, aes(date, count, color = package)) + geom_line() + dark_mode() +
            xlab("Date") + scale_y_continuous(name="Number of downloads", labels = comma) + 
            scale_x_date( limits = c( (lubridate::today() - (input$time_range * 7 * input$year_range)),lubridate::today() ) )
          
        }
        
      }
      
      })
    
    output$interactive_ggplot <- renderPlotly({
      plot_container$plot
    
    })
    
    output$download_plot <- downloadHandler(
      filename <- function() {
        paste0("Pkgs_plots", ".png", sep = "")},
      content <- function(file_norm){
        ggsave(file_norm, plot=plot_container$plot)
        })
    
    
    output$mytable <- DT::renderDataTable({
      
      d <- downloads()
      st = aggregate(d$count, list(d$package), FUN=mean)
      colnames(st) = c('Package','Daily_Mean')
      
      if (input$plot_freq == "week") {
        
        d$week_raw <- as.Date(lubridate::ceiling_date(d$date, "week"))
        date = as.data.frame(unique(d$week_raw))
        
        d = d %>% 
          group_by(year = year(date), week = week(date), package) %>% 
          summarise_if(is.numeric, sum)
        
        d = cbind(d, as.numeric(1))
        names(d)[ncol(d)] <- "control"
        
        date = as.data.frame(with(d, get_date(year = year, week = week, day = control)))
        d = cbind(d,date)
        names(d)[ncol(d)] <- "date"
        
        d = janitor::clean_names(d) #some QC
        
        st = aggregate(d$count, list(d$package), FUN=mean)
        colnames(st) = c('Package','Weekly_Mean')
        
      } else if (input$plot_freq == "tw"){
        
        d$count= zoo::rollapply(d$count, 7, sum, fill=NA)
        st = aggregate(d$count, list(d$package), FUN=mean, na.rm=TRUE)
        colnames(st) = c('Package','Trail_Weekly_Mean')
        
      } else if (input$plot_freq == "ytd") {
        
        d = d %>%
          group_by(package) %>%
          transmute(count=cumsum(count), date=date) 
        st = aggregate(d$count, list(d$package), FUN=mean)
        colnames(st) = c('Package','Cumulative_Mean')
        
      }
      
      DT::datatable(st, options = list(scrollX = TRUE),
                    rownames = FALSE) })
    
})
