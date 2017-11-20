################################################################################
# Functions for FPDS breakdowns 2.0 Shiny App - March 2017
# Add stacked plots and drawdown period lines - Oct 2017
################################################################################

library(magrittr)
library(dplyr)
library(lazyeval)
library(forcats)

populate_ui_var_lists <- function(
  # Fills the ui menus with appropriate variables from the tibble passed to it
  #
  # Args:
  data_source,    # tibble from which to populate the ui menus
  session = getDefaultReactiveDomain()  # shiny app session
  ){

  # get the class for each variable (except fiscal year)
  var_class <- sapply(data_source, class)

  # put numeric variables in the y_var list
  numerics <- names(data_source)[
    (var_class == "numeric" | var_class == "integer") & colnames(data_source)!="Fiscal.Year"]
  updateSelectInput(session, "y_var",
                    choices = numerics,
                    selected = "Action.Obligation.2016")

  # put categorical variables in the color_var and facet_var lists
  categories <- names(data_source)[var_class == "factor"]
  categories <- c("None", categories)
  updateSelectInput(session, "color_var", choices = categories)
  updateSelectInput(session, "facet_var", choices = categories)
}

#Extract a legend
# https://stackoverflow.com/questions/43366616/ggplot2-legend-only-in-a-plot
# Alternate unused approach From https://github.com/tidyverse/ggplot2/wiki/Share-a-legend-between-two-ggplot2-graphs

g_legend<-function(a.gplot){
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)}


#When facet !="None"
# theme(strip.background = element_rect(colour = "#554449", fill = "white", size=0.5),
      # panel.border = element_rect(colour = "#554449", fill=NA, size=0.5)) +
  
add_period <- function(
  # Args:
  main_plot,    # a plot of the data, should be drawn using build_plot
  plot_data,
  chart_geom, #Line chart or bar chart
  text=TRUE #Whether or not to show period names
  #
  # Returns:
  #   A ggplot object including user-specified geom layer
  ){

  # add 4 drawdown periods
    # specify four drawdown periods
    period <- c("Pre-drawdown", "Start of Drawdown", "BCA deline period", "Current")
    startFY <- c(2009, 2011, 2013, 2016)
    endFY <- c(2010,2012,2015,2016)
    drawdownpd <- data.frame(period, startFY, endFY)
    if(chart_geom == "Line Chart") {
      main_plot <-main_plot+
      geom_vline(data=drawdownpd, mapping=aes(xintercept=startFY, color=period),
                 linetype='dashed',size=0.2) +
      geom_text(data=drawdownpd,mapping=aes(x=startFY,
                                            label=period),
                y=(range(plot_data[,ncol(plot_data)])[1]),
                colour='#808389', size=3, angle=90, vjust=1.2, hjust=0)
    } else {
      main_plot <- main_plot+
        geom_vline(data=drawdownpd, mapping=aes(xintercept=startFY-0.5),
                   linetype='dashed',size=0.2) +
        geom_text(data=drawdownpd,mapping=aes(x=startFY, 
                                              label=period),
                  # y=(range(plot_data[,ncol(plot_data)])[1]),
                  colour='#808389', size=3, angle=90, vjust=-0.5, hjust=0)
    }
    main_plot
}


populate_edit_var <- function(
  # Populates the edit_var element on the edit page, based on the current data

  # Args:
  current_data,    # the current data for the app
  input,           # shiny input object
  session = getDefaultReactiveDomain() # shiny app session
  ){

  # insert the variable selection list
  insertUI(
    selector = "#edit_var_placeholder",
    ui = tags$div(
      selectInput(
        inputId = "edit_var",
        label = "Variables",
        choices = names(current_data),
        selected = names(current_data)[1],
        multiple = FALSE,
        selectize = FALSE,
        size = length(names(current_data))
      ),
      id = "edit_var_select"
    )
  )


  # update the variable renaming text box
  updateTextInput(
    session,
    inputId = "rename_var_txt",
    value = names(current_data)[1]
  )

}


