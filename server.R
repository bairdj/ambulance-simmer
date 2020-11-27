#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(simmer)
library(dplyr)
library(tidyr)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    values <- reactiveValues()
    
    observeEvent(input$run_sim, {
        env <- simmer("Ambulance Network")
        
        hospitals <- paste0("hospital", 1:input$n_hospital)
        
        patient <- trajectory("Patient") %>%
            seize("ambulance", 1) %>%
            timeout(input$enroute) %>%
            # On scene time
            timeout(input$on_scene) %>%
            # Check if conveying to hospital
            branch(
                option = function() {sample(c(0,1), size=1, prob=c(1-input$conveyance, input$conveyance))},
                continue = FALSE,
                trajectory() %>%
                    timeout(input$to_hospital) %>%
                    # Get a hospital bed
                    simmer::select(hospitals, policy = "shortest-queue") %>%
                    seize_selected() %>%
                    # Can release the ambulance once the hospital is available
                    release("ambulance") %>%
                    timeout(function() {rnorm(1, input$hospital_time, 60)}) %>%
                    release_selected()
            ) %>%
            release("ambulance")
        
        env %>%
            add_resource("ambulance", input$ambulances) %>%
            add_generator("patient", patient, function() rexp(1, input$cph/60), mon = 2)
        
        for (hospital in hospitals) {
            env %>% add_resource(hospital, input$hospital_capacity)
        }
        
        progress <- shiny::Progress$new()
        on.exit(progress$close())
        progress$set(message = "Running simulation", value = 0)
        
        update_sim_progress <- function(sim_progress) {
            progress$inc(sim_progress)
        }
        
        env %>% run(until = input$sim_length, progress = update_sim_progress)
        
        values$resources <- env %>% get_mon_resources()
        values$hospital_resources <- values$resources %>% filter(substr(resource, 1, 8) == "hospital")
        values$arrivals <- env %>% get_mon_arrivals(per_resource = TRUE)
        values$attributes <- env %>% get_mon_attributes()
    })

    
    output$ambulances <- renderPlot({
        req(values$resources)
        values$resources %>%
            filter(resource == "ambulance") %>%
            mutate(Available = capacity - server) %>%
            rename(`In Use` = server) %>%
            pivot_longer(c(Available, `In Use`), values_to = "n") %>%
            ggplot(aes(time, n, fill = name)) +
            geom_area() +
            xlab("Time") +
            ylab("Ambulances") +
            labs(title = "Ambulance utilisation") +
            guides(fill=guide_legend((title=NULL)))
    })
    
    output$hospitals <- renderPlot({
        req(values$hospital_resources)
        values$hospital_resources %>%
            mutate(Available = capacity - server) %>%
            rename(`Used` = server, Queue = queue) %>%
            pivot_longer(c(Available, Used), values_to = "n", names_to = "Status") %>%
            ggplot(aes(time, n, fill = Status)) +
            geom_area() +
            xlab("Time") +
            ylab("Beds") +
            labs(title = "Hospital bed utilisation") +
            facet_wrap(~resource)
    })
    
    output$ambulance_waiting <- renderPlot({
        req(values$hospital_resources)
        values$hospital_resources %>%
            # Widen to fill in missing values
            select(time, resource, queue) %>%
            arrange(time) %>%
            pivot_wider(names_from = resource, values_from = queue) %>%
            fill(starts_with("hospital")) %>%
            pivot_longer(starts_with("hospital"), names_to = "Hospital", values_to = "n") %>%
            ggplot(aes(time, n, group = Hospital)) +
            geom_area() +
            xlab("Time") +
            ylab("Ambulances waiting") +
            labs(title = "Ambulances waiting at hospital")
    })
    
    output$held_calls <- renderPlot({
        req(values$resources)
        values$resources %>%
            filter(resource == "ambulance") %>%
            ggplot(aes(time, queue)) +
            geom_line() +
            xlab("Time") +
            ylab("Calls held") +
            labs(title = "Calls waiting with no available ambulance")
    })

})
