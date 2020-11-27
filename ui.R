#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(simmer)
library(plotly)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Ambulance Simmer"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            sliderInput("ambulances", "Ambulances", min = 0, max = 500, value = 100),
            sliderInput("cph", "Calls per hour", min = 0, max = 500, value = 100),
            sliderInput("enroute", "Driving time to call", min = 0, max = 60, value = 15),
            sliderInput("on_scene", "On scene time", min = 0, max = 120, value = 30),
            sliderInput("conveyance", "Conveyance rate", min = 0, max = 1, value = 0.6),
            sliderInput("to_hospital", "Driving time to hospital", min = 0, max = 60, value = 15),
            sliderInput("n_hospital", "Number of hospitals", min = 0, max = 50, value = 10),
            sliderInput("hospital_capacity", "Hospital bed capacity", min = 0, max = 100, value = 25),
            sliderInput("hospital_time", "Hospital time", min = 0, max = 1000, value = 240),
            sliderInput("sim_length", "Simulation length", min = 0, max = 10000, value = 60 * 24),
            actionButton("run_sim", "Run simulation")
        ),

        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel(
                tabPanel("Ambulances", plotOutput("ambulances"), plotOutput("ambulance_waiting")),
                tabPanel("Hospitals", plotOutput("hospitals")),
                tabPanel("Calls", plotOutput("held_calls"))
            )
        )
    )
))
