USE [DIIG]
GO
/****** Object:  View [Vendor].[VendorFPDShistoryPlatformCustomerDirectDiscretization]    Script Date: 3/16/2017 12:26:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [Vendor].[VendorFPDShistoryPlatformCustomerDirectDiscretization]
AS

SELECT C.Fiscal_year
, C.Customer
, C.PlatformPortfolio
, C.AllContractor 
, C.ParentID
, isnull(PCN.CSISName, C.allcontractor + '^')  as ContractorDisplayName
, rank() over (partition by fiscal_year, c.customer, c.PlatformPortfolio  order by SumOfobligatedAmount desc)  as ContractAnnualPlatformCustomerVendorRank
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
	, isnull(cpc.PlatformPortfolio, PSC.PlatformPortfolio) as PlatformPortfolio
	, Parent.jointventure
	, iif(parent.parentid is null or
		parent.firstyear>c.fiscal_year or
		parent.mergeryear<=c.fiscal_year,1,0) as WarningFlag
	, Parent.UnknownCompany
	, Parent.Top100Federal
	, Sum(C.obligatedAmount) AS SumOfobligatedAmount
	, Sum(C.numberOfActions) AS SumOfnumberOfActions

		FROM (Contract.FPDS as C
			left outer join FPDSTypeTable.AgencyID AS Agency
			ON C.contractingofficeagencyid = Agency.AgencyID 
		LEFT JOIN Contractor.DunsnumberToParentContractorHistory as Dunsnumber
			ON (C.DUNSNumber=Dunsnumber.DUNSNUMBER) 
			AND (C.fiscal_year=Dunsnumber.FiscalYear)) 
		LEFT JOIN Contractor.ParentContractor as Parent
			ON Dunsnumber.ParentID=Parent.ParentID	
		LEFT JOIN FPDSTypeTable.ProductOrServiceCode AS PSC 
			ON PSC.ProductOrServiceCode = C.productorservicecode
		left outer join FPDSTypeTable.ClaimantProgramCode cpc
			on c.claimantprogramcode=cpc.claimantprogramcode

	GROUP BY C.fiscal_year
	, ISNULL(Agency.Customer, Agency.AGENCYIDText)
	, Agency.SubCustomer
	, isnull(cpc.PlatformPortfolio, PSC.PlatformPortfolio) 
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
