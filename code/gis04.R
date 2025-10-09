if (!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse,
               terra,
               sf,
               tidyterra,
               mapview,
               stars,
               here)

(spr_ex <- rast(here("data/spr_example.tif")))

#EXPORT DATA
# overwrite = TRUE enables overwriting
writeRaster(x = spr_ex, 
            filename = here("data/spr_elev.tif"),
            overwrite = TRUE)

#MAPPING
ggplot() +
  geom_spatraster(data = spr_ex)

#MAPVIEW FUNCTION
star_ex <- st_as_stars(spr_ex)
mapview(star_ex)

#RASTER DATA TYPES
##Continuous
v_elev <- values(spr_ex)
head(v_elev)

na.omit(v_elev) %>% 
  mean()

#EXTRACT DATA FROM A GIVEN LOCATION
##xy specifies long/lat

xy<- cbind(6.0000, 50.0000)
extract(spr_ex, xy)

df_point <- tibble(lon = c(6, 5.9),
                   lat = c(50, 49.96))
extract(spr_ex, df_point)
unique(spr_ex)

##Discrete
(spr_for <-rast(here("data/spr_forest_nc.tif")))

ggplot()+
  geom_spatraster(data = spr_for)

unique(spr_for)

v_binary <- values(spr_for)
(p_forest <- mean(v_binary))

###discrete coded values
(spr_land <- rast(here("data/spr_land_reclass.tif")))
unique(spr_land)
sullivan <- cbind(-79.8063, 36.0701)
extract(spr_land,sullivan ) #UNCG Sullivan Building

ggplot() +
  geom_spatraster(data = spr_land)

#RECLASSIFICATION
# write a conversion matrix
# left, original value
# right, value after conversion
(cm <- cbind(c(0, 1001, 1010, 1100),
             c(0, 1, 0, 0)))
(cm2 <- cbind(c(0, 1001, 1010, 1100),
             c(0, 0, 1, 0)))
(cm3 <- cbind(c(0, 1001, 1010, 1100),
             c(0, 0, 0, 1)))

spr_bin <- classify(spr_land,
                    rcl = cm)

v_bin <- values(spr_bin)
mean(v_bin)


ggplot() +
  geom_spatraster(data = spr_bin)


# EXERSICE ----------------------------------------------------------------
##1
(spr_prec_ncne <- rast(here("data/spr_prec_ncne.tif")))

##2
###There are 162 columns, 532 rows of data with one layer. 
###Each cell represents a rectangular area of 0.008333333 degrees in both longitude and latitude.
###Spatial extent shows -79.89181 for xmin, -75.45847 for xmax, 35.24153 for ymin, 36.59153 for ymax.
### The CRS is WGS84.
###Precipitation values are ranging from 1063.1 to 1501.5. 

##3
ggplot() +
  geom_spatraster(data = spr_prec_ncne)

##4
sf_site <- readRDS(here("data/sf_finsync_nc.rds"))

df_xy <- st_coordinates(sf_site)

df_land <- extract(spr_land, y =  df_xy)

table(df_land)

##5
(cm2 <- cbind(c(0, 1001, 1010, 1100),
             c(0, 0, 0, 1)))

spr_urban <- classify(spr_land,
                    rcl = cm2)

v_urban <- values(spr_urban)
mean(v_urban)
