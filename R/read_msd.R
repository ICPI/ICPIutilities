

#' Import ICPI MER Structured Datasets .txt into R and covert to .rds
#'
#' This function imports a stored ICPI MER/ER Structured Datasets and coverts it from a .txt to an .Rds to significantly limit file size
#' @export
#' @param file enter the full path to the MSD/ERSD file, eg "~/ICPI/Data/ICPI_MER_Structured_Dataset_PSNU_20180323_v2_1.txt"
#' @param to_lower do you want to convert all names to lower case, default = TRUE
#' @param save_rds save the Structured Dataset as an rds file, default = TRUE
#' @param remove_txt should the txt file be removed, default = FALSE
#'
#' @examples
#'
#'\dontrun{#convert Q1 clean PSNU file from txt to Rds
#'#read in file for use (without saving as an RDS)
#'    df_psnu <- read_msd("~/ICPI/Data/ICPI_MER_Structured_Dataset_PSNU_20180323_v2_1.txt", save_rds = FALSE)
#'#convert to RDS and delete the original txt file
#'  read_msd("~/ICPI/Data/ICPI_MER_Structured_Dataset_PSNU_20180323_v2_1.txt", remove_txt = TRUE)}
#'
read_msd <-
  function(file,
           to_lower = TRUE,
           save_rds = TRUE,
           remove_txt = FALSE) {
    #ensure file ends in .txt
    if (stringr::str_detect(file, ".zip") == TRUE)
      file <- unzip_msd(file, remove_txt)

    #import
    df <- data.table::fread(file, sep = "\t", colClasses = "character", showProgress = FALSE)
    df <- tibble::as_tibble(df)

    #ER vs MER (MSD or Genie)
    if (stringr::str_detect(file, "/ER_Structured_Dataset")) {
      df <- dplyr::rename_all(df, ~stringr::str_remove_all(., " |-"))
      df <- dplyr::mutate(df, FY2018 = as.double(FY2018))
      #mach MSD
      df <- dplyr::rename(df, MechanismID = Mechanism,
                              PrimePartner = PrimePartnerName,
                              ImplementingMechanismName = MechanismName,
                              Cumulative = FY2018)
      df <- tibble::add_column(df, Fiscal_Year = 2018L, .after = "Dataset")
    } else if (any(stringr::str_detect(names(df), "FY[:digit:]{4}"))) {
      df <- df %>%
        dplyr::rename(AgeAsEntered = age_as_entered,
                      TrendsCoarse  = coarse_age) %>%
        tidyr::gather(Fiscal_Year, Cumulative, dplyr::starts_with("FY")) %>%
        dplyr::mutate(Fiscal_Year = stringr::str_remove(Fiscal_Year, "FY"),
                      Cumulative = as.double(Cumulative),
                      Fiscal_Year = as.integer(Fiscal_Year))
    } else {
      #covert Target/Qtr/Cumulative to double & year to integer
      df <- dplyr::mutate_at(df, dplyr::vars(TARGETS, dplyr::starts_with("Qtr"), Cumulative), ~ as.double(.))
      #convert year to integer
      df <- dplyr::mutate(df, Fiscal_Year = as.integer(Fiscal_Year))
    }

    #convert blanks to NAs
    df <- dplyr::mutate_if(df, is.character, ~ dplyr::na_if(., ""))

    #rename to lower for ease of use
    if (to_lower == TRUE)
      df <- dplyr::rename_all(df, ~ tolower(.))

    #save as rds
    newfile <- stringr::str_replace(file, "txt", "rds")
    if (save_rds == TRUE)
      saveRDS(df, newfile)

    #remove txt file
    if (remove_txt == TRUE)
      file.remove(file)

    return(df)
  }


#' Unzip packaged MSD
#'
#' @param msdfilepath_zip full file path of zipped MSD
#' @param remove_zip after extracting the flat file, do you want the zipped folder removed?

unzip_msd <- function(msdfilepath_zip, remove_zip = FALSE){

  #identify folder zipped file is stored in for extraction
  folder <- dirname(msdfilepath_zip)

  #identify txt file name in the zipped folder to use with read_msd()
  file <- unzip(msdfilepath_zip, list = TRUE)
  file <- file$Name

  #unzip MSD
  unzip(msdfilepath_zip, exdir = folder)

  #unziped file folderpath
  new_filepath <- file.path(folder, file)

  #delete zip file
  if (remove_zip == TRUE)
    unlink(msdfilepath_zip)

  return(new_filepath)
}
