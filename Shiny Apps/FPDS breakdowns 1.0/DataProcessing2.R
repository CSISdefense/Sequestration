#I dropped the second line because of a null# 
data <- read.csv("data2.csv",
                  na.strings = c("NULL"))

names(data) <- c("FY",
                 "Customer", 
                 "SubCustomer", 
                 "Category", 
                 "Portfolio", 
                 "VendorSize", 
                 "Competition", 
                 "Offers",
                 "Amount", 
                 "Actions")

write.csv(data, "data3.csv")