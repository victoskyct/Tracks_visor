
library(sf)
library(leaflet)
library(leaflet.extras)

rutas<- st_read('rutas_FINAL.shp')

colnames(rutas) <- c('Nombre', 'Distancia_Km', 'Desnivel_Positivo', 'geometry')


rutas <- st_transform(rutas, crs="+proj=longlat +datum=WGS84 +no_defs")
st_geometry(rutas) <- 'geometry'


server <- function(input, output, session) {

  filteredData <- reactive({
    rutas[rutas$Distancia_Km >= input$range[1] & rutas$Distancia_Km <= input$range[2] &
            rutas$Desnivel_Positivo >= input$range2[1] & rutas$Desnivel_Positivo <= input$range2[2], ]
  })
    
  factpal <- colorFactor(topo.colors(5), rutas$Nombre)
  
  output$map <- renderLeaflet({

    leaflet(rutas) %>% addTiles() %>% addProviderTiles(providers$Esri.WorldTopoMap) %>%
      
      addPolylines(color= ~factpal(Nombre), label = paste("Nombre", rutas$Nombre, "<br>",
                                                          "Distancia:", rutas$Distancia_Km, "<br>",
                                                          "Desnivel:", rutas$Desnivel_Positivo))  %>%
      
      addDrawToolbar(
        targetGroup='rutas',
        editOptions = editToolbarOptions(selectedPathOptions = selectedPathOptions()))  
  })
  
  observe({
    
    leafletProxy("map", data = filteredData()) %>%
      clearShapes() %>%
      addPolylines(color= ~factpal(Nombre), label = paste("Nombre:", substr(rutas$Nombre, 0, 30),',',
                                                           "Distancia:", rutas$Distancia_Km,',',
                                                           "Desnivel:", rutas$Desnivel_Positivo))
  })

  
  output$downloadData <- downloadHandler(
    filename = function(){
      paste(input$filenames, '.gpx', sep='')
    },
    content = function(file) {
      write_sf(rutas[rutas$Nombre == input$filenames, ]$geometry, driver='GPX', file)
    }
  )
}
