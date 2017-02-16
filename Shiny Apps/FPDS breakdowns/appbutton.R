################################################################################
# Vendor Size Charts Interactive App
# L.Lipsey for DIIG May 2016
################################################################################

require(shiny)
require(ggplot2)
require(plyr)
require(dplyr)
require(scales)

################################################################################
# Visual settings for user interface
################################################################################

# defines a list of customers for use in the customer selectInput.
# defining it seperately isn't necessary and only saves typing it twice in the
# selectInput command in the ui section
customers <- c("Air Force", "Army", "Navy", "MDA", "DLA",
               "Military Health", "Other DoD")

# same thing for list of platform portfolios
vendorsize <- c("Big Five", "Large", "Medium", "Small")

# here's the ui section - visual settings for the plot + widgets
ui <- 
  
  
  fluidPage(
    fluidRow(
      
      # left column - column sizes should add up to 12, this one is 3 so
      # the other one will be 9
      column(3, align = 'center',
             
             br(), 
             
             # year slider
             sliderInput('Yr', "Year Range:",
                         min = 2000, max = 2015,
                         value = c(2000,2015),
                         step = 1, width = '100%', sep = ""),
             
             # Settings for Category select
             selectInput("Cat","Category",
                         c("Products", "Services", "R&D"),
                         multiple = TRUE,
                         selectize = FALSE,
                         selected = c("Products", "Services", "R&D"),
                         width = '100%',
                         size = 3),
             
             # Settings for Vendor Size checkbox group
             selectInput("VS","Vendor Size", vendorsize,
                         multiple = TRUE,
                         selectize = FALSE,
                         selected = vendorsize,
                         width = '100%',
                         size = 5),
             
             # br(), adds a blank line
             br(),
             
             # Settings for Customer select
             selectInput("Customer","Customer", customers,
                         multiple = TRUE,
                         selectize = FALSE,
                         selected = customers,
                         width = '100%',
                         size = 7),
             br(),
             
             downloadButton('PlotDownloadBtn',"Download Displayed Plot"),
             downloadButton('CSVDownloadBtn', 
                            "Download Displayed Data (csv)"),
             downloadButton('FullDownloadBtn',
                            "Download Full Data (csv)")
      ),
      
      
      # left column - column sizes should add up to 12, this one is 9 so
      # the other one will be 3 
      column(9, align = "center",
             plotOutput("plot")
      )
    )
    
    # end of ui section
  )


# server function starts

