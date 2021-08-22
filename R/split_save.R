#' Export a single dataset into multiple files by group
#'
#' @param df dataframe to split
#' @param group_var grouping variable to split the dataset by, eg operatingunit, fundingagency
#' @param folderpath directory where you want to store the files
#' @param filename_stub generic stub for naming all the files
#' @param include_date include date after filenamestub? default = FALSE, eg "20180913"
#'
#' @export
#'
#' @importFrom dplyr %>%
#'
#' @examples
#' \dontrun{
#' #create country specific files for TX_NEW
#'  df_mer %>%
#'   filter(indicator == "TX_NEW",
#'          standardizeddisaggregate == "Total Numerator") %>%
#'   split_save(operatingunit, "~/CountryFiles", "FY18Q3_TX")
#' }

split_save <- function(df, group_var, folderpath, filename_stub, include_date = FALSE){

  .Deprecated(msg = "Functions in ICPIutilities are no longer being maintained\n and have been transfered to gophr. Install gophr via\n remotes::install_github('USAID-OHA-SI/gophr')")

  #enquote group var due to NSE
    group_var <- dplyr::enquo(group_var)

  #get a list of distinct memebers of the user defined grouping variable
    grp_members <- df %>%
      dplyr::distinct(!!group_var) %>%
      dplyr::pull()

  #include date in file name if specified
    if(include_date == TRUE) filename_stub <- paste(filename_stub, format(Sys.Date(), "%Y%m%d"), sep ="_")

  #export one file for each group member
    purrr::walk(.x = grp_members,
                .f = ~ df %>%
                  dplyr::filter(!!group_var == .x) %>%
                  readr::write_csv(file.path(folderpath, paste0(filename_stub, "_", .x, ".csv")),
                                   na = ""))
}




