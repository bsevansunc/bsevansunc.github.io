library(rinat)

# Read in inat data from a subset of cities from 2018:2020:

monarch <-
  c('Washington, DC',
    'New York, NY',
    'Chicago, IL',
    'Boston, MA') %>% 
  purrr::map_dfr(
    function(location) {
      purrr::map_dfr(
        2018:2020,
        function(yr) {
          rinat::get_inat_obs(
            taxon_name = "Danaus plexippus",
            query = location, 
            year = yr,
            maxresults = 10000) %>% 
            dplyr::as_tibble() %>% 
            dplyr::group_by(user_login) %>% 
            dplyr::summarize(n = dplyr::n()) %>% 
            dplyr::ungroup() %>% 
            dplyr::mutate(
              year = yr,
              city = location)
        })
    })

# Make untidy and wrangle to file:

monarch %>%
  dplyr::group_by(city, year) %>%
  dplyr::summarize(n = sum(n)) %>%
  tidyr::pivot_wider(
    names_from = year,
    names_prefix = 'year_',
    values_from = n) %>% 
  readr::write_csv('tidy_data_exercise/data/monarch_inat.csv')
