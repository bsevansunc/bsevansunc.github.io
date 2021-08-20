
# Set up ------------------------------------------------------------------

# If lubridate is not installed, do so now (uncomment line):

# install.packages('lubridate')

# Load libraries:

library(tidyverse)
library(lubridate)

# List files in your working directory:

list.files()

# If you don't see the value "data" in your list:

# dir.create("data")

# Put the file messy_weather.csv inside the data directory if it isn't 
# already there. 

# Load file into R:

messy_weather <-
  read_csv('data/messy_weather.csv')

# Review: Functions -------------------------------------------------------

# Comparing primitive (C) and R functions:

`<-`

`sd`

# Make a simple R function that multiplies a given value, x, by two:

multiply_by_two <-
  function(x) {
    x*2
  }

# Print the formals, body, and environment of the function:

formals(multiply_by_two)

body(multiply_by_two)

environment(multiply_by_two)

# Everything but the last section of a function is in the function's 
# environment and will not be passed to the global environment:

losing_a_y <-
  function(x) {
    y <- x
    y*2
  }

losing_a_y(3)

y

# What does setting a return do?

losing_a_y <-
  function(x) {
    y <- x
    return(y)
    y*2
  }

losing_a_y(3)

y

# Forcing something into your global environment:

losing_a_y <-
  function(x) {
    y <<- x
    y*2
  }

losing_a_y(3)

y

# nested functions --------------------------------------------------------

# Initial values:

my_vector <-
  1:5

# Add another silly function for illustration:

add_one <-
  function(x) {
    x+1
  }

# Non-nested, new object for each step:

my_vector <-
  1:5

my_vector2 <-
  multiply_by_two(my_vector)

add_one(my_vector2)

# Non-nested, overwrite object for each step:

my_vector <-
  1:5

my_vector <-
  multiply_by_two(my_vector)

add_one(my_vector)

# Nested:

add_one(
  multiply_by_two(1:5))

# The pipe! ---------------------------------------------------------------

# The above, piped version:

1:5 %>%
  multiply_by_two() %>%
  add_one()

# Clean the environment:

# - See the bindings in your global environment:

objects()

# - Remove objects we won't use again:

rm(multiply_by_two)

rm(losing_a_y)

rm(y)

rm(my_vector)

rm(add_one)

rm(my_vector2)

# The pipe in action! -----------------------------------------------------

# Look at the messy data:

messy_weather

# Normalization, long days, not piped:

messy_weather_long_days <-
  pivot_longer(
    data = messy_weather,
    cols = march_1:march_31,
    names_to = 'day',
    values_to = 'value',
    names_prefix = 'march_')

messy_weather_long_days

# Normalization, long days, piped:

messy_weather %>%
  pivot_longer(
    cols = march_1:march_31,
    names_to = 'day',
    values_to = 'value',
    names_prefix = 'march_')

# Normalization, fix dates, not piped:

messy_weather_date_fix <-
  unite(
    messy_weather_long_days,
    c('year', 'month', 'day'),
    col = 'date',
    sep = '-',
    na.rm = TRUE)

messy_weather_date_fix

# Normalization, fix dates, piped:

messy_weather_long_days %>%
  unite(
    c('year', 'month', 'day'),
    col = 'date',
    sep = '-',
    na.rm = TRUE)

# Normalization, observations in more than one row, not piped:

messy_weather_wide_weather <-
  pivot_wider(
    messy_weather_date_fix,
    names_from = variable,
    values_from = value)

messy_weather_wide_weather

# Normalization, observations in more than one row, piped:

messy_weather_date_fix %>%
  pivot_wider(
    names_from = variable,
    values_from = value)

# Normalization, multiple variables in one column, not piped:

messy_weather_temperature_fix <-
  separate(
    messy_weather_wide_weather,
    col = temperature_min_max,
    into = c('temperature_min', 'temperature_max'),
    sep = ':')

messy_weather_temperature_fix

# Normalization, multiple variables in one column, piped:

messy_weather_wide_weather %>%
  separate(
    col = temperature_min_max,
    into = c('temperature_min', 'temperature_max'),
    sep = ':')

# Normalization, more than one level of observation in a table, not piped:

weather_stations <-
  distinct(
    select(
      messy_weather_temperature_fix,
      station:name))

observations <-
  select(
    messy_weather_temperature_fix,
    station, date:temperature_max)

weather_stations

# Normalization, more than one level of observation in a table, piped:

weather_stations <-
  messy_weather_temperature_fix %>%
  select(station:name) %>%
  distinct()

observations <-
  messy_weather_temperature_fix %>%
  select(station, date:temperature_max)

# Normalization, full not piped version:

messy_weather <-
  read_csv('data/messy_weather.csv')

messy_weather_long_days <-
  pivot_longer(
    data = messy_weather,
    cols = march_1:march_31,
    names_to = 'day',
    values_to = 'value',
    names_prefix = 'march_')

messy_weather_date_fix <-
  unite(
    messy_weather_long_days,
    c('year', 'month', 'day'),
    col = 'date',
    sep = '-',
    na.rm = TRUE)

messy_weather_wide_weather <-
  pivot_wider(
    messy_weather_date_fix,
    names_from = variable,
    values_from = value)

messy_weather_temperature_fix <-
  separate(
    messy_weather_wide_weather,
    col = temperature_min_max,
    into = c('temperature_min', 'temperature_max'),
    sep = ':')

weather_stations <-
  distinct(
    select(
      messy_weather_temperature_fix,
      station:name))

observations <-
  select(
    messy_weather_temperature_fix,
    station, date:temperature_max)

