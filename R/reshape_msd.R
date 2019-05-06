#' Reshape Semi-Wide MSD
#'
#' @param df MSD dataset in the semi-wide format
#' @param direction direction of reshape, wide (default) or long
#'
#' @export
#'
#' @examples
#' \dontrun{
#'  #read in data
#'   df_genie <- match_msd("~/Downloads/PEPFAR-Data-Genie-PSNUByIMs-2018-08-15.zip")
#'  #reshape long
#'   df_genie_long <- reshape_msd(df_genie, direction = "long")
#'  #or reshape wide
#'   df_genie_wide <- reshape_msd(df_genie, direction = "wide") }

reshape_msd <- function(df, direction = c("wide", "long")){

  #check if upper case (for FY or fy names)
    is_upper <- stringr::str_detect(names(df)[1], "[[:upper:]]")

  #reshape long (wide need to be reshaped long first as well)
    df <- df %>%
      tidyr::gather(period, val, targets:cumulative, na.rm = TRUE) %>%
      dplyr::filter(val != 0) %>%
      dplyr::mutate(period = stringr::str_remove(period, "tr"), #remove "tr" from "Qtr" to match old
                    period = stringr::str_replace(period, "(TARGETS|targets)", "_\\1"), #add _ to match old
                    fiscal_year = paste0(ifelse(is_upper, "FY", "fy"), fiscal_year)) %>%  #add FY to match old
      tidyr::unite(period, c(fiscal_year, period), sep = "") #combine fy and pd together

  #reshape wide (default)
    if("wide" %in% direction){
      df <- df %>%
        dplyr::mutate(period = stringr::str_replace(period, "(C|c)um", "z.\\1um")) %>% #add z to reorder correctly
        tidyr::spread(period, val) %>%
        dplyr::rename_all( ~ stringr::str_remove(.,"z.")) #remove z
    }

  return(df)
}
