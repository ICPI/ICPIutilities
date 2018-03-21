

#' Import Fact View Dataset .txt into R and covert to .rds
#'
#' This funciton imports a stored ICPI Fact View Dataset and coverts it from a .txt to an .Rds to significantly limit file size
#' @export
#' @param file What is the file name, eg ICPI_FactView_PSNU_20171222_v2_1.txt?
#' @param path file path to the parent folder, default = "~/ICPI/Data/"
#' @param to_lower do you want to convert all names to lower case, default = TRUE
#' @param save_rds save the Fact View as an Rds file, default = TRUE
#' @param remove_txt should the txt file be removed, default = FALSE
#'
#' @importFrom dplyr %>%
#' @examples
#'
#'\dontrun{#convert Q4 clean OUxIM file from txt to Rds
#'  df_fv_psnu <- read_fv("ICPI_FactView_PSNU_20171222_v2_1.txt",
#'  path = "~/Downloads/")
#'#import Q1 PSNU
#'  df_pnsu <-  read_fv("ICPI_FactView_PSNU_20180215_v1_3.txt",
#'  path = "~/Downloads/", save_rds = FALSE)}
#'
read_fv <-
  function(file,
           path = "~/ICPI/Data/",
           to_lower = TRUE,
           save_rds = TRUE,
           remove_txt = FALSE) {
    #ensure file ends in .txt
    if (stringr::str_detect(file, ".txt") == FALSE)
      file <- paste0(file, ".txt")

    #import
    df <- readr::read_tsv(file.path(path, file),
                          guess_max = 500000)

    #change mechid to character for ease of use
    if ("MechanismID" %in% names(df))
      df <- dplyr::mutate(df, MechanismID = as.character(MechanismID))

    #rename to lower for ease of use
    if (to_lower == TRUE)
      df <- dplyr::rename_all(df, ~ tolower(.))

    #save as Rds
    newfile <- stringr::str_replace(file, "txt", "Rds")
    if (save_rds == TRUE)
      saveRDS(df, file.path(path, newfile))

    #remove txt file
    if (remove_txt == TRUE)
      file.remove(file.path(path, file))

    return(df)
  }
