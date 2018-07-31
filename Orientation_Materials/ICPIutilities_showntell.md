DIV Show and Tell: ICPIutilities
================
A.Chafetz
August 2, 2018

Setup
-----

Before getting started, you'll want to load up the dependences that this script relies upon. If you don't have any of the functions installed, take a minute to install them using the `install.packages()` function.

``` r
#install any missing packages
#  install.packages(c("tidyverse", "fs", "devtools"))

#load dependencies
  library(tidyverse)
```

    ## -- Attaching packages ------------------------------------------------------------------------------------------------------- tidyverse 1.2.1 --

    ## v ggplot2 2.2.1     v purrr   0.2.5
    ## v tibble  1.4.2     v dplyr   0.7.5
    ## v tidyr   0.8.1     v stringr 1.3.1
    ## v readr   1.1.1     v forcats 0.3.0

    ## -- Conflicts ---------------------------------------------------------------------------------------------------------- tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
  library(fs)
  library(devtools)
```

What is a function?
-------------------

If you've been working in R at all, you've encountered lots and lots of functions. Functions are segements of code in which the user provides inputs or arguments, such as providing a dataframe, and typically have one purpose, i.e. perform a single operation. For instance, a function you likely have performed in the past is to read in a dataset, using the function `read.csv()`.

In addition to using functions that already exist, users can create their own. Below is an example of a user created function. The function name is `b_fcn()`, which is defined like any other object in R. The user then specifies this is going to be function by writing out `function()` and identifying the arguments which the user is going to have to enter. The meat of the function is contained between the two curly bracket and defines what the function is doing.

Let's start out by running the function so it's stored in the environment and can be used later.

``` r
#basic function
  b_fcn <- function(x){
    x + 1
  }

#test function
  b_fcn(10)
```

    ## [1] 11

ICPIutilities
-------------

A package in R is simply just a collection of functions. Unlike programs like Excel or Stata that have most of the functionality of the platform built in, R is open sources and relies heavily on user created functions and packages. RStudio curates a set of packages that are extremely useful, especially if you're getting started with R, called the `tidyverse`, which includes packages such as `dplyr()`, `lubridate()`, and `ggplot()`.

In my work with R, I've found that contantly return back to the same bits of code depesite work on different projects when I'm working with the MER Structured Datasets. To help my future self and others in the PEPFAR space who are working with this dataset, I have created a package that contains a number of useful function.

Let's start by installing the package and then we get dive into how to use it. Since this package is hosted on GitHub, you'll have to install it using the `devtools::install_github()` function rather than the normal `install.packages()` like you would do if it were installed on CRAN.

``` r
#install/check for updates
##   install_github("ICPI/ICPIutilities")

  library(ICPIutilities)
```

If you naviage to your packages window and click on `ICPIutilities`, you will see all the functions contained within the package.

read\_msd()
-----------

The first function that is most useful to getting you going with using the MER Structured Dataset (MSD) in R is by reading it in. Today we'll be working with the ICPI training dataset that is stored on GitHub. Let's start by importing this via `readr::read_tsv()` and take a look at the columns.

``` r
#file location on GitHub
  fileurl <- "https://raw.githubusercontent.com/ICPI/TrainingDataset/master/Output/MER_Structured_TRAINING_Dataset_PSNU_IM_FY17-18_20180622_v2_1.txt"
#import
  df_training_orig <- read_tsv(fileurl)
```

    ## Parsed with column specification:
    ## cols(
    ##   .default = col_character(),
    ##   MechanismID = col_integer(),
    ##   coarseDisaggregate = col_logical(),
    ##   FY2017_TARGETS = col_double(),
    ##   FY2017Q1 = col_integer(),
    ##   FY2017Q2 = col_integer(),
    ##   FY2017Q3 = col_integer(),
    ##   FY2017Q4 = col_integer(),
    ##   FY2017APR = col_integer(),
    ##   FY2018_TARGETS = col_integer(),
    ##   FY2018Q1 = col_integer(),
    ##   FY2018Q2 = col_integer(),
    ##   FY2019_TARGETS = col_integer()
    ## )

    ## See spec(...) for full column specifications.

    ## Warning in rbind(names(probs), probs_f): number of columns of result is not
    ## a multiple of vector length (arg 1)

    ## Warning: 32 parsing failures.
    ## row # A tibble: 5 x 5 col     row col       expected               actual file                       expected   <int> <chr>     <chr>                  <chr>  <chr>                      actual 1  4344 FY2017Q2  no trailing characters e3     'https://raw.githubuserco~ file 2  8148 FY2017APR no trailing characters e3     'https://raw.githubuserco~ row 3  8829 FY2018Q2  no trailing characters e3     'https://raw.githubuserco~ col 4 10399 FY2017APR no trailing characters e3     'https://raw.githubuserco~ expected 5 10831 FY2017APR no trailing characters e3     'https://raw.githubuserco~
    ## ... ................. ... .......................................................................... ........ .......................................................................... ...... .......................................................................... .... .......................................................................... ... .......................................................................... ... .......................................................................... ........ ..........................................................................
    ## See problems(...) for more details.

``` r
#take a look at the variable types
  glimpse(df_training_orig)
