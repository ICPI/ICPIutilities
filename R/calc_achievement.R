#' Adorn Achievement
#'
#' Function to calculate target achievement (cumulative and/or quarterly) for a
#' standard MSD or one reshaped using reshape_msd() as well as to apply achievement
#' group labels and colors.
#'
#' @param df data frame as standrd MSD or one from reshape_msd()
#' @param qtr if using standard MSD, need to provide the most recent quarter,
#' ideally using identifypd(df_msd, pd_type = "quarter")
#'
#' @return data frame with achievement values, labels, and colors
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
#'  summarise(across(where(is.double), sum, na.rm = TRUE)) %>%
#'  ungroup()
#'
#' adorn_achievement(df_msd_agg)
#'
#' df_msd_agg %>%
#'  reshape_msd("quarters") %>%
#'  adorn_achievement()
#'
#' df_msd_agg %>%
#'  reshape_msd("quarters", qtrs_keep_cumulative = TRUE) %>%
#'  adorn_achievement() }
adorn_achievement <- function(df, qtr = NULL){

  #make sure key variables exist
  if(var_missing(df, c("period", "fiscal_year")))
    stop("The data frame provided is missing period or fiscal year, one of which is required.")

  #calculate achievement if it doesn't already exists
  if(var_missing(df, c("achievement", "achievement_qtrly")))
    df <- calc_achievement(df)

  #apply binned color and labels
  df_achv <- color_achievement(df, qtr)

  return(df_achv)
}



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
#'  summarise(across(where(is.double), sum, na.rm = TRUE)) %>%
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



#' Color and label achievement
#'
#' @param df MSD dataframe
#' @param curr_qtr if wide MSD, need to specify the curren period, defaults to Q4
#' @param input_type whether to handle 'achievement' or 'achievement_qtrly'
#'
#' @return dataframe with achievement colors and labels
#'
color_achievement <- function(df, curr_qtr = NULL){

  #flag the use of q4 if curr_qtr is not provided
  if(is.null(curr_qtr) && var_missing(df, "period")){
    usethis::ui_info("No quarter provided; assuming all cumulative values are from Q4")
    curr_qtr <- 4
  }

  #stop if not a valid quarter
  if((!is.numeric(curr_qtr) || !curr_qtr %in% c(1:4)) && var_missing(df, "period"))
    stop("The quarter parameter must be a number between 1-4")

  #determine whether to label/color off quarterly or annual achievement
  if(var_exists(df, "achievement_qtrly")){
    df <- dplyr::mutate(df, achv_value = achievement_qtrly)
  } else {
    df <- dplyr::mutate(df, achv_value = achievement)
  }

  #add a quarter column need for the color/labeling
  df <- assign_quarter(df, curr_qtr)

  #apply labels and colors based on quarterly goal
  df <- df %>%
    dplyr::mutate(qtr_goal = ifelse(indicator %in% snapshot_ind, 1, 1*(qtr/4)),
                  achv_label = dplyr::case_when(is.na(achv_value) ~ NA_character_,
                                                achv_value <= qtr_goal-.25 ~ glue::glue("<{100*(qtr_goal-.25)}%") %>% as.character,
                                                achv_value <= qtr_goal-.1 ~ glue::glue("{100*(qtr_goal-.25)}-{100*(qtr_goal-.11)}%") %>% as.character,
                                                achv_value <= qtr_goal+.1 ~ glue::glue("{100*(qtr_goal-.1)}-{100*(qtr_goal+.1)}%") %>% as.character,
                                                TRUE ~ glue::glue("+{100*(qtr_goal+.1)}%") %>% as.character),
                  achv_color = dplyr::case_when(is.na(achv_value) ~ NA_character_,
                                                achv_value <= qtr_goal-.25 ~ "#c43d4d", #old_rose_light
                                                achv_value <= qtr_goal-.1 ~ "#ffcaa2", #burnt_sienna_light
                                                achv_value <= qtr_goal+.1 ~ "#5BB5D5", #scooter_medium
                                                TRUE ~ "#e6e6e6"))  %>% #trolley_grey_light
    dplyr::select(-c(achv_value, qtr_goal, qtr))

  return(df)
}



#' Assign Quarter
#'
#' @param df MSD dataframe, standard or reshaped via reshape_msd()
#' @param curr_qtr quarter for current fiscal year (if standard MSD)
#'
#' @return data frame with a quarter column
#'
assign_quarter <- function(df, curr_qtr = 4){

  #default to q4 if not provided (if it needs to be used)
  if(is.null(curr_qtr))
    curr_qtr <- 4

  #create a quarter column needed for calculating achievement labels/colors
  if(var_exists(df, "period")){
    df <- df %>%
      dplyr::mutate(fy = stringr::str_sub(period, 3, 4) %>% as.numeric,
                    qtr = dplyr::case_when(stringr::str_detect(period, "Q") ~ stringr::str_sub(period, -1) %>% as.numeric,
                                           fy == max(fy) ~ curr_qtr,
                                           TRUE ~ 4)) %>%
      dplyr::select(-fy)
  } else {
    df <- dplyr::mutate(df, qtr = ifelse(fiscal_year == max(fiscal_year), curr_qtr, 4))
  }

  return(df)
}
