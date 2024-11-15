# irs-revoked-exempt-orgs

Scripts and documentation used to build the database of revoked IRS Exempt Organizations.



### ORGANIZATIONS WITH 501(c)(3) STATUS REVOKED

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
# DOWNLOAD AND UNZIP

f <- "https://apps.irs.gov/pub/epostcard/data-download-revocation.zip"
download.file( url=f, "revoked.zip" )
unzip( "revoked.zip" )
file.remove( "revoked.zip" )

fn <- "data-download-revocation.txt"

df <- 
  read.delim( 
    file=fn, 
    header = FALSE, 
    sep = "|", 
    quote = "",
    dec = ".", 
    fill = TRUE,  
    colClasses="character" )

v <-   # VARIABLE NAMES 
  c( "EIN", "Legal.Name", 
     "Doing.Business.As.Name", 
     "Organization.Address", 
     "City", "State", 
     "ZIP.Code", "Country", 
     "Exemption.Type", "Revocation.Date", 
     "Revocation.Posting.Date", 
     "Exemption.Reinstatement.Date" )

names( df ) <- v


# CHANGE TAX.YEAR FROM YYYY-MM TO YYYY

x <- df$Revocation.Date
year <- substr( x, 8, 11 )
df$Year <- year

k <- "Revocation Count by Year"
year |> table() |> 
  format( big.mark="," ) |> 
  knitr::kable( caption=k )

# Table: Revocation Count by Year

|2010 |377,416 |
|2011 |92,923  |
|2012 |47,775  |
|2013 |52,381  |
|2014 |37,531  |
|2015 |35,898  |
|2016 |44,214  |
|2017 |86,046  |
|2018 |63,704  |
|2019 |41,476  |
|2020 |39,584  |
|2021 |48,204  |
|2022 |55,328  |
|2023 |62,075  |
|2024 |54,113  |




#  NOTE THE TYPES OF EXEMPT ORGS 
#  (501C3, 501C4, ETC.) ARE BEING REVOKED:

k <- "Revocations by 501c Type"
x <- df$Exemption.Type 
x |> table() |> 
  format( big.mark="," ) |> 
  knitr::kable( align="r", caption=k )

# Table: Revocations by 501c Type

|02 |   3,646|
|03 | 736,690|
|04 | 166,037|
|05 |  24,441|
|06 |  45,631|
|07 |  50,354|
|08 |  26,514|
|09 |   5,277|
|1  |      43|
|10 |   6,969|
|11 |       9|
|12 |   2,500|
|13 |   6,296|
|14 |     930|
|15 |     891|
|16 |      14|
|17 |     316|
|18 |       8|
|19 |  24,026|
|20 |      24|
|21 |      31|
|22 |       2|
|23 |       2|
|24 |       2|
|25 |     334|
|26 |       5|
|27 |       3|
|29 |      10|
|40 |       5|
|50 |      24|
|7  |       1|
|70 |      14|
|90 |       1|


# THE DATABASE INCLUDES REINSTATEMENTS

x <- df$Exemption.Reinstatement.Date
t <- x |> substr( 8, 11 ) |> table() 
t |> format( big.mark="," ) |> 
     knitr::kable( caption="Reinstatements by Year" )

|2010 |28,764  |
|2011 |11,915  |
|2012 |15,140  |
|2013 |11,723  |
|2014 |10,969  |
|2015 |12,505  |
|2016 |12,365  |
|2017 |12,741  |
|2018 |11,018  |
|2019 |7,085   |
|2020 |4,763   |
|2021 |5,526   |
|2022 |7,543   |
|2023 |7,880   |
|2024 |2,616   |


#  NEW AUTOMATIC REVOCATION POLICY TOOK 
#  EFFECT IN 2010 - NOTE THE PURGE

t <- table( df$Year )
title <- "IRS Automatic Revocation of Tax Exempt Status by Year"

barplot( t, 
  col="gray", border="white", 
  cex.main=1.5, main=title )

abline( 
  h=seq(50000,350000,50000), 
  col="white" )
```

![image](https://github.com/user-attachments/assets/73298069-ef21-4cb6-8e8a-446a38a3d1fe)



### EXPORT THE DATASET

The the package 'foreign' is not installed first try:  `install.packages("foreign")`

```R
# AS R DATA SET
fn <- "RevokedOrganizations.rds"
saveRDS( df, file=fn )

# AS CSV
fn <- "RevokedOrganizations.csv"
write.csv( df, fn, row.names=F )

# IN STATA
install.packages( "haven" )
library( haven )
fn <- "RevokedOrganizations.dta"
write_dta( df, fn )

# IN SPSS  - creates a text file and a script for reading it into SPSS
library( foreign )
df <- "RevokedOrganizations.txt"
cf <- "CodeToLoadDataInSPSS.txt"
write.foreign( df, datafile=df, codefile=df, package="SPSS" )
```