```

    ## Observations: 27,618
    ## Variables: 42
    ## $ Region                    <chr> "The Known World", "The Known World"...
    ## $ RegionUID                 <chr> "rsgfCo9eMmd", "rsgfCo9eMmd", "rsgfC...
    ## $ OperatingUnit             <chr> "Westeros", "Westeros", "Westeros", ...
    ## $ OperatingUnitUID          <chr> "ZTxJsumQ8ay", "ZTxJsumQ8ay", "ZTxJs...
    ## $ CountryName               <chr> "Westeros", "Westeros", "Westeros", ...
    ## $ SNU1                      <chr> "The North", "The North", "The North...
    ## $ SNU1Uid                   <chr> "Nwedavx1iKP", "Nwedavx1iKP", "Nweda...
    ## $ PSNU                      <chr> "The North", "The North", "The North...
    ## $ PSNUuid                   <chr> "Nwedavx1iKP", "Nwedavx1iKP", "Nweda...
    ## $ SNUPrioritization         <chr> "1 - Scale-Up: Saturation", "1 - Sca...
    ## $ typeMilitary              <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
    ## $ MechanismUID              <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
    ## $ PrimePartner              <chr> "Grayscale", "Grayscale", "Grayscale...
    ## $ FundingAgency             <chr> "HHS/CDC", "HHS/CDC", "HHS/CDC", "HH...
    ## $ MechanismID               <int> 80001, 80001, 80001, 80001, 80001, 8...
    ## $ ImplementingMechanismName <chr> "Grayscale", "Grayscale", "Grayscale...
    ## $ indicator                 <chr> "EMR_SITE", "HRH_CURR_ManagementCadr...
    ## $ numeratorDenom            <chr> "N", "N", "N", "N", "N", "N", "N", "...
    ## $ indicatorType             <chr> "Not Applicable", "DSD", "Not Applic...
    ## $ disaggregate              <chr> "Service Delivery Area", "Total Nume...
    ## $ standardizedDisaggregate  <chr> "Service Delivery Area", "Total Nume...
    ## $ categoryOptionComboName   <chr> "Service Delivery Area - Early Infan...
    ## $ AgeAsEntered              <chr> NA, NA, NA, "15-19", "15+", "10-14",...
    ## $ AgeFine                   <chr> NA, NA, NA, "15-19", "Incompatible A...
    ## $ AgeSemiFine               <chr> NA, NA, NA, "15-19", NA, "10-14", "0...
    ## $ AgeCoarse                 <chr> NA, NA, NA, "15+", "15+", "<15", "<1...
    ## $ Sex                       <chr> NA, NA, NA, "Male", "Female", "Femal...
    ## $ resultStatus              <chr> NA, NA, NA, NA, NA, "Negative", "Neg...
    ## $ otherDisaggregate         <chr> "Service Delivery Area - Early Infan...
    ## $ coarseDisaggregate        <lgl> NA, NA, NA, NA, TRUE, NA, NA, NA, NA...
    ## $ modality                  <chr> NA, NA, NA, NA, NA, "Emergency Ward"...
    ## $ isMCAD                    <chr> "N", "N", "N", "N", "N", "Y", "Y", "...
    ## $ FY2017_TARGETS            <dbl> NA, NA, NA, NA, 15770, NA, NA, NA, N...
    ## $ FY2017Q1                  <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
    ## $ FY2017Q2                  <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
    ## $ FY2017Q3                  <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
    ## $ FY2017Q4                  <int> 10, 30, 20, NA, NA, NA, NA, NA, NA, ...
    ## $ FY2017APR                 <int> 10, 30, 20, NA, NA, NA, NA, NA, NA, ...
    ## $ FY2018_TARGETS            <int> NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
    ## $ FY2018Q1                  <int> NA, NA, NA, NA, NA, 10, NA, 10, 10, ...
    ## $ FY2018Q2                  <int> NA, NA, NA, NA, NA, 10, NA, NA, 10, ...
    ## $ FY2019_TARGETS            <int> NA, NA, NA, 20, NA, NA, NA, NA, NA, ...

What are some things that you noticed by importing the dataset normally through `readr::read_tsv()`?

Let's save the training dataset locally and then open that using the `ICPIutilities::read_msd()`.

``` r
#create a temporary directory to work in
  tmp <- dir_create(file_temp())
  
