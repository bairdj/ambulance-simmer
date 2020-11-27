# ambulance-simmer
Discrete event simulation for an ambulance + hospital network using [Simmer](https://r-simmer.org/) and presented in R Shiny.

# Resources
* Ambulance (single queue)
* Hospitals (individal queue per hospital)

# Patient trajectory explanation
1. Call placed
2. Ambulance resource seized if available
3. Ambulance drives to scene
4. Ambulance at scene

## If conveyance to hospital required
1. Destination hospital selected (the hospital with the current shortest queue)
2. Ambulance drives to hospital
3. If hospital has bed capacity, patient is transferred to hospital and ambulance released
4. If hospital has no capacity, patients joins queue *with* the ambulance. The ambulance is not released until a bed becomes available

## If conveyance to hospital not required
1. Ambulance is released immediately


# Running
The quickest way to run in your local R session is
```
library(shiny)
runGitHub("ambulance-simmer", "bairdj", "main")
```

All parameters can be controlled from the sliders on the main page. Once the simulation has been run, charts will be presented for analysis.
