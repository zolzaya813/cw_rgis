if (!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse,
               terra,
               sf,
               tidyterra,
               mapview,
               stars,
               here,
               exactextractr)

# data --------------------------------------------------------------------

## finsync survey site
sf_site <- readRDS(here("data/sf_finsync_nc.rds"))

## county polygons
sf_nc_county <- readRDS(here("data/sf_nc_county.rds"))

## precipitation raster
spr_prec_nc <- rast(here("data/spr_prec_nc.tif"))


# point-wise extraction ---------------------------------------------------

ggplot() +
  geom_spatraster(data = spr_prec_nc) +
  geom_sf(data = sf_site) +
  scale_fill_viridis_c() + # change color palette for raster
  theme_bw()

# # The following code works exactly as:
# spr_site_prec <- extract(x = spr_prec_nc,
#                          y = sf_site,
#                          bind = TRUE)
# 
# sf_site_prec <- st_as_sf(spr_site_prec)


(sf_site_prec <- extract(x = spr_prec_nc, #always put the raster data
                         y = sf_site,
                         bind = TRUE) %>% 
    st_as_sf()) #converts into sf file

ggplot() +
  geom_sf(data = sf_nc_county,       # Plot county boundaries as a grey background
          fill = "gray85") + 
  geom_sf(data = sf_site_prec,       # Plot survey points colored by precipitation
          aes(color = precipitation)) +
  scale_color_viridis_c() +          # Apply a perceptually uniform color scale
  theme_bw()                        # Use a clean black-and-white theme



# zonal statistics --------------------------------------------------------

#POLYGON-BASED

##transform geodedic to projected crs

#st_transform() - for vector data - polygon
sf_nc_county_proj <- st_transform(sf_nc_county,
                                  crs = 32617)
#project() - for raster data
spr_prec_nc_proj <- project(x = spr_prec_nc, 
                            y = "EPSG: 32617",
                            method = "bilinear") 


# NOTE: `progress = FALSE` turns off the progress bar for cleaner output
(df_prec_county <- exact_extract(x = spr_prec_nc_proj, # x will be always raster
                                 y = sf_nc_county_proj,
                                 fun = "mean",
                                 append_cols = TRUE,
                                 progress = FALSE) %>% 
    as_tibble() %>% # convert to tibble
    rename(precipitation = mean)) # rename the output column)

(df_prec_county_stdev <- exact_extract(x = spr_prec_nc_proj, # x will be always raster
                                 y = sf_nc_county_proj,
                                 fun = "stdev",
                                 append_cols = TRUE,
                                 progress = FALSE) %>% 
    as_tibble())


(sf_nc_county_prec <- sf_nc_county %>% 
    left_join(df_prec_county,
              by = "county"))

ggplot() +
  geom_sf(data = sf_nc_county_prec,
          aes(fill = precipitation),
          color = "gray50") +
  scale_fill_viridis_c() +
  theme_bw()

#buffer based analysis


#transform to geodedic to projected
sf_site_proj <- sf_site %>%
  st_transform(crs = 32617)

#create a buffer zone - st_buffer() creates buffer
sf_site_buff_proj <- sf_site_proj %>%
  st_buffer(dist = 10000) # unit is meter in a projected CRS

ggplot()+
  geom_sf(data = sf_nc_county_proj) +
  geom_sf(data = sf_site_buff_proj,
          fill = "gold") +
  geom_sf(data = sf_site_proj) +
  theme_bw()

#calculate the mean precip for each site buffer
(df_prec_buff <- exact_extract(x = spr_prec_nc_proj,
                                      y = sf_site_buff_proj,
                                      fun = "mean",
                                      append_cols = TRUE) %>% 
  as_tibble() %>% 
  rename(precipitation = mean))

#link to site layer
(sf_site_prec_buff <- sf_site %>% 
    left_join(df_prec_buff,
              by = "site_id"))

#high precipitation sites
sf_site_prec_buff %>% 
  arrange(desc(precipitation)) %>% 
  slice(1:3)
  

#visualize
ggplot() +
  geom_sf(data = sf_nc_county,
          fill = "gray85") + 
  geom_sf(data = sf_site_prec_buff,
          aes(color = precipitation)) +
  scale_color_viridis_c() +
  theme_bw()
