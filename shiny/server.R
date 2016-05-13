library(shiny)
source("gr-stats.R")
shinyServer(
  function(input, output) {
    
    options("width" = 1000)
    
    userId <- reactive({ processURL(input$grURL) })
    
    dataInput <- reactive({
      input$reload
      data <- getData(userId())
      data
    })
    
    output$source_link <- renderUI({
      tags$a("Source Code on GitHub",
             href="https://github.com/VictorDavis/gr-stats")
    })
    
    output$downloadData <- downloadHandler(
      filename = "gr-stats.csv",
      content = function(file) {
        df <- dataInput()
        drop <- names(df) %in% c("my_name","my_face")
        write.table(df[,!drop], file, sep=",", row.names = FALSE)
      }
    )
    
    output$headData <- renderPrint({
      data <- dataInput()
      if (is.data.frame(data)) {
        head(data[,c("read_at","title","my_rating")])
      } else {
        ""
      }
    })
    
    output$my_face <- renderUI({
      data <- dataInput()
      noface <- "https://s.gr-assets.com/assets/nophoto/user/f_111x148-8060b12280b2aec7543bafb574ee8422.png"
      if (is.data.frame(data)) {
        tags$figure(
          tags$img(src = data$my_face[1]),
          tags$figcaption(data$my_name[1])
        )
      } else {
        tags$img(src = noface)
      }
    })
    
    # books per year
    df1 <- reactive({ dataBooksPerYear(dataInput()) })
    output$dataBooksPerYear <- renderPrint(df1())
    output$plotBooksPerYear <- renderPlot(plotBooksPerYear(df1()))
    output$plotPagesPerYear <- renderPlot(plotPagesPerYear(df1()))
    
    # books by gender
    df2 <- reactive({ dataBooksByGender(dataInput()) })
    output$dataBooksByGender <- renderPrint(df2())
    output$plotBooksByGender <- renderPlot(plotBooksByGender(df2()))
    output$plotRatingsByGender <- renderPlot(plotRatingsByGender(df2()))
    
    # reading speed
    df3 <- reactive({ dataPagesPerDay(dataInput()) })
    output$summaryReadSpeed <- renderPrint(summaryReadSpeed(df3()))
    output$dataPagesPerDay <- renderPrint(df3())
    output$plotPagesPerDay <- renderPlot(plotPagesPerDay(df3()))
    
    # label under "books per year" graph
    output$labelBooksPerYear <- renderPrint({
      x = input$p1a$x
      y = input$p1a$y
      
      if (is.numeric(x)) {
        x <- round(x)
        y <- round(y)
        df <- df1()
        yyyy <- sort(unique(year(df$read_at)))[x]
        df <- df[year(df$read_at) == yyyy,]
        df <- df[order(df$my_rating, df$read_at),]
        
        if (is.na(df[y,"title"]))
          ""
        else
          paste(df[y,"title"], paste(df[y,"my_rating"], "stars"), df[y,"read_at"], sep=" - ")
      } else {
        "Hover your mouse over the graph above"
      }
    })
    
    # label under "pages per year" graph
    output$labelPagesPerYear <- renderPrint({
      x = input$p1b$x
      y = input$p1b$y
      
      if (is.numeric(x)) {
        x <- round(x)
        y <- round(y)
        # print(c(x,y))
        
        df <- df1()
        yyyy <- sort(unique(year(df$read_at)))[x]
        df <- df[year(df$read_at) == yyyy,]
        df <- df[order(df$read_at),]
        df[is.na(df$num_pages),"num_pages"] <- 0
        df$cum_pages <- cumsum(df$num_pages)
        
        if (!any(y < df$cum_pages))
          ""
        else
          y <- min(which(y < df$cum_pages))
          paste(df[y,"title"], paste(df[y,"my_rating"], "stars"), paste(df[y,"num_pages"], "pages"), df[y,"read_at"], sep = " - ")
      } else {
        "Hover your mouse over the graph above"
      }
    })
    
    # label under "books by gender" graph
    output$labelBooksByGender <- renderPrint({
      x = input$p2a$x
      y = input$p2a$y
      
      if (is.numeric(x)) {
        x <- round(x)
        y <- round(y)
        
        df <- df2()
        yyyy <- sort(unique(year(df$read_at)))[x]
        df <- df[year(df$read_at) == yyyy,]
        df <- df[order(df$author_gender, df$read_at),]
        
        if (is.na(df[y,"title"]))
          ""
        else
          paste(df[y,"title"], df[y,"author_name"], df[y,"author_gender"], sep = " - ")
      } else {
        "Hover your mouse over the graph above"
      }
    })
    
    # label under "reading speed" graph
    output$labelPagesPerDay <- renderPrint({
      x = input$p3$x
      y = input$p3$y
      if (is.numeric(x)) {
        x <- round(x)
        y <- round(y)
        # print(c(x,y))
        
        date <- as.Date(x, origin = "1970-01-01")
        df <- df3()
        df <- df[between(date, df$started_at, df$read_at),]
        if (nrow(df) <= 0) {
          paste("You weren't reading any books on",date,".")
        } else {
          df
        }
      }
    })
  }
)