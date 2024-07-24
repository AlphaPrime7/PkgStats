tabPanel(
  title = "About",
  id = "aboutTab",
  value = "aboutTab",
  name = "aboutTab",
  class = "fade",
  icon = icon("info-circle"),
  shiny::includeMarkdown(file.path("text","about.md")),
  h2("Version"),
  "PkgStats version", as.character(1.00)
)