#OccAssess Shiny App

# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(data.table)
library (ggplot2)
library(lubridate)
library(tidyverse)
library(occAssess)
library(rnrfa)
library(sparta)

#source("assessRecordNumber.R")
#source("createData.R")

#DATA FRAMES ONLY LOAD SUCCESSFULLY IN THIS BIT

setwd("C:/BRERC")
 



#chr = 'this is a string'


#MyData <<- list(df1,df2)

#doesn't do anything
Updater <<- function(Chosen) {

#First remove the dataframe.
#if already made is true
#rm(MyData)

setwd("C:/BRERC")

#MyData<-read.csv(Chosen)
  
}

#array containing the 5 OccAssess function names.
funcList <<- list("DoAssess1", "DoAssess2", "DoAssess3", "DoAssess4", "DoAssess5")

#array containing CSV filenames
CSVList <<- list("Avon_Birds.CSV", "Avon_Butterflies.CSV")

df1 = read.csv("Avon_Birds.CSV") #This is the CSV you made in 'run first'
df2 = read.csv("Avon_Butterflies.CSV")

#array containing Dataframes
#MyData <<- list("MyData$Dataframe1", "MyData$Dataframe2")


# Define UI for application
shinyUI(fluidPage(
  
  # Application title
titlePanel(h1("BRERC Tools",h4("OccAssess Functions"))),
#radioButtons("normalize", "Normalize?", list("TRUE", "FALSE"), "")  
  #Buttons
shinyjs::useShinyjs(),
actionButton("btn2","Assess Record Number (ARN)"),
actionButton("btn4","ARN Normalized"),
actionButton("btn","Assess Species Number"),
actionButton("btn3","Assess Species ID"),
#actionButton("btn5","Assess Rarity Bias"),
downloadButton('downloadPlot', 'Download Plot'),
textOutput("text"),
  
  sidebarLayout(
    
    # Sidebar
    sidebarPanel(
      #textOutput('textWithNewlines'),
      uiOutput('textWithHTML'),
      
      selectInput("csvs", "Choose Database", c("Avon_Birds.CSV","BRERC.CSV", "Avon_Butterflies.CSV"), selected = "Avon_Birds.CSV"),
      actionButton("btn6","Load CSV")
      #sliderInput("obs",
      #            "Number of observations:",
      #            min = 0,
      #            max = 1000,
      #            value = 500)
    ),
    
    #Main panel with plot.
    # Show the plot png
    mainPanel(
      imageOutput("myImage"),
      textOutput("csv"),
      #ChosenCSV = ("csv"),
      #UpdateLoadedCSV()
    )
    
  )
))

