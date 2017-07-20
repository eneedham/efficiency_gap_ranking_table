#clear the workspace
rm(list = ls())

# set working directory for easy export of html widget
setwd("//FILESHARE/projects/Azavea_CartographicServices/_ContentMarketing/2017_EfficiencyGap/data")

#you might need this if your script won't automatically recognize piping %>%
install.packages("magrittr")
library(magrittr)

#necessary for the googlesheets package. It should automatically insall but in case it doesn't, try doing it manually
install.packages("dplyr")
library(dplyr)

#use this package to access data stored in googlesheets
install.packages("googlesheets")
library(googlesheets)


# Getting Data from Googlesheets ------------------------------------------

#get a list of all of the sheets in my google drive
(my_sheets <- gs_ls())

#get info about the googlesheet
gs_ls("Efficiency Gap Data")

#assign the sheet to a variable
gap_dat <- gs_title("Efficiency Gap Data")

#get a list of the tabs in the gap_dat variable
gs_ws_ls(gap_dat)

#create a dataframe of the tab that you are working with
## note that the file name, tab names, and field names, if changed on the google sheet, will need to be changed in the script
dat <- gap_dat %>%
  gs_read(ws = "Esther's Graphic")

#create a shortened list of variables to include in the ggplot bar graph
graphic_dat <- dat[dat$Seat_Advantage > 0 ,c(1,2,3,6,7)]

#create a shortened list of variables to include in the table.
##Place the index numbers in the order you want them to appear in the table.
table_dat <- dat[c(1,2,3,5,7)]



# Table -------------------------------------------------------------------

#load datatables and html widgets packages
install.packages("DT")
install.packages("htmlwidgets")
library(DT)
library(htmlwidgets)


#create data table as R object
gap_rankings_table <-  datatable((table_dat), 
    colnames=c("State", "Partisan Advantage Ranking", "Seat Advantage", "Efficiency Gap", "Party Advantage"), 
    rownames = FALSE,
    options = list(
      autoWidth = TRUE,
      columnDefs = list(list(width = '10%', targets = 0), list(width = '20%', targets = c(1,2,3,4)), (list(className = 'dt-center', targets = c(1,2,3,4)) )),
      # scrollX=FALSE,scrollY=0,
      # scrollX=FALSE,scrollY=0,
      scrollCollapse=TRUE,
      pageLength = 50,
      order = list(list(2, 'Ranking')),
      initComplete = JS(
          "function(settings, json) {",
          "$(this.api().table().header()).css({'background-color': '#292D39', 'color': '#fff', 'font-family': 'helvetica'});",
          "}")
   )) %>%
  formatStyle(c('State', 'Ranking', 'Seat_Advantage', 'Efficiency Gap', 'Party_Advantage'), fontSize = '12px', fontFamily = 'helvetica') %>%
  formatStyle(c('State', 'Party_Advantage'), fontWeight = 'bold') %>%
  formatStyle(c('State', 'Ranking', 'Seat_Advantage', 'Efficiency Gap', 'Party_Advantage'),backgroundColor = styleEqual(c('Republican', 'Democrat'), c('#ff595f', '#45bae8')))%>%
  formatStyle('Party_Advantage',color = '#FFF')

#save the widget as an html page
saveWidget(gap_rankings_table, "gap_rankings_table.html", selfcontained = FALSE, libdir = "src")

# Bar Graph ---------------------------------------------------------------

install.packages("scales")
install.packages("ggplot2")
install.packages("plyr")
library(plyr)
library(ggplot2)
library(scales)

#also load the Azavea theme for easy ggplot styling
install.packages("devtools")
library(devtools)
install("//FILESHARE/projects/Azavea_CartographicServices/azaveaTheme")
library(azaveaTheme)


seat_advantage_graphic <- ggplot(graphic_dat, aes(State, Seat_Advantage)) +
  geom_bar(stat = "identity", width=0.5, aes(x=reorder(State, -Ranking),fill = Party_Advantage)) + 
  labs(y="Number of Seats", x = "States with a Seat Advantage", subtitle ="States Ranked by Partisan Advantage", title="Efficiency Gap Seat Advantage") +
  theme(axis.title.y = element_blank()) +
  scale_fill_manual(values=c('#45bae8','#ff595f'), name="Party Advantage") +
  coord_flip() +
  azaveaTheme() +
  theme(axis.title = element_text(hjust=1, face ="italic"))
  
  