#save
  localfile_txt <- file.path(tmp, "FY18trainingdataset.txt")
  write_tsv(df_training_orig, localfile_txt, na = "")
```

Let's try importing the dataset using the ICPIulitities function.

``` r
#import with read_rds
  df_training <- read_msd(localfile_txt)
#take a look at the variable types
  glimpse(df_training)
```

    ## Observations: 27,618
    ## Variables: 42
    ## $ region                    <chr> "The Known World", "The Known World"...
    ## $ regionuid                 <chr> "rsgfCo9eMmd", "rsgfCo9eMmd", "rsgfC...
    ## $ operatingunit             <chr> "Westeros", "Westeros", "Westeros", ...
    ## $ operatingunituid          <chr> "ZTxJsumQ8ay", "ZTxJsumQ8ay", "ZTxJs...
    ## $ countryname               <chr> "Westeros", "Westeros", "Westeros", ...
    ## $ snu1                      <chr> "The North", "The North", "The North...
    ## $ snu1uid                   <chr> "Nwedavx1iKP", "Nwedavx1iKP", "Nweda...
    ## $ psnu                      <chr> "The North", "The North", "The North...
    ## $ psnuuid                   <chr> "Nwedavx1iKP", "Nwedavx1iKP", "Nweda...
    ## $ snuprioritization         <chr> "1 - Scale-Up: Saturation", "1 - Sca...
    ## $ typemilitary              <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
    ## $ mechanismuid              <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
    ## $ primepartner              <chr> "Grayscale", "Grayscale", "Grayscale...
    ## $ fundingagency             <chr> "HHS/CDC", "HHS/CDC", "HHS/CDC", "HH...
    ## $ mechanismid               <chr> "80001", "80001", "80001", "80001", ...
    ## $ implementingmechanismname <chr> "Grayscale", "Grayscale", "Grayscale...
    ## $ indicator                 <chr> "EMR_SITE", "HRH_CURR_ManagementCadr...
    ## $ numeratordenom            <chr> "N", "N", "N", "N", "N", "N", "N", "...
    ## $ indicatortype             <chr> "Not Applicable", "DSD", "Not Applic...
    ## $ disaggregate              <chr> "Service Delivery Area", "Total Nume...
    ## $ standardizeddisaggregate  <chr> "Service Delivery Area", "Total Nume...
    ## $ categoryoptioncomboname   <chr> "Service Delivery Area - Early Infan...
    ## $ ageasentered              <chr> NA, NA, NA, "15-19", "15+", "10-14",...
    ## $ agefine                   <chr> NA, NA, NA, "15-19", "Incompatible A...
    ## $ agesemifine               <chr> NA, NA, NA, "15-19", NA, "10-14", "0...
    ## $ agecoarse                 <chr> NA, NA, NA, "15+", "15+", "<15", "<1...
    ## $ sex                       <chr> NA, NA, NA, "Male", "Female", "Femal...
    ## $ resultstatus              <chr> NA, NA, NA, NA, NA, "Negative", "Neg...
    ## $ otherdisaggregate         <chr> "Service Delivery Area - Early Infan...
    ## $ coarsedisaggregate        <chr> NA, NA, NA, NA, "TRUE", NA, NA, NA, ...
    ## $ modality                  <chr> NA, NA, NA, NA, NA, "Emergency Ward"...
    ## $ ismcad                    <chr> "N", "N", "N", "N", "N", "Y", "Y", "...
    ## $ fy2017_targets            <dbl> NA, NA, NA, NA, 15770, NA, NA, NA, N...
    ## $ fy2017q1                  <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
    ## $ fy2017q2                  <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
    ## $ fy2017q3                  <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
    ## $ fy2017q4                  <dbl> 10, 30, 20, NA, NA, NA, NA, NA, NA, ...
    ## $ fy2017apr                 <dbl> 10, 30, 20, NA, NA, NA, NA, NA, NA, ...
    ## $ fy2018_targets            <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
    ## $ fy2018q1                  <dbl> NA, NA, NA, NA, NA, 10, NA, 10, 10, ...
    ## $ fy2018q2                  <dbl> NA, NA, NA, NA, NA, 10, NA, NA, 10, ...
    ## $ fy2019_targets            <dbl> NA, NA, NA, 20, NA, NA, NA, NA, NA, ...

In addition to reading in all of the columns correctly, the function also saves the dataset in a .Rds format. This format is proprietary to R, but it provides the advantage of significantlly compressing the file size of the dasasets we're working with locally.

``` r
#print file sizes (GB)
  paste("txt file =", round(file.size(localfile_txt) / 1000000, 1), "GB")
