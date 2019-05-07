#' Add cumulative value for current FY
#' @description This function is adapted from the achafetz/PartnerProgress repo.
#' Given the change to the MSD and inclusion of a cumulative value, this function
#' is no longer necessary and is deprecated.
#' @param df data frame to add cumulative column onto
#' @param priorpd add APR value is missing from a prior year
#'
#' @export
#'
#' @importFrom dplyr %>%
#' @importFrom dplyr vars
#'
#' @examples
#' \dontrun{
#' df_mer <- add_cumulative(df_mer)
#' df_genieextract <- add_cumulative(df_genieextract, "2017")}


add_cumulative <- function(df, priorpd = NULL){

  .Deprecated(msg = "Given MSD's structural revision, `add_cumulative()` is no longer useful and has been deprecated.")

  #store column names (to work for both lower case and camel case) & then covert to lowercase
    headers_orig <- names(df)
    df <- dplyr::rename_all(df, ~ tolower(.))

  #convert any logical/factor variables to character (if they exist)
    df <- df %>%
      dplyr::mutate_if(is.logical, ~ as.character(.)) %>%
      dplyr::mutate_if(is.factor,  ~ as.character(.))

  #aggregate so no no double counting (eg mech with 2 lines, one targ, one resuls only)
    df <- df %>%
      dplyr::group_by_if(is.character) %>%
      dplyr::summarize_if(is.double, sum, na.rm = TRUE) %>%
      dplyr::ungroup()

  #identify period
    if(!is.null(priorpd)){
      fy <- as.integer(priorpd)
      qtr <- 4L
    } else {
    fy <- identifypd(df, "year")
    qtr  <- identifypd(df, "quarter")
    }
  #concatenate variable name, eg fy2018cum
    varname <- paste0("fy", fy, "cum")
  #add q to end of fy select function
    fy_str <- paste0("fy", fy, "q")

  #generate cumulative value
    #if its Q4, just use APR value
    if(qtr == 4 && is.null(priorpd)){
      df <- df %>%
        dplyr::mutate(!!varname := get(paste0("fy", fy, "apr")))

        #reapply original variable casing type plus cumulative
        headers_orig <- c(headers_orig, varname)
        names(df) <- headers_orig

        return(df)

    } else {

    #identify "metadata" columns to keep
      lst_meta <- df %>%
        dplyr::select_if(is.character) %>%
        names()

    #aggregate curr fy quarters via reshape and summarize
      df_cum <- df %>%
        #keep "metadata" and any quarterly values from current fy
        dplyr::select(lst_meta, dplyr::starts_with(fy_str))  %>%
        #reshape long (and then going to aggregate)
        tidyr::gather(pd, !!varname, dplyr::starts_with(fy_str), na.rm  = TRUE) %>%
        #aggregating over all quaters, so remove
        dplyr::select(-pd) %>%
        #group by meta data
        dplyr::group_by_if(is.character) %>%
        #aggregate to create cumulative value
        dplyr::summarise_at(dplyr::vars(!!varname), ~ sum(.)) %>%
        dplyr::ungroup()

     #merge cumulative back onto main df
      df <- dplyr::full_join(df, df_cum, by = lst_meta)

      #adjust semi annual indicators
      semi_ann <- c("AGYW_PREV", "CXCA_SCRN", "CXCA_TX",
                    "KP_PREV", "OVC_HIVSTAT", "OVC_SERV",
                    "PP_PREV", "PrEP_CURR", "PrEP_NEW",
                    "SC_STOCK", "TB_PREV", "TX_ML", "TX_TB")
      if(qtr %in% c(2, 3)) {
        df <- dplyr::mutate(df, !!varname := ifelse(indicator %in% semi_ann, get(paste0(fy_str, "2")), get(!!varname)))
      }
      if(!is.null(priorpd)) {
        df <- dplyr::mutate(df, !!varname := ifelse(indicator %in% semi_ann, get(paste0(fy_str, "4")), get(!!varname)))
      }

      #adjust FY17APR value for OVC_SERV - sum of program areas less FY17Q2 Active
      df <- adj_ovc_apr17(df)

      #adjust snapshot indicators to equal current quarter
      snapshot <- c("TX_CURR")
      df <- dplyr::mutate(df, !!varname := ifelse(indicator %in% snapshot, get(paste0(fy_str, qtr)), get(!!varname)))

      #reapply original variable casing type plus cumulative
      headers_orig <- c(headers_orig, varname)
      names(df) <- headers_orig

      if(!is.null(priorpd)) {
        varname_apr <- paste0("fy", fy, "apr")
        q4 <- paste0("fy", fy, "q4")

        if(TRUE %in% stringr::str_detect(names(df), "Q")) {
          varname_apr <- toupper(varname_apr)
          q4 <- toupper(q4)
        }
        df <- df %>%
          tibble::add_column(!!varname_apr := as.numeric(NA), .after = q4) %>%
          dplyr::mutate(!!varname_apr := get(varname)) %>%
          dplyr::select(-dplyr::contains("cum"))
      }

      return(df)
    }

}
