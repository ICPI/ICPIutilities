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
    if(any(grepl("[[:upper:]]",names(df))))
    {names(df) <- tolower(names(df))}

  kp.group.df <- df %>%
    ## subset indicators and disaggs related to KP ##
    dplyr::filter(indicator %in% c("HTS_TST","HTS_TST_POS","TX_NEW","TX_CURR","TX_PVLS",
                                   "KP_PREV","KP_MAT","HTS_SELF","HTS_RECENT","PrEP_NEW","PrEP_CURR")) %>%
    dplyr::filter(grepl("KeyPop",disaggregate,ignore.case=T) |
                   standardizeddisaggregate %in% c("Total Numerator","Total Denominator")) %>%

    ## Standardize KP groups ##
    dplyr::mutate(kpgroup = dplyr::case_when(
      grepl("MSM",categoryoptioncomboname) ~ "MSM",
      grepl("FSW",categoryoptioncomboname) ~ "FSW",
      grepl("TG",categoryoptioncomboname) ~ "TG",
      grepl("PWID",categoryoptioncomboname) ~ "PWID",
      grepl("prison",categoryoptioncomboname,ignore.case=T) ~ "Prisoners",
      indicator=="KP_MAT" ~ "PWID",
      TRUE ~ NA_character_
    )) %>%

    # Allow for "new" (post FY2019Q1) and "old" (FY2019Q1 and earlier) MSD formats, respectively
    {if("qtr2" %in% names(.)) {
        tidyr::gather(.,fiscalquarter,value,targets:cumulative) %>%
        dplyr::filter(!is.na(value)) %>%
        dplyr::mutate(period = paste0("fy",fiscal_year,"_",fiscalquarter)) %>%
        dplyr::select(-fiscalquarter)} else .} %>%

    {if("FY2018Q4" %in% names(.)) {
        tidyr::gather(.,period,value,starts_with("fy20")) %>%
        dplyr::filter(!is.na(value))} else .} %>%

    # create a temporary variable keypopgenpop to be used to calculate estimated general population
    dplyr::mutate(keypopgenpop = stringr::str_extract(disaggregate, "Total|KeyPop"))

  ## calculate the values for general population / unattributable risk
  genpop.df <- kp.group.df %>%
    # KP_PREV and KP_MAT are not eligible for general population calculations, as all results are KP by definition.
    dplyr::filter(!indicator %in% c("KP_PREV", "KP_MAT")) %>%

    # these try() statements are to drop columns that could impact aggregation / summarise but may not appear in all MSD (past/current/future)
    {tryCatch(dplyr::select(.,-use_as_aggregate),error=function(e) .)}  %>%
    {tryCatch(dplyr::select(.,-statushiv),error=function(e) .)}   %>%
    {tryCatch(dplyr::select(.,-resultstatus),error=function(e) .)}  %>%
    {tryCatch(dplyr::rename(.,mech_name=implementingmechanismname),error=function(e) .)} %>%
    {tryCatch(dplyr::rename(.,mech_code=mechanismid),error=function(e) .)} %>%

    # need to aggregate the kp sub-groups within disagg options before transposing to wide
    # this group_by / group_by_at is critical - selecting the wrong grouping variables can cause issues with re-aggregating later
    # using group_by_at and deselecting variables allows for multiple types of MSD (ouxIM, sitexIM)
    # note: resultStatus was renamed StatusHIV as of FY2019Q2.
    dplyr::group_by_at(dplyr::vars(-value,-standardizeddisaggregate,-disaggregate,-categoryoptioncomboname,
                                   -mech_name,-otherdisaggregate, -kpgroup, -population)) %>%
    dplyr::summarise(value=sum(value,na.rm=T)) %>%
    tidyr::spread(keypopgenpop, value) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(genpop = sum(Total, -KeyPop,na.rm=TRUE)) %>%

    # in unusual cases where sum of KP disaggs > Total Numerator, set General population -> 0
    # Be careful with handling dedup here, which will also be negative
    dplyr::mutate(genpop = ifelse(
      (genpop<0 & !grepl("Dedup",primepartner,ignore.case=T)), 0,
      genpop)) %>%
    dplyr::ungroup()


  # print a summary of KP and genpop calculations into the console
  genpop.df %>%
    dplyr::group_by(period,indicator,numeratordenom) %>%
    dplyr::summarise_at(dplyr::vars(genpop,KeyPop,Total),list(sum),na.rm=T) %>%
    dplyr::arrange(desc(period)) %>%
    print()

  genpop.subset.df <- genpop.df %>%
    # fix column names
    dplyr::select(-Total,-KeyPop) %>%
    dplyr::mutate(kpgroup="General Population/Unidentified Risk",
                  otherdisaggregate="General Population/Unidentified Risk") %>%
    dplyr::rename(value=genpop) %>%
    dplyr::filter(!is.na(value))


  ## bind the genpop rows back onto original data frame ##
  kp.group.df <- dplyr::select(kp.group.df,-keypopgenpop)
  gp <- dplyr::bind_rows(kp.group.df,genpop.subset.df)
  return(gp)
}
