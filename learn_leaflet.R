#Loading the packages ----

library(leaflet)
library(leafem)
library(mapview)

# Create the map
my_map <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=-1.6178, lat=54.9783, popup="Home of legends")

my_map  # Display the map in Viewer window

#Multiple backdrop maps ----

#Can add different layers but issues can arise from layers covering up important parts of map
#aka opacity is your friend here

leaflet() %>% 
  addTiles() %>%  
  addCircleMarkers(lng=-1.6178, lat=54.9783,
                   popup="The world's most important city!",
                   radius = 10, color = "red") %>% 
  addProviderTiles(providers$Esri.WorldImagery) %>% 
  addProviderTiles(providers$Stamen.TonerLines,
                   options = providerTileOptions(opacity = 0.8)) %>%
  addProviderTiles(providers$Stamen.TonerLabels)
  

#Not the second add providertiles is split, this is just for ease of reading as more is added.

#Changing marker symbols ----

#Sometimes it helps to change the shape of markers or the size. 
#Optional task is to produce markers for london and newcastle proportional to size

leaflet() %>%
  addTiles() %>%  
  addCircleMarkers(lng=-1.6178, lat=54.9783,
                   popup="Newcastle",
                   radius = , color = "red", fillColor = "yellow", opacity = 1)

leaflet() %>%
  addTiles() %>%  
  addCircleMarkers(lng=0.1278, lat=51.5074,
                   popup="London",
                   radius = 80, color = "red", fillColor = "yellow", opacity = 1)

#Marker popups and labels ----

#We can make it so labls and popups display when hovered over, not just clicked 

#addCircleMarkers(lng=-1.6178, lat=54.9783,
                 #popup="Newcastle population 270k",
                 #labelOptions = labelOptions(textsize = "15px")

leaflet() %>%
  addTiles() %>%  
  addCircleMarkers(lng=-1.6178, lat=54.9783, 
                   label="Newcastle",
                   labelOptions = labelOptions(textsize ="15:px") %>% 
                     labelOptions = labelOptions(noHide ="FALSE"),
                   radius = "10", color = "red", fillColor = "yellow", opacity = 1)

?labelOptions()

leaflet() %>%
  addTiles() %>% 
  addCircleMarkers(lng=-1.6178, lat=54.9783,
                   label ="Newcastle population 270k",
                   labelOptions = labelOptions(noHide = FALSE))

#Vector maps and leaflet ----
install.packages("sf")
library(sf)

nafferton_fields <- st_read("www/naff_fields.shp")

st_crs(nafferton_fields) #Looking at co-ordinate systems

# First reset nafferton fields to OS 27700. Depending on the source of your data
# you may not always need this first step
nafferton_fields <- nafferton_fields %>% 
  st_set_crs(27700) %>% 
  st_transform(27700)

# Transform to latitude longitude
nafferton_fields_ll <- st_transform(nafferton_fields, 4326) # Lat-Lon

plot(nafferton_fields_ll)

leaflet() %>% 
  addProviderTiles(providers$Esri.WorldImagery) %>% 
  addFeatures(nafferton_fields_ll)

#2.2 Displaying subsets of vector data ----

nafferton_fields_ll[nafferton_fields_ll$Farm_Meth=="Organic",]
leaflet() %>% 
  addProviderTiles(providers$Esri.WorldImagery) %>% 
  addFeatures(nafferton_fields_ll[nafferton_fields_ll$Farm_Meth=="Organic",],
              fillColor="green",
              color="white",
              opacity =0.7,
              fillOpacity=1) %>% 
  addFeatures(nafferton_fields_ll[nafferton_fields_ll$Farm_Meth=="Conventional",],
              fillColor="red",
              color="yellow", 
              fillOpacity=1)

#Continuous colour options ----

# Set the bins to divide up your areas
bins <- c(0, 25000, 50000, 75000, 100000, 125000, 150000, 175000, 200000, 225000)

# Decide on the colour palatte
pal <- colorQuantile(palette = "Greens", n=6, domain = nafferton_fields_ll$Area_m)

# Create the map
leaflet() %>% 
  addProviderTiles(providers$Esri.WorldImagery) %>% 
  addFeatures(nafferton_fields_ll,
              fillColor = ~pal(nafferton_fields_ll$Area_m),
              fillOpacity = 1)

?colorQuantile

#adding legend ----

# Now leaflet is called with nafferton_fields_ll
leaflet(nafferton_fields_ll) %>% 
  addProviderTiles(providers$Esri.WorldImagery) %>% 
  addFeatures(fillColor = ~pal(Area_m),
              fillOpacity = 1, 
              highlightOptions = highlightOptions(
                color = "yellow",
                weight = 5,
                bringToFront = TRUE)) %>% 
  addLegend("topright",
            pal = pal,
            values = ~Area_m,
            title = "Field area",
            labFormat = labelFormat(suffix = " m^2"),
            opacity = 1)

#Highlights and popups ----

#Added the following to the above code highlightOptions = highlightOptions(color = "yellow",
#weight = 5,
#bringToFront = TRUE)

field_info <- paste("Method: ", nafferton_fields_ll$Farm_Meth,
                    "<strong>",
                    "Crop: ", nafferton_fields_ll$Crop_2010)



leaflet(nafferton_fields_ll) %>% 
  addProviderTiles(providers$Esri.WorldImagery) %>% 
  addFeatures(nafferton_fields_ll,
              fillColor = ~pal(Area_m),
              fillOpacity = 1,
              highlightOptions = highlightOptions(color = "yellow", weight = 5,
                                                  bringToFront = TRUE),
              popup = field_info) %>% 
  addLegend("bottomright", pal = pal,
            values = ~Area_m,
            title = "Field area",
            labFormat = labelFormat(suffix = " m^2"),
            opacity = 1)

#Interactive control of foreground and background maps ----

leaflet() %>% 
  addTiles(group = "OSM (default)") %>% 
  addProviderTiles(providers$Esri.WorldImagery,
                   group = "Satellite")%>% 
  addLayersControl(
    baseGroups = c("OSM (default)", "Satellite"), 
  ) %>% 
  setView(lat = 54.9857, lng=-1.8990, zoom=10)

#Adding overlay of nafferton farm
leaflet() %>% 
  addTiles(group = "OSM (default)") %>% 
  addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") %>% 
  addFeatures(nafferton_fields_ll, group = "Nafferton Farm") %>% 
  addLayersControl(
    baseGroups = c("OSM (default)", "Satellite"), 
    overlayGroups = "Nafferton Farm",
    options = layersControlOptions(collapsed = TRUE)
  )

#Now adding conventional or organic 
# Organic or conventional
leaflet() %>%
  addTiles(group = "OSM (default)") %>% 
  addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") %>% 
  addFeatures(nafferton_fields_ll[nafferton_fields_ll$Farm_Meth=="Organic",],
              fillColor="green",
              color="white",
              opacity =0.7,
              fillOpacity=1,
              group = "Organic") %>% 
  addFeatures(nafferton_fields_ll[nafferton_fields_ll$Farm_Meth=="Conventional",],
              fillColor="red",
              color="yellow", 
              fillOpacity=1,
              group = "Conventional") %>% 
  addLayersControl(
    baseGroups = c("OSM (default)", "Satellite"), 
    overlayGroups = c("Organic", "Conventional"),
    options = layersControlOptions(collapsed = TRUE)
  )

#Integration with shiny ----

