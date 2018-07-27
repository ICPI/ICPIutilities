#' Add NET_NEW to dataset (orginally in achafetz/PartnerProgress)
#'
#' @param df dataframe to create net new based off of and append onto
#' @param archived_msd_folderpath if importing FY16Q4 data, identify the folder path where archived file with FY15-16 data sits
#'
#' @export
#'
#' @importFrom dplyr %>%
#'
#' @examples
#' \dontrun{
#' df_msd <- combine_netnew(df_msd, "~/ICPI/Data")}
#'
#'
combine_netnew <- function(df, archived_msd_filepath = NULL){

  #if merging in FY16Q4 data to ensure FY17cum TX_NET_NEW correctness
    if(!is.null(archived_msd_filepath)){
      df <- import_oldtx(df, archived_msd_filepath)
    }

  #store column names (to work for both lower case and camel case) & then covert to lowercase
    headers_orig <- names(df)
    df <- dplyr::rename_all(df, ~ tolower(.))

  #save column names/order for binding at end
    msd_order <- names(df)

  #keep TX_CURR to create net_new off of
    df_tx <- df %>%
      dplyr::filter(indicator == "TX_CURR")

  #ensure coarsedisggregate is a character for grouping
    df_tx <- df_tx %>%
       dplyr::mutate(coarsedisaggregate = as.character(coarsedisaggregate))

  #create net new values for results and targets
    df_nn_result <- gen_netnew(df_tx, type = "result")
    df_nn_target <- gen_netnew(df_tx, type = "target")

  #create new new for apr by aggregating results data
    df_nn_apr <- df_nn_result %>%
      #reshape long so years can be aggregated together
      tidyr::gather(pd, val, dplyr::starts_with("fy2")) %>%
      #remove period, leaving just year to be aggregated together
      dplyr::mutate(pd = stringr::str_remove(pd, "q[:digit:]"),
                    pd = as.character(pd)) %>%
      #aggregate
      dplyr::group_by_if(is.character) %>%
      dplyr::summarise(val = sum(val, na.rm = TRUE)) %>%
      dplyr::ungroup() %>%
      #rename year with apr to match structured dataset & replace 0's
      dplyr::mutate(pd = paste0(pd, "apr"),
                    val = ifelse(val==0, NA, val)) %>%
      #reshape wide to match MSD
      tidyr::spread(pd, val)

  #join all net new pds/targets/apr together
    join_vars <- df %>%
      dplyr::select(-dplyr::starts_with("fy")) %>%
      names()
    df_combo <- dplyr::full_join(df_nn_result, df_nn_target, by = join_vars)
    df_combo <- dplyr::full_join(df_combo, df_nn_apr, by = join_vars)

  #add dropped values back in and reoder to append onto original dataframe
    df_combo <- df_combo %>%
      dplyr::select(msd_order)

  #append TX_NET_NEW onto main dataframe
    df <- dplyr::bind_rows(df, df_combo)

  #reapply original variable casing type
    names(df) <- headers_orig

  return(df)

}



#' Create Net New Variable
#'
#' @param df data frame to use
#' @param type either result or target, default = result
#'
#' @importFrom dplyr %>%
#'
#' @examples
#' \dontrun{
#' df_mds_results <- gen_netnew(df_mds, type = "result")}

gen_netnew <- function(df, type = "result"){

  #for results, only want to keep quarterly data; for targets, calc off targets and priod q4
    if(type == "result") {
      df_nn <- df %>%
        dplyr::select(-dplyr::ends_with("targets"))
    } else {
      df_nn <- df %>%
        dplyr::select(-dplyr::ends_with("q1"), -dplyr::ends_with("q2"), -dplyr::ends_with("q3"))

    }

  #aggregate so only one line per mech/geo/disagg
    df_nn <- df_nn %>%
      #remove uids that different between targets/results and no need for apr value
      dplyr::select(-dplyr::ends_with("apr")) %>%
      #aggregate all quartertly data
      dplyr::group_by_if(is.character) %>%
      dplyr::summarize_at(dplyr::vars(dplyr::starts_with("fy2")), ~ sum(., na.rm = TRUE)) %>%
      dplyr::ungroup()

  #reshape long to subtract prior pd (keeping full set of pds to ensure nn = pd - pd_lag.1)
    df_nn <- df_nn %>%
      tidyr::gather(pd, val, dplyr::starts_with("fy2"), factor_key = TRUE) %>%
      #fill all NAs with zero so net new can be calculated
      dplyr::mutate(val = ifelse(is.na(val), 0, val))

  #create new new variables
    df_nn <- df_nn %>%
      #group by all meta data and then order by period within each group
      dplyr::group_by_if(is.character) %>%
      dplyr::arrange(pd) %>%
      dplyr::mutate(netnew = val - dplyr::lag(val)) %>%
      dplyr::ungroup() %>%
      #replace all 0's with NA and change ind name from TX_CURR to TX_NET_NEW
      dplyr::mutate(netnew = ifelse(netnew==0, NA, netnew),
             indicator = "TX_NET_NEW") %>%
      #remove val since just need net new
      dplyr::select(-val) %>%
      #reshape wide to bind back onto main data frame
      tidyr::spread(pd, netnew)

  #remove Q4 for targets since just needed for target calc and q4 net new here is meaningless/wrong
    if(type == "target"){
      df_nn <- df_nn %>%
        dplyr::select(-dplyr::ends_with("q4"))
    }

    return(df_nn)
}


