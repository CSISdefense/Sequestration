USE [DIIG]
GO
/****** Object:  View [Vendor].[VendorSizeFPDShistoryBucketCustomerCountry]    Script Date: 3/16/2017 12:26:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


















CREATE VIEW [Vendor].[VendorSizeFPDShistoryBucketCustomerCountry] 
AS
SELECT 
	C.fiscal_year
	,CD.MinOfFiscal_Year 
	,getDate() AS Query_Run
	,isnull(A.Customer,A.AgencyIDtext) AS Customer,
	CountryCode.Country3LetterCodeText,
	CountryCode.Region
	,isnull(P.ServicesCategory, 'Unlabeled') AS ServicesCategory
	,isnull(P.ProductsCategory, 'Unlabeled') AS ProductsCategory
	,isnull(P.ProductOrServiceArea, 'Unlabeled') AS ProductOrServiceArea
	,isnull(P.RnD_BudgetActivity, 'Unlabeled') AS RnD_BudgetActivity
	,isnull(P.ProductServiceOrRnDarea, 'Unlabeled') AS ProductServiceOrRnDarea
	,PSC.IsService
	,P.ProductOrServiceCode
	,P.ProductOrServiceCodeText
		,atl.USDATL
	,atl.BBP1
	,atl.WSARAreg
	,atl.BBP2
	,atl.BBP3

	,P.DoDportfolio
	, CASE
		WHEN Parent.Top6=1 and Parent.JointVenture=1 and C.contractingofficerbusinesssizedetermination in ('s','y')
		THEN 'Large: Big 5 JV (Small Subsidiary)'
		WHEN Parent.Top6=1 and Parent.JointVenture=1
		THEN 'Large: Big 5 JV'
		WHEN Parent.Top6=1 and C.contractingofficerbusinesssizedetermination in ('s','y')
		THEN 'Large: Big 5 (Small Subsidiary)'
		WHEN Parent.Top6=1
		THEN 'Large: Big 5'
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
		WHEN C.contractingofficerbusinesssizedetermination='s' or C.contractingofficerbusinesssizedetermination='y'
		THEN 'Small'
		when Parent.UnknownCompany=1
		Then 'Unlabeled'
		ELSE 'Medium <1B'
	END AS VendorSize
	, CASE
	WHEN Parent.ParentID is not null and isnull(Parent.UnknownCompany,0)=0 
	THEN Parent.ParentID 
	WHEN c.parentdunsnumber is not null and isnull(ParentSquared.UnknownCompany,0)=0 
	THEN c.parentdunsnumber
	WHEN c.dunsnumber is not null and isnull(Parent.UnknownCompany,0)=0 
	THEN c.dunsnumber
	WHEN isnull(svnh.isunknownvendorname,1)=0
	THEN svnh.standardizedvendorname
	ELSE c.dunsnumber
	END as RoughUniqueEntity 
	, CASE
	WHEN Parent.Top6=1 and Parent.JointVenture=1 
		THEN 'Large: Big 6 JV'
	WHEN Parent.Top6=1
		THEN 'Large: Big 6'
	WHEN Parent.LargeGreaterThan3B=1 
		THEN 'Large'
	WHEN Parent.LargeGreaterThan1B=1 
		THEN 'Medium >1B'
	WHEN C.contractingofficerbusinesssizedetermination='s' or C.contractingofficerbusinesssizedetermination='y'
	THEN 'Small'
	when coalesce(parent.UnknownCompany,svnh.isunknownvendorname)=1
	Then 'Unlabeled'
	ELSE 'Medium <1B'
END AS RoughUniqueEntitySize

, (SELECT ClassifyMaxcontractSize from contractor.ClassifyMaxcontractSize(
		parent.LargeGreaterThan3B
		,coalesce(PCH.MaxOfCSIScontractIDObligatedAmount
			,ParentDUNS.MaxOfCSIScontractIDObligatedAmount
			,svnh.MaxOfCSIScontractIDObligatedAmount
		)
		)) as ClassifyMaxcontractSize
	,C.obligatedamount as SumofObligatedAmount
	,C.numberofactions as SumofNumberofActions
	--,sum(C.obligatedamount) as SumofObligatedAmount
	--,sum(C.numberofactions) as SumofNumberofActions
	,IIf(Left(P.productorservicecode,1)='Q'
   Or Left(P.productorservicecode,1)='Y',
   'Other Service','Professional Service')
    AS Legacy
   ,A.SubCustomer
   ,p.Simple
   ,NAICS.principalnaicscode
   ,NAICS.principalnaicscodeText
   ,isnull(cpc.PlatformPortfolio,p.PlatformPortfolio) as PlatformPortfolio
   ,C.piid
   ,C.idvpiid
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
	left join vendor.vendorname vname
	on c.vendorname=vname.vendorname
	left join vendor.standardizedvendornamehistory svnh
	on vname.standardizedvendorname=svnh.standardizedvendorname
	and c.fiscal_year=svnh.fiscal_year
		left outer join
			FPDSTypeTable.ClaimantProgramCode  as cpc
				on cpc.ClaimantProgramCode=c.claimantprogramcode
	LEFT OUTER JOIN Contract.CSIStransactionID AS CSIS
	On CSIS.CSIStransactionID = C.CSIStransactionID
	LEFT OUTER JOIN Contract.ContractDiscretization AS CD
	ON CD.CSIScontractID = CSIS.CSIScontractID
left join contract.CSIStransactionID ctid
	on c.CSIStransactionID=ctid.CSIStransactionID
left join Agency.ContractATLregime atl
	on ctid.CSIScontractID=atl.CSIScontractID
LEFT JOIN FPDSTypeTable.PrincipalNaicsCode AS NAICS
	on NAICS.principalnaicscode = C.principalnaicscode


--GROUP BY
--C.fiscal_year
--	,isnull(A.Customer,A.AgencyIDtext) 
--	,CountryCode.Country3LetterCodeText
--	,CountryCode.Region
--	,isnull(P.ServicesCategory, 'Unlabeled') 
--	,PSC.IsService
--	,P.DoDportfolio
--	,P.PlatformPortfolio
--		, CASE
--		WHEN Parent.Top6=1 and Parent.JointVenture=1 and C.contractingofficerbusinesssizedetermination in ('s','y')
--		THEN 'Large: Big 6 JV (Small Subsidiary)'
--		WHEN Parent.Top6=1 and Parent.JointVenture=1
--		THEN 'Large: Big 6 JV'
--		WHEN Parent.Top6=1 and C.contractingofficerbusinesssizedetermination in ('s','y')
--		THEN 'Large: Big 6 (Small Subsidiary)'
--		WHEN Parent.Top6=1
--		THEN 'Large: Big 6'
--		WHEN Parent.LargeGreaterThan3B=1 and C.contractingofficerbusinesssizedetermination in ('s','y')
--		THEN 'Large (Small Subsidiary)'
--		WHEN Parent.LargeGreaterThan3B=1
--		THEN 'Large'
--		WHEN Parent.LargeGreaterThan1B=1  and C.contractingofficerbusinesssizedetermination in ('s','y')
--		THEN 'Medium >1B (Small Subsidiary)'
--		WHEN Parent.LargeGreaterThan1B=1
--		THEN 'Medium >1B'
--		WHEN C.contractingofficerbusinesssizedetermination in ('s','y')
--		THEN 'Small'
--		when Parent.UnknownCompany=1
--		Then 'Unlabeled'
--		ELSE 'Medium <1B'
--	END 
--	--, CASE
--	--	WHEN Parent.Top6=1 and Parent.JointVenture=1
--	--	THEN 'Large: Big 6 JV'
--	--	WHEN Parent.Top6=1
--	--	THEN 'Large: Big 6'
--	--	WHEN Parent.LargeGreaterThan3B=1
--	--	THEN 'Large'
--	--	WHEN Parent.LargeGreaterThan1B=1
--	--	THEN 'Medium >1B'
--	--	WHEN C.contractingofficerbusinesssizedetermination='s' or C.contractingofficerbusinesssizedetermination='y'
--	--	THEN 'Small'
--	--	when Parent.UnknownCompany=1
--	--	Then 'Unlabeled'
--	--	ELSE 'Medium <1B'
--	--END 
--	,IIf(Left(P.productorservicecode,1)='Q'
--   Or Left(P.productorservicecode,1)='Y',
--   'Other Service','Professional Service')
--   ,A.SubCustomer






























GO
