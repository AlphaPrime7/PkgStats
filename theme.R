library(fresh)
create_theme(
  theme = "default",
  bs_vars_navbar(
    default_bg = "#3f2d54",
    default_color = "#6f2d58",
    default_link_color = "#FFFFFF",
    default_link_active_color = "#FFFFFF"
  ),

  bs_vars_wells(
    bg = "#FFF",
    border = "#3f2d54"
  ),
  
  output_file = "www/mytheme.css"
)
