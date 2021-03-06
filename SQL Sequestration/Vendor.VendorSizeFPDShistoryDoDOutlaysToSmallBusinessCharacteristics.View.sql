USE [DIIG]
GO
/****** Object:  View [Vendor].[VendorSizeFPDShistoryDoDOutlaysToSmallBusinessCharacteristics]    Script Date: 3/16/2017 12:26:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [Vendor].[VendorSizeFPDShistoryDoDOutlaysToSmallBusinessCharacteristics] 
AS
SELECT 
	C.fiscal_year
	,sum(C.obligatedamount) as Tot_Obl
	,firm8aflag
	,hubzoneflag
	,sdbflag
	,womenownedflag
	,isecondisadvwomenownedsmallbusiness
	,veteranownedflag
	,srdvobflag
	,avg(numberofemployees) as Av_Emp
	,maj_agency_cat
	, CASE
		WHEN Parent.Top6=1 and Parent.JointVenture=1 and C.contractingofficerbusinesssizedetermination in ('s','y')
		THEN 'Large: Big 6 JV (Small Subsidiary)'
		WHEN Parent.Top6=1 and Parent.JointVenture=1
		THEN 'Large: Big 6 JV'
		WHEN Parent.Top6=1 and C.contractingofficerbusinesssizedetermination in ('s','y')
		THEN 'Large: Big 6 (Small Subsidiary)'
		WHEN Parent.Top6=1
		THEN 'Large: Big 6'
		WHEN Parent.IsPreTop6=1
		THEN 'Large: Pre-Big 6'
		WHEN Parent.LargeGreaterThan3B=1 and C.contractingofficerbusinesssizedetermination in ('s','y')
		THEN 'Large (Small Subsidiary)'
		WHEN Parent.LargeGreaterThan3B=1
		THEN 'Large'
		WHEN Parent.LargeGreaterThan1B=1  and C.contractingofficerbusinesssizedetermination in ('s','y')
		THEN 'Medium >1B (Small Subsidiary)'
		WHEN Parent.LargeGreaterThan1B=1
		THEN 'Medium >1B'
		WHEN C.contractingofficerbusinesssizedetermination in ('s','y')
		THEN 'Small'
		when Parent.UnknownCompany=1
		Then 'Unlabeled'
		ELSE 'Medium <1B'
	END AS VendorSize

FROM Contract.FPDS AS C
	LEFT JOIN Contractor.DunsnumberToParentContractorHistory AS PCH
		ON (C.Dunsnumber=PCH.Dunsnumber)
		AND (C.fiscal_year=PCH.FiscalYear)
	LEFT JOIN FPDSTypeTable.AgencyID AS A
		ON (C.contractingofficeagencyid=A.AgencyID)
	LEFT JOIN FPDSTypeTable.ProductOrServiceCode AS P
		ON (C.productorservicecode=P.ProductOrServiceCode)
	LEFT JOIN Contractor.ParentContractor As Parent
		ON (PCH.ParentID=Parent.ParentID)
	LEFT OUTER JOIN Contractor.DunsnumbertoParentContractorHistory as ParentDUNS
		ON C.fiscal_year = ParentDUNS.FiscalYear AND C.parentdunsnumber = ParentDUNS.DUNSnumber
	LEFT OUTER JOIN Contractor.ParentContractor as PARENTsquared
		ON ParentDUNS.ParentID = PARENTsquared.ParentID
	LEFT JOIN FPDSTypeTable.Country3lettercode as CountryCode
		ON (C.placeofperformancecountrycode=CountryCode.Country3LetterCode)
	LEFT JOIN ProductOrServiceCode.ServicesCategory As PSC
		ON (PSC.ServicesCategory = P.ServicesCategory)
	left join Vendor.VendorName as vname
	on c.vendorname=vname.vendorname
	left join vendor.standardizedvendornamehistory svnh
	on vname.standardizedvendorname=svnh.standardizedvendorname
	and c.fiscal_year=svnh.fiscal_year
		left outer join
			FPDSTypeTable.ClaimantProgramCode  as cpc
				on cpc.ClaimantProgramCode=c.claimantprogramcode

WHERE maj_agency_cat = '9700'

GROUP BY 	C.fiscal_year
	,firm8aflag
	,hubzoneflag
	,sdbflag
	,womenownedflag
	,isecondisadvwomenownedsmallbusiness
	,veteranownedflag
	,srdvobflag
	,maj_agency_cat
	, CASE
		WHEN Parent.Top6=1 and Parent.JointVenture=1 and C.contractingofficerbusinesssizedetermination in ('s','y')
		THEN 'Large: Big 6 JV (Small Subsidiary)'
		WHEN Parent.Top6=1 and Parent.JointVenture=1
		THEN 'Large: Big 6 JV'
		WHEN Parent.Top6=1 and C.contractingofficerbusinesssizedetermination in ('s','y')
		THEN 'Large: Big 6 (Small Subsidiary)'
		WHEN Parent.Top6=1
		THEN 'Large: Big 6'
		WHEN Parent.IsPreTop6=1
		THEN 'Large: Pre-Big 6'
		WHEN Parent.LargeGreaterThan3B=1 and C.contractingofficerbusinesssizedetermination in ('s','y')
		THEN 'Large (Small Subsidiary)'
		WHEN Parent.LargeGreaterThan3B=1
		THEN 'Large'
		WHEN Parent.LargeGreaterThan1B=1  and C.contractingofficerbusinesssizedetermination in ('s','y')
		THEN 'Medium >1B (Small Subsidiary)'
		WHEN Parent.LargeGreaterThan1B=1
		THEN 'Medium >1B'
		WHEN C.contractingofficerbusinesssizedetermination in ('s','y')
		THEN 'Small'
		when Parent.UnknownCompany=1
		Then 'Unlabeled'
		ELSE 'Medium <1B'
	END





GO
