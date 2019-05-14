#' Extract lastest period of dataset
#' @description This function is pulled from the achafetz/PartnerProgress repo
#' @param df dataset to use to find latest period
#' @param pd_type what is returned? (a) full, eg fy2018q1; (b)year, eg 2018; (c) quarter, eg 1; (d) target, eg fy2018_targets
#' @param pd_prior do you want the last period returned (instead of the current); default = FALSE
#'
#' @export
#'
#' @importFrom dplyr %>%
#'
#' @examples
#' \dontrun{
#' #return full, current period, eg "fy2018q3"
#' identifypd(df_mer)
#' #return the current quarter, eg 3
#' identifypd(df_mer, "quarter")
#' #return the current target, eg fy2018_targets
#' identifypd(df_mer, "target")
#' #return the prior quarter, eg "fy2018q2"
#' identifypd(df_mer, pd_prior = TRUE)
#'   }
#'
identifypd <- function(df, pd_type = "full", pd_prior = FALSE) {

  #get header names based on new or old structure
    if(any(stringr::str_detect(names(df), "(Q|q)tr1"))){

      #figure out whether to make FY upper or lower, depending on the case of Qtr
      fy_case <- ifelse(any(stringr::str_detect(names(df), "Q")), "FY", "fy")

      headers <- df %>%
        dplyr::group_by(fiscal_year) %>%
        dplyr::summarise_at(dplyr::vars(dplyr::matches("[Q|q]")), sum, na.rm = TRUE) %>%
        dplyr::mutate_all(~dplyr::na_if(., 0)) %>%
        tidyr::gather(qtr, val, dplyr::matches("[Q|q]"), na.rm = TRUE) %>%
        tidyr::unite(pd, c("fiscal_year", "qtr"), sep = "") %>%
        dplyr::mutate(pd = stringr::str_remove(pd, "tr") %>% paste0(fy_case, .)) %>%
        dplyr::arrange(pd) %>%
        dplyr::pull(pd)

    } else {
      headers <- names(df)
    }

  #pull current (last column) or prior (2nd to last column)
  pos = dplyr::case_when(pd_prior == FALSE                    ~ -1, #pull last col, curr pd
                         pd_prior == TRUE &&
                           !pd_type %in% c("target", "year")  ~ -2, #pull 2nd to last col, last pd
                         TRUE                                 ~ -5) #pull 5 quarters ago, push year to 1 prior

  #figure out column, keeping only variables that are a quarter
  pd <- headers[stringr::str_detect(headers, "[q|Q](?=[:digit:])")] %>%
    dplyr::nth(pos)
  #extract different portions of the the last column based on pd_type
  if(pd_type == "year") {
    start_pt <- 3
    end_pt <- -3
  } else if(pd_type == "quarter") {
    start_pt <- -1
    end_pt <- -1
  } else if(pd_type == "target") {
    pd <- stringr::str_replace(pd, "q[:digit:]", "_targets") #if lower case
    pd <- stringr::str_replace(pd, "Q[:digit:]", "_TARGETS") #if camel case (MSD standard)
    return(pd)
    break
  } else {
    return(pd)
    break
  }
  #for year/quarter, extract portion asked for and return as integer
  pd <- stringr::str_sub(pd, start_pt, end_pt) %>%
    as.integer(.)
  return(pd)
}

