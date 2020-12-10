#' Import ICPI MER Structured Datasets .txt into R and covert to .rds
#'
#' This function imports a stored ICPI MER/ER Structured Datasets and coverts it from a .txt to an .Rds to significantly limit file size
#' @export
#' @param file enter the full path to the MSD/FSD file
#' @param save_rds save the Structured Dataset as an rds file, default = FALSE
#' @param remove_txt should the txt file be removed, default = FALSE
#'
#' @examples
#'
#'\dontrun{#convert Q1 clean PSNU file from txt to Rds
#'#read in file for use
#'  path <- "~/Data/ICPI_MER_Structured_Dataset_PSNU_20180323_v2_1.txt"
#'  df_psnu <- read_msd(path)
#'#convert to RDS and delete the original txt file
#'  read_msd(path, save_rds = TRUE, remove_txt = TRUE)}
#'
read_msd <-
  function(file,
           save_rds = FALSE,
           remove_txt = FALSE) {

    #read in rds if it already exists
    if(tools::file_ext(file) == "rds"){
      df <- readr::read_rds(file)
    } else {

    #import
      df <- vroom::vroom(file, delim = "\t", col_types = c(.default = "c"))

    #drop Genie variables
      vars_genie <- c("dataelementuid", "categoryoptioncombouid",
                      "approvallevel", "approvalleveldescription")
      vars_keep <- setdiff(names(df), vars_genie)
      df <- dplyr::select(df, all_of(vars_keep))

    #convert old format (pre-FY19Q1) to match new if applicable
      df <- convert_oldformat(df)

    #align FSD primepartner naming with MSD
      df <- dplyr::rename_with(df, ~stringr::str_replace(., "prime_partner", "primepartner"))

    #covert target/results/budgets to double
      df <- df %>%
        dplyr::mutate(dplyr::across(c(dplyr::matches("target"), dplyr::starts_with("qtr"),
                                      dplyr::matches("cumulative"), dplyr::matches("cop_budget"),
                                      dplyr::matches("_amt")),
                                    as.double))

    #convert year to integer
      df <- dplyr::mutate(df, fiscal_year = as.integer(fiscal_year))

    #convert blanks to NAs
     # df <- dplyr::mutate_if(df, is.character, ~ dplyr::na_if(., ""))

    #save as rds
      newfile <- rename_msd(file)
      if (save_rds == TRUE)
        saveRDS(df, newfile)

    #remove txt file
      if (remove_txt == TRUE && !grepl(".com", file))
        file.remove(file)
    }

    return(df)

  }


#' Rename MSD file when importing
#'
#' @param file enter the full path to the MSD/ERSD file, eg "~/ICPI/Data/ICPI_MER_Structured_Dataset_PSNU_20180323_v2_1.txt"

rename_msd <- function(file){

  if(stringr::str_detect(file, "Genie")){
    #classify file type
    headers <- vroom::vroom(file, n_max = 0, col_types = readr::cols(.default = "c")) %>%
      names()
    type <- dplyr::case_when(
      "sitename" %in% headers                           ~ "SITE_IM",
      !("mech_code" %in% headers)                       ~ "PSNU",
      !("psnu" %in% headers)                            ~ "OU_IM",
      TRUE                                              ~ "PSNU_IM")
    file <- file.path(dirname(file),
                      paste0("MER_Structured_Dataset_GENIE", type,
                             ifelse(type == "NAT_SUBNAT", "_FY15-21", "_FY18-21"), stringr::str_remove_all(Sys.Date(), "-"),".txt"))
  }

  file <- stringr::str_replace(file, "(zip|txt)$", "rds")

  return(file)

}


#' Convert any old MSDs to new format
#'
#' @param df data frame from read_msd()

convert_oldformat <- function(df){

  if(any(stringr::str_detect(names(df), "FY"))){

    #rename all vars to lower & to match new names
      df <- df %>%
        dplyr::rename_all(tolower) %>%
        dplyr::rename(mech_code = mechanismid,
                      mech_name = implementingmechanismname,
                      trendsfine =  agefine,
                      trendssemifine = agesemifine,
                      trendscoarse = agecoarse,
                      statushiv = resultstatus)

    #remove mechanism UID no longer used
      df <- dplyr::select(df, -mechanismuid)

    #reshape full long to convert pd from var to columne
      df <- tidyr::gather(df, period, value, dplyr::starts_with("fy"))

    #separate fy from period and reshape wide to match new format
      df <- df %>%
        dplyr::mutate(period = stringr::str_remove_all(period, "fy|_"),
                      period = stringr::str_replace(period, "q", "qtr")) %>%
        tidyr::separate(period, c("fiscal_year", "period"), sep = 4) %>%
        tidyr::spread(period, value) %>%
        dplyr::rename(cumulative = apr) %>%
        dplyr::select(-cumulative, -qtr1:-qtr4, -targets, dplyr::everything())
  }

  return(df)

}
