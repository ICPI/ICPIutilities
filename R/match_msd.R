#' Transmute DATIM Genie output to match MER Structured Dataset
#'
#' @param genie_filepath enter the full file path to the zipped DATIM Genie file
#' @param to_lower do you want to convert all names to lower case, default = TRUE
#' @param save_rds save the Structured Dataset as a rds file, default = TRUE
#'
#' @export
#'
#' @importFrom dplyr %>%
#' @examples
#' \dontrun{
#' df_genie <- match_msd("~/Downloads/PEPFAR-Data-Genie-PSNUByIMs-2018-08-15.zip") }
#'
match_msd <- function(genie_filepath,
                      to_lower = TRUE,
                      save_rds = TRUE){

  #rename Genie name to be similar to the MSD file name
    #determine filename in zipped folder to create filepath once extracted
    file <- unzip(genie_filepath, list = TRUE) %>% .$Name
    #extract file from zipped folder
    extract_path <- dirname(genie_filepath)
    unzip(genie_filepath, exdir = extract_path)
    #determine file path for renaming
    filepath <- file.path(extract_path, file)
    #classify file type
    headers <- readr::read_tsv(filepath, n_max = 0, col_types = readr::cols(.default = "c")) %>%
      names()
    type <- dplyr::case_when(
      any(str_detect(names(headers), "FY[:digit:]{4}"))  ~ "NAT_SUBNAT",
      "SiteName" %in% headers                           ~ "SITE_IM",
      !("mech_code" %in% headers)                       ~ "PSNU",
      !("PSNU" %in% headers)                            ~ "OU_IM",
      TRUE                                              ~ "PSNU_IM")
    filename_new <- file.path(extract_path,
                              paste0("MER_Structured_Dataset_", type,
                                     ifelse(type == "NAT_SUBNAT", "_FY15-20", "_GENIE_FY18-20"), stringr::str_remove_all(Sys.Date(), "-"),".txt"))
    file.rename(filepath, filename_new)

  #import and save as RDS
    df_genie <- ICPIutilities::read_msd(filename_new, to_lower = FALSE, save_rds = FALSE, remove_txt = TRUE)

  #clean up
    df_genie <- df_genie %>%
      #remove elements missing from MSD
      dplyr::select(-c(dataElementUID, categoryOptionComboUID, ApprovalLevel, ApprovalLevelDescription)) %>%
      #group by meta data
      dplyr::mutate(Fiscal_Year = as.character(Fiscal_Year)) %>%
      dplyr::group_by_if(is.character) %>%
      #aggregate to create cumulative value
      dplyr::summarise_if(is.double, sum, na.rm = TRUE) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(Fiscal_Year = as.integer(Fiscal_Year))

  #rename to lower for ease of use
    if (to_lower == TRUE)
      df_genie <- dplyr::rename_all(df_genie, tolower)

  #save as rds
    newfile <- stringr::str_replace(filename_new, "txt", "rds")
    if (save_rds == TRUE)
      saveRDS(df_genie, newfile)

    return(df_genie)

}
