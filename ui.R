require(leaflet)
require(leaflet.extras)
require(sf)

rutas <- st_read('rutas_FINAL.shp')

colnames(rutas) <- c('Nombre', 'Distancia_Km', 'Desnivel_Positivo', 'geometry')


rutas <- st_transform(rutas, crs="+proj=longlat +datum=WGS84 +no_defs")
st_geometry(rutas) <- 'geometry'



ui <- bootstrapPage(
  leafletOutput("map", height = 1000, width = 2000),
  absolutePanel(top = 10, right = 10,
                sliderInput('range', 'Distancia', min(rutas$Distancia_Km), max(rutas$Distancia_Km), value = range(rutas$Distancia_Km), step=0.2),
                sliderInput('range2', 'Desnivel positivo', min(rutas$Desnivel_Positivo), max(rutas$Desnivel_Positivo), value = range(rutas$Desnivel_Positivo), step=10),
                tags$style(type = "text/css"), 
                sidebarLayout(
                  sidebarPanel(width = 10,
                               selectInput("filenames", "Select the file you want to download:", rutas$Nombre), 
                               downloadButton('downloadData', 'Download')), 
                  mainPanel(tableOutput('table')))
                
  ))
