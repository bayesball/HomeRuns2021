# HomeRuns2021

Shiny apps to explore home run rates for Statcast seasons 2015 through 2021.

HomeRunRates2021

One selects a range of dates and use sliders to select a rectangular region of (launch angle, exit velocity)
values.  App will compute the count and rate of balls in play (BIP) in that region for that range of dates.  Also it will
compute the count and rate of home runs (HR) in that region.

A live version of this Shiny app is available at https://bayesball.shinyapps.io/HomeRunRates2021/

HomeRunsCompare

One selects a range of dates and two seasons to compare.  The app will compare the batted ball rates and 
the home run rates in bins of values defined by launch angle and exit velocity.  One can compare the rates
by either differences in percentages or a z statistic.

A live version of this Shiny app is available at https://bayesball.shinyapps.io/HomeRunsCompare/

The R code for each Shiny app is available as the file app.R in the folders HomeRunRates2021 and HomeRunCompare.

To run the Shiny app locally ...

- download the app.R file and place it in a folder
- launch R and make the folder the current working directory
- type in the Console window

shiny::runApp()

Note:  Each app requires that the following R packages are installed:

shiny, ggplot2, readr, dplyr, lubridate

