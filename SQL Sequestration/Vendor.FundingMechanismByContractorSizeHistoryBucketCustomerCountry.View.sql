USE [DIIG]
GO
/****** Object:  View [Vendor].[FundingMechanismByContractorSizeHistoryBucketCustomerCountry]    Script Date: 3/16/2017 12:26:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [Vendor].[FundingMechanismByContractorSizeHistoryBucketCustomerCountry] 
AS
SELECT 
	C.fiscal_year
	,Max(getDate()) AS Query_Run
	,isnull(A.Customer,A.AgencyIDtext) AS Customer
	,CountryCode.Country3LetterCodeText
	,CountryCode.Region
	,P.ServicesCategory AS ServicesCategory
	,PSC.IsService
	,P.DoDportfolio
	,F.TypeofContractPricingText
	,CASE
		WHEN PC.Top6=1 and PC.JointVenture=1
		THEN 'Large: Big 6 JV'
		WHEN PC.Top6=1
		THEN 'Large: Big 6'
		WHEN PC.LargeGreaterThan3B=1
		THEN 'Large'
		WHEN PC.LargeGreaterThan1B=1
		THEN 'Medium >1B'
		WHEN C.contractingofficerbusinesssizedetermination='s' or C.contractingofficerbusinesssizedetermination='y'
		THEN 'Small'
		ELSE 'Medium <1B'
	END AS [Size]
	,sum(C.obligatedamount) as SumofObligatedAmount
	,sum(C.numberofactions) as SumofNumberofActions
	,IIf(Left(P.productorservicecode,1)='Q'
   Or Left(P.productorservicecode,1)='Y',
   'Other Service','Professional Service')
    AS Legacy
   ,A.SubCustomer
FROM Contract.FPDS AS C
	LEFT JOIN Contractor.DunsnumberToParentContractorHistory AS PCH
		ON (C.Dunsnumber=PCH.Dunsnumber)
		AND (C.fiscal_year=PCH.FiscalYear)
	LEFT JOIN FPDSTypeTable.AgencyID AS A
		ON (C.contractingofficeagencyid=A.AgencyID)
	LEFT JOIN FPDSTypeTable.ProductOrServiceCode AS P
		ON (C.productorservicecode=P.ProductOrServiceCode)
	LEFT JOIN Contractor.ParentContractor As PC
		ON (PCH.ParentID=PC.ParentID)
	LEFT JOIN FPDSTypeTable.Country3lettercode as CountryCode
		ON (C.placeofperformancecountrycode=CountryCode.Country3LetterCode)
	LEFT JOIN ProductOrServiceCode.ServicesCategory As PSC
		ON (PSC.ServicesCategory = P.ServicesCategory)
	LEFT OUTER JOIN FPDSTypeTable.typeofcontractpricing AS F 
		ON C.TypeofContractPricing = F.TypeOfContractPricing
GROUP BY
C.fiscal_year
	,isnull(A.Customer,A.AgencyIDtext) 
	,CountryCode.Country3LetterCodeText
	,CountryCode.Region
	,isnull(P.ServicesCategory, 'Unlabeled') 
	,PSC.IsService
	,P.ServicesCategory
	,P.DoDportfolio
	,F.TypeofContractPricingText
	,CASE
		WHEN PC.Top6=1 and PC.JointVenture=1
		THEN 'Large: Big 6 JV'
		WHEN PC.Top6=1
		THEN 'Large: Big 6'
		WHEN PC.LargeGreaterThan3B=1
		THEN 'Large'
		WHEN PC.LargeGreaterThan1B=1
		THEN 'Medium >1B'
		WHEN C.contractingofficerbusinesssizedetermination='s' or C.contractingofficerbusinesssizedetermination='y'
		THEN 'Small'
		ELSE 'Medium <1B'
	END 
	,IIf(Left(P.productorservicecode,1)='Q'
   Or Left(P.productorservicecode,1)='Y',
   'Other Service','Professional Service')
   ,A.SubCustomer







GO