DoAssess1 <<- function(y) {

#1.####Assess Record Number#####

# This function enables researchers to quickly establish how the number of records has changed over time. 
# Note the argument "normalize" which, if TRUE, will rescale the counts for each level of identifier to 
# enable comparisons where they are very different.

  #browser()
  
periods <- list(1950:2019)
Periods <- list(1950:2019) #get back original one here and unlist it.
#lists every year in these ranges.
periods <- as.numeric(unlist(periods))

#alternative way, gets rid of the weird number of records problem.
#periods <- list(1950, 1960, 1970, 1980, 1990, 2000, 2010)

#converting the above list of time periods to a string. (1950:1959 etc)
Periods <- toString(Periods)
print(Periods)

#MyData <<- list(df1,df2)

if (y == 1)
{ MyDF <- df1 }

if (y == 2)
{ MyDF <- df2 } 

#assign("MyData[1]",MyData$Dataframe)
#print(MyData[1]$data.frame)

#dataset is too big to look at everything at once, will need subset

nRec <- assessRecordNumber(dat = MyDF,
                           periods = periods,
                           species = "Species",
                           x = "east",
                           y = "north",
                           year = "Year", 
                           spatialUncertainty = "Uncertainty",
                           identifier = "taxagroup",
                           normalize = FALSE)

#converting the period groups made in OccAssess to a String (1 to 7)
nRecPeriods <- toString(nRec$data$Period)
print(nRecPeriods)

MyPlot <- ggplot2::ggplot(data = nRec$data, ggplot2::aes(y = nRec$data$val, x = periods, colour = group, group = group)) +
  #adding in the custom x axis ticks
  #has to be at the start***
  ggplot2::scale_x_continuous(n.breaks = 10) +
  ggplot2::scale_y_continuous(n.breaks = 10) +
  ggplot2::geom_point() +
  ggplot2::geom_line() +
  ggplot2::theme_linedraw() +
  ggplot2::ylab("Number of records") +
  ggplot2::labs(colour = "",
                x = "Period")

#works but is no longer needed.
#MyPlot + scale_x_discrete(labels=c(periods))
#MyPlot + scale_x_discrete(breaks=c(periods))



#for actual x axis name
#MyPlot$labels$x = (labels=c(periods))
 
plot(MyPlot)

write.csv(nRec$data,"C://BRERC//BRERC2.csv", row.names = TRUE)
system("chmod 644 C://BRERC//BRERC2.csv")

#write results that display in console to a txt file.
sink(file = "lm_output.txt")
print("This function enables researchers to quickly establish how the number of records has changed over time. Note the argument normalize which, if TRUE, will rescale the counts for each level of identifier to enable comparisons where they are very different.")
sink() #end diversion of output

}

  DoAssess2 <<- function() {
  
    #2.####Assess Species Number#####
    
    # In addition to the number of records, you may wish to know how the number of species 
    # (taxonomic coverage) in your dataset changes over time. For this you can use the function assessSpeciesNumber
    
    
    periods <- list(1950:1959, 1960:1969, 1970:1979, 1980:1989, 1990:1999, 2000:2009, 2010:2019)
    
    nSpec <- assessSpeciesNumber(dat = MyData,
                                 periods = periods,
                                 species = "Species",
                                 x = "east",
                                 y = "north",
                                 year = "Year", 
                                 spatialUncertainty = "Uncertainty",
                                 identifier = "taxagroup",
                                 normalize = FALSE)
    
    str(nSpec$data)
    #Plot function 2 results.
    plot(nSpec$plot)
    
    #write results that display in console to a txt file.
    sink(file = "lm_output.txt")
    print("In addition to the number of records, you may wish to know how the number of species (taxonomic coverage) in your dataset changes over time.")
    sink() #end diversion of output
  
  }

  DoAssess3 <<- function() {

    #3.####Assess Species ID######
    
    #It has been speculated that apparent changes in taxonomic coverage could, in fact, reflect a 
    # change in taxonomic expertise over time. For example, if fewer individuals have the skill to 
    #identify certain species, then it may not appear in your dataset in the later periods. 
    #The function assessSpeciesID treats the proportion of species identified to species level 
    #as a proxy for taxonomic expertise:
    
    
    periods <- list(1950:1959, 1960:1969, 1970:1979, 1980:1989, 1990:1999, 2000:2009, 2010:2019)
    
    propID <- assessSpeciesID(dat = MyData,
                              periods = periods,
                              type = "proportion",
                              species = "Species",
                              x = "east",
                              y = "north",
                              year = "Year", 
                              spatialUncertainty = "Uncertainty",
                              identifier = "taxagroup")
    str(propID$data)
    
    #Plot function 3 results
    plot(propID$plot)
    
    #write results that display in console to a txt file.
    sink(file = "lm_output.txt")
    print("It has been speculated that apparent changes in taxonomic coverage could, in fact, reflect a change in taxonomic expertise over time. For example, if fewer individuals have the skill to identify certain species, then it may not appear in your dataset in the later periods. The function assessSpeciesID treats the proportion of species identified to species level as a proxy for taxonomic expertise.")
    sink() #end diversion of output
    
  }
  
  DoAssess4 <<- function() {
    
    #1.####Assess Record Number#####
    
    # This function enables researchers to quickly establish how the number of records has changed over time. 
    # Note the argument "normalize" which, if TRUE, will rescale the counts for each level of identifier to 
    # enable comparisons where they are very different.
    
    periods <- list(1950:1959, 1960:1969, 1970:1979, 1980:1989, 1990:1999, 2000:2009, 2010:2019)
    
    #dataset is too big to look at everything at once, will need subset
    
    nRec <- assessRecordNumber(dat = MyData,
                               periods = periods,
                               species = "Species",
                               x = "east",
                               y = "north",
                               year = "Year", 
                               spatialUncertainty = "Uncertainty",
                               identifier = "taxagroup",
                               normalize = TRUE)
    str(nRec$data)
    
    plot(nRec$plot)
    
    #write results that display in console to a txt file.
    sink(file = "lm_output.txt")
    print("This function enables researchers to quickly establish how the number of records has changed over time. Note the argument normalize which, if TRUE, will rescale the counts for each level of identifier to enable comparisons where they are very different.")
    sink() #end diversion of output
    
  }  
  
  DoAssess5 <<- function() {
    
    #4.####assess Rarity Bias#####
    
    # A number of studies have defined taxonomic bias in a dataset as the degree of 
    # proportionality between species' range sizes (usually proxied by the number of 
    # grid cells on which it has been recorded) and the total number of records. One 
    # can regress the number of records on range size, and the residuals give an index 
    # of how over-or undersampled a species is given its prevalence. The function assessSpeciesBias
    # conducts these analyses for each time period, and uses the r2 value from the linear regressions 
    # as an index proportionality between range sizes and number of records. Higher values indicate 
    # that species' are sampled in proportion to their range sizes whereas lower values indicate that 
    # some species are over- or undersampled.
    
    
    
    periods <- list(1950:1959, 1960:1969, 1970:1979, 1980:1989, 1990:1999, 2000:2009, 2010:2019)
    
    taxBias <- assessRarityBias(dat = MyData,
                                periods = periods,
                                res = 0.5,
                                prevPerPeriod = FALSE,
                                species = "Species",
                                x = "east",
                                y = "north",
                                year = "Year", 
                                spatialUncertainty = "Uncertainty",
                                identifier = "taxagroup")
    
    
    str(taxBias$data)
    
    #plot(taxBias$plot)
    
    taxBias$plot +ggplot2::ylim(c(0,1))
    
    #write results that display in console to a txt file.
    sink(file = "lm_output.txt")
    print("It has been speculated that apparent changes in taxonomic coverage could, in fact, reflect a change in taxonomic expertise over time. For example, if fewer individuals have the skill to identify certain species, then it may not appear in your dataset in the later periods. The function assessSpeciesID treats the proportion of species identified to species level as a proxy for taxonomic expertise.")
    sink() #end diversion of output
    
  }  