```

    ## [1] "txt file = 8.3 GB"

``` r
  localfile_rds <- str_replace(localfile_txt, "txt", "Rds")
  paste("rds file =", round(file.size(localfile_rds) / 1000000, 1), "GB")
```

    ## [1] "rds file = 0.4 GB"

rename\_official()
------------------

Usually after importing the dataset, my next task is cleaning up the mechanism and partner names. Have a look at the current set of mechanisms. There are differences possible between partner names and mechanism names over time, but the mechanism id is unique.

``` r
#import
  fileurl <- "https://raw.githubusercontent.com/ICPI/ICPIutilities/master/Orientation_Materials/FY18Q2_mechanism_list.csv"
  df_mechs <- read_csv(fileurl, col_types = cols(.default = "c"))
```

``` r
#how many distinct mechanism & partner names are there?
  (n <- nrow(df_mechs))
```

    ## [1] 958

``` r
#how many distinct mechanism ids are there?
  (n_mechs <- df_mechs %>% 
    distinct(mechanismid) %>% 
    nrow())
```

    ## [1] 862

So it appears that there are 958 combinations, but only 862 distinct mechanims. Let's look at what's going on.

``` r
#how many mechanism are duplicates?
  df_mechs %>% 
    count(mechanismid, sort = TRUE) %>% 
    filter(n > 1) %>% 
    group_by(n) %>% 
    count(n) %>% 
    rename(occurances = n, obs = nn) %>% 
    mutate(obs = obs/2)
```

    ## # A tibble: 2 x 2
    ## # Groups:   occurances [2]
    ##   occurances   obs
    ##        <int> <dbl>
    ## 1          2    46
    ## 2          3     1

``` r
#a quick look at some examples
  (dups <- df_mechs %>% 
    group_by(mechanismid) %>% 
    mutate(obs = n()) %>% 
    ungroup() %>% 
    arrange(obs, mechanismid) %>% 
    filter(obs > 1))
```

    ## # A tibble: 190 x 5
    ##    operatingunit mechanismid primepartner    implementingmechanismn~   obs
    ##    <chr>         <chr>       <chr>           <chr>                   <int>
    ##  1 Zambia        10227       Western Provin~ WPHO Follow on              2
    ##  2 Zambia        10227       Western Provin~ WPHO Followon               2
    ##  3 Zambia        10236       University Tea~ University Teaching Ho~     2
    ##  4 Zambia        10236       University Tea~ University Teaching Ho~     2
    ##  5 Zambia        10238       TBD             TBD (ZNBTS)                 2
    ##  6 Zambia        10238       Zambia Nationa~ ZNBTS                       2
    ##  7 Mozambique    12168       Pathfinder Int~ Increasing access to H~     2
    ##  8 Mozambique    12168       Pathfinder Int~ PATHFINDER                  2
    ##  9 Kenya         13546       Henry Jackson ~ Kisumu West                 2
    ## 10 Kenya         13546       Henry Jackson ~ Kisumu West (Placehold~     2
    ## # ... with 180 more rows

To solve this issue of different names associated with each mechanism id, we can use an API pull from DATIM's public data to determine which set of names is currently in use, i.e. the latest in FACTSInfo, and replace all the names in the dataset with theses.

Inspec the help file of `rename_official()` and then use it to fix the dataset

``` r
#replace the outdated names
  dups %>% 
    rename_official()
