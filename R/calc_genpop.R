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
  #checks
  # 1. did user provide a data frame

  if(!is.data.frame(df))
    stop("Not a data frame")

  # 2. code is written to take MSD columns as named in native dataset.  read_msd(df,to_lower=F) only
    if(!any(grepl("[[:upper:]]",names(df))))
    stop("You may have converted variable names to lower case.  Try ICPIUtilities::read_msd(df,to_lower=FALSE)")

  kp.group.df <- df %>%
    ## subset indicators and disaggs related to KP ##
    dplyr::filter(indicator %in% c("HTS_TST","HTS_TST_POS","TX_NEW","KP_PREV","KP_MAT","HTS_SELF","HTS_RECENT","PrEP_NEW","PrEP_CURR"),
                  (grepl("KeyPop",disaggregate,ignore.case=T) | standardizedDisaggregate=="Total Numerator"),
                  numeratorDenom=="N") %>%

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

    # Allow for "new" (post FY2019Q1) and "old" (FY2019Q1 and earlier) MSD formats, respectively
    {if("Qtr2" %in% names(.)) {
        tidyr::gather(.,fiscalquarter,value,TARGETS:Cumulative) %>%
        dplyr::filter(!is.na(value)) %>%
        dplyr::mutate(fiscalperiod = paste0("FY",Fiscal_Year,"_",fiscalquarter)) %>%
        dplyr::select(-Fiscal_Year,-fiscalquarter)} else .} %>%

    {if("FY2018Q4" %in% names(.)) {
        tidyr::gather(.,fiscalperiod,value,starts_with("FY20")) %>%
        dplyr::filter(!is.na(value))} else .} %>%

    # create a temporary variable keypopgenpop to be used to calculate estimated general population
    dplyr::mutate(keypopgenpop = stringr::str_extract(disaggregate, "Total Numerator|KeyPop"))

  ## calculate the values for general population / unattributable risk
  genpop.df <- kp.group.df %>%
    # KP_PREV and KP_MAT are not eligible for general population calculations, as all results are KP by definition.
    dplyr::filter(!indicator %in% c("KP_PREV", "KP_MAT")) %>%

    # these try() statements are to drop columns that could impact aggregation / summarise but may not appear in all MSD (past/current/future)
    {tryCatch(dplyr::select(.,-use_as_aggregate),error=function(e) .)}  %>%
    {tryCatch(dplyr::select(.,-StatusHIV),error=function(e) .)}   %>%
    {tryCatch(dplyr::select(.,-resultStatus),error=function(e) .)}  %>%

    # need to aggregate the kp sub-groups within disagg options before transposing to wide
    # this group_by / group_by_at is critical - selecting the wrong grouping variables can cause issues with re-aggregating later
    # using group_by_at and deselecting variables allows for multiple types of MSD (ouxIM, sitexIM)
    # note: resultStatus was renamed StatusHIV as of FY2019Q2.
    dplyr::group_by_at(dplyr::vars(-value,-standardizedDisaggregate,-disaggregate,-categoryOptionComboName,
                                   -ImplementingMechanismName,-otherDisaggregate, -kpgroup)) %>%
    dplyr::summarise(value=sum(value,na.rm=T)) %>%
    tidyr::spread(keypopgenpop, value) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(genpop = sum(`Total Numerator`, -KeyPop,na.rm=TRUE)) %>%

    # in unusual cases where sum of KP disaggs > Total Numerator, set General population -> 0
    # Be careful with handling dedup here, which will also be negative
    dplyr::mutate(genpop = ifelse(
      (genpop<0 & !grepl("Dedup",PrimePartner,ignore.case=T)), 0,
      genpop)) %>%
    dplyr::ungroup()


  # print a summary of KP and genpop calculations into the console
  genpop.df %>%
    dplyr::group_by(fiscalperiod,indicator) %>%
    dplyr::summarise_at(dplyr::vars(genpop,KeyPop,`Total Numerator`),list(sum),na.rm=T) %>%
    dplyr::arrange(desc(fiscalperiod)) %>%
    print()

  genpop.subset.df <- genpop.df %>%
    # fix column names
    dplyr::select(-`Total Numerator`,-`KeyPop`) %>%
    dplyr::mutate(kpgroup="General Population/Unidentified Risk",
                  otherDisaggregate="General Population/Unidentified Risk") %>%
    dplyr::rename(value=genpop) %>%
    dplyr::filter(!is.na(value))

  ## bind the genpop rows back onto original data frame ##
  kp.group.df <- dplyr::select(kp.group.df,-keypopgenpop)
  gp <- dplyr::bind_rows(kp.group.df,genpop.subset.df)
  return(gp)
}
