pacman::p_load(tidyverse,
               sf,
               mapview,
               here)


# spatial join ------------------------------------------------------------

(sf_nc_county <- st_read(dsn = here("data/nc.shp"),
                         quiet = TRUE))
(sf_site <- readRDS(here("data/sf_finsync_nc.rds")))
(sf_str_guilford <- readRDS(here("data/sf_stream_gi.rds")))

#st_join() evaluates two geometry layers
sf_site_join <- st_join(x = sf_site, # base layer
                        y = sf_nc_county) # overlaying layer
print(sf_site)
print(sf_site_join)

#how it works
sf_one <- sf_site %>% 
  slice(1)
mapview(sf_nc_county) + mapview(sf_one)

#get data by county
sf_site_guilford <- sf_site_join %>% 
  filter(county == "guilford")

sf_nc_guilford <- sf_nc_county %>% 
  filter(county == "guilford")


ggplot() +
  geom_sf(data = sf_nc_guilford) +
  geom_sf(data = sf_str_guilford,
          color = "steelblue") +
  geom_sf(data = sf_site_guilford,
          color = "tomato") +
  theme_bw()

df_n <- sf_site_join %>% 
  as_tibble() %>% 
  group_by(county) %>% 
  summarize(count_site = n()) %>% 
  arrange(desc(count_site))


sf_nc_n <- sf_nc_county %>% 
  left_join(df_n, by = "county") %>% 
  mutate(count_site = ifelse(is.na(count_site),
                         0,
                         count_site))
print(sf_nc_n)

ggplot()+
  geom_sf(data = sf_nc_n,
          aes(fill = count_site))
  
# geometric analysis ------------------------------------------------------

#length calculation
(sf_str_proj <- st_transform(sf_str_guilford, crs = 32617))

v_str_l <- st_length(sf_str_proj)
head(v_str_l)

sf_str_w_len <- sf_str_guilford %>% 
  mutate(length = as.numeric(v_str_l))

ggplot() +
  geom_sf(data = sf_str_w_len,
          aes(color = length))

#area calculation
(sf_nc_county_proj <- st_transform(sf_nc_county, crs = 32617))

v_area <- st_area(sf_nc_county)
head(v_area)

(sf_nc_county_w_area <- sf_nc_county %>% 
    mutate(area = as.numeric(v_area/ 1e+6)))

ggplot()+
  geom_sf(data = sf_nc_county_w_area,
          aes(fill = area))


# exercise  ---------------------------------------------------------------

sf_quakes <- readRDS(here("data/sf_quakes.rds"))
sf_nz <- readRDS(here("data/sf_nz.rds"))

mapview(sf_nz) + mapview(sf_quakes)


sf_quakes_join <- st_join(x = sf_quakes, 
                        y = sf_nz)

sf_quakes_nz <-sf_quakes_join %>% 
  drop_na(fid)


sf_quakes_nz %>% 
  nrow()
mapview(sf_quakes_nz)

sf_n_site <- sf_site_join %>% 
  group_by(county) %>% 
  summarize(n_site = n())

sf_n10 <- sf_n_site %>% 
  filter(n_site > 10 )

ggplot()+
  geom_sf(data = sf_n_site,
          color = "grey") +
  geom_sf(data = sf_n10, 
          color = "salmon")
