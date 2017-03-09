################################################################################
# FPDS breakdowns 2.0 app - March 2017
#
# ui.R
################################################################################

library(shiny)
library(tidyverse)

shinyUI(fluidPage(
  
  sidebarLayout(
    sidebarPanel(
      titlePanel("FPDS Charts"),
      wellPanel(
        sliderInput(
          inputId ="year",
          label = "Years",
          min = 2000,
          max = 2016,
          value = c(2010,2015)
        )
      ),
      wellPanel(
        radioButtons(
          inputId = "chart_geom",
          label = NULL,
          choices = c("Bar Chart", "Line Chart"),
          selected = "Line Chart"
        ),
        selectInput(
          inputId = "color_var",
          label = "Color Breakout",
          choices = "None",
          selected = "None",
          width = "100%",
          selectize = TRUE
        ),
        selectInput(
          inputId = "facet_var",
          label = "Facet Breakout",
          choices = "None",
          selected = "None",
          width = "100%",
          selectize = TRUE
        )
      ),
      wellPanel(
        selectInput(
          inputId = "y_var",
          label = "Y Variable",
          choices = "Action.Obligation",
          selected = "Action.Obligation",
          width = "100%",
          selectize = TRUE
        ),
        radioButtons(
          inputId = "y_total_or_share",
          label = NULL,
          choices = c("As Total", "As Share"),
          selected = "As Total"
        )
      )
    ),
    mainPanel(
      plotOutput("plot"),
      width = 8
    )
  )
))