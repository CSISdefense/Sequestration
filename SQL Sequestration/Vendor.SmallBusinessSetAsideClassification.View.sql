USE [DIIG]
GO
/****** Object:  View [Vendor].[SmallBusinessSetAsideClassification]    Script Date: 3/16/2017 12:26:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














CREATE VIEW [Vendor].[SmallBusinessSetAsideClassification] 
AS
SELECT 
F.fiscal_year
,Max(getDate()) AS Query_Run
,A.Customer
,A.SubCustomer
,PSC.ServicesCategory
,F.typeofsetaside
,f.firm8aflag AS Firm8A
,f.hubzoneflag AS HUBZone
,f.minorityownedbusinessflag AS MinorityOwned
, CASE
	WHEN f.saaobflag = 'Y'
	THEN 'South Asian American Owned'
	WHEN f.apaobflag ='Y'
	THEN 'Asian-Pacific American Owned'
	WHEN f.baobflag = 'Y'
	THEN 'Black American Owned'
	WHEN f.haobflag = 'Y'
	THEN 'Hispanic American Owned'
	WHEN isotherminorityowned =1
	THEN 'Other Minority Owned'
	ELSE 'No Set Aside'
  END AS MinoritySetAside
, CASE
	WHEN f.sdbflag = 'Y' OR f.issbacertifiedsmalldisadvantagedbusiness = 1
	THEN 'Small Disadvantaged Business'
	ELSE 'No Set Aside'
  END AS SmallDisadvantagedBusiness
, CASE
	WHEN isalaskannativeownedcorporationorfirm = 1
	THEN 'Alaskan Native Owned'
	WHEN F.isnativehawaiianownedorganizationorfirm = 1 
	THEN 'Native Hawaiian Owned'
	WHEN f.istriballyownedfirm = 1 OR f.isindiantribe =1 OR f.naobflag ='Y'
	THEN 'Native American Owned'
	ELSE 'No Set Aside'
  END AS NativeGroupOwned
, CASE
	WHEN f.womenownedflag ='Y' OR f.iswomenownedsmallbusiness =1 OR f.isecondisadvwomenownedsmallbusiness =1
	THEN 'Woman Owned'
	ELSE 'No Set Aside'
  END AS WomanOwned
, CASE
	WHEN f.srdvobflag ='Y' 
	THEN 'Service-Disabled Veteran Owned'
	WHEN f.veteranownedflag = 'Y'
	THEN 'Veteran Owned'
	ELSE 'No Set Aside'
  END AS VeteranOwned
,sum(f.obligatedamount) AS SubOfObligatedAmount

FROM Contract.FPDS AS F
LEFT JOIN FPDSTypeTable.AgencyID AS A
On A.AgencyID = F.contractingofficeagencyid
LEFT JOIN FPDSTypeTable.ProductOrServiceCode AS PSC
on PSC.ProductOrServiceCode = F.productorservicecode

GROUP BY
F.fiscal_year
,A.Customer
,A.SubCustomer
,PSC.ServicesCategory
,F.typeofsetaside
,f.firm8aflag 
,f.hubzoneflag 
,f.minorityownedbusinessflag 
, CASE
	WHEN f.saaobflag = 'Y'
	THEN 'South Asian American Owned'
	WHEN f.apaobflag ='Y'
	THEN 'Asian-Pacific American Owned'
	WHEN f.baobflag = 'Y'
	THEN 'Black American Owned'
	WHEN f.haobflag = 'Y'
	THEN 'Hispanic American Owned'
	WHEN isotherminorityowned =1
	THEN 'Other Minority Owned'
	ELSE 'No Set Aside'
  END 
, CASE
	WHEN f.sdbflag = 'Y' OR f.issbacertifiedsmalldisadvantagedbusiness = 1
	THEN 'Small Disadvantaged Business'
	ELSE 'No Set Aside'
  END 
, CASE
	WHEN isalaskannativeownedcorporationorfirm = 1
	THEN 'Alaskan Native Owned'
	WHEN F.isnativehawaiianownedorganizationorfirm = 1 
	THEN 'Native Hawaiian Owned'
	WHEN f.istriballyownedfirm = 1 OR f.isindiantribe =1 OR f.naobflag ='Y'
	THEN 'Native American Owned'
	ELSE 'No Set Aside'
  END 
, CASE
	WHEN f.womenownedflag ='Y' OR f.iswomenownedsmallbusiness =1 OR f.isecondisadvwomenownedsmallbusiness =1
	THEN 'Woman Owned'
	ELSE 'No Set Aside'
  END 
, CASE
	WHEN f.srdvobflag ='Y' 
	THEN 'Service-Disabled Veteran Owned'
	WHEN f.veteranownedflag = 'Y'
	THEN 'Veteran Owned'
	ELSE 'No Set Aside'
  END 




GO
