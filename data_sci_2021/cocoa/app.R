#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

country <-
    c(
        'Select a country' = 'Select a country',
        'Belize' = 'QYBXDSQP',
        'Bolivia' = '3PIHVS7W',
        'Brazil' = 'MKFDEKNE')

region <-
    c(
        'Africa' = 'KCG89HTA',
        'Asia' = 'MWLDB4FH')

article_type <-
    c(
        'Journal article' = 'RZ8L7S94',
        'Report' = 'GCCZV6NX')

topic <-
    c(
        'Agroforestry' = 'M4ETIC6F',
        'Biodiversity' = '4BNDN6M7')


# Define UI for application that draws a histogram
ui <- 
    fluidPage(
        
        # Application title
        titlePanel("Cocoa bibliography exaple"),
        
        # Sidebar with a slider input for number of bins 
        br(),
        fluidRow(
            column(width = 10, 
                   selectInput(
                       inputId = "country_select",
                       label = "Country:",
                       choices = country),
                   offset = 1),
            column(width = 1)),
        # Show a plot of the generated distribution
        mainPanel(
            HTML('htmlOut')
        )
    )


# Define server logic required to draw a histogram
server <- function(input, output) {
    
    rv <-
        reactiveValues()
    
    rv$bib <-
        reactive({
            if(!is.null(country_select) &&
                  country_select != 'Select a country') {
                url <-
                    str_c(
                        'https://api.zotero.org/groups/2785774/collections/',
                        input$country_select,
                        '/items/?format=json&include=bib')
                
                httr::GET('https://api.zotero.org/groups/2785774/collections/BBQUTBXB/items/?collections=VFM72G6M&format=json&include=bib') %>% 
                    httr::content() %>% 
                    map(~ .$bib) %>% 
                    unlist() %>% 
                    str_c(collapse = '')
            } else {
                ''
            }
        })

    output$htmlOut <- 
        renderText({rv$bib})
}

# Run the application 
shinyApp(ui = ui, server = server)
