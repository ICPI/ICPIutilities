#' Extract lastest period of dataset
#' @description This function is pulled from the achafetz/PartnerProgress repo
#' @param df dataset to use to find latest period
#' @param pd_type what is returned? (a) full, eg fy2018q1; (b)year, eg 2018; (c) or quarter, eg 1
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
#' #return the prior quarter, eg "fy2018q2"
#' identifypd(df_mer, pd_prior = TRUE)
#'   }
#'
identifypd <- function(df, pd_type = "full", pd_prior = FALSE) {
  #get list of header
  headers <- names(df)
  #pull current (last column) or prior (2nd to last column)
  if(pd_prior == FALSE) {
    pos = -1
  } else {
    pos = -2
  }
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
  } else {
    return(pd)
    break
  }
  #for year/quarter, extract portion asked for and return as integer
  pd <- stringr::str_sub(pd, start_pt, end_pt) %>%
    as.integer(.)
  return(pd)
}

