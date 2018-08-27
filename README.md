## ICPI Utilities

[![Build Status](https://travis-ci.org/ICPI/ICPIutilities.svg?branch=master)](https://travis-ci.org/ICPI/ICPIutilities)

![image](https://user-images.githubusercontent.com/8933069/43399475-2a7a052c-93d9-11e8-9fab-03d05153fd05.png)

This package contains a number of useful functions for creating and/or working with ICPI datasets and products.

Contents
- [Installation](https://github.com/ICPI/ICPIutilities#installation)
- [Usage](https://github.com/ICPI/ICPIutilities#usage)
  - [read_msd()](https://github.com/ICPI/ICPIutilities#read_msd)
  - [rename_official()](https://github.com/ICPI/ICPIutilities#rename_official)
  - [add_cumulative()](https://github.com/ICPI/ICPIutilities#add_cumulative)
  - [identifypd()](https://github.com/ICPI/ICPIutilities#identifypd)
  - [combine_netnew()](https://github.com/ICPI/ICPIutilities#combine_netnew)
  - [match_msd()](https://github.com/ICPI/ICPIutilities#match_msd)
  - [add_color()](https://github.com/ICPI/ICPIutilities#add_colord)

### Installation
While many packages you use daily are on CRAN, additional packages can also be hosted on and installed from GitHub. You'll need to have a package called `devtools` which will then allow you to install the ICPI package.

How to install package?
```
install.packages("devtools")
devtools::install_github("ICPI/ICPIutilities")
```
To ensure you have the latest version, you can always rerun `devtools::install_github("ICPI/ICPIutilities")`

### Usage

The `ICPIutilities` package has a few function that analysts may find useful for their work.

```
library(ICPIutilities)
```

#### read_msd()
The ICPI MER Structured Datasets are posted to [PEPFAR Sharepoint](https://www.pepfar.net/OGAC-HQ/icpi/Products/Forms/AllItems.aspx?RootFolder=%2FOGAC-HQ%2Ficpi%2FProducts%2FICPI%20Data%20Store%2FMER&FolderCTID=0x0120004DAC66286D0B8344836739DA850ACB95&View=%7B58E3102A-C027-4C66-A5C7-84FEBE208B3C%7D) as tab-delimited, text files (the extension is .txt). R has no problem reading in delimited files, but can run into issues due to the fact that that R guesses what columns are based on the first 1,000 rows. Since the MSDs are large, the first 1,000 rows of a column may be blank and R would interepret the column as string. Additional quirks arise from the fact that mechanism ids are read as numbers when they really should be string and the `coarseDisaggregate` variable is read in as a logical variable rather than string. The `read_msd()` function helps by importing all the columns as string and then converting the value columns (all starting with FY) to numeric (doubles).

While there is no correct or incorrect way to name variables, [a best practice](http://r-pkgs.had.co.nz/style.html) is to write them as all lower case (or snake casing with underscores to separate words) as opposed to camel casing (eg `coarseDisaggregate`) as found in the MSD files. The `read_msd()` function has an option to convert the variables to all lower.

An additional feature is the `read_msd()` function allows the user to save the .txt file as a .Rds file. This formatting compresses the file, allowing the MSD to take up one-tenth of the space as the normal .txt file. To reopen an .Rds, you can use the base R function `readRDS()`.

```
#open MSD in R
  df_ou_im <- read_msd("~/Data/ICPI_MER_Structured_Dataset_OU_IM_FY17-18_20180515_v1_1", save_rds = FALSE)

#open MSD in R, keeping camel casing
  df_ou_im <- read_msd("~/Data/ICPI_MER_Structured_Dataset_OU_IM_FY17-18_20180515_v1_1", to_lower = FALSE, save_rds = FALSE)

#store as an RDS file
  read_msd("~/Data/ICPI_MER_Structured_Dataset_OU_IM_FY17-18_20180515_v1_1")
```

#### rename_official()

Some mechanisms and partners are recorded in FACTSInfo with multiple names as they have changed over different time periods. This function replaces all partner and mechanism names the most recent name for each mechanism ID, so that a mechanism id doesn't have multiple partner or mechanism names. This process of standardization helps with looking at the same mechanism over time in a pivot table in Excel or aggregation in a stats package. The source of the official list comes originally from FACTSInfo, but it pulls from a publicly available DATIM SQL View that maintains this list. This function has been updated to work both with lower and camel casing now.

```
#replace partner and mechanism names with offical name
  df_ou_im <- rename_official(df_ou_im)
```

#### add_cumulative()

The MER Structured Datasets contain end of year totals for previous fiscal years, but do not include cumulative/snapshot values prior to Q4. This function identifies the current fiscal year using `identifypd()` and then works to create either a cumulative or snapshot value for each indicator (snapshot indicators include OVC_SERV, TB_PREV,TX_CURR, and TX_TB). The `add_cumulative()` function now takes an argument of prior_pd allowing a user to add in an cumulative/APR value for a prior year (eg DATIM genie output is missing APR values). By specifying the period, an APR value will be created.

```
#add cumulative column to dataset
  df_ou_im <- add_cumulative(df_ou_im)

#add an APR value to a prior period when the value is missing from the dataset
  df_genieextract <- add_cumulative(df_genieextract, priorpd = "2017")
```
#### identifypd()

The `identifypd()` function is used within the `add_cumulative()` but can be used outside of it as well. It identifies the current period by pulling the last quarter's column. It has a few options to allow you pull the FY or quarter only, or full variable name. You need to specify the `pd_type` to be returned.

```
#find current quarter & fy
  	curr_q  <- currentpd(df_ou_im, "quarter")
  	curr_fy <- currentpd(df_ou_im, "year")
  	fy_full <- currentpd(df_ou_im, "full") %>%
  	           toupper()
```

#### combine_netnew()

This function calculates TX_NET_NEW as it is not included in the MER Structured datasets. TX_NET_NEW is calculated by subtracting the current period's TX_CURR from the last period and for targets, it's created off the gap between the target for the current FY and the APR value for the prior year. Note that the current MSD starts in FY17; TX_NET_NEW for Q1 and APR for FY17 will be incorrect/incomplete due to the fact that the function does not have FY16 data to base this off. To solve this issue, you will need to download the FY15-16 Archived MSD file and then specify its location as an argument in the `combine_netnew()` function.

```
library(tidyverse)

#open current MSD
  df_psnu_im <- read_rds("~/ICPI/Data/ICPI_MER_Structured_Dataset_PSNU_IM_FY17-18_20180515_v1_1.Rds")

#create net new (not including FY16Q4, making net new for FY17Q1 = 0 and throwing off the cumulative net new)
  df_psnu_im <- combine_netnew(df_psnu_im)

#create net new with FY15-16 archived MSD file
  df_psnu_im <- combine_netnew(df_psnu_im, archived_msd_filepath = "~/ICPI/Data")
```

#### match_msd

Most of the analysis at ICPI relies on use of the MER Structured Dataset which is a frozen instance of the PEFPAR dataset produced twice a quarter. Sometimes it's important to work with inprocess data prior to the release of the MSD, which means accessing the data through the PEPFAR Data Genie on DATIM. The output of the Genie is very similar, but not exactly the same. To make working with the dataset easier, the `match_msd()` function. The function removes columns not present in the MSD (`dataElementUID`, `categoryOptionComboUID`, `ApprovalLevel`, and `ApprovalLevelDescription`) and adds in an APR column for prior fiscal year (eg `FY2017APR`). The function extracts the zipped file and outputs an RDS file.

```
#unzip Genie file and convert to match MSD, exports a RDS file
  match_msd("~/Downloads/PEPFAR-Data-Genie-PSNUByIMs-2018-08-15.zip")

#unzip, keeping camel casing, exports a RDS file
  match_msd("~/Downloads/PEPFAR-Data-Genie-PSNUByIMs-2018-08-15.zip", to_lower = FALSE)

#create a dataframe but does not export
  df_genie <- match_msd("~/Downloads/PEPFAR-Data-Genie-PSNUByIMs-2018-08-15.zip", save_rds = FALSE)
```

The default output is to change the columns to lower case, similar to `read_msd()`, but this can be turned off.  

#### add_color()

ICPI/DIV has crafted [four color schemes](https://github.com/ICPI/DIV/blob/master/Color_Palettes/ICPI_Color_Palette.pdf) for use in ICPI products. To import a color palette into R, you can use the `add_color()` function. This function will create a list of hex colors to use when using a graphing package in R, like `ggplot()`. There are five colors to choose from (an additional color scheme for Panorama "stoplight" colors). Use the function input column to identify which color scheme to pull

| Color Palette             | function input |
|---------------------------|----------------|
| Autumn Woods              | woods          |
| Coast of Bohemia          | bohemia        |
| Tidepools                 | tidepools      |
| By the Power of Grayscale | grayscale      |
| Panorama                  | panorama       |

```
#add list of hex colors to use with graph
  plot_scheme <- add_color("tidepools")
```  

===

Disclaimer: The findings, interpretation, and conclusions expressed herein are those of the authors and do not necessarily reflect the views of United States Agency for International Development, Centers for Disease Control and Prevention, Department of State, Department of Defense, Peace Corps, or the United States Government. All errors remain our own.
