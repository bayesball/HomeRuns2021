# app to compute brushed home run rates
library(shiny)
library(ggplot2)
library(dplyr)
library(readr)
library(lubridate)

# turn off warnings
options(warn=-1)

# data setup
current_date <- ymd(substr(Sys.time(), 1, 10))
date_2021_hi <- current_date - 1

# read in statcast dataset
sc_2021 <- read.csv("statcast2021.csv")
scip <- read_csv("SC_BB_mini.csv")

# adjust 2021 date if necessary
date_2021_hi <- min(date_2021_hi,
                 max(ymd(sc_2021$Game_Date)))
date_2021_lo <- ymd("2021-04-01")

# create in-play 2021 dataset
sc_2021 %>%
  filter(type == "X") %>%
 mutate(HR = ifelse(events == "home_run", 1, 0),
        game_date = Game_Date)  %>% 
  select(game_year, game_date, launch_angle,
         launch_speed, HR) -> 
 scip_2021

# merge two datasets
rbind(scip, scip_2021)  %>% 
  filter(game_year %in% 2015:2021) -> scip

# want HR variable to be character
scip$HR <- as.character(scip$HR)

# shiny app
ui <- fluidPage(
  theme = bslib::bs_theme(version = 4,
                          bootswatch = "superhero"),
  fluidRow(
    column(4, wellPanel(
      h3(id="big-heading",
         "Select Date Range"),
      dateInput("date_lo",
                label = h6("2021 Starting Date:"),
                value = date_2021_lo),
      dateInput("date_hi",
                label = h6("2021 Ending Date:"),
                value = date_2021_hi),
      actionButton("goButton", "Download Table")
    )),
    column(8,
      h3(id="big-heading", "Brushed In-Play & HR Rates"),
      plotOutput("plot1",
                 brush =
                   brushOpts("plot_brush",
                             fill = "#0000ff"),
                 height = "330px"),
      tableOutput("table1")
    ))
)
server <- function(input, output, session) {
  output$plot1 <- renderPlot({
    
    md1 <- paste(month(input$date_lo), "-",
                 day(input$date_lo), sep = "")
    md2 <- paste(month(input$date_hi), "-",
                 day(input$date_hi), sep = "")
    scip %>% 
      mutate(date1 = ymd(paste(game_year, "-", md1,
                               sep = "")),
             date2 = ymd(paste(game_year, "-", md2,
                               sep = ""))) %>% 
      filter(game_date >= date1,
             game_date <= date2) -> scipR
    
    scnew <- sample_n(scipR, size = 10000)
    
    md1 <- paste(month(input$date_lo), "-",
                 day(input$date_lo), sep = "")
    md2 <- paste(month(input$date_hi), "-",
                 day(input$date_hi), sep = "")
    the_title <- paste("Sample Data from ", md1, " to ",
                       md2, sep = "")
    ggplot() +
    geom_point(data = scnew,
               mapping = aes(launch_angle,
                             launch_speed,
                             color = HR),
               size = 1, alpha = 0.4
               ) +
    geom_point(data =
                 brushedPoints(scnew,
                               input$plot_brush),
                 mapping = aes(launch_angle,
                               launch_speed)) +
      xlim(15, 50) + ylim(90, 115) +
      ggtitle(the_title) +
      xlab("Launch Angle (degrees)") +
      ylab("Exit Velocity (mph)") +
      theme(plot.title = 
              element_text(colour = "blue", size = 18,
               hjust = 0.5, vjust = 0.8, angle = 0)) +
      theme(text=element_text(size=18)) +
      scale_color_manual(values = c("orange", "blue"))
  }, res = 96)
  
  output$table1 <- renderTable({
      req(input$plot_brush)
    
      md1 <- paste(month(input$date_lo), "-",
                 day(input$date_lo), sep = "")
      md2 <- paste(month(input$date_hi), "-",
                 day(input$date_hi), sep = "")
      
      scip %>% 
        mutate(date1 = ymd(paste(game_year, "-", md1,
                                 sep = "")),
               date2 = ymd(paste(game_year, "-", md2,
                                 sep = ""))) %>% 
       filter(game_date >= date1,
              game_date <= date2) -> scipR
    
      scipR %>% 
        group_by(game_year) %>% 
        summarize(N = n()) -> S1
      
      sc1 <- brushedPoints(scipR,
                           input$plot_brush)
      la_lo <- min(sc1$launch_angle)
      la_hi <- max(sc1$launch_angle)
      ls_lo <- min(sc1$launch_speed)
      ls_hi <- max(sc1$launch_speed)
      
      label <- paste(round(la_lo, 1), "< LA <", 
                     round(la_hi, 1),
                     ", ", 
                     round(ls_lo, 1),
                     "< LS <",
                     round(ls_hi, 1), sep="")
      
      scipR %>% 
        filter(launch_angle >= la_lo,
               launch_angle <= la_hi,
               launch_speed >= ls_lo,
               launch_speed <= ls_hi) %>% 
        group_by(game_year) %>% 
        summarize(BIP = n(),
                  HR = sum(HR == "1", 
                           na.rm = TRUE)) %>% 
        inner_join(S1, by = "game_year") %>% 
        mutate(Region = label,
               BIP_Rate = 100 * BIP / N,
               HR_Rate = as.character(
                    round(100 * HR / BIP, 1)),
               Season = as.character(game_year)) %>% 
        select(Season, Region, BIP, BIP_Rate, HR, HR_Rate)
      
  }, digits = 2)
  
  observeEvent(input$goButton, {
    req(input$plot_brush)
    
    md1 <- paste(month(input$date_lo), "-",
                 day(input$date_lo), sep = "")
    md2 <- paste(month(input$date_hi), "-",
                 day(input$date_hi), sep = "")
    
    scip %>% 
      mutate(date1 = ymd(paste(game_year, "-", md1,
                               sep = "")),
             date2 = ymd(paste(game_year, "-", md2,
                               sep = ""))) %>% 
      filter(game_date >= date1,
             game_date <= date2) -> scipR
    
    scipR %>% 
      group_by(game_year) %>% 
      summarize(N = n()) -> S1
    
    sc1 <- brushedPoints(scipR,
                         input$plot_brush)
    la_lo <- min(sc1$launch_angle)
    la_hi <- max(sc1$launch_angle)
    ls_lo <- min(sc1$launch_speed)
    ls_hi <- max(sc1$launch_speed)
    
    scipR %>% 
      filter(launch_angle >= la_lo,
             launch_angle <= la_hi,
             launch_speed >= ls_lo,
             launch_speed <= ls_hi) %>% 
      group_by(game_year) %>% 
      summarize(BIP = n(),
                HR = sum(HR == "1", 
                         na.rm = TRUE)) %>% 
      inner_join(S1, by = "game_year") %>% 
      mutate(LA_lo = la_lo, LA_hi = la_hi,
             LS_lo = ls_lo, LS_hi = ls_hi,
             BIP_Rate = round(100 * BIP / N, 2),
             HR_Rate = round(100 * HR / BIP, 1),
             Season = as.character(game_year)) %>% 
      select(Season, LA_lo, LA_hi, 
             LS_lo, LS_hi, BIP, BIP_Rate, 
             HR, HR_Rate) -> my_out
    
      LA_mid <- round((la_lo + la_hi) / 2, 1)
      LS_mid <- round((ls_lo + ls_hi) / 2, 1)
      file_name <- paste("output/out_", LA_mid, "_",
                         LS_mid, ".csv", sep = "")
      write_csv(my_out, file_name)
  })
                        
}

shinyApp(ui = ui, server = server)
