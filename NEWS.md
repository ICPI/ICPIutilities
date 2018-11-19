# ICPIutilities 1.0.25

* Fix bug with `read_msd()` where columns with now values would be converted to string. Important update for `match_msd()` where this may occur.

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



