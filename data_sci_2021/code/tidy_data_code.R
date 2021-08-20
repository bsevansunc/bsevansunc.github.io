
# setup -------------------------------------------------------------------

library(tidyverse)

# Names of files we will use for this lesson:

file_names <-
  c('badDate',
    'badYear',
    'bird_rawCounts',
    'birdHabits',
    'dfTooLong',
    'wideFrame',
    'untidyFrame',
    'badBandingRecord')

# Read the files from my GitHub account (a necessary evil, currently):

file_names %>% 
  purrr::map(
    ~ file.path(
      'https://raw.githubusercontent.com/bsevansunc',
      'smsc_data_science/master/data',
      str_c(., '.csv')) %>% 
      read_csv()) %>% 
  set_names(file_names) %>% 
  list2env(envir = .GlobalEnv)

# Remove file_names for a clean global environment:

rm(file_names)

# I've got one more frame I would like to add:

really_bad_date <-
  tibble(
    month = 3,
    day = 10,
    year = 2021)

# Each variable forms a column --------------------------------------------

# Dealing with variables combined into a single column (separate):

badDate

separate(
  data = badDate,
  col = observationDate,
  into = c('date1', 'date2'),
  sep = ", ")

# Dealing with a single variable split into multiple columns (unite):

really_bad_date

unite(
  data = really_bad_date, 
  col = 'date', 
  c(year, month, day), 
  sep = '-')

# Dealing with transitive columns:

badYear

# By position: 

select(badYear, 1:4)

select(badYear, -5)

# By name:

select(badYear, id:mass)

select(badYear, -observationYear)

# Each observation forms a row --------------------------------------------

# Dealing with multiple observations in a row:

untidyFrame

pivot_longer(
  data = untidyFrame,
  cols = treatmentA:treatmentB,
  names_to = 'treatment',
  names_prefix = 'treatment',
  values_to = 'value')

# Dealing with multiple rows per observation:

dfTooLong

pivot_wider(
  data = dfTooLong,
  names_from = measurement,
  values_from = value)

# Pivot wider:

pivot_wider(
  data = dfTooLong,
  names_from = measurement,
  values_from = value)

# Each level of observation forms a table ---------------------------------

badBandingRecord

bird_list <-
  list(
    birds = 
      select(
        badBandingRecord,
        birdID,
        observationDate,
        site,
        mass),
    sites =  
      select(
        badBandingRecord,
        site,
        canopyCover))

bird_list[[2]] <- 
  distinct(bird_list[[2]])

bird_list




