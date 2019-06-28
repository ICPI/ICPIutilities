#' Calculate General Population PEPFAR results
#'
#' Standardizes key populations groupings and calculates estimated general population result
#' by subtracting key populations results from Total Numerator
#'
#' @param df PEPFAR MER structured dataset in data.frame format for calculation, such as the object created by ICPIutilities::read_msd()
#' @importFrom dplyr %>%
#'
#' @return a simplified summarised dataframe with a standardized kpgroup variable and results for general population
#' @export
#'

#'
calc_genpop <- function(df) {
  ## Function only takes a data.frame
  # require(usethis)
  # require(devtools)
  # library(ICPIutilities)
  # library(tidyverse)
  # library(roxygen2)

  if(is.data.frame(df)) {

    ## code is written to take MSD columns as named in native dataset.  read_msd(df,to_lower=F) only
    if(any(grepl("[[:upper:]]",names(df)))) {

      require(tidyverse)
      kp.group.df <- df %>%
        ## subset indicators and disaggs related to KP ##
        dplyr::filter(indicator %in% c("HTS_TST","HTS_TST_POS","TX_NEW","KP_PREV","KP_MAT","HTS_SELF","HTS_RECENT","PrEP_NEW","PrEP_CURR")) %>%
        dplyr::filter(grepl("KeyPop",disaggregate,ignore.case=T) | standardizedDisaggregate=="Total Numerator") %>%
        dplyr::filter(numeratorDenom=="N") %>%

        ## Standardize KP groups ##
        dplyr::mutate(kpgroup = dplyr::case_when(
          grepl("MSM",categoryOptionComboName) ~ "MSM",
          grepl("FSW",categoryOptionComboName) ~ "FSW",
          grepl("TG",categoryOptionComboName) ~ "TG",
          grepl("PWID",categoryOptionComboName) ~ "PWID",
          grepl("prison",categoryOptionComboName,ignore.case=T) ~ "Prisoners",
          indicator=="KP_MAT" ~ "PWID",
          TRUE ~ NA_character_
        )) %>%

        # the original transpose to long is deprecated because of the updated MSD structure as of FY2019Q2
        # tidyr::gather("fiscalperiod","value",starts_with("FY20")) %>%
        tidyr::gather(fiscalquarter,value,TARGETS:Cumulative) %>%
        dplyr::mutate(fiscalperiod = paste0("FY",Fiscal_Year,"_",fiscalquarter)) %>%
        dplyr::select(-Fiscal_Year,-fiscalquarter) %>%
        # create a temporary variable keypopgenpop to be used to calculate estimated general population
        dplyr::mutate(keypopgenpop = case_when(
          standardizedDisaggregate=="Total Numerator" ~ "Total Numerator",
          grepl("KeyPop",disaggregate,ignore.case=T) ~ "Key Pop"
        ))

      ## calculate the values for general population / unattributable risk
      genpop.df <- kp.group.df %>%
        # KP_PREV and KP_MAT are not eligible for general population calculations, as all results are KP by definition.
        dplyr::filter(indicator!="KP_PREV" & indicator!="KP_MAT") %>%
        dplyr::ungroup() %>%

        # need to aggregate the kp sub-groups within disagg options before transposing to wide
        # this group_by / group_by_at is critical - selecting the wrong grouping variables can cause issues with re-aggregating later
        # using group_by_at and deselecting variables allows for multiple types of MSD (ouxIM, sitexIM)
        # note: resultStatus was renamed StatusHIV as of FY2019Q2.
        dplyr::group_by_at(vars(-value,-standardizedDisaggregate,-disaggregate,-categoryOptionComboName, -ImplementingMechanismName,-otherDisaggregate, -kpgroup,-StatusHIV)) %>%
        dplyr::summarise(value=sum(value,na.rm=T)) %>%

        tidyr::spread(keypopgenpop, value) %>%
        dplyr::rowwise() %>%
        dplyr::mutate(genpop = sum(`Total Numerator`, -`Key Pop`,na.rm=TRUE)) %>%

        # in unusual cases where sum of KP disaggs > Total Numerator, set General population -> 0
        # Be careful with handling dedup here, which will also be negative
        dplyr::mutate(genpop = ifelse(
          (genpop<0 & !grepl("Dedup",PrimePartner,ignore.case=T)), 0,
          genpop)) %>%

        # fix column names
        dplyr::select(-`Total Numerator`,-`Key Pop`) %>%
        dplyr::mutate(kpgroup="General Population/Unidentified Risk",
                      otherDisaggregate="General Population/Unidentified Risk") %>%
        dplyr::rename(value=genpop) %>%
        dplyr::filter(!is.na(value)) %>%
        dplyr::ungroup()

      ## bind the genpop rows back onto original data frame ##
      kp.group.df <- dplyr::select(kp.group.df,-keypopgenpop)
      gp <- dplyr::bind_rows(kp.group.df,genpop.df)
      return(gp)
    }

    else(warning("You may have converted variable names to lower case.  Try ICPIUtilities::read_msd(df,to_lower=FALSE)"))
  }
  else(warning("Not a data frame"))
}
