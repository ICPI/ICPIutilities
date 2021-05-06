#' Calculate Achievement
#'
#' @param df MSD based dataframe
#'
#' @return one or two additional columns that calculate achievement and/or quarterly achievement
#' @export
#'
#' @examples
#' \dontrun{
#' df_msd <- read_msd(path)
#' df_msd_agg <- df_msd %>%
#'  filter(operatingunit == "Jupiter"
#'         indicator %in% c("TX_NEW", "TX_CURR"),
#'         fundingagency != "Dedup",
#'         standardizeddisaggregate == "Total Numerator") %>%
#'  group_by(operatingunit, fundingagency, fiscal_year, indicator) %>%
#'  summarise(dplyr::across(where(is.double), sum, na.rm = TRUE)) %>%
#'  ungroup()
#'
#' calc_achievement(df_msd_agg)
#'
#' df_msd_agg %>%
#'  reshape_msd("quarters") %>%
#'  calc_achievement() }
calc_achievement <- function(df){
  if(!"targets" %in% names(df))
    usethis::ui_stop("No {usethis::ui_field('targets')} in the dataframe provided")

  if(!"cumulative" %in% names(df) && !"results_cumulative" %in% names(df))
    usethis::ui_stop("No {usethis::ui_field('cumulative')} or {usethis::ui_field('results_cumulative')} in the dataframe provided")

  #calculate normal achievement
  if("cumulative" %in% names(df))
    df <- dplyr::mutate(df, achievement = cumulative/targets)

  #calcuate quarterly achievement
  if("results_cumulative" %in% names(df))
    df <- dplyr::mutate(df, achievement_qtrly = results_cumulative/targets)

  #convert Inf and NaN to NA
  df <- df %>%
    dplyr::mutate(dplyr::across(dplyr::starts_with("achievement"), ~ dplyr::na_if(., Inf)),
                  dplyr::across(dplyr::starts_with("achievement"), ~ dplyr::na_if(., NaN)))

  #round percent
  df <- df %>%
    dplyr::mutate(dplyr::across(dplyr::starts_with("achievement"), ~ round(., 2)))

  return(df)

}