```

    ## # A tibble: 190 x 5
    ##    operatingunit mechanismid primepartner       implementingmechani~   obs
    ##    <chr>         <chr>       <chr>              <chr>                <int>
    ##  1 Zambia        10227       Western Province ~ WPHO Follow on           2
    ##  2 Zambia        10227       Western Province ~ WPHO Follow on           2
    ##  3 Zambia        10236       University Teachi~ University Teaching~     2
    ##  4 Zambia        10236       University Teachi~ University Teaching~     2
    ##  5 Zambia        10238       TBD                TBD (ZNBTS)              2
    ##  6 Zambia        10238       TBD                TBD (ZNBTS)              2
    ##  7 Mozambique    12168       Pathfinder Intern~ PATHFINDER               2
    ##  8 Mozambique    12168       Pathfinder Intern~ PATHFINDER               2
    ##  9 Kenya         13546       Henry Jackson Fou~ Kisumu West (Placeh~     2
    ## 10 Kenya         13546       Henry Jackson Fou~ Kisumu West (Placeh~     2
    ## # ... with 180 more rows

add\_cumulative()
-----------------

Another useful function that I use in most projects is a cumulative or year to date indicator. This process can be done manually but then requires updating every quarter when you add new variables onto the dataset, i.e. a new quarter.

Take a minute or two to write out how you would calculate a cumulative variable.

``` r
# create a cumulative/YTD indicator
  df_training <- add_cumulative(df_training)
```

Let's see how this looks with a couple indicators.

``` r
#function to summarize FY18 results
  tab_mer <- function(df, ind, ou = "Westeros"){
    df %>% 
      filter(operatingunit == ou, indicator == ind,
             standardizeddisaggregate == "Total Numerator") %>% 
      group_by(indicator, psnu) %>% 
      summarise_at(vars(starts_with("fy2018q"), fy2018cum), ~ sum(., na.rm = TRUE)) %>% 
      ungroup()
  }

#look at PSNUs in Westeros for a quarterly and snapshot indicator
  tab_mer(df_training, "TX_NEW")
```

    ## # A tibble: 6 x 5
    ##   indicator psnu              fy2018q1 fy2018q2 fy2018cum
    ##   <chr>     <chr>                <dbl>    <dbl>     <dbl>
    ## 1 TX_NEW    Beyond the Wall         30       40        70
    ## 2 TX_NEW    Dorne                   10       10        20
    ## 3 TX_NEW    The Crownlands          40       50        90
    ## 4 TX_NEW    The Iron Islands        10       10        20
    ## 5 TX_NEW    The North              130      160       290
    ## 6 TX_NEW    The Vale of Arryn      410      430       840

``` r
  tab_mer(df_training, "TX_CURR")
```

    ## # A tibble: 6 x 5
    ##   indicator psnu              fy2018q1 fy2018q2 fy2018cum
    ##   <chr>     <chr>                <dbl>    <dbl>     <dbl>
    ## 1 TX_CURR   Beyond the Wall        240      270       270
    ## 2 TX_CURR   Dorne                   20       30        30
    ## 3 TX_CURR   The Crownlands         440      490       490
    ## 4 TX_CURR   The Iron Islands       160      160       160
    ## 5 TX_CURR   The North             4280     4350      4350
    ## 6 TX_CURR   The Vale of Arryn     4020     4360      4360

The great part about this function is that it is time agnostic. If we add in another period, we can see that the calculation is performed without any issue.

``` r
#function agnostic to time period
  df_training %>% 
    select(-fy2018cum) %>% 
    mutate(fy2018q3 = round(fy2018q2 * 1.25, 0)) %>% 
    add_cumulative() %>% 
    tab_mer("TX_NEW")
```

    ## # A tibble: 6 x 6
    ##   indicator psnu              fy2018q1 fy2018q2 fy2018q3 fy2018cum
    ##   <chr>     <chr>                <dbl>    <dbl>    <dbl>     <dbl>
    ## 1 TX_NEW    Beyond the Wall         30       40       50       120
    ## 2 TX_NEW    Dorne                   10       10       12        32
    ## 3 TX_NEW    The Crownlands          40       50       62       152
    ## 4 TX_NEW    The Iron Islands        10       10       12        32
    ## 5 TX_NEW    The North              130      160      200       490
    ## 6 TX_NEW    The Vale of Arryn      410      430      538      1378

combine\_netnew
---------------

The calculation for TX\_NET\_NEW should be relatively straight forward, but it's made cumbersome due to the fact that each period is its own indicator and the calculations are not uniform (i.e. results/apr/targets require different calculations). Let's add NET NEW to the datasets.

``` r
  df_training <- combine_netnew(df_training)
