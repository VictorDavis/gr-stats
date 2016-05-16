library(shiny)
shinyUI(
  navbarPage("My Goodreads Stats",
    tabPanel("My Information",
             textInput('grURL', # http://www.goodreads.com/author/show/8282486.Victor_A_Davis
                       'Copy/Paste your Goodreads Profile URL:',
                       value = ""),
             conditionalPanel("input.grURL !== '' ",
               actionButton('reload', 'Load my Data'),
               conditionalPanel("$('#headData').hasClass('recalculating')", 
                                tags$div('Downloading your Goodreads activity... You might want to grab a book while you wait...')
               ),
               fluidRow(
                 column(width = 2, uiOutput("my_face")),
                 column(width = 10, verbatimTextOutput("headData"))
               ),
               downloadButton('downloadData', 'Save Data'),
               uiOutput("source_link")
             ),
             style = 'width: 100%;'
    ),
    tabPanel("Books per Year",
             fluidRow(
               column(width = 6, plotOutput("plotBooksPerYear", hover = hoverOpts(id="p1a"))),
               column(width = 6, plotOutput("plotPagesPerYear", hover = hoverOpts(id="p1b")))
             ),
             fluidRow(
               column(width = 6, verbatimTextOutput("labelBooksPerYear")),
               column(width = 6, verbatimTextOutput("labelPagesPerYear"))
             )),
    tabPanel("Gender Habits",
             fluidRow(
               column(width = 6, plotOutput("plotBooksByGender", hover = hoverOpts(id="p2a"))),
               column(width = 6, plotOutput("plotRatingsByGender"))
             ),
             fluidRow(
               column(width = 6, verbatimTextOutput("labelBooksByGender"))
             )),
    tabPanel("Reading Speed",
             fluidRow(
               column(width = 12, plotOutput("plotPagesPerDay", hover = hoverOpts(id="p3")))
             ),
             verbatimTextOutput("summaryReadSpeed"),
             fluidRow(
               column(width = 12, verbatimTextOutput("labelPagesPerDay"))
             )
    )
  )
)
