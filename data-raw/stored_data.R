#Snapshot indicator list - MER 2.5
#https://datim.zendesk.com/hc/en-us/articles/360000084446-MER-Indicator-Reference-Guides
snapshot_ind <- c("AGYW_PREV",
                  "AGYW_PREV_D",
                  "OVC_SERV",
                  "PrEP_CURR",
                  "OVC_HIVSTAT",
                  "TX_CURR",
                  "TX_ML",
                  "TX_TB_D", #only TX_TB denom, not num
                  "TX_PVLS",
                  "TX_PVLS_D",
                  "SC_CURR")

usethis::use_data(snapshot_ind, overwrite = TRUE)
