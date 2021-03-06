USE [DIIG]
GO
/****** Object:  View [Vendor].[VendorFPDShistoryCOCOMCustomerDirectDiscretization]    Script Date: 3/16/2017 12:26:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [Vendor].[VendorFPDShistoryCOCOMCustomerDirectDiscretization]
AS

SELECT C.Fiscal_year
, C.Customer
, C.SubCustomer
, C.PlatformPortfolio
, C.AllContractor 
, C.ParentID
, C.Country3LetterCodeText
, C.StateCode
, C.COCOM
, isnull(PCN.CSISName, C.allcontractor + '^')  as ContractorDisplayName
, rank() over (partition by fiscal_year, c.customer, c.cocom order by SumOfobligatedAmount desc)  as ContractAnnualPlatformSubCustomerVendorRank
, (SELECT VendorIsRanked from Vendor.VendorIsRanked(
			null --@ServiceCategory as varchar(255)
			,null --,@ServicesOnly as bit
			,C.Customer --,@Customer as varchar(255)
			,C.SubCustomer --,@SubCustomer as varchar(255)
			,C.SumOfobligatedAmount--,@SumOfobligatedAmount as decimal(19,4)
			,C.UnknownCompany--,@UnknownCompany as bit
			,C.Top100Federal--,@Top100Federal as bit
			,PCN.CSISName--,@CSISname as nvarchar(255)
			,C.allcontractor--,@AllContractor as varchar(255)
		)) as VendorIsRanked
, C.Small
, C.jointventure
, C.WarningFlag
, C.UnknownCompany
, C.Top100Federal
, C.SumOfobligatedAmount
, C.SumOfnumberOfActions
--Grouping Sub-Query
FROM (
	SELECT C.Fiscal_year
	, isnull(parent.parentid,C.dunsnumber) AS AllContractor 
	, parent.parentid
	, Max(IIf(C.contractingofficerbusinesssizedetermination='S' 
	   And Not (parent.largegreaterthan3B=1 Or parent.Largegreaterthan3B=1)
	   ,1
	   ,0)) AS Small
	, ISNULL(Agency.Customer, Agency.AGENCYIDText) as Customer
	, Agency.SubCustomer
	, PSC.PlatformPortfolio
	, CountryCode.Country3LetterCodeText
	, St.StateCode
	, COALESCE (St.StateCOCOM, CO.Country_COCOM) as COCOM
	, Parent.jointventure
	, iif(parent.parentid is null or
		parent.firstyear>c.fiscal_year or
		parent.mergeryear<=c.fiscal_year,1,0) as WarningFlag
	, Parent.UnknownCompany
	, Parent.Top100Federal
	, Sum(C.obligatedAmount) AS SumOfobligatedAmount
	, Sum(C.numberOfActions) AS SumOfnumberOfActions

		FROM (Contract.FPDS as C
		LEFT OUTER JOIN FPDSTypeTable.StateCOCOM as St 
			ON St.StateCode = C.pop_state_code
		left outer join FPDSTypeTable.AgencyID AS Agency
			ON C.contractingofficeagencyid = Agency.AgencyID 
		LEFT JOIN Contractor.DunsnumberToParentContractorHistory as Dunsnumber
			ON (C.DUNSNumber=Dunsnumber.DUNSNUMBER) 
			AND (C.fiscal_year=Dunsnumber.FiscalYear)) 
		LEFT JOIN Contractor.ParentContractor as Parent
			ON Dunsnumber.ParentID=Parent.ParentID	
		LEFT OUTER JOIN FPDSTypeTable.Country3LetterCode AS CountryCode 
			ON C.placeofperformancecountrycode = CountryCode.Country3LetterCode
		LEFT OUTER JOIN FPDSTypeTable.COCOMLabeling AS CO
			ON CO.Country = CountryCode.Country3LetterCodeText
		LEFT JOIN FPDSTypeTable.ProductOrServiceCode AS PSC 
			ON PSC.ProductOrServiceCode = C.productorservicecode

	GROUP BY C.fiscal_year
	, ISNULL(Agency.Customer, Agency.AGENCYIDText)
	, Agency.SubCustomer
	, PSC.PlatformPortfolio
	, CountryCode.Country3LetterCodeText
	, St.StateCode
	, St.StateCOCOM
	, CO.Country_COCOM
	, Parent.jointventure
	, iif(parent.parentid is null or
		parent.firstyear>c.fiscal_year or
		parent.mergeryear<=c.fiscal_year,1,0) 
	, Parent.UnknownCompany
	, Parent.Top100Federal
	, isnull(parent.parentid,C.dunsnumber) 
	, parent.parentid
) as C
--End Grouping Subquery
		LEFT JOIN Contractor.ParentContractorNameHistory as PCN
			ON C.ParentID = PCN.ParentID
			AND C.Fiscal_Year = PCN.FiscalYear;
	















GO
