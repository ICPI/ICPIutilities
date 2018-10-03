#' Add FY17 APR OVC_SERV Total Numerator
#'
#' @param df dataframe to adjust OVC_SERV FY17 APR targets
#'
#' @importFrom dplyr %>%
#'

adj_ovc_apr17 <- function(df){

  if("fy2017cum" %in% names(df) && "OVC_SERV" %in% unique(df$indicator)) {

    #filter for just OVC ProgramStatus to convert and then aggregate
    df_ovc <- df %>%
      dplyr::filter(indicator == "OVC_SERV", standardizeddisaggregate == "ProgramStatus")

    #remove FY17Q2 Active since only Q4 is used & create APR column
    df_ovc <- df_ovc %>%
      dplyr::mutate_at(dplyr::vars(fy2017q2, fy2017q4), ~ ifelse(is.na(.), 0, .)) %>%
      dplyr::mutate(fy2017q2 = ifelse(otherdisaggregate == "Active", 0, fy2017q2),
                    fy2017cum = fy2017q2 + fy2017q4)

    #change program status to match Total Numerator
    df_ovc <- df_ovc %>%
      dplyr::mutate(disaggregate = "Total Numerator",
                    standardizeddisaggregate = "Total Numerator",
                    categoryoptioncomboname = "default",
                    agefine = NA,
                    otherdisaggregate = NA)

    #aggregate created fy2017apr
    df_ovc <- df_ovc %>%
      dplyr::group_by_if(is.character) %>%
      dplyr::summarise_at(dplyr::vars(fy2017cum), ~ sum(., na.rm = TRUE)) %>%
      dplyr::ungroup() %>%
      dplyr::filter(fy2017cum != 0)

    #remove fy2017apr and merge on actual OVC numerator
    df <- df %>%
      dplyr::mutate(fy2017cum = ifelse((indicator == "OVC_SERV" & standardizeddisaggregate == "Total Numerator"), NA, fy2017cum)) %>%
      dplyr::bind_rows(df_ovc)
    rm(df_ovc)

  }
    invisible(df)
}
