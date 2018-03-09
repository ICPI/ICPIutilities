#' import PSNUxIM pairs from DP Allocation tab
#'
#' @param folderpath folder location where the data pack is stored
#' @param filename file name of the data pack including .xlsx
#' @param type either orig or new
#'
#' @return PSNU, IM and Type columns from the DP

import_pairs <- function(folderpath, filename, type){
  require(dplyr)
  require(readxl)
  require(magrittr)
  df <- readxl::read_xlsx(file.path(folderpath, filename),
                          sheet = "Allocation by SNUxIM", skip = 3)
  df <- dplyr::filter(df, !Dsnulist %in% c("Total", "Filter Row", "Dsnulist")) %>%
    dplyr::select(Dsnulist, D_priority,	D_mech,	D_type) %>%
    dplyr::mutate_all(as.character)
  dplyr::mutate(df, !!type := 1)
}



#' compare PSNUxIM pairs in Original v Current DP allocation tab
#'
#' @param new_file file name of the new Data Pack including .xlsx
#' @param orig_file file name of the original Data Pack including .xlsx
#' @param folderpath folder location where both data pack's are stored
#'
#' @return PSNU, IM and Type columns comparison to use in Disagg Tools

compair <- function(new_file, orig_file, folderpath){
  require(dplyr)
  df_orig <- import_pairs(folderpath, orig_file, "orig")
  df_new <- import_pairs(folderpath, new_file, "new")
  df_full <- dplyr::full_join(df_orig, df_new)
  df_full <- dplyr::mutate(df_full, to_add = if_else(is.na(orig), "ADD", ""))
  readr::write_csv(df_full, file.path(folderpath,"pairstoadd.csv"), na= "")
}



