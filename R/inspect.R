#' Investigate MER disaggs
#'
#' @param df data frame to inspect
#' @param ind MER indicator(s) to aggregate into table
#' @param group_var row variables in the table (aggregated up to), default = standardizeddisaggregate; must be written in list form c()
#' @param pd period(s) to look at
#' @param ou operating unit (filter)
#' @param agency funding agency to (filter)
#' @param nd numerator (N) or denominator (D) (filter)
#' @param order_on what variable to sort on (descending)
#' @param disagg standardized disaggregate to filter on
#' @param clean knitr table (TRUE) or tibble (FALSE) -
#'  set clean = FALSE if creating a data frame
#'
#' @return aggregated data table
#'
#' @importFrom dplyr %>%
#'
##' @examples
##' \dontrun{#inspect TX_CURR disaggs
##' df_mer %>% inspect("TX_CURR")
##'
##' #inspect TX_CURR by funding agency in Kenya
##' df_mer %>%
##' inspect("TX_CURR", group_var = c("fundingagency"),
##' disagg = "MostCompleteAgeDisagg",
##' pd = c(fy2016apr, fy2017apr),
##' order_on = fy2017apr,
##' ou = "Kenya")}
#'

inspect <- function(df, ind, group_var = c("standardizeddisaggregate"), disagg = NULL, pd = fy2017apr, ou = NULL, agency = NULL, nd = NULL, order_on = NULL, clean = TRUE){
  pd <- dplyr::enquo(pd)
  order_on <- dplyr::enquo(order_on)
  disagg <- dplyr::enquo(disagg)

  if(!missing(ou)) {
    df <- dplyr::filter(df, operatingunit %in% ou)
  }

  if(!missing(agency)) {
    df <- dplyr::filter(df, fundingagency %in% agency)
  }

  if(!missing(nd)) {
    df <- dplyr::filter(df, numeratordenom %in% nd)
  }

  df <- dplyr::filter(df, indicator %in% ind)

  df <- df %>%
    dplyr::group_by_(.dots = group_var) %>%
    dplyr::summarise_at(vars(!!pd), ~ sum(., na.rm = TRUE)) %>%
    dplyr::ungroup()

  if(!missing(order_on)) {
    df <- dplyr::arrange(df, desc(!!order_on))
  }
  if(clean == TRUE){
    knitr::kable(df, format.args = list(big.mark = ",", zero.print = FALSE))
  } else {
    df
  }
}


