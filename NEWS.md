# ICPIutilities 2.1.1

# ICPIutilities 2.1.0
* add new function, `calc_genpop()`, which create a new disaggregate to breakout general population from key populations

# ICPIutilities 2.0.3
* adjust `reshape_msd()` to allow to work with naitive camel case variable names in MSD

# ICPIutilities 2.0.2
* fixed bug in `read_msd()` that didn't recognize Genie files which didn't convert the targets, quarters or cumulative to numeric columns.

# ICPIutilities 2.0.1

* `identify_pd()` updated to work with the new dataset structure
* `reshape_msd()` function reshapes the current structure to fully long or to match the previous MSD's wider format
* `read_msd()`
  - updated to work for semiwide format
  - `Fiscal_Year` treated as integer
  - Users can now enter a zipped filepath into `file` and `read_msd()` will extract the flat file and import it
  - Compatible with the ER dataset
* `add_cumulative()`
  - Update semi-annual indicator list to reflect MER 2.3 indicator changes
  - Removed adjustment for FY17 OVC APR
  - DEPRECATED: MSD's new structure includes cumulative natively
*`rename_official()` cleaned up code, using `curl` to check internet connection
  
# ICPIutilities 1.0.25

* Fix bug with `read_msd()` where columns with now values would be converted to string. Important update for `match_msd()` where this may occur.
* When no connection is available, `rename_official()` will print out a warning rather than result in an error, halting the rest of the script execution.

# ICPIutilities 1.0.24

* Remove creation of FY17 APR column in `match_msd()` as it is now included in the Genie (as of Oct 24, 2018)
* Resolve grouping & duplication bug with `add_cumulative()`. Now it aggregates before adding a cumulative value in. 

# ICPIutilities 1.0.23

* Allow user to convert site level Genie output to match MSD via the `match_msd()` function
* Fixes bug for `identifypd()`, where if `pd_type == "year"` and `prior_pd = TRUE` returned current year

# ICPIutilities 1.0.22

* Adjusted the FY17 APR OVC_SERV values created with `add_cumulative()` to be correct (ie using with Genie) (#36)
* Fixed bug in `add_cumulative()` that broke code if variables were upper case

# ICPIutilities 1.0.21

* All RDS files are now saved (and work off of) all lower case file extensions `.rds` instead of `.Rds` (#32)
* Added a `NEWS.md` file to track changes to the package.



