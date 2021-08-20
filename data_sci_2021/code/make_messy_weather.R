library(rnoaa)
library(sf)

stations <-
  ghcnd_stations()

station_subset <-
  stations %>% 
  filter(nchar(state) > 0) %>% 
  filter(last_year >= 2020) %>% 
  filter(first_year <= 2010) %>% 
  filter(state %in% c('CA', 'MD', 'VA', 'DC', 'NY', 'NC', 'WI', 'FL', 'MI')) %>% 
  select(id:name) %>% 
  distinct()

station_subset %>% 
  st_as_sf(coords = c('longitude', 'latitude')) %>% 
  st_write('test.kml', append = FALSE)

my_stations <-
  c(
    'US1FLIR0019', # florida
    'USC00311677', # chapel hill
    'US1NCDH0006', # asheville
    'USW00094728', # central park
    'USC00304174', # ithaca
    'US1MIWS0011', # ann ar bor
    'USC00470273', # madison
    'USC00040693'  # berkely
  )
  
ncdc(
  datasetid='GHCND', 
  stationid='GHCND:USC00315356',
  startdate = '2010-09-01', 
  enddate = '2010-10-31', 
  token = 'zZYFjikCJCWYYDRCtGkCGRdcWPhWzNue',
  datatypeid = c('PRCP', 'SNOW', 'TMAX', 'TMIN'),
  limit=500) %>% 
  .$data %>% 
  select(date:value) %>% 
  mutate(date = str_remove(date, 'T00:00:00') %>% 
           lubridate::as_date())

example_weather <-
    purrr::map_dfr(
      2010:2020,
      function (yr) {
        ncdc(
          datasetid='GHCND', 
          stationid= str_c('GHCND:', my_stations),
          startdate = str_c(yr,'03-01', sep = '-'), 
          enddate = str_c(yr,'03-31', sep = '-'), 
          token = 'zZYFjikCJCWYYDRCtGkCGRdcWPhWzNue',
          datatypeid = c('PRCP', 'SNOW', 'TMAX', 'TMIN'),
          limit = 1000) %>% 
          .$data
      })


messy_weather <-
  example_weather %>% 
  select(date:value) %>% 
  mutate(value = ifelse(datatype != 'SNOW', value * .1, value)) %>% 
  pivot_wider(names_from = datatype, values_from = value) %>% 
  filter(!is.na(TMAX), !is.na(TMIN)) %>% 
  mutate(date = str_remove(date, 'T00:00:00') %>% 
           lubridate::as_date()) %>% 
  mutate(temperature_min_max = str_c(TMIN, TMAX, sep = ':')) %>% 
  select(-c(TMAX, TMIN)) %>% 
  rename(precip = PRCP, snow = SNOW) %>% 
  mutate_at(vars(precip, snow), ~ as.character(.)) %>% 
  pivot_longer(precip:temperature_min_max, names_to = 'variable') %>% 
  mutate(
    day = lubridate::mday(date),
    month = 3,
    year = lubridate::year(date)) %>% 
  select(
    station,
    year,
    month,
    variable, 
    day, 
    value) %>% 
  pivot_wider(names_from = day, values_from = value, names_prefix = 'march_') %>% 
  mutate(station = str_remove(station, 'GHCND:')) %>% 
  left_join(
    station_subset %>% 
      rename(station = id), 
    by = 'station') %>% 
  select(station, longitude, latitude, elevation:name, year:march_31) %>% 
  mutate_at(vars(year, month), ~ as.character(.))

write_csv(messy_weather, 'data/messy_weather.csv')


list(
  stations = 
    read_csv('data/messy_weather.csv') %>% 
    select(station:name) %>% 
    distinct(),
  observations = 
    read_csv('data/messy_weather.csv') %>% 
    pivot_longer(march_1:march_31, names_to = 'day', names_prefix = "march_") %>% 
    pivot_wider(names_from = variable, values_from = value) %>% 
    separate(temperature_min_max, sep = ':', into = c('tmin', 'tmax')) %>% 
    unite(year:day, col = 'date', sep = '-') %>% 
    select(station, date:tmax))
