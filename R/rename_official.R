
#' Cleanup Mechanism and Partner Names to their Official Names
#'
#' Some mechanisms and partners are recorded in FACTSInfo with multiple names over different time period. This function replaces all partner and mechanism names the most recent name for each mechanism ID from a FACTSInfo COP Matrix Report.
#'
#' In order to run this function, you *MUST* have already downloaded a Standard COP Matrix Report from FACTSInfo. Instructures here - https://gist.github.com/achafetz/2657385467425a3aa1433716edfd322a
#'
#' @param df identify the FactView data frame to clean
#' @param report_folder_path file path to the parent folder?
#' @param report_start_year what is the start year of the COP Matrix Report, default's to 2016
#'
#' @importFrom dplyr %>%
#'
#' @examples
#' \dontrun{
#' df_psnu_im <- rename_official(df_psnu_im, "~/Documents/") }

rename_official <- function(df, report_folder_path, report_start_year = 2016) {
  #check that mechanism exists in Fact View before starting (OUxIM or PSNUxIM, not PSNU)
  if("mechanismid" %in% names(df) == FALSE) {
    stop('This dataset does not have mechanisms. Make sure it is OUxIM or PSNUxIM')
  }

  #check that COP Matrix Report exists and is in
  if(!file.exists(Sys.glob(file.path(report_folder_path,"*Standard COP Matrix Report*.xls")))){
    stop('Download FACTSInfo COP Matrix Report (instructions - https://goo.gl/hkDVjz) or re-identify folder path before continuing.')
  }

  #import official mech and partner names; source: FACTS Info
  df_names <- readxl::read_excel(Sys.glob(file.path(report_folder_path,"*Standard COP Matrix Report*.xls")), skip = 1)

  #rename variable stubs
  names(df_names) <- gsub("Prime Partner", "primepartner", names(df_names))
  names(df_names) <- gsub("Mechanism Name", "implementingmechanismname", names(df_names))

  #figure out latest name for IM and partner (should both be from the same year)
  df_names <- df_names %>%

    #rename variables that don't fit pattern
    dplyr::rename(operatingunit =  `Operating Unit`, mechanismid = `Mechanism Identifier`,
           primepartner__0 = primepartner, implementingmechanismname__0 = implementingmechanismname) %>%
    #reshape long
    tidyr::gather(type, name, -operatingunit, -mechanismid) %>%

    #split out type and year (eg type = primeparnter__1 --> type = primepartner,  year = 1)
    tidyr::separate(type, c("type", "year"), sep="__") %>%

    #add year (assumes first year if report is 2014)
    dplyr::mutate(year = as.numeric(year) + report_start_year) %>%

    #drop lines/years with missing names
    dplyr::filter(!is.na(name)) %>%

    #group to figure out latest year with names and keep only latest year's names (one obs per mech)
    dplyr::group_by(operatingunit, mechanismid, type) %>%
    dplyr::filter(year==max(year)) %>%
    dplyr::ungroup() %>%

    #reshape wide so primepartner and implementingmechanismname are two seperate columsn to match fact view dataset
    tidyr::spread(type, name) %>%

    #convert mechanism id to string for merging back onto main df
    dplyr::mutate(mechanismid = as.character(mechanismid)) %>%

    #keep only names with mechid and renaming with _F to identify as from FACTS
    dplyr::select(mechanismid, implementingmechanismname, primepartner) %>%
    dplyr::rename(implementingmechanismname_F = implementingmechanismname, primepartner_F = primepartner)

  #match mechanism id type for compatible merge
  df <- dplyr::mutate(df, mechanismid = as.character(mechanismid))

  #merge in official names
  df <- dplyr::left_join(df, df_names, by="mechanismid")

  #replace prime partner and mech names with official names
  df <- df %>%
    dplyr::mutate(implementingmechanismname = ifelse(is.na(implementingmechanismname_F), implementingmechanismname, implementingmechanismname_F),
           primepartner = ifelse(is.na(primepartner_F), primepartner, primepartner_F)) %>%
    dplyr::select(-dplyr::ends_with("_F"))
}
