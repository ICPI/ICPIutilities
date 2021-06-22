#' Reshape Semi-Wide MSD
#'
#' @param df MSD dataset in the semi-wide format
#' @param direction direction of reshape, "long" (default), "wide" (original MSD structure),
#' "semi-wide" (one column for targets, cumulative, results) or "quarters" (quarters pivoted, but not targets - useful for quarterly achievement))
#' @param clean clean period for graphing, eg(fy2019qtr2 -> FY19Q2) and create a period type (targets, results, cumulative)
#' @param qtrs_keep_cumulative whether to keep the cumulative column when using quaters for direction, default = FALSE
#'
#' @export
#'
#' @examples
#' \dontrun{
#'  #read in data
#'   df_genie <- match_msd("~/Downloads/PEPFAR-Data-Genie-PSNUByIMs-2018-08-15.zip")
#'  #reshape long
#'   df_genie_long <- reshape_msd(df_genie)
#'  #reshape wide (to look like old format)
#'   df_genie_long <- reshape_msd(df_genie, direction = "wide")
#'  #reshape semi-wide (one column for targets, cumulative, results)
#'   df_genie_wide <- reshape_msd(df_genie, direction = "semi-wide")
#'  #reshape quarters (quarters pivoted, but not targets - useful for quarterly achievement)
#'   df_genie_wide <- reshape_msd(df_genie, direction = "semi-wide")
#'   }

reshape_msd <- function(df, direction = c("long", "wide", "semi-wide", "quarters"),
                        clean = TRUE, qtrs_keep_cumulative = FALSE){

  #limit direction to 1 if not specified
    direction <- direction[1]

  #check if upper case (for FY or fy names)
    is_upper <- stringr::str_detect(names(df)[1], "[[:upper:]]")
    fy_var <- ifelse(is_upper, dplyr::sym("Fiscal_Year"), dplyr::sym("fiscal_year"))

    if(("fiscal_year" %in% names(df) == FALSE)) {
      stop('This dataframe is missing the fiscal_year indicator needed to create period.')
    }

  #adjust group
    var_match <- ifelse(direction == "quarters", "(Q|q)tr", "TARGETS|targets|(Q|q)tr|(C|c)umulative")

  #reshape long (wide need to be reshaped long first as well)
    df <- df %>%
      tidyr::pivot_longer(dplyr::matches(var_match),
                          names_to = "period",
                          names_prefix = "qtr",
                          names_transform = list(period = as.integer),
                          values_drop_na = TRUE)

  #identify current period
    curr_year <- identifypd(df, "year")
    curr_qtr <- identifypd(df, "quarter")

  #filter future periods
    df <- df %>%
      dplyr::filter(!(fiscal_year == curr_year & period > curr_qtr))

  #clean up period
    df <- df %>%
      dplyr::mutate(period = stringr::str_replace(period, "(TARGETS|targets)", "_\\1"), #add _ to match old
                    !!fy_var := paste0(ifelse(is_upper, "FY", "fy"), !!fy_var)) %>%  #add FY to match old
      tidyr::unite(period, c(!!fy_var, period), sep = "q") #combine fy and pd together

  #reshape wide
    if(direction == "wide"){
      df <- df %>%
        dplyr::mutate(period = stringr::str_replace(period, "(C|c)um", "zzz.\\1um")) %>% #add z to reorder correctly
        tidyr::spread(period, value) %>%
        dplyr::rename_all( ~ stringr::str_remove(.,"zzz.")) #remove zzz
    }

  #clean
    if((direction == "long" && clean == TRUE) || direction %in% c("semi-wide", "quarters")){
      df <- df %>%
        dplyr::mutate(period_type = stringr::str_extract(period, "TARGETS|targets|(C|c)umulative") %>% tolower,
                      period_type = ifelse(is.na(period_type), "results", period_type),
                      period = stringr::str_remove(period, "20") %>% toupper,
                      period = stringr::str_remove(period, "CUMULATIVE|_TARGETS")) %>%
        dplyr::select(-value, dplyr::everything())
    }

  #semi-wide
    if(direction == "semi-wide"){
      df <- df %>%
        tidyr::pivot_wider(names_from = period_type)
    }

  #quarters
    if(direction == "quarters"){

      #remove cumulative
      if(qtrs_keep_cumulative == FALSE)
        df <- dplyr::select(df, -dplyr::matches("(C|c)umulative"))

      #create a fiscal year
      df <- df %>%
        dplyr::mutate(fiscal_year = stringr::str_sub(period, end = 4), .before = period)

      #rename value to results since only one value type
      df <- dplyr::rename(df, results = value)

      #identify grouping variables
      var_char <- df %>%
        dplyr::select(!where(is.numeric)) %>%
        dplyr::select(-period) %>%
        names()

      #arrange with in group and create cumulative
      df <- df %>%
        dplyr::group_by(dplyr::across(var_char)) %>%
        dplyr::arrange(period, .by_group = TRUE) %>%
        dplyr::mutate(results_cumulative = cumsum(results),
                      results_cumulative = ifelse(indicator %in% snapshot_ind, results, results_cumulative)) %>%
        dplyr::ungroup() %>%
        dplyr::select(-period_type)

      #convert fiscal year to integer
      df <- dplyr::mutate(df, fiscal_year = stringr::str_sub(fiscal_year, 3, 4) %>% as.integer() + 2000 %>% as.integer())
    }


  return(df)
}
