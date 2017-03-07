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
      titlePanel("FPDS breakouts"),
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
        selectInput(
          inputId = "y_var",
          label = "Y Variable",
          choices = "Action.Obligation",
          selected = "Action.Obligation",
          width = "100%",
          selectize = TRUE
        ),
        selectInput(
          inputId = "color_var",
          label = "Color Breakout Variable",
          choices = "None",
          selected = "None",
          width = "100%",
          selectize = TRUE
        ),
        selectInput(
          inputId = "facet_var",
          label = "Facet Breakout Variable",
          choices = "None",
          selected = "None",
          width = "100%",
          selectize = TRUE
        )
      )
    ),
    mainPanel(
      plotOutput("plot"),
      width = 8
    )
  )
))