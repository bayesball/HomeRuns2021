# HomeRuns2021

Shiny app to explore home run rates for Statcast seasons 2015 through 2021.

One selects a range of dates and brushes a rectangular region of (launch angle, exit velocity)
values.  App will compute the count and rate of balls in play (BIP) in that region for that range of dates.  Also it will
compute the count and rate of home runs (HR) in that region.

A live version of this Shiny app is available at https://bayesball.shinyapps.io/HomeRunRates2021/

Requires the following R packages:

shiny, ggplot2, readr, dplyr, lubridate

To run this Shiny app locally and see the code:

- download this respository as a zip file
- unpack the zip file
- launch R and make this folder the current working directory
- type in the Console window

shiny::runApp()

