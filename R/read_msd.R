

#' Import ICPI MER Structured Datasets .txt into R and covert to .rds
#'
#' This function imports a stored ICPI MER Structured Datasets and coverts it from a .txt to an .Rds to significantly limit file size
#' @export
#' @param file enter the full path to the MSD file, eg "~/ICPI/Data/ICPI_MER_Structured_Dataset_PSNU_20180323_v2_1.txt"
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

    #covert Target/Qtr/Cumulative to double & year to integer
    df <- dplyr::mutate_at(df, dplyr::vars(TARGETS, dplyr::starts_with("Qtr"), Cumulative), ~ as.double(.))
    #convert year to integer
    df <- dplyr::mutate(df, Fiscal_Year = as.integer(Fiscal_Year))

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
