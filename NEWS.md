# ICPIutilities 2.2.1
* add a new function, `calc_achievement` for cumulative and quarterly target achievement calculations
* update naming of `primepartner` from FSD and remove a tab quote from `cop_budget_pipeline` amount that was throwing a warning after convering to a double
* changes the naming convention on the backend for `rename_official` to avoid inadvertently dropping/changing variables due to suffix pattern
* fill Q3 `results_cumulative` for semi-annual indicators when using `reshape_msd(direction = "quarter")`

# ICPIutilities 2.2.0
* updates to `read_msd()` to handle two additional reshapes - semi-wide and quarters (for quarterly target achievement)
* clean up bug from converting country in FSD to countryname in `read_msd()`, which was causing the variable to be renamed countrynamename 
* update `identify_pd()` to provide periods in the same format as `reshape_msd()` and decomission the use of targets as a parameter

# ICPIutilities 2.1.8
* require `dplyr v1.0.0` or later to handle some of the code improvements
* update `read_msd()` to handle changes to the variable naming with FSD and align with MSD
* change the `reshape_msd()` `val` column to be called `value` (warning message added)
* change the default parameter in `reshape_msd()` from `clean = TRUE` 
* move from travis.ci to GitHub Actions for CI

# ICPIutilities 2.1.6
* change defaults in `read_msd()` to not save as an rds and not delete original txt file
* fix potential bug with `read_msd()` rds output filename
* allow `read_msd()` to read in rds if its already created
* added backwards comptability to handle old/wide format of MSD prior to FY19Q1

# ICPIutilities 2.1.5
* change default in `reshape_msd()` to be long and added a parameter to have a cleaner period output, `clean = TRUE`

# ICPIutilities 2.1.4
* update `read_msd()` to not try to delete file if providing a URL
* removed award information from `mech_name` in `rename_official()`
* adjust `read_msd()` to handle variant of NAT_SUBNAT MSD structure for importing

# ICPIutilities 2.1.3
* faster imports by using `vroom`
* update `read_msd()` to handle only lower case variable in the MSD/Genie starting in FY19Q4i
* DEPRECATED: `match_msd()` since it is covered by `read_msd()`

# ICPIutilities 2.1.2
* allow `read_msd()` to import the NAT_SUBNAT dataset

# ICPIutilities 2.1.1
* with the FY19Q3i release, adjusted all functions to work with the new columns and adjusted column names

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



