library(tidyverse)
df0 <- tibble(x = 1:50, 
             y = x * 2)

df0 %>% 
  ggplot(aes(x = x, y = y )) +
  geom_line()+
  geom_point()

#histogram
iris %>% 
  ggplot(aes(x =Sepal.Length)) +
  geom_histogram()

iris %>% 
  ggplot(aes(x =Species,
             y = Sepal.Length,
             color = Species)) +
  geom_boxplot()

iris %>% 
  ggplot(aes(x =Species,
             y = Sepal.Length,
             fill = Species)) +
  geom_boxplot()

# ggplot exercise ---------------------------------------------------------

g_petal <- iris %>% 
  ggplot(aes(x = Petal.Width,
             y = Petal.Length)) +
  geom_point()
print(g_petal)


g_petal_box <- iris %>% 
  ggplot(aes(x = Species, y = Petal.Length, fill = Species)) +
  geom_boxplot()
print(g_petal_box)


# exercise ----------------------------------------------------------------

df_mtcars <- as.tibble(mtcars)

#select rows with cyl 4
filter(df_mtcars, cyl == 4 )

#select specific columns
select(df_mtcars,
       c(mpg, cyl, disp, wt, vs, carb))

#select rows with cyl is >4
#then select colums of mpg, cyl, disp, wt, vs, carb
#assign to df_sub
df_sub <- mtcars %>% 
  filter(cyl > 4 ) %>% 
  select(mpg, cyl, disp, wt, vs, carb)

v_car <- rownames(mtcars)

df_mtcars <- mtcars %>%
  mutate(car = v_car)

#identivy the lightest car ("wt) with cyl = 8
mtcars %>% 
  filter (cyl == 8) %>% 
  arrange(wt)

#calculate average of the cars within each group of gears
df_mean <- mtcars %>% 
  group_by(gear) %>% 
  summarise(wt_mean = mean(wt))
print(df_mean)


#combination of dplyr operations with ggplot
df_mtcars %>% 
  filter( cyl == 6) %>% 
  ggplot(aes(x = wt, y = qsec)) + 
  geom_point()

df_mtcars %>% 
  group_by(gear) %>% 
  summarise(wt_mean = mean(wt),
            qsec_mean = mean(qsec)) %>% 
  ggplot(aes(x = wt_mean, y = qsec_mean)) +
  geom_point()

