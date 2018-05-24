

#' Import ICPI MER Structured Datasets .txt into R and covert to .rds
#'
#' This funciton imports a stored ICPI MER Structured Datasets and coverts it from a .txt to an .Rds to significantly limit file size
#' @export
#' @param file enter the full path to the MSD file, eg "~/ICPI/Data/ICPI_MER_Structured_Dataset_PSNU_20180323_v2_1.txt"
#' @param to_lower do you want to convert all names to lower case, default = TRUE
#' @param save_rds save the Structured Dataset as an Rds file, default = TRUE
#' @param remove_txt should the txt file be removed, default = FALSE
#'
#' @importFrom dplyr %>%
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
    if (stringr::str_detect(file, ".txt") == FALSE)
      file <- paste0(file, ".txt")

    #import
    df <- readr::read_tsv(file.path(file),
                          col_types = cols(.default = "c"))

    #change mechid to character for ease of use
    if ("MechanismID" %in% names(df))
      df <- dplyr::mutate(df, MechanismID = as.character(MechanismID))

    #rename to lower for ease of use
    if (to_lower == TRUE)
      df <- dplyr::rename_all(df, ~ tolower(.))

    #save as Rds
    newfile <- stringr::str_replace(file, "txt", "Rds")
    if (save_rds == TRUE)
      saveRDS(df, newfile)

    #remove txt file
    if (remove_txt == TRUE)
      file.remove(file)

    return(df)
  }