# Normalization, full piped version:

messy_weather_temperature_fix <-
  read_csv('data/messy_weather.csv') %>%
  pivot_longer(
    cols = march_1:march_31,
    names_to = 'day',
    values_to = 'value',
    names_prefix = 'march_') %>%
  unite(
    c('year', 'month', 'day'),
    col = 'date',
    sep = '-',
    na.rm = TRUE) %>%
  pivot_wider(
    names_from = variable,
    values_from = value) %>%
  separate(
    col = temperature_min_max,
    into = c('temperature_min', 'temperature_max'),
    sep = ':')

weather_stations <-
  messy_weather_temperature_fix %>%
  select(station:name) %>%
  distinct()

observations <-
  messy_weather_temperature_fix %>%
  select(station, date:temperature_max)

# Clean the environment:

# - See the bindings in your global environment:

objects()

# - Remove objects we won't use again:

rm(messy_weather)

rm(messy_weather_long_days)

rm(messy_weather_date_fix)

rm(messy_weather_wide_weather)

rm(messy_weather_temperature_fix)

objects()

# introduction to mutate --------------------------------------------------

glimpse(weather_stations)

glimpse(observations)

# Making year a proper date column in Base R:

temp <-
  observations

temp$date <-
  lubridate::as_date(temp$date)

glimpse(temp)

# Making year a proper date column in tidyverse, but without a pipe:

mutate(
  .data = observations,
  date = lubridate::as_date(date)) %>%
  glimpse()

# Making year a proper date column in tidyverse, with a pipe:

observations %>%
  mutate(date = lubridate::as_date(date)) %>%
  glimpse()

# Making multiple variables numeric in Base R:

temp <-
  observations

temp$precip <-
  as.numeric(temp$precip)

temp$snow <-
  as.numeric(temp$snow)

temp$temperature_min <-
  as.numeric(temp$temperature_min)

temp$temperature_max <-
  as.numeric(temp$temperature_max)

glimpse(temp)

# Making multiple variables numeric in tidyverse, without a pipe:

mutate_at(
  observations,
  vars(precip:temperature_max),
  as.numeric) %>%
  glimpse()

# Making multiple variables numeric in tidyverse, with a pipe:

observations %>%
  mutate_at(
    vars(precip:temperature_max),
    as.numeric) %>%
  glimpse()

# Bringing the formatted date back into the mix:

observations %>%
  mutate(date = lubridate::as_date(date)) %>%
  mutate_at(
    vars(precip:temperature_max),
    as.numeric) %>%
  glimpse()

# Doing all of the tidying and initial mutating in one step:

messy_weather_temperature_fix <-
  read_csv('data/messy_weather.csv') %>%
  pivot_longer(
    cols = march_1:march_31,
    names_to = 'day',
    values_to = 'value',
    names_prefix = 'march_') %>%
  unite(
    c('year', 'month', 'day'),
    col = 'date',
    sep = '-',
    na.rm = TRUE) %>%
  pivot_wider(
    names_from = variable,
    values_from = value) %>%
  separate(
    col = temperature_min_max,
    into = c('temperature_min', 'temperature_max'),
    sep = ':') %>%
  mutate(date = lubridate::as_date(date)) %>%
  mutate_at(
    vars(precip:temperature_max),
    as.numeric)

weather_stations <-
  messy_weather_temperature_fix %>%
  select(station:name) %>%
  distinct()

observations <-
  messy_weather_temperature_fix %>%
  select(station, date:temperature_max)

glimpse(weather_stations)

# Cleaning that messy R environment:

objects()

rm(temp)

rm(messy_weather_temperature_fix)

objects()

# introduction to filtering -----------------------------------------------

# Filter by state, base R:

weather_stations[weather_stations$state == 'NY',]

# Tidyverse filter, not piped:

filter(weather_stations, state == 'NY')

# Tidyverse filter, piped:

weather_stations %>%
  filter(state == 'NY')

# Multiple filter in base R:

weather_stations[weather_stations$state == 'NY' & weather_stations$elevation > 100,]

# Multiple filter, tidyverse:

weather_stations %>%
  filter(state == 'NY' & elevation > 100)

# Multiple filter with comma:

weather_stations %>%
  filter(
    state == 'NY',
    elevation > 100)

# Pulling at the end of a filter:

weather_stations %>%
  filter(
    state == 'NY',
    elevation > 100) %>%
  pull()

# Using pulled data to filter another table:

observations %>%
  filter(
    station %in% {
      weather_stations %>%
        filter(
          state == 'NY',
          elevation > 100) %>%
        pull(station)
    })

# Filtering with a function:

observations %>%
  filter(lubridate::year(date) == 2015)

# Filtering with multiple functions:

observations %>%
  filter(
    lubridate::year(date) == 2015,
    lubridate::day(date) == 15)

# Joining data ------------------------------------------------------------

# The bread-and-butter left join:

observations %>%
  left_join(
    weather_stations,
    by = 'station')

# Joining only a subset of columns:

observations %>%
  left_join(
    weather_stations %>%
      select(station, state),
    by = 'station')

# A filtered join:

observations %>%
  inner_join(
    weather_stations %>%
      filter(state == 'NY') %>%
      select(station),
    by = 'station')

# The dangers of joining data that aren't normalized!

temp1 <-
  tibble(
    key = fruit[c(1,1,2)],
    b = 3:5)

temp2 <-
  tibble(
    id = letters[1:3],
    key = fruit[c(1,2,2)])

temp1
temp2

temp1 %>%
  left_join(temp2, by = 'key')











