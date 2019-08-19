
#' Cleanup Mechanism and Partner Names to their Official Names
#'
#' Some mechanisms and partners are recorded in FACTSInfo with multiple names over different time period. This function replaces all partner and mechanism names the most recent name for each mechanism ID pulling from a DATIM SQL View.
#'
#' @param df identify the MER Structured DataSet to clean
#'
#' @importFrom dplyr %>%
#'
#' @export
#'
#' @examples
#' \dontrun{
#' df_psnu_im <- rename_official(df_psnu_im) }

rename_official <- function(df) {

  #check that mechanism exists in MSD before starting (OUxIM or PSNUxIM, not PSNU)
  if(("mech_code" %in% names(df) == FALSE)) {
    stop('This dataset does not have mechanisms. Make sure it is OUxIM or PSNUxIM')
  }

  #check internet connection
  if(curl::has_internet() == FALSE) {
    print("No internet connection. Cannot access offical names & rename.")
  } else {

  #store column names (to work for both lower case and camel case) & then covert to lowercase
    headers_orig <- names(df)
    df <- dplyr::rename_all(df, tolower)

  #access current mechanism list posted publically to DATIM
    sql_view_url <- "https://www.datim.org/api/sqlViews/fgUtV6e9YIX/data.csv"
    mech_official <- readr::read_csv(sql_view_url,
                                     col_types = readr::cols(.default = "c"))

  #rename variables to match MSD and remove mechid from mech name
    mech_official <- mech_official %>%
      dplyr::select(mech_code = code,
                    primepartner_d = partner,
                    mech_name_d = mechanism) %>%
      dplyr::mutate(mech_name_d = stringr::str_remove(mech_name_d, "0000[0|1] |[:digit:]+ - "))

  #merge official names into df
    df <- dplyr::left_join(df, mech_official, by="mech_name")

  #replace prime partner and mech names with official names and then remove
    if(!"mech_name" %in% names(df)){
      df <- dplyr::mutate(df, mech_name = as.character(NA))
    }
    if(!"primepartner" %in% names(df)){
      df <- dplyr::mutate(df, primepartner = as.character(NA))
    }

    df <- df %>%
      dplyr::mutate(mech_name = mech_name_d,
                    primepartner = primepartner_d) %>%
      dplyr::select(-dplyr::ends_with("_d"))

  #reapply original variable casing type
    names(df) <- headers_orig
  }

  return(df)
}
