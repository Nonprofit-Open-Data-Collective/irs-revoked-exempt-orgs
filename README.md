# irs-revoked-exempt-orgs

Scripts and documentation used to build the database of revoked IRS Exempt Organizations.



# ORGANIZATIONS WITH 501(c)(3) STATUS REVOKED

From: https://www.irs.gov/charities-non-profits/tax-exempt-organization-search-bulk-data-downloads

Internal Revenue Service United States Department of the Treasury

>Using the link below, you may download as a zipped text file the most recent listing of all organizations whose federal tax exemption was automatically revoked for not filing a Form 990-series annual return or notice for three consecutive tax years. The download file is a large compressed file, from which you may extract a very large delimited text file. This file is updated on a monthly basis. Opening the file using word processing software may prevent formatting/appearance issues that may be present if the file is viewed with a text editing program. Information is available describing the layout and contents of the downloadable file.
>
>Format: Pipe-Delimited ASCII Text
>
>The Automatic Revocation information will be listed in rows, with each field of data separated by a pipe ('|') symbol. The following table describes the format and order of each field in a row, representing one Automatic Revocation listing.



## DATA DICTIONARY

Field	  | Notes
--------|------------------------------------------------------
EIN	        | Required; Employer Identification Number
Legal Name	| Optional
Doing Business As Name | 	Optional
Organization Address	 | Optional
City	| Optional
State | 	Optional
ZIP Code  |	Optional
Country	  | Required; Format: 2 Letter Country Code
Exemption Type	| Optional; 501(c) status, FE (c)(3), (c)(4)
Revocation Date  |	Required; Format: DD-MON-YYYY
Revocation Posting Date	  | Required; Format: DD-MON-YYYY
Exemption Reinstatement Date  |  	Optional; Format: DD-MON-YYYY





## BUILD THE DATASET


```R 


# create subdirectory for the data

getwd()

dir.create( "revocations" )

setwd( "./revocations" )



# download and unzip

file.url <- "https://apps.irs.gov/pub/epostcard/data-download-revocation.zip"

download.file( url=file.url, "revoked.zip" )

unzip( "revoked.zip" )

file.remove( "revoked.zip" )

dat.revoked <- read.delim( file="data-download-revocation.txt", 
            header = FALSE, 
            sep = "|", 
            quote = "",
            dec = ".", 
            fill = TRUE,  
            colClasses="character"
          )



# add header information - variable names

var.names <- c("EIN", "Legal.Name", "Doing.Business.As.Name", "Organization.Address", 
"City", "State", "ZIP.Code", "Country", "Exemption.Type", "Revocation.Date", 
"Revocation.Posting.Date", "Exemption.Reinstatement.Date")


names( dat.revoked ) <- var.names

rm( var.names )


# change Tax.Year from YYYY-MM to YYYY

dat.revoked$Year <- substr( dat.revoked$Revocation.Date, 8, 11 )


# Note the types of exempt orgs (501c3, 501c4, etc.) are being revoked:

table( dat.revoked$Exemption.Type )


# The database includes reinstatements

table( substr( dat.revoked$Exemption.Reinstatement.Date, 8, 11) )


# New automatic revocation policy took effect in 2010 - note the purge

barplot( table( dat.revoked$Year ), col="gray", border="white", 
         main="IRS Automatic Revocation of Tax Exempt Status by Year", 
         cex.main=1.5 )
abline( h=seq(50000,350000,50000), col="white" )

```

![](revocations_by_year.png)


## EXPORT THE DATASET

```R

# AS R DATA SET

saveRDS( dat.revoked, file="RevokedOrganizations.rds" )


# AS CSV

write.csv( dat.revoked, "RevokedOrganizations.csv", row.names=F )


# IN STATA

install.packages( "haven" )
library( haven )
write_dta( dat.revoked, "RevokedOrganizations.dta" )


# IN SPSS  - creates a text file and a script for reading it into SPSS

library( foreign )
write.foreign( df=dat.revoked, datafile="RevokedOrganizations.txt", codefile="CodeToLoadDataInSPSS.txt", package="SPSS" )

# if package 'foreign' is not installed first try:  install.packages("foreign")

```
