
# setup -------------------------------------------------------------------

library(tidyverse)

# Names of files we will use for this lesson:

file_names <-
  c('bird_rawCounts',
    'birdHabits',
    'dfTooLong',
    'wideFrame',
    'untidyFrame')

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