server <- function(input, output, session){

################################################################################
# Read in and clean up data
################################################################################      

# read in data            
FullData <- read.csv("CleanedVendorSize2.csv")

# rename MilitaryHealth to have a space
levels(FullData$Customer)[5] <- "Military Health"

# make Big Five the first category (so it displays at the top of the legend)
FullData$VendorSize <- relevel(FullData$VendorSize, "Big Five")

# Rescale total obligations variable (Amount) to units of $Billion
# Coll: look back at breakouts interactive to see similar code 
FullData$Amount <- FullData$Amount / 1000000000

# drop observations with NULL customer
FullData <- filter(FullData, Portfolio != "NULL")


# save FY as 2 digits instead of 4, for better visual scale
FullData$FY <- factor(substring(as.character(FullData$FY), 3, 4))

################################################################################
# Subset data based on user input
################################################################################

dataset <- reactive({
    
    ## subset by year, based on year slider ##
    # findInterval is a confusing (but supposedly faster-running) way to do this
    # that I found on google.  Probably a normal conditional test would be fine.
    shown <- filter(FullData,
                    findInterval((as.numeric(as.character(FY)))+2000,
                                 c(input$Yr[1], input$Yr[2]+1)) == 1L)
      
      ## subset data based on which categories the user selected ##
      
      # the selectInput widget holds the selected choices as a vector of
      # strings. This code checks whether the each observation is in the
      # selected categories, and discards it if isn't in all three.  The %in%
      # operator is a nice way to avoid typing lots of conditional tests all
      # strung together 
      shown <- filter(shown, VendorSize %in% input$VS &
                             Category %in% input$Cat &
                             Customer %in% input$Customer)
      
      # aggregate rows by summing Amount.  The only breakouts left will be the
      # ones in the .(  ) call - FY and VendorSize in this case
      shown <- ddply(shown, .(FY, Portfolio), summarize, Amount = sum(Amount))
      
      # return the subsetted dataframe to whatever called dataset()
      shown

# end of dataset() function      
})

################################################################################
# Set colors  
################################################################################
colorset <- 
  c(
    #Set Category Colors 
    "Aircraft and Drones" = "#554449", 
    "Electronics and Communications" = "#7C3772", 
    "Facilities and Construction" = "#36605a", 
    "Missile and Space Systems" = "#AD4545", 
    "Other Products" = "#008e9d", 
    "Weapons and Ammunition" = "#599a9e", 
    "Other R&D and Knowledge Based" = "#CE884E", 
    "Ships & Submarines" = "#63c5b8",
    "Land Vehicles" = "#C74F4F", 
    "Other Services" = "#628582")

nameset <- 
  c( 
    #Set Category Colors 
    "Aircraft and Drones" = "Aircraft and Drones", 
    "Electronics and Communications" = "Electronics and Communications", 
    "Facilities and Construction" = "Facilities and Construction", 
    "Missile and Space Systems" = "Missile and Space Systems", 
    "Other Products" = "Other Products", 
    "Weapons and Ammunition" = "Weapons and Ammunition", 
    "Other R&D and Knowledge Based" = "Other R&D and Knowledge Based", 
    "Ships & Submarines" = "Ships and Submarines",
    "Land Vehicles" = "Land Vehicles", 
    "Other Services" = "Other Services")

DIIGcolors <- scale_color_manual(values = colorset, name = NULL, labels = nameset)

################################################################################
# Build the plot for output
################################################################################

plotsettings <- reactive({
  p <- ggplot(data = dataset(),
              aes(x=FY,
                  group=Portfolio, fill = Portfolio)) +
    geom_bar(aes(weight=Amount), width=.7) +
    facet_wrap(~ Portfolio, nrow = 2) + 
    
    theme(strip.text.x = element_text(family = "Arial", size = 10, color = "white")) + 
    theme(strip.background = element_rect(fill=c("#786F73"
                                                 ))) + 

    #coll: Added title 
    ggtitle("Contract Obligations by Platform Portfolio") + 
    theme(plot.title = element_text(
      family = "Arial", color = "#554449", size = 26, face="bold", margin=margin(20,0,30,0))) + 

    #coll: Custom background color/layout 
    theme(panel.border=element_blank(), 
          panel.background = element_blank(),
          panel.grid.major.x = element_blank(), 
          panel.grid.minor.x = element_blank(), 
          panel.grid.major.y = element_line(size=.1, color="grey80"), 
          panel.grid.minor.y = element_line(size=.1, color="grey80")) + 
    
    scale_fill_manual(values=c("#554449",
                                 "#7C3772",
                                 "#36605a", 
                                 "#AD4545", 
                                 "#008e9d",
                                 "#599a9e",
                                 "#CE884E",
                                 "#63c5b8",
                                 "#C74F4F",
                                 "#628582")) + 
    
    theme(legend.position="none") + 
    theme(legend.text = element_text(size = 18, color="#554449")) +
    theme(legend.title = element_text(size = 18, face = "bold", color="#554449")) +
    theme(legend.key = element_rect(fill="white")) +
    theme(legend.key.width = unit(3,"line")) +
    theme(axis.text.x = element_text(size = 08, color="#554449", margin=margin(-5,0,0,0))) +
    theme(axis.ticks.length = unit(.00, "cm")) +
    theme(axis.text.y = element_text(size = 14, color="#554449", margin=margin(0,5,0,0))) +
    theme(axis.title.x = element_text(size = 16, face = "bold", color="#554449", margin=margin(15,0,0,0))) +
    theme(axis.title.y = element_text(size = 16, face = "bold", color="#554449", margin=margin(0,15,0,0))) +
    xlab("Fiscal Year") +
    ylab("Constant 2015 $ Billion") 
  
  
  p     
})


################################################################################
# Run download buttons
################################################################################

# run csv download button
output$CSVDownloadBtn <- downloadHandler(
  filename = paste('DoD contract shares ', Sys.Date(),'.csv', sep=''),
  content = function(file) {
    writedata <- dataset()
    writedata$FY <- as.numeric(as.character(writedata$FY)) + 2000
    writedata$Percent <- writedata$Percent * 100
    writedata <- select(writedata, FY, Customer, Amount, Percent)
    write.csv(writedata, file)
  }
)

################################################################################
# Output the built plot and start the app
################################################################################


output$plot <- renderPlot({
  plotsettings()
}, height = 600) 



}

# starts the app
shinyApp(ui= ui, server = server)
