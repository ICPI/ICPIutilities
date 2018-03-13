#pacman::p_load(tidyverse, readxl, glue)


#' IMPORT DATA PACK OR DISAGG TOOL
#'
#' @param filepath where is the folder that contains the Data Pack or Disagg Tool
#' @param file what is the file name of the DP/DT
#'
#' @importFrom dplyr %>%
#'
#' @return import datafram


import <- function(filepath, file) {
  df <- readxl::read_xlsx(file.path(filepath, file), sheet = "Allocation by SNUxIM", skip = 5) %>%
    dplyr::select(-ends_with("_pct")) %>% #remove percentages since only values are used
    dplyr::mutate(D_mechanismid = as.character(D_mechanismid)) #replace mech id with character so only values are numeric
}






#' Identify duplicates
#'
#' @param filepath where is the folder that contains the Data Pack or Disagg Tool
#' @param file what is the file name of the DP/DT
#'
#' @return duplicates count (PSNU-MechanismID-Type combos should be unique)
#'
#' @importFrom dplyr %>%
#'
identify_dups <- function(filepath, file) {

  #read in DP or DTs
    df <- import(filepath, file)

  #create this variable if using data pack (only exists in DTs)
    if(!"psnu_type_mechid" %in% names(df)) {
      df <- dplyr::mutate(df, psnu_type_mechid = paste(Dsnulist, D_type, D_mech, sep = " "))
    }
  #identify if there are any duplicates & print
    dups <- dplyr::group_by(df, psnu_type_mechid)
    dups <- dplyr::filter(dups, n() > 1)
    dups <- dplyr::select(dups, psnu_type_mechid)
    if(nrow(dups) == 0) {
      return(print("No duplicates found!"))
    } else {
      return(dups)
    }
}


#' Identify Neg or Missing Errors with HTS, TX, OVC, and VMMC in Allocation Tab
#'
#' @param filepath where is the folder that contains the Data Pack or Disagg Tool
#' @param file what is the file name of the DP/DT
#'
#' @return lines where there is a numerator/disagg discrepency
#' @importFrom dplyr %>%
#'
flag_error <- function(filepath, file) {

  #read in DP or DTs
  df <- import(filepath, file)

  #flag
  df_flag <- df %>%
    #select relevant variables (ones that are subtracted in DTs)
    dplyr::select(Dsnulist:D_indicatortype, D_tx_ret_D_fy19,	D_tx_ret_u15_D_fy19, D_tx_ret_fy19,
                  D_tx_ret_u15_fy19, D_tx_new_fy19,	D_tx_new_u15_fy19, D_tx_curr_fy19,
                  D_tx_curr_u15_fy19, D_vmmc_circ_fy19, D_vmmc_circ_1529_fy19, starts_with("D_hts_tst_"), -D_hts_tst_keypop_fy19) %>%
    #reshape long & remove missing values
    tidyr::gather(indicator, val, -Dsnulist:-D_indicatortype) %>%
    dplyr::filter(!is.na(val), val!=0) %>%
    #mutate
    dplyr::mutate(
      #create integer after rounding
      val= as.integer(round(val, 0)),
      #remove "D_" and "_fy19"
      indicator = stringr::str_sub(indicator, 3, -6),
      #identify as total numerator or age disagg
      pair = dplyr::case_when(
        stringr::str_detect(indicator, "hts_tst_pos") ~ "disagg",
        stringr::str_detect(indicator, "hts_tst") ~ "total",
        stringr::str_detect(indicator, "15") ~ "disagg",
        TRUE ~ "total"),
      #define hts modalities as their own column
      modality_age = dplyr::case_when(
        stringr::str_detect(indicator, "hts_tst_pos") ~ stringr::str_replace(indicator,"hts_tst_pos_", ""),
        stringr::str_detect(indicator, "hts_tst") ~ stringr::str_replace(indicator,"hts_tst_", "")),
      #remove ages/pos from indicator name for reshape
      indicator = dplyr::case_when(
        stringr::str_detect(indicator, "hts_tst") ~ "hts_tst",
        TRUE ~ stringr::str_replace_all(indicator,c("_u15" = "", "_o15" = "", "_1529" = "", "_pos" = ""))
      )) %>%
    #reshape to compare disagg to total numerator value (replace NAs with 0)
    tidyr::spread(pair, val) %>%
    tidyr::replace_na(list(total = 0, disagg = 0)) %>%
    #rearrange
    dplyr::select(Dsnulist, D_priority, D_mechanismid, D_indicatortype, indicator, modality_age, total, disagg) %>%
    #identify the issue
    dplyr::mutate(flag = case_when(
      disagg == 0      ~ "Total but no Disagg/Pos!",
      disagg > total ~ "Greater Disagg/Pos than Total!")) %>%
    #only keep error lines
    dplyr::filter(!is.na(flag)) %>%
    #sort
    dplyr::arrange(indicator, modality_age, Dsnulist, D_mechanismid)
  return(df_flag)
}

