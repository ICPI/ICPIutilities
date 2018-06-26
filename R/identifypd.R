#' Extract lastest period of dataset
#' @description This function is pulled from the achafetz/PartnerProgress repo
#' @param df dataset to use to find latest period 
#' @param pd_type what is returned? (a) full, eg fy2018q1; (b)year, eg 2018; (c) or quarter, eg 1
#' 
#' @export
#' 
#' @importFrom dplyr %>%
#'
#' @examples
#' \dontrun{
#' identifypd(df_mer)
#' identifypd(df_mer, "quarter") }
#' 
identifypd <- function(df, pd_type = "full") {
  #get list of header
  headers <- names(df)
  #figure out column, keeping only variables that are a quarter
  pd <- headers[stringr::str_detect(headers, "q(?=[:digit:])")] %>% 
    tail(., n =1)
  #extract different poritions of the the last column based on pd_type 
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

