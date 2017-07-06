################################################################################
# Sequestration App
################################################################################
rm(list = ls())
require(shiny)
require(ggplot2)
require(dplyr)
require(scales)
require(gridExtra)
require(grid)
require(Cairo)
library(forcats)

################################################################################
# Visual settings for user interface
################################################################################


Portfolio <- c("Aircraft and Drones", 
               "Electronics and Communications",
               "Facilities and Construction", 
               "Land Vehicles",
               "Missile and Space Systems",
               "Ships & Submarines", 
               "Weapons and Ammunition", 
               "Other Products",
               "Other R&D and Knowledge Based", 
               "Other Services",
               "NULL")

IsSubContract <- c("Prime Contract",
                 "SubContract")

Customer <- c("Army",
               "Navy", 
               "Air Force", 
               "MDA", 
               "DLA",
               "Other DoD")
  
Faceting <- c("AllPrimes",
              "PrimeReportInFSRS",
              "SubReportInFSRS")

# here's the ui section - visual settings for the plot + widgets

ui <- fluidPage(
  
  
  ####CSS Import of Google Font "Open Sans" for body  
  tags$style(HTML("
                  @import url('//fonts.googleapis.com/css?family=Open+Sans');
                  
                  body {
                  font-family: 'Open Sans',  sans-serif;
                  font-weight: 500;
                  line-height: 1.1;
                  color: #554449;
                  }
                  
                  ")),
  tags$head(
    tags$style(HTML("body{background-color: #fcfcfc;}"))),
  tags$div(HTML("<div class='fusion-secondary-header'>
                <div class='fusion-row'>
                <div class='fusion-alignleft'><div class='fusion-contact-info'><center style=' padding:20px;'><a href='http://csis.org/program/international-security-program' target='_blank'><img class='logo' src='https://defense360.csis.org/wp-content/uploads/2015/08/ISP_new.png' width='40%'></a></center><a href='mailto:'></a></div></div>
                </div>
                </div>")),
  tags$style(HTML(".fusion-secondary-header {border-bottom: 3px solid #6F828F}")),
  br(), 
  ####Copy below to change slider color     
  tags$style(HTML(".irs-bar {background: #63c5b8}")),
  tags$style(HTML(".irs-bar {border-top: 1px #63c5b8}")),
  tags$style(HTML(".irs-bar {border-bottom: 1px #63c5b8}")),
  tags$style(HTML(".irs-single, .irs-to, .irs-from {background: #628582}")),
  #tags$style(HTML(".irs-slider {background: black}")),
  #  tags$style(HTML(".irs-grid-pol {display: absolute;}")),
  tags$style(HTML(".irs-max {color: #554449}")),
  tags$style(HTML(".irs-min {color: #554449}")),
  tags$style(HTML(".irs-bar-edge {border: 1px #63c5b8}")),
  tags$style(HTML(".irs-bar-edge {border-color: 1px #63c5b8}")),
  tags$style(HTML(".irs-bar-edge {border-color: 1px #63c5b8}")),
  ####  
  
  fluidRow(
    
    # left column - column sizes should add up to 12, this one is 3 so
    # the other one will be 9
    column(3, align = 'center',
           br(),
           
           # year slider
           sliderInput('Yr', "Year Range:",
                       min = 2008, max = 2016,
                       value = c(2008,2016),
                       ticks = FALSE,
                       step = 1, width = '100%', sep = ""),
           
           selectInput("Portfolio","Platform Portfolio",
                       Portfolio,
                       multiple = TRUE,
                       selectize = FALSE,
                       selected = Portfolio,
                       width = '100%'),
#           selectInput("IsSubContract","Sub or Prime Contract",
#                       IsSubContract,
#                       multiple = TRUE,
#                       selectize = FALSE,
#                       selected = IsSubContract,
#                       width = '100%'),
          selectInput("Customer", "Customer", 
                       Customer, 
                       multiple = TRUE,
                       selectize = FALSE,
                       selected = Customer,
                       width = '100%')),

    # left column - column sizes should add up to 12, this one is 9 so
    # the other one will be 3 
    column(9, align = "center",
           div(
             style = "position:relative",
             plotOutput("plot") 
                      #  hover = hoverOpts(id = "plot_hover", delay = 30))
           )   #uiOutput("hover_info")
    )
 )
)

  
  # end of ui section
  
# server function starts

server <- function(input, output, session){
  
  ################################################################################
  # Read in and clean up data
  ################################################################################      
  
  # read in data            
  FullData <- read.csv("Sequestration_Duplicates.csv",header = TRUE, sep = ",")
  
  # rename MilitaryHealth to have a space
  #levels(FullData$Customer)[5] <- "Military Health"
  FullData$SubCustomer[FullData$Customer == "MilitaryHealth"] <- "Other DoD"  
  
  # make Big Five the first category (so it displays at the top of the legend)
  # FullData$VendorSize <- relevel(FullData$VendorSize, "Big Five")
  
  # save FY as 2 digits instead of 4, for better visual scale
  #FullData$FY <- factor(substring(as.character(FullData$FY), 3, 4))
  
  ################################################################################
  # Subset data based on user input
  ################################################################################
  
  dataset <- reactive({
    
    ## subset by year, based on year slider ##
    
    # input$Yr[1] is the user-selected minimum year
    # input$Yr[2] is the user-selected maximum year
    # as.numeric(levels(FY))[FY] is just FY, converted from a factor to
    # a numeric variable
    shown <- filter(FullData, fiscal_year >= input$Yr[1] & fiscal_year <= input$Yr[2])
    
    
    ## subset data based on which categories the user selected ##
    
    # the selectInput widget holds the selected choices as a vector of
    # strings. This code checks whether the each observation is in the
    # selected categories, and discards it if isn't in all three.  The %in%
    # operator is a nice way to avoid typing lots of conditional tests all
    # strung together 
    shown <- filter(shown, Portfolio %in% input$Portfolio &
#                      IsSubContract %in% input$IsSubContract &
                      Customer %in% input$Customer
    )
    
#    shown <- shown %>%
#      group_by(fiscal_year, Faceting) %>%
#      summarise(Amount = sum(PrimeOrSubTotalAmount))
    
    #shown <- shown %>%
    #  group_by(FY) %>%
    #  mutate(Percent = Amount / sum(Amount))
    
#    shown <- shown %>%
#      filter(!is.na(Faceting))
    
    
    #shown$VendorSize <- fct_reorder(
    #  shown$VendorSize,
    #  (shown$Percent * (shown$FY == input$Yr[2])) ,
    #  mean,
    #  na.rm = TRUE,
    #  .desc = TRUE)
    
    # return the subsetted dataframe to whatever called dataset()
    return(shown)
    
    # end of dataset() function      
  })
  
  
  ################################################################################
  # Build the plot for output
  ################################################################################
  
#  plotsettings <- reactive({
#    p <- ggplot(data = dataset(),
#                aes(x=FY, y=Percent, 
#                    color=VendorSize, group=VendorSize, fill = VendorSize)) +
#      geom_line(size = 1.5) +
#      
#      #coll: Added title 
#      ggtitle("Contract Obligations by Vendor Size") + 
#      scale_color_manual(
#        values = c(
#          "Big Five" = "#C74F4F",
#          "Large" =  "#5F597C",
#          "Medium" = "#599a9e",
#          "Small" = "#84B564")) +
#      ########################################################################################share below
#      
#      # diigtheme1:::diiggraph()+ 
#      theme(plot.title = element_text(
#        family = "Open Sans", color = "#554449", size = 26, face="bold",
#        margin=margin(20,0,30,0), hjust = 0.5)) +
      
#      coord_cartesian(ylim = c(0, 1.05*max(dataset()$Percent))) +  
#      
#      theme(panel.border = element_blank(),
#            panel.background = element_rect(fill = "#FCFCFC", color="#FCFCFC"),
#            plot.background = element_rect(fill = "#FCFCFC", color="#FCFCFC"),
#            #plot.background = element_rect(fill="#F9FBFF"), second choic
#      plot.background = element_rect(fill="#EFF1F5"),
            #plot.background = element_rect(fill="#ECF2F5"),
#            panel.grid.major.x = element_blank(),
#            panel.grid.minor.x = element_blank(),
#            panel.grid.major.y = element_line(size=.1, color="lightgray"),
#            panel.grid.minor.y = element_line(size=.1, color="lightgray")) +
      
#      scale_y_continuous(labels=percent) +
#      scale_x_continuous(breaks = seq(input$Yr[1], input$Yr[2], by = 1),
#                         labels = function(x) {substring(as.character(x), 3, 4)}) +
      
      
      
#      theme(legend.position = "right") +
#      theme(legend.title=element_blank()) +
#      theme(legend.text = element_text(size = 18, color="#554449")) +
      # theme(legend.title = element_text(size = 18, face = "bold", color="#554449")) +
#      theme(legend.key = element_rect(fill="#FCFCFC")) +
#      theme(legend.background = element_rect(fill="#FCFCFC")) + 
#      theme(legend.key.width = unit(3,"line")) +
#      theme(axis.text.x = element_text(size = 14, color="#554449", margin=margin(-10,0,0,0))) +
#      theme(axis.ticks.length = unit(.00, "cm")) +
#      theme(axis.text.y = element_text(size = 14, color="#554449", margin=margin(0,5,0,0))) +
#      theme(axis.title.x = element_text(size = 16, face = "bold", color="#554449", margin=margin(15,0,0,0))) +
#      theme(axis.title.y = element_text(size = 16, face = "bold", color="#554449", margin=margin(0,15,0,0))) +
      
#      xlab("Fiscal Year") +
#      ylab("Share of Contract Obligations") +
#      theme(plot.caption = element_text(
#        size = 12, face = "bold", color = "#554449", family = "Open Sans"
#      )) +
#      labs(caption = "Source: FPDS; CSIS analysis", size = 30, family= "Open Sans")  
    ########################################################################################share above
    # return the built-up plot object to whatever called plotsettings() 
    # currently the renderPlot() function below is the only thing that calls it
    
    
#    p         
#  })
  
  plotsettings2 <- reactive({
    
    # # calculate breaks for x axis
    # xbreaks <- rev(seq(
    #   from = input$Yr[2],
    #    to = input$Yr[1],
    #    by = -1 * ceiling((input$Yr[2] - input$Yr[1]) / 7)))
    # 
    # xlabels <- as.character(xbreaks)
    
    
    # ggplot call
    
    p <- ggplot(data = dataset(),
                aes(x=fiscal_year, 
                    y=PrimeOrSubTotalAmount,
                    fill = FacetingFill)) +
      geom_bar(width=.7,stat="identity") +
      ggtitle("Contract Obligations by whether in FSRS or is Subcontract") +
      
      facet_wrap(~ Faceting, ncol = 2, scales="free_y", 
                 drop = TRUE) + 
      
      scale_fill_manual(
        values = c(
          # "AllPrimes" = "#33FF66",
          "PrimeNotReportInFSRS" =  "#33FF66",
          "PrimeReportInFSRS" =  "#0066FF",
          "SubReportInFSRS" = "#FF6699")) +


      theme(strip.text.x = element_text(family = "Arial", size = 12, color = "#554449")) +
      theme(strip.background = element_rect(color = "gray95", fill=c("white"
      ))) +
      
      theme(panel.spacing.y = unit(1, "lines")) +
      
      #coll: Added title 
      ##############################################################################facet below 
      theme(plot.title = element_text(
        family = "Arial", color = "#554449", size = 26, face="bold",
        margin=margin(20,0,30,0), hjust = 0.5)) +
      
      theme(panel.border = element_blank(),
            panel.background = element_rect(fill = "#FCFCFC"),
            plot.background = element_rect(fill = "#FCFCFC", color="#FCFCFC"),
            #plot.background = element_rect(fill="#F9FBFF"), second choice
            #plot.background = element_rect(fill="#EFF1F5"),
            #plot.background = element_rect(fill="#ECF2F5"),
            panel.grid.major.x = element_blank(),
            panel.grid.minor.x = element_blank(),
            panel.grid.major.y = element_line(size=.1, color="lightgray"),
            panel.grid.minor.y = element_line(size=.1, color="lightgray")) +
      
      #scale_x_continuous() +
      scale_x_continuous(breaks = seq(input$Yr[1], input$Yr[2], by = 1),
                         labels = function(x) {substring(as.character(x), 3, 4)}) +
      
      
      
      theme(legend.position="none") +
      theme(strip.background = element_rect(color = "gray95", fill=c("#fcfcfc"))) +
      theme(strip.text.x = element_text(family = "Open Sans",
                                        size = rel(1.7),
                                        color = "#554449")) +
      theme(legend.text = element_text(size = 18, color="#554449")) +
      theme(legend.title = element_text(size = 18, face = "bold", color="#554449")) +
      theme(legend.key = element_rect(fill="#fcfcfc")) +
      theme(legend.key.width = unit(3,"line")) + 
      theme(axis.text.x = element_text(size = 14, color="#554449", margin=margin(-5,0,0,0))) +
      theme(axis.ticks.length = unit(.00, "cm")) +
      theme(axis.text.y = element_text(size = 14, color="#554449", margin=margin(0,5,0,0))) +
      theme(axis.title.x = element_text(size = 16, face = "bold", color="#554449", margin=margin(15,0,0,0))) +
      theme(axis.title.y = element_text(size = 16, face = "bold", color="#554449", margin=margin(0,15,0,0))) +
      
      xlab("Fiscal Year") +
      ylab("DoD Contract Obligated Amount in billion $") +
      theme(plot.caption = element_text(
        size = 12, face = "bold", color = "#554449", family = "Open Sans"
      )) +
      labs(caption = "Source: FPDS; CSIS analysis", size = 30, family= "Open Sans") 
    ##############################################################################facet above
    
    p     
  })
  
  
  
  ################################################################################
  # Output the built plot and start the app
  ################################################################################
  
  
  output$plot <- renderPlot({
          plotsettings2()},height = 700) 
  
#  output$CSVDownloadBtn <- downloadHandler(
#    filename = paste('CSIS-Contract-Obligations-by-Vendor-Size-', Sys.Date(),'.csv', sep=''),
#    content = function(file) {
#      writedata <- dataset()
#      writedata$Percent <- writedata$Percent * 100
#      write.csv(writedata, file)
#    }
#  )
  
  
  # run full data download button
#  output$FullDownloadBtn <- downloadHandler(
#    filename = paste('CSIS.Contract Obligations by Vendor Size.', Sys.Date(),'.csv', sep=''),
#    content = function(file) {
#      writedata <- FullData
#      writedata <- select(writedata, FY, VendorSize, Customer, Category,
#                          Portfolio, Amount)
#      write.csv(writedata, file)
#    }
#  )
  
  # run displayed data download button
  #output$CSVDownloadBtn <- downloadHandler(
  #    filename = paste('DoD contract shares ', Sys.Date(),'.csv', sep=''),
  #    content = function(file) {
  #        writedata <- dataset()
  #        writedata$FY <- as.numeric(as.character(writedata$FY)) + 2000
  #        writedata$Percent <- writedata$Percent * 100
  #        writedata <- select(writedata, FY, VendorSize, Amount, Percent)
  #        write.csv(writedata, file)
  #    }
  #)
  
  ##############################################################################
  # Give details when user hovers the plot
  # See https://gitlab.com/snippets/16220
  ##############################################################################
  
  
#  output$hover_info <- renderUI({
#    hover <- input$plot_hover
    
#    if(is.null(hover)) return(NULL)
    
#    switch(
#      input$Chart,
#      "Line" = {
#        point <- nearPoints(dataset(), hover, xvar = "FY", yvar = "Percent",
#                            threshold = (150 / (input$Yr[2] - input$Yr[1])) + 10,
#                            maxpoints = 1, addDist = TRUE)
#      },
#      "Bar" = {
#        point <- nearPoints(dataset(), hover, xvar = "FY", yvar = "Amount",
#                            threshold = 200,
#                            maxpoints = 1, addDist = TRUE)
#      }
#    )
    
#    if(nrow(point) == 0) return(NULL)
    
#    if(input$Chart == "Bar"){
#      year <- round(hover$x)
#      if(year < input$Yr[1] | year > input$Yr[2]) return(NULL)
#      if(hover$y < 0) return(NULL)
      
#      hov_amount <- dataset() %>%
#        filter(FY == year & VendorSize == point$VendorSize) %>%
#        .$Amount %>%
#        unlist
      
#      hov_percent <- dataset() %>%
#        filter(FY == year & VendorSize == point$VendorSize) %>%
#        .$Percent %>%
#        unlist
      
#      if(hover$y > hov_amount) return(NULL)
#    } else {
#      year <- point$FY
#      hov_amount <- point$Amount
#      hov_percent <- point$Percent
#    }
    
    # calculate point position INSIDE the image as percent of total dimensions
    # from left (horizontal) and from top (vertical)
#    left_pct <- (hover$x - hover$domain$left) /
#      (hover$domain$right - hover$domain$left)
#    top_pct <- (hover$domain$top - hover$y) /
#      (hover$domain$top - hover$domain$bottom)
    
#     calculate distance from left and bottom side of the picture in pixels
#    left_px <- hover$range$left + left_pct *
#      (hover$range$right - hover$range$left)
#    top_px <- hover$range$top + top_pct *
#      (hover$range$bottom - hover$range$top)
    
    # Use HTML/CSS to change style of tooltip panel here
#    style <- paste0(
#      "position:absolute; z-index:100; background-color: rgba(245, 245, 245, 0.85); ",
#      "left:", left_px + 2, "px; top:", top_px + 2, "px;")
    
#    wellPanel(
#      style = style,
#      p(HTML(paste0("<b> Fiscal Year: </b>", year, "<br/>",
#                    "<b> Vendor Size: </b>", point$VendorSize, "<br/>",
#                    "<b> Share: </b>", round(hov_percent*100,1), "%<br/>",
#                    "<b> Amount: </b> $",
#                    round(hov_amount,2),  " Billion")))
#    )
#  })
  # end of the server function
}



# starts the app
shinyApp(ui= ui, server = server)






























