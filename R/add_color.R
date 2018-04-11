#' Add ICPI colors as Vector
#'
#' @description The ICPI color palettes can be imported as hex vectors into R. To do so, you can use the `add_colors()` function to extract from Github.
#'
#' There are four color palette. To simplify the input, you will just use the last word of the color palette name in lower case.
#'
#' Palette Name | Input
#' -- | --
#'   Autumn Woods | "woods"
#' Coast of Bohemia | "bohemia"
#' Tidepools | "tidepools"
#' By the Power of Grayscale | "grayscale"
#'
#' @param palette which color palette to pull in (lower case, last word), Default = "woods"
#'
#' @importFrom dplyr %>%
#'
#' @examples
#' \dontrun{
#' #pull in Autumn Woods hex colors as vector
#'   palette_woods <- add_color()
#' #pull in By the Power of Grayscale colors as vector
#'   palette_gray <- add_color("grayscale") }
#'
add_color <- function(palette = "woods"){

  #identify github link where color palette is stored
    url <- "https://raw.githubusercontent.com/ICPI/DIV/master/Documents/Color/ICPI_Color_Palette.csv"

  #import color palette from github
    df_import <- readr::read_csv(url)

  #reshape so each column has the palette and its ordered hex colors
    df_limited <- df_import %>%
      #change palette name so in reshape, it will be just one word
      dplyr::mutate(palette2 = stringr::word(palette, -1) %>%
                        #paste("palette", ., sep = "_") %>%
                        tolower()) %>%
      #subset to just palettes
      dplyr::select(order, palette2, hex) %>%
      #reshape wide
      tidyr::spread(palette2, hex)

  #pull out list of hex colors from df
    lst_palette <- df_limited %>%
      dplyr::pull(palette)

  return(lst_palette)

}
