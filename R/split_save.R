#' Export a single dataset into multiple files by group
#'
#' @param df dataframe to split
#' @param folderpath directory where you want to store the files
#' @param filename_stub generic stub for naming all the files
#'
#' @export
#'
#' @importFrom dplyr %>%
#'
#' @examples
#' \dontrun{
#'   split_save(df, "~/CountryFiles", "FY18Q3_TX")
#' }

split_save <- function(df, folderpath, filename_stub){
  df %>%
    split(.$operatingunit) %>%
    purrr::walk(~.x %>%
                  readr::write_csv(file.path(folderpath,
                                             paste0(filename_stub, "_", unique(.$operatingunit), ".csv"),
                                   na = "")))
}




