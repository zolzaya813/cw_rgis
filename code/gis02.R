pacman::p_load(tidyverse,
               sf,
               mapview,
               here)


# read/export vector data -------------------------------------------------

# read a shapefile (e.g., ESRI Shapefile format)
# `quiet = TRUE` just for cleaner output
(sf_nc_county <- st_read(dsn = here::here("data/nc.shp"),
                         quiet = TRUE))

# save as shapefile (overwrites by setting append = FALSE)
st_write(sf_nc_county, 
         dsn = here::here("data/sf_nc_county.shp"),
         append = FALSE) # If it's TRUE it adds data to existing file 

# save as Geo package (overwrites by setting append = FALSE)
st_write(sf_nc_county, 
         dsn = here::here("data/sf_nc_county.gpkg"),
         append = FALSE) 

# save as an RDS file (compact and efficient for use within R)
saveRDS(sf_nc_county,
        file = here::here("data/sf_nc_county.rds"))

# read from an RDS file
sf_nc_county <- readRDS(file = here::here("data/sf_nc_county.rds"))


# Points ------------------------------------------------------------------

(sf_site <- readRDS(here::here("data/sf_finsync_nc.rds")))

mapview(sf_site,
        col.regions = "black", # point's fill color
        legend = FALSE) # disable legend

## first 10 sites
(sf_site_f10 <- sf_site %>% 
    slice(1:10))
mapview(sf_site_f10,
        col.regions = "black", # point's fill color
        legend = FALSE) # disable legend

# Line --------------------------------------------------------------------

(sf_str <- readRDS(here::here("data/sf_stream_gi.rds")))
mapview(sf_str,
        color = "steelblue", # line's color
        legend = FALSE) # disable legend

## first 10 line strings
(sf_str_f10 <- sf_str %>% 
    slice(1:10))
mapview(sf_str_f10,
        color = "steelblue", # line's color
        legend = FALSE) # disable legend


# Polygon -----------------------------------------------------------------

(sf_nc_county <- readRDS(here::here("data/sf_nc_county.rds")))
mapview(sf_nc_county,
        col.regions = "grey", # polygon's fill color
        legend = FALSE) # disable legend

(sf_nc_gi <- sf_nc_county %>% 
    filter(county == "guilford"))

mapview(sf_nc_gi,
        col.regions = "grey", # polygon's fill color
        legend = FALSE) # disable legend

ggplot() +
  geom_sf(data = sf_nc_gi,
          fill = "forestgreen",
          alpha = 0.3) +
  geom_sf(data = sf_str,
          color = "steelblue")


# Exercise ----------------------------------------------------------------

sf_str_as <- readRDS(here::here("data/sf_stream_as.rds"))
print(sf_str_as)
print(sf_nc_county)

# st_write(sf_str_as,
#          dsn = "data/sf_stream_as.gpkg",
#          append = FALSE)
 
ggplot() +
  geom_sf(data = sf_nc_county) +
  geom_sf(data = sf_str_as)

sf_nc_as <- sf_nc_county %>% 
  filter(county == "ashe")
print(sf_nc_as)

ggplot() +
  geom_sf(data = sf_nc_as,
          fill = "forestgreen",
          alpha = 0.2) +
  geom_sf(data = sf_str_as,
          color = "steelblue")+
  theme_bw()

