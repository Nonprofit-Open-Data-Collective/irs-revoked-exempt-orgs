## DOWNLOAD REVOCATIONS DATA
##
## https://www.irs.gov/charities-non-profits/tax-exempt-organization-search-bulk-data-downloads

## DATA DICTIONARY
# 
# Field	                        | Notes
# ------------------------------|--------------------------------
# EIN	        		| Required; Employer Identification Number
# Legal Name			| Optional
# Doing Business As Name 	| Optional
# Organization Address	 	| Optional
# City				| Optional
# State 			| Optional
# ZIP Code  			| Optional
# Country	  		| Required; Format: 2 Letter Country Code
# Exemption Type		| Optional; 501(c) status, FE (c)(3), (c)(4)
# Revocation Date  		| Required; Format: DD-MON-YYYY
# Revocation Posting Date	| Required; Format: DD-MON-YYYY
# Exemption Reinstatement Date  | Optional; Format: DD-MON-YYYY







file.url <- "https://apps.irs.gov/pub/epostcard/data-download-revocation.zip"


# TRY URL CONNECTION UP TO 10 TIMES 

try.10 <- 1
while( ! file.exists( "revoked.zip" ) )
{
  try( download.file( url=file.url, "revoked.zip" ) )
  try.10 <- try.10 + 1
  if( try.10 > 10 ){ break }
}



unzip( "revoked.zip" )

file.remove( "revoked.zip" )

d <- 
  read.delim( file="data-download-revocation.txt", 
              header = FALSE, 
              sep = "|", 
              quote = "",
              dec = ".", 
              fill = TRUE,  
              colClasses="character" )



# ADD VARIABLE NAMES

var.names <- c( "ein", "legal_name", "doing_business_as_name", 
                "organization_address", "city", "state", "zip_code", 
                "country", "exemption_type", "revocation_date", 
                "revocation_posting_date", "exemption_reinstatement_date")

names( d ) <- var.names

rm( var.names )




# CHANGE Tax.Year from YYYY-MM to YYYY
# ADD A UNIQUE ID:  ID-EIN-YYYY-MM-DD

d$RYEAR <- substr( d$revocation_date, 8, 11 )
d$RDATE <- as.Date( d$revocation_date, format="%d-%b-%Y" )
d$ID <- paste0( "ID-", d$ein, "-", d$RDATE )




#####
##### SAVE RECORDS
#####

# DATE FOR FILENAMES

yyyy.mm   <- format( Sys.Date(), "%Y-%m" )

filename <-  paste0( yyyy.mm, "-REVOCATIONS-ORGS.csv" )
write.csv( d, filename, row.names=F )



# CREATE A LOGFILE

logname <- paste0( yyyy.mm, "-REVOCATIONS-LOG.txt" )
zz <- file( logname, open = "wt" )
sink( zz, split=T )
sink( zz, type = "message", append=TRUE )
  
print( paste0( "There are ", nrow(d), " records in this file." ) )
print( paste0( "There are ", ncol(d), " columns in the dataset." ) )
print( paste0( "First six records:" ) )
print( head(d[,c(1,2,10,11)]) %>% knitr::kable() )

sink( type="message" )
sink()      # close sink
close(zz)   # close connection

# file.show( "2023-05-REVOCATIONS-LOG.txt" )


# CREATE A RECORD COUNT TABLE

t <- table( d$RDATE ) %>% as.data.frame()
names(t) <- c("DATE","COUNT")
tablename <- paste0( yyyy.mm, "-REVOCATIONS-TABLE.csv" )
write.csv( t, tablename, row.names=F )






####
####   PORT TO NCCS S3
####


# create "revocations/" directory

# port logfile, counts table, and data frame