```

The functions spits back an error here since it doesn't know how to handle the cumulative value we added with the last function. This issue is likely a bug I can work out in the future but I wanted to demonstrate the error message. If you think about it though, the logical flow should be to add net new on before you create a cumulative value.

What is going on behind the scenes to make this funciton work is that it's breaking the dataframe into multiple long dataframes (where all the periods and their values share two columns, period and value) and each dataframe is then broken out by results vs targets vs APR values to deal with each seperately.

``` r
#reattempt by removing the cumulative indicator before adding it back on
  df_training <- df_training %>% 
    select(-fy2018cum) %>% 
    combine_netnew() %>% 
    add_cumulative()
  
  df_training %>% 
    select(starts_with("fy2018")) %>% 
    names()
```

    ## [1] "fy2018_targets" "fy2018q1"       "fy2018q2"       "fy2018cum"

Let's test it to see if the function works. Anything we should note here?

``` r
#check to see if TX_NET_NEW calculated correctly
    df_training %>% 
      filter(operatingunit == "Westeros", indicator %in% c("TX_CURR", "TX_NET_NEW"),
             standardizeddisaggregate == "Total Numerator") %>% 
      group_by(operatingunit, indicator) %>% 
      summarise_if(is.numeric, ~ sum(., na.rm = TRUE)) %>% 
      ungroup() %>% 
      gather(pd, val, -operatingunit, -indicator, factor_key = TRUE) %>% 
      spread(indicator, val)
```

    ## # A tibble: 11 x 4
    ##    operatingunit pd             TX_CURR TX_NET_NEW
    ##    <chr>         <fct>            <dbl>      <dbl>
    ##  1 Westeros      fy2017_targets    7590          0
    ##  2 Westeros      fy2017q1          7550          0
    ##  3 Westeros      fy2017q2          7940        390
    ##  4 Westeros      fy2017q3          8560        620
    ##  5 Westeros      fy2017q4          8990        430
    ##  6 Westeros      fy2017apr         8990       1440
    ##  7 Westeros      fy2018_targets   12090       3100
    ##  8 Westeros      fy2018q1          9160        170
    ##  9 Westeros      fy2018q2          9660        500
    ## 10 Westeros      fy2019_targets    5780      -6310
    ## 11 Westeros      fy2018cum         9660        670

Other functions
---------------

The `ICPIutilities` package has a couple other useful functions. One of them is used to identify the current period and is especially useful in the `add_cumulative` function.

``` r
identifypd(df_training)
```

    ## [1] "fy2018q2"

``` r
## ?identifypd

identifypd(df_training, "year")
```

    ## [1] 2018

``` r
identifypd(df_training, "quarter")
```

    ## [1] 2

This function can have broader application in other functions, allowing the function to be more automated.

``` r
  track <- function(df, ind, ou = "Westeros"){
    prior_apr <- paste0("fy",identifypd(df_training, "year") - 1, "apr")
    curr_cum <- paste0("fy",identifypd(df_training, "year"), "cum")
    curr_targets <- paste0("fy",identifypd(df_training, "year"), "_targets")
  
    df %>% 
      filter(operatingunit == "Westeros", indicator == ind,
             standardizeddisaggregate == "Total Numerator") %>% 
      group_by(indicator, psnu) %>% 
      summarise_at(vars(prior_apr, curr_targets, curr_cum), ~ sum(., na.rm = TRUE)) %>% 
      ungroup()
  }
  
  track(df_training, "TX_NEW")
```

    ## # A tibble: 6 x 5
    ##   indicator psnu              fy2017apr fy2018_targets fy2018cum
    ##   <chr>     <chr>                 <dbl>          <dbl>     <dbl>
    ## 1 TX_NEW    Beyond the Wall          30             90        70
    ## 2 TX_NEW    Dorne                    20              0        20
    ## 3 TX_NEW    The Crownlands          150            340        90
    ## 4 TX_NEW    The Iron Islands         20             10        20
    ## 5 TX_NEW    The North               720            970       290
    ## 6 TX_NEW    The Vale of Arryn      1570           2750       840

The last function included in the package pulls the hex colors from the ICPI color palette into R to use when graphing.

``` r
  (tidepools <- add_color("tidepools"))
```

    ## [1] "#ceb966" "#9cb084" "#6bb1c9" "#6585cf" "#7e6bc9" "#a379bb"
