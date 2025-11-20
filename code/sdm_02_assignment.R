# setup -------------------------------------------------------------------
rm(list = ls())

if (!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse,
               ggeffects,
               sf,
               terra,
               tidyterra,
               exactextractr,
               mapview,
               here,
               patchwork)

# data --------------------------------------------------------------------

(spr_elev_mgl <- rast(here("shapefiles/Mongolia//Mongolia_DEM_SRTM/Mongolia_SRTM_DEM.tif")))

df_data <- read_csv(here("data/df_data_extended_general_locality_updated_111825.csv"))

#selected two  most abundant species that one is the highest in weight and other one is lowest
##Sorex caecutiens - 5.67g ~ shrew
##Urocitellus undulatus - 288.23g ~ ground_squirrel

df_data_sp <- df_data %>%
  mutate(presence = 1) %>%
  pivot_wider(
    id_cols = c(year, aimag_name_eng, soum_name_eng, spec_locality_general),
    names_from = SCIENTIFIC_NAME,
    values_from = presence,
    values_fn = ~ as.integer(any(.x == 1)),
    values_fill = 0
  ) %>%
  distinct(year,
           aimag_name_eng,
           soum_name_eng,
           spec_locality_general,
           .keep_all = TRUE) %>%
  select(year,
    aimag_name_eng,
    soum_name_eng,
    spec_locality_general,
    "Urocitellus undulatus",
    "Sorex caecutiens"
  ) %>%
  rename(y = "Urocitellus undulatus", z = "Sorex caecutiens") %>%
  drop_na(y)

df_data_site <- df_data %>% 
  group_by(year, aimag_name_eng,soum_name_eng,spec_locality_general) %>% 
  summarize(lon = mean(DEC_LONG),
            lat = mean(DEC_LAT)) %>% 
  ungroup() %>% 
  drop_na(lon)

df_data_wider <- df_data_site %>% 
  left_join(df_data_sp, by = c("year","aimag_name_eng", "soum_name_eng", "spec_locality_general"))

sum(df_data_wider$y)
# visualize ---------------------------------------------------------------

(sf_site <- df_data_wider %>% 
  st_as_sf(coords = c("lon", "lat"),
           crs = 4326))

sf_site <- st_transform(sf_site, crs = crs(spr_elev_mgl))

(sf_site_w_elev <- extract(x = spr_elev_mgl,
                         y = sf_site,
                         bind = TRUE) %>% 
    st_as_sf())

(sf_site_w_elev <- sf_site_w_elev %>%
  mutate(species =
           case_when(
             y == 1 & z == 0 ~ "Urocitellus_undulatus",
             y == 0 & z == 1 ~ "Sorex_caecutiens",
             y == 1 & z == 1 ~ "Both",
             TRUE ~ "None"
           )))
ggplot() +
  geom_spatraster(data = spr_elev_mgl) +
  geom_sf(data = sf_site_w_elev,
          aes(color = factor(species))) +
  scale_fill_viridis_c() +
  scale_color_manual(values = c("Sorex_caecutiens" = "red",
                               "Urocitellus_undulatus" = "blue",
                               "Both" = "purple",
                               "None" = "grey70")) +
  theme_bw()


# analysis ----------------------------------------------------------------

df_site_w_elev <- as_tibble(sf_site_w_elev) %>% 
  rename(elevation = Mongolia_SRTM_DEM)


(m_shrew <- glm(z ~ elevation,
              data = df_site_w_elev,
              family = "binomial"))
summary(m_shrew)

df_shrew_pred <- ggpredict(m_shrew,
                     terms = "elevation [all]")

(m_ground_squirrel <- glm(y ~ elevation,
                data = df_site_w_elev,
                family = "binomial"))
summary(m_ground_squirrel)
df_g_squirrel_pred <- ggpredict(m_ground_squirrel,
                           terms = "elevation [all]")

ground_squirrel <- ggplot() +
  geom_point(data = df_site_w_elev, aes(x = elevation, y = y)) +
  geom_line(data = df_g_squirrel_pred, aes(x = x, y = predicted)) +
  geom_ribbon(
    data = df_g_squirrel_pred,
    aes(x = x, ymin = conf.low, ymax = conf.high),
    fill = "grey",
    alpha = 0.2) +
  labs(title = "Urocitellus_undulatus", x = "Elevation", y = "Probability of occurrence") +
  theme_bw()

shrew <- ggplot() +
  geom_point(data = df_site_w_elev, aes(x = elevation, y = z)) +
  geom_line(data = df_shrew_pred, aes(x = x, y = predicted)) +
  geom_ribbon(
    data = df_shrew_pred,
    aes(x = x, ymin = conf.low, ymax = conf.high),
    fill = "grey",
    alpha = 0.2) +
  labs(title = "Sorex_caecutiens", x = "Elevation", y = "Probability of occurrence") +
  theme_bw()

(shrew | ground_squirrel)


# SPECIES RICHNESS --------------------------------------------------------

df_data_spec_richness <- df_data %>%
  group_by(year, aimag_name_eng, soum_name_eng, spec_locality_general) %>% 
  summarise(spec_richness = n())

df_data_spec_richness_w_elev <- df_site_w_elev %>% 
  left_join(df_data_spec_richness, by = c("year","aimag_name_eng", "soum_name_eng", "spec_locality_general"))

(m_spec_ricness <- MASS::glm.nb(spec_richness ~ elevation,
                                data = df_data_spec_richness_w_elev))
summary(m_spec_ricness)

df_spec_richness_pred <- ggpredict(m_spec_ricness,
                           terms = "elevation [all]")

(spec_richness <- ggplot() +
  geom_point(data = df_data_spec_richness_w_elev, aes(x = elevation, y = spec_richness)) +
  geom_line(data = df_spec_richness_pred, aes(x = x, y = predicted)) +
  geom_ribbon(
    data = df_spec_richness_pred,
    aes(x = x, ymin = conf.low, ymax = conf.high),
    fill = "grey",
    alpha = 0.2) +
  labs(title = "Species richness", x = "Elevation", y = "Probability of occurrence") +
  theme_bw())
