#DataDiagnostics Shiny App

# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required
shinyServer(function(input, output, clientData) {
  
  GenerateContent <- function() {
    
    output$myImage <- renderImage({
      #Calls the function to do DataDiagnostics and makes the resulting plot
      #into a png file.
      
      # A temp file to save the output.
      # This file will be removed later by renderImage
      #figure out how to keep image as BRERC want to use it.

    outfile <- tempfile(fileext='.png')
      
      # Generate the PNG
    png(outfile, width=400, height=320)
      #call the function that does DataDiagnostics
    DoDiagnostics()
    dev.off() #main="Generated in renderImage()"
      
      # Return a list containing the filename
    list(src = outfile,
           contentType = 'image/png',
           width = 400,
           height = 320,
           alt = "This is alternate text", deleteFile = FALSE)
    })
    
    
      output$textWithHTML <- renderUI({
      rawText <- readLines('lm_output.txt') # get raw text
      
      # split the text into a list of character vectors
      #   Each element in the list contains one line
      splitText <- stringi::stri_split(str = rawText, regex = '\\n')
      
      # wrap a paragraph tag around each element in the list
      replacedText <- lapply(splitText, p)
      
      return(replacedText)
      })
    
  }
  
          observeEvent(input$btn2, {
            withCallingHandlers({
            shinyjs::html("text", "")
            GenerateContent()
            },
              message = function(m)
              {
              shinyjs::html(id = "text", html = m$message, add = TRUE)
              })
    
          })

})