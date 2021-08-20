# Setup -------------------------------------------------------------------

# Run this line of code only if you do not currently have the current 
# version of tidyverse installed!

install.packages('tidyverse')

# Load the libraries we will use:

library(tidyverse)

# indexing vectors --------------------------------------------------------

# Create a vector of numeric values:

numericVector <-
  c(1, 1, 2, 3, 5, 8)

# Use indexing to subset a vector:

numericVector

numericVector[3]

numericVector[3:4]

numericVector[c(1,3)]

# Indexing matrices -------------------------------------------------------

# Generate a matrix using the numeric vector:

m <-
  matrix(
    numericVector,
    ncol = 2)

# Index by row (x) and column (y) position [x,y]:

m

m[ ,1]

m[2, ]

m[1:2, 1]

m[c(1, 3), 1]

# Indexing data frames ----------------------------------------------------

# Generate data frame:

df <-
  as.data.frame(m)

names(df) <- c('hello', 'world')

df

# Index by row (x) and column (y) position [x,y]:

df[1:2, 2]

# Index by row (x) position and column name [x, 'name']:

df

df[1:2, 'world']

# Review of logical values ------------------------------------------------

# The "is equal to" logical operator:

3 == 3

3 == 4

3 == 2 + 1

3 == 3 + 1

(3 == 3) + (3 == 2 + 1)

# Using logic with objects - vectors --------------------------------------

numericVector

# Evaluate whether values in numericVector are equal to 3:

numericVector == 3

# Evaluate whether values in numericVector are equal to 1:

numericVector == 1

# Using logic with objects - matrices -------------------------------------

# Evaluate whether values in matrix m are equal to 3:

m

m == 3

# Evaluate whether values in data frame df are equal to 3:

df

df == 3

# Explore logical operators in a vector:

numericVector

numericVector != 3

!(numericVector == 3)

numericVector < 3

numericVector <= 3

numericVector > 3

numericVector >= 3

# Repeat the above with your matrix, m, and data frame, df.
  
# Logic: comparing sets ---------------------------------------------------

# Test whether values in numericVector match values 1 or 3:

numericVector %in% c(1,3)

# Test whether values in numericVector DO NOT match values 1 or 3:

!(numericVector %in% c(1,3))

# Test whether values in v match values 1 OR 3:

numericVector == 1 | numericVector == 3

# Test whether values in v match values 1 AND 3:

numericVector == 1 & numericVector == 3

# Test whether values in v are less than 5 and not equal to 2:

numericVector < 5 & numericVector != 2

# Indexing and logic: Query vectors ---------------------------------------

# Use indexing to subset a vector:

numericVector

numericVector[3]

# Use logic to subset a vector:

numericVector > 2

numericVector[numericVector > 2]

# At which indices is the numericVector greater than two? 

numericVector

numericVector > 2

which(numericVector > 2)

numericVector[4:6]

numericVector[which(numericVector > 2)]

numericVector[numericVector > 2]

# Indexing and logic: Query matrices --------------------------------------

# Matrix indexing:

m

m[,]

m[1,1]

m[2,2]

m[2, ]

m[ ,2]

m[1:2,2]

# Logical test of whether the first column of m is greater than 1:

m[,1] > 1

# At which indices does our logical statement evaluate to TRUE?

which(m[,1] > 1)

# Query m by index and logical statement:

m[3, ]

m[which(m[,1] > 1), ]

m[m[,1] > 1, ]

# Indexing and logic: Query data frames -----------------------------------

# Index data frame df by row (x) and column (y) position [x,y]:

df[,]

df[1,1]

df[2,2]

df[2, ]

df[ ,2]

df[1:2,2]

# Data frame indexing by position ...

df[,1]

df[,2]

# ... is equivalent to:

df$hello

df$world


# Now you -----------------------------------------------------------------

# Query  df such that values of column one are less than 2 and 
# values of column two are less than 5. Use "matrix notation" and the 
# column names of df to do so.
