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

analyze_runtime = function(){
  profvis::profvis(shiny::runApp())
}

get_package_names = function(){
  description <- sprintf("%s/web/packages/packages.rds", getOption("repos", "https://cran.rstudio.com/")["CRAN"])
  con <- if(substring(description, 1L, 7L) == "file://"){
    file(description, "rb")
  } else {
    url(description, "rb")
  }
  on.exit(close(con))
  db <- readRDS(gzcon(con, level = 6, allowNonCompressed = TRUE))
  rownames(db) <- NULL
  db = db[, c("Package", "Title")]
  db = as.vector(db[,1])
  
  return(db)
}