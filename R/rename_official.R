
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
  if(("mechanismid" %in% names(df) == FALSE && "MechanismID" %in% names(df) == FALSE)) {
    stop('This dataset does not have mechanisms. Make sure it is OUxIM or PSNUxIM')
  }

  #store column names (to work for both lower case and camel case) & then covert to lowercase
    headers_orig <- names(df)
    df <- dplyr::rename_all(df, ~ tolower(.))

  #access current mechanism list posted publically to DATIM
    mech_official <- readr::read_csv("https://www.datim.org/api/sqlViews/fgUtV6e9YIX/data.csv",
                                     col_types = readr::cols(.default = "c"))

  #rename variables to match MSD and remove mechid from mech name
    mech_official <- mech_official %>%
      dplyr::select(mechanismid = code,
                    primepartner_d = partner,
                    implementingmechanismname_d = mechanism) %>%
      dplyr::mutate(implementingmechanismname_d = stringr::str_remove(implementingmechanismname_d, "0000[0|1] |[:digit:]+ - "))

  #merge official names into df
    df <- dplyr::left_join(df, mech_official, by="mechanismid")

  #replace prime partner and mech names with official names and then remove
    df <- df %>%
      dplyr::mutate(implementingmechanismname = implementingmechanismname_d,
                    primepartner = primepartner_d) %>%
      dplyr::select(-dplyr::ends_with("_d"))

  #reapply original variable casing type
    names(df) <- headers_orig

  return(df)
}
