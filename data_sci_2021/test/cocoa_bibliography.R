# setup -------------------------------------------------------------------

library(shiny)
library(shinyWidgets)
library(tidyverse)
library(stringr)
library(httr)
library(shinyjs)

subset_tibble <-
    read_csv('Zotero_TagURLCodes_AH1.csv') %>% 
    filter(!tag %in% c('Article Type', 'Country', 'Region', 'Topic', 'Global'))

tag_classes <- 
    unique(subset_tibble$tag_class)

subset_list <-
    purrr::map(
        tag_classes,
        function(x) {
            tibble(tag = 'All', collection = NA_character_) %>% 
                bind_rows(
                    subset_tibble %>% 
                        filter(tag_class == x) %>% 
                        select(tag, collection)
                )
        }) %>% 
    set_names(tag_classes)

# User interface:

ui <- 
    fluidPage(
        useShinyjs(),
        fluidRow(
            column(9, offset = 1, titlePanel("Cocoa bibliography example")),
            column(2)
        ),
        hr(),
        br(),
        fluidRow(
            column(9, offset = 1, 
                   HTML('<p style = "font-size: 1.5em;">Please note: The full library hosted on zotero and available at <a href = "https://www.zotero.org/groups/2785774/cocoa_library/library" target = "_blank">this link</a>.</p>'),
                   br()),
            column(2)
        ),
        fluidRow(
            column(
                3, 
                offset = 1,
                h3('Geography'),
                br(),
                radioButtons(
                    'geography_radio', 
                    label = NULL, 
                    choices = c('Region' = 'region', 'Country' = 'country')),
                selectInput(
                        inputId = "geography_select",
                        label = "Select region or country:",
                        choices = subset_list$region$tag)),
            column(
                width = 3,
                h3('Topic'),
                br(),
                selectInput(
                    inputId = "topic_select",
                    label = NULL,
                    choices = subset_list$topic$tag)),
            column(
                width = 3,
                h3('Article type'),
                br(),
                selectInput(
                    inputId = "article_select",
                    label = NULL,
                    choices = subset_list$article_type$tag)),
            column(2)
        ),
        fluidRow(
            column(9, offset = 1, 
                   br(),
                   actionBttn(
                       inputId = 'submit', 
                       label = 'Search bibliography', 
                       style = 'material-flat',
                       icon = icon('sliders'),
                       block = TRUE,
                       color = 'primary'),
                   hr(),
                   br()),
            column(2)
        ),
        # Bibliography output:
        mainPanel(
            br(),
            hidden(
                div(id = 'progress_bar_div',
                    progressBar(
                        id = "progress_bar",
                        value = 0,
                        total = 100,
                        title = "",
                        display_pct = TRUE
                    ))),
            fluidRow(
                column(width = 9, htmlOutput('htmlOut'), offset = 1),
                column(width = 2)
            )),
        br()
    )


# Server logic:

server <- function(input, output, session) {
    
    # Radio button changes input:
    
    observe({
        updateSelectInput(
            session, 
            inputId = 'geography_select', 
            label = input$subset_by %>% 
                str_replace('topic','Topic') %>% 
                str_replace('country','Country') %>% 
                str_replace('region','Region') %>% 
                str_replace('article_type','Article type'),
            choices = subset_list[[input$geography_radio]],
            selected = NULL)
    })
    
    rv <- reactiveValues()
    
    # Generate query:
    
    url <- reactive({

        # Add geography subset:
        
        if(input$geography_select != 'All') {
                collection <-
                    subset_tibble %>% 
                    filter(
                        tag_class == input$geography_radio,
                        tag == input$geography_select) %>% 
                    pull(collection)
                
                url <-
                    str_c(
                        'https://api.zotero.org/groups/2785774/collections/',
                        collection,
                        '/items/?')
        } else {
            url <- 'https://api.zotero.org/groups/2785774/items/?'
        }
        
        # Add topic and article type subset:
        
        topic <- 
            ifelse(
                input$topic_select == 'All', 
                NA_character_, 
                str_c('tag=', input$topic_select)) %>% 
            str_replace_all(' ', '+')
        
        article <-
            ifelse(
                input$article_select == 'All', 
                NA_character_, 
                str_c('itemType=', input$article_select)) %>% 
            str_replace('Book Section', 'bookSection') %>% 
            str_replace('Conference Paper', 'conferencePaper') %>% 
            str_replace('Journal Article', 'journalArticle')
        
        topic_article <-
            case_when(
            is.na(topic) & is.na(article) ~ NA_character_,
            is.na(topic) & !is.na(article) ~ article,
            !is.na(topic) & is.na(article) ~ topic,
            TRUE ~ str_c(article, topic, sep = '&'))
        
        if(!is.na(topic_article)){
            url <-
                str_c(url, topic_article, '&')
        }
        
        str_c(url, 'format=json&include=bib&limit=20') 
            
    })
    

    # Read and format data from Zoteros API:
    
    bib <-
        eventReactive(input$submit, {
                url <- url()
                cat(url)
                   
            bib_collapsed <- NULL

            bib <-
                tryCatch(
                    httr::GET(url) %>%
                        httr::content() %>%
                        map(~ .$bib))

            if(length(bib) > 0) {
                bib <- purrr::map(
                    1:length(bib),
                    function(item) {
                        bib_url <-
                            bib[[item]] %>%
                            str_extract('https://[^<]{0,100}') %>%
                            str_remove('.$')

                        bib_hyperlink <-
                            bib_url %>%
                            str_c('<a target = "_blank" href = "', .) %>%
                            str_c('">', bib_url, '</a>')

                        bib[[item]] <-
                            bib[[item]] %>%
                            str_replace(bib_url, bib_hyperlink)
                    })

                bib_collapsed <-
                    unlist(bib) %>%
                    sort() %>%
                    str_c(collapse = '<br>')

                bib_collapsed
            } else {
                '<div><br><h4>No matching records!</h4></div>'
            }
        })
    
    output$htmlOut <-
        renderText({as.character(bib())})
}

# Run:

shinyApp(ui = ui, server = server)
