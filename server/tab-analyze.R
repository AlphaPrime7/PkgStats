downloads <- reactive({
  packages <- input$pkgs
  cran_downloads0 <- purrr::possibly(cran_downloads, otherwise = NULL, quiet = TRUE)
  req(packages)
  cran_downloads0(package = packages, 
                  from    = get_initial_release_date(packages), 
                  to      = Sys.Date()-1)
})
plot_container <- reactiveValues()

observeEvent(input$plot_button,{
  req(downloads())
  d <- downloads()
  
  if(isTRUE(input$smoothen)){
    
    d = d %>%
      group_by(package) %>%
      dplyr::mutate(count = zoo::rollmean(count, k = 3, fill='extend'))
    d <- d %>% mutate(across(where(is.numeric), round, 0))
    
    if (input$plot_freq == "week") {
      
      d$week_raw <- as.Date(lubridate::ceiling_date(d$date, "week"))
      #d$week_num = strftime(d$date, format = "%V")
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
  
  suppressWarnings({
    req(downloads())
    d <- downloads()
    st = aggregate(d$count, list(d$package), FUN=mean)
    colnames(st) = c('Package','Daily_Mean')
    st <- st %>% mutate(across(c('Daily_Mean'), round, 0))
    
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
      st <- st %>% mutate(across(c('Weekly_Mean'), round, 0))
      
    } else if (input$plot_freq == "tw"){
      
      d$count= zoo::rollapply(d$count, 7, sum, fill=NA)
      st = aggregate(d$count, list(d$package), FUN=mean, na.rm=TRUE)
      colnames(st) = c('Package','Trail_Weekly_Mean')
      st <- st %>% mutate(across(c('Trail_Weekly_Mean'), round, 0))
      
    } else if (input$plot_freq == "ytd") {
      
      d = d %>%
        group_by(package) %>%
        transmute(count=cumsum(count), date=date) 
      st = aggregate(d$count, list(d$package), FUN=mean)
      colnames(st) = c('Package','Cumulative_Mean')
      st <- st %>% mutate(across(c('Cumulative_Mean'), round, 0))
      
    }
    
    DT::datatable(st, options = list(scrollX = TRUE),
                  rownames = FALSE) })
  
})
