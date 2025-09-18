if (!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse,
               sf,
               mapview)

df_fish <- read_csv("data/data_finsync_nc.csv")
print(df_fish)

sf_site <- df_fish %>% 
  distinct(site_id, lon, lat) %>% # get unique combinations of longitude & latitude
  st_as_sf(coords = c("lon", "lat"),
           crs = 4326)

print(sf_site)

mapview(sf_site,
        legend = FALSE)

##export data
saveRDS(sf_site,
        file = "data/sf_finsync_nc.rds")

# conversion from geodetic to projected -----------------------------------

sf_ft_wgs <- sf_site %>% 
  slice(c(1, 2)) # slice selects by the rows

print(sf_ft_wgs)

sf_ft_utm <- sf_ft_wgs %>% 
  st_transform(crs = 32617)

print(sf_ft_utm)

st_distance(sf_ft_utm)


# exercise ----------------------------------------------------------------

df_quakes <- as.tibble(quakes)
print(df_quakes)

sf_quakes <- df_quakes %>% 
  st_as_sf(coords = c("long", "lat"),
           crs = 4326)

mapview(sf_quakes, legend = FALSE)

sf_ft_quakes <- sf_quakes %>% 
  slice(c(1,2))

sf_ft_quakes_proj <- sf_ft_quakes %>% 
  st_transform(crs = 32760 )

st_distance(sf_ft_quakes_proj)

saveRDS(sf_quakes, file = "data/sf_quakes.rds")
