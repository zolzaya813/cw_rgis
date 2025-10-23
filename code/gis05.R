if (!require(pacman)) install.packages("pacman")

pacman::p_load(tidyverse,
               terra,
               sf,
               tidyterra,
               mapview,
               stars,
               here)


# crop --------------------------------------------------------------------

(spr_prec <- rast(here("data/spr_prec_us.tif"))) #US-wide precipitation layer

# ggplot()+
#   geom_spatraster(data = spr_prec)

#ext() - extent of the layer
ext(spr_prec)

#crop() - ditect entry of lat/long
## crop to:
## longitude range: -80 to -75
## latitude range: 34 to 37
spr_prec_crop <- crop(x = spr_prec, # raster layer to be cropped
                      y = c(-80, -75, 34, 37))
ext(spr_prec_crop)

sf_nc_county <- readRDS(here("data/sf_nc_county.rds"))

ggplot()+
  geom_spatraster(data = spr_prec_crop) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25) 

##Vector extent
spr_prec_nc <- crop(x = spr_prec,
                    y = sf_nc_county)

ggplot() +
  geom_spatraster(data = spr_prec_nc) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25)


# Merge -------------------------------------------------------------------

#combines panels with same size

spr_nw <- rast(here("data/spr_prec_ncnw.tif")) # Northwest NC
spr_ne <- rast(here("data/spr_prec_ncne.tif")) # Northeast NC
spr_sw <- rast(here("data/spr_prec_ncsw.tif")) # Southwest NC
spr_se <- rast(here("data/spr_prec_ncse.tif")) # Southeast NC

ggplot() +
  geom_spatraster(data = spr_nw) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25)

##two files
spr_n <- merge(spr_nw, spr_ne)

ggplot() +
  geom_spatraster(data = spr_n) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25)

ext(spr_n)

##more than two raster files
### 1st step: create a list of raster layers
list_spr <- list(spr_nw,
                 spr_ne,
                 spr_sw,
                 spr_se)

#2nd step:converting list format into SpatRasterCollection by sprc() function
spr_col <- sprc(list_spr) 

spr_merge <- merge(spr_col)
ext(spr_merge)

ggplot() +
  geom_spatraster(data = spr_merge) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25)

#export 
writeRaster(spr_merge, 
            filename = here("data/spr_prec_nc.tif"),
            overwrite = TRUE)


# stack -------------------------------------------------------------------

spr_prec_nc <- rast(here("data/spr_prec_nc.tif"))
spr_tmp_nc <- rast(here("data/spr_tmp_nc.tif"))

print(spr_prec_nc)

spr_pt_nc <- c(spr_prec_nc,
               spr_tmp_nc)

print(spr_pt_nc)


# reprojection ------------------------------------------------------------
##convert CRS for raster file. (x = raster, y = target CRS)
### after the transformation, you cannot convert back - you will loose data
(spr_prec_nc_proj <- project(x = spr_prec_nc,
                             y = "EPSG:32617",
                             method = "bilinear"))

# exersice ----------------------------------------------------------------
##1
spr_tmp_nw <- rast(here("data/spr_tmp_ncnw.tif")) 
spr_tmp_ne <- rast(here("data/spr_tmp_ncne.tif"))
spr_tmp_sw <- rast(here("data/spr_tmp_ncsw.tif"))
spr_tmp_se <- rast(here("data/spr_tmp_ncse.tif"))

# sf_nc_county <- readRDS("data/sf_nc_county.rds")

list_tmp <- list(spr_tmp_nw,
                 spr_tmp_ne,
                 spr_tmp_sw,
                 spr_tmp_se)

spr_tmp_col <- sprc(list_tmp)

spr_tmp_merge <- merge(spr_tmp_col)

ggplot() +
  geom_spatraster(data = spr_tmp_merge) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25)

##2
sf_camden <- sf_nc_county %>% 
  filter(county == "camden")

ext(sf_camden)

spr_tmp_camden <- crop(x = spr_tmp_merge,
                       y = sf_camden)

ggplot() +
  geom_spatraster(data = spr_tmp_camden) +
  geom_sf(data = sf_nc_county,
          alpha = 0.25)

print(spr_tmp_camden)

##3
(spr_tmp_camden_proj <- project(x = spr_tmp_camden,
                                y = "EPSG:32618"))


