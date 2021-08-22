.onLoad <- function (libname, pkgname)
{
  packageStartupMessage("\nWARNING:\nICPIutilities is no longer being maintained.\nFunctions have been transfered to USAID-OHA-SI/gophr.\nInstall gophr via\n remotes::install_github('USAID-OHA-SI/gophr')\n")
}


#' Check if all variables in list exist
#'
#' @param df data frame
#' @param vars quoted variable(s)
#'
var_exists <- function(df, vars){
  all(vars %in% names(df))
}

#' Check if all variables in list are missing
#'
#' @param df data frame
#' @param vars quoted variable(s)
#'
var_missing <- function(df, vars){
  !any(vars %in% names(df))
}