create_edit_values_list <- function(
  # creates the list of values available for editing, when the user changes the
  # variable they are examining
  #
  # Args:
  current_data,  # current data frame in the app
  input,         # shiny input object
  session = getDefaultReactiveDomain()  # shiny session object
  ){


  edit_var_class <- class(unlist(
    current_data[which(names(current_data) == input$edit_var)]
  ))

  if(edit_var_class != "factor") {
    values_shown <- "*Not a Category Variable*"

    insertUI(
      selector = "#edit_value_placeholder",
      ui = tags$div(
        selectInput(
          inputId = "edit_value",
          label = "Values",
          choices = values_shown,
          multiple = FALSE,
          selectize = FALSE,
          size = 2
        ),
        id = "edit_value_select"
      )
    )
  } else {
    values_shown <- levels(unlist(
      current_data[which(names(current_data) == input$edit_var)]))

    insertUI(
      selector = "#edit_value_placeholder",
      ui = tags$div(
        selectInput(
          inputId = "edit_value",
          label = "Values",
          choices = values_shown,
          multiple = FALSE,
          selectize = FALSE,
          size = length(values_shown)
        ),
        id = "edit_value_select"
      )
    )
  }

  # update the rename text box
  updateTextInput(
    session,
    inputId = "rename_value_txt",
    value = values_shown[1]
  )

}


clear_edit_ui <- function(
  # removes the variable and value selection selectInputs from the Edit Data tab
  #
  # Args:
  input,    # shiny input object
  session = getDefaultReactiveDomain()  # shiny session object
  ){

  removeUI(
    selector = "#edit_value_select",
    multiple = TRUE,
    immediate = TRUE
  )

  removeUI(
    selector = "#edit_var_select",
    multiple = TRUE,
    immediate = TRUE
  )

}

drop_from_frame <- function(
  # filters out and drops factor levels from a factor in a data frame
  #
  # Args:
  passed_frame,    # the data frame, as an object
  passed_var,   # the name of the variable, as a string
  passed_levels,    # the name of the levels to drop, as a string
  session = getDefaultReactiveDomain()    # shiny session object
  #
  # Returns:
  #   The data frame with the factor level removed
){
  # stack overflow: https://tinyurl.com/mtys7xo
  passed_frame %<>%
    filter_(interp(~!val %in% passed_levels, val = as.name(passed_var)))

  passed_frame[[passed_var]] <- fct_drop(passed_frame[[passed_var]])

  return(passed_frame)
}




update_title <- function(
  # populates the title field with a dynamic title, if appropriate
  #
  # Args:
  passed_data,   # the data used in the plot
  input,    # shiny input object
  user_title,   # "None" unless the user has manually entered a title
  session = getDefaultReactiveDomain()   # shiny session object
  #

){
  if(user_title != "None") {
    updateTextInput(session, "title_text", value = user_title)
    return()
    }

  title <- input$y_var
  if(input$color_var != "None"){
    if(input$facet_var != "None"){
      title <- paste(
        title, "by", input$color_var, "and", input$facet_var)
    } else {
      title <- paste(title, "by", input$color_var)
    }
  } else if(input$facet_var != "None"){
    title <- paste(title, "by", input$facet_var)
  }

  # check for a single-level filter
  cats <- names(passed_data)[sapply(passed_data, class) == "factor"]
  for(i in seq_along(cats)){
    if(length(unique(passed_data[[i]])) == 1){
      title <- paste(unlist(unique(passed_data[[i]])), title)
    }
  }

  if(input$y_total_or_share == "As Total") title <- paste("Total", title)
  if(input$y_total_or_share == "As Share") title <- paste("Share of", title)

  updateTextInput(session, "title_text", value = title)

}


rename_value <- function(
  # Renames a factor level to user-specified name, in the passed data frame
  #
  # Args:
  passed_data,    # the data frame in which to rename the value
  input,     # shiny input object
  session = getDefaultReactiveDomain()    # shiny session object
  #
  # Returns: a data frame with the factor level renamed
){
  levels(passed_data[[input$edit_var]])[levels(passed_data[[
        input$edit_var]]) == input$edit_value] <- input$rename_value_txt

  return(passed_data)
}
