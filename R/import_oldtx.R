
#' Import FY16Q4 data for TX_NET_NEW Calculation
#'
#' @param df dataframe to add archived data onto
#' @param archived_msd_folderpath folder path where archived file with FY15-16 data sits
#' @param prior_fy what year do you want to extract Q4 from in the archived dataset
#'
#' @importFrom dplyr %>%

import_oldtx <- function(df, archived_msd_folderpath, prior_fy = "2016"){

  #determine MSD type - OU_IM, PSNU, or PSNU_IM
    #a. collect header names
    headers <- df %>%
      dplyr::rename_all(~ tolower(.)) %>%
      names()
    #b. classify
    msd_type <- dplyr::case_when(
      !("mechanismid" %in% headers) ~ "PSNU",
      !("psnu" %in% headers)        ~ "OU", #"OU_IM"
      TRUE                          ~ "PSNU_IM"
    )

  #check if archive rds/txt file exists
    msdfile_rds <- Sys.glob(file.path(archived_msd_folderpath, paste0("*MER_Structured_Dataset_", msd_type, "_FY15-16*.Rds")))
    msdfile_txt <- Sys.glob(file.path(archived_msd_folderpath, paste0("*MER_Structured_Dataset_", msd_type, "_FY15-16*.txt")))
    if(length(msdfile_rds) == 0 && length(msdfile_txt) == 0){
      stop("No archived file exists in specified folder to append onto current dataframe")
    }

  #open rds/txt file
    if(length(msdfile_rds) == 1){
      df_tx_old <- readr::read_rds(msdfile_rds) %>%
        dplyr::filter(indicator == "TX_CURR", standardizeddisaggregate %in% c("Total Numerator", "MostCompleteAgeDisagg"))
    }

    if(length(msdfile_rds) == 0 && length(msdfile_txt) == 1){
      df_tx_old <- ICPIutilities::read_msd(msdfile_txt, save_rds = FALSE) %>%
        dplyr::filter(indicator == "TX_CURR", standardizeddisaggregate %in% c("Total Numerator", "MostCompleteAgeDisagg"))
    }

  #store column names (to work for both lower case and camel case) & then covert to lowercase
    headers_meta <- df %>%
      dplyr::select_if(is.character) %>%
      names()
    header_vals <- df %>%
      dplyr::select_if(is.numeric) %>%
      names()
    df <- dplyr::rename_all(df, ~ tolower(.))

  #filter to operatingunit(s) in original dataframe
    ous <- unique(df$operatingunit)
    df_tx_old <- dplyr::filter(df_tx_old, operatingunit %in% ous)

  #setup period to extract
    old_pd <- paste0("fy", prior_fy, "q4")

  #limit just to just meta data (string vars), excluding partner/mech and other UIDs that may lead to misalignment in merge
    lst_meta <- df_tx_old %>%
      dplyr::select_if(is.character) %>%
      names()
    df_tx_old <- dplyr::select(df_tx_old, lst_meta, old_pd)

  #rename offical
    df_tx_old <- ICPIutilities::rename_official(df_tx_old)

  #aggregate
    df_tx_old <- df_tx_old %>%
      dplyr::group_by_if(is.character) %>%
      dplyr::summarise_at(dplyr::vars(old_pd), ~ sum(., na.rm = TRUE)) %>%
      dplyr::ungroup() %>%
      dplyr::filter_at(dplyr::vars(old_pd), dplyr::any_vars(.!= 0))

  #join archive data onto current dataset
    df_merge <- dplyr::full_join(df, df_tx_old, by = lst_meta)

  #reorder so FY16Q4 comes before FY17
    lst_meta <- df_merge %>%
      dplyr::select_if(is.character) %>%
      names()
    df_merge <- dplyr::select(df_merge, lst_meta, old_pd, dplyr::everything())

  #reapply original variable casing
    names(df_merge) <- c(headers_meta, old_pd, header_vals)

  #change old q4 to upper case if necessary
    test_upper <- paste0("FY",ICPIutilities::identifypd(df, "year"),"Q1")
    if(test_upper %in% names(df)){
      old_pd_upper <- toupper(old_pd)
      df_merge <- dplyr::rename(df_merge, !!old_pd_upper := !!old_pd)
    }

  return(df_merge)

}
