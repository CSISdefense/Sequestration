USE [DIIG]
GO
/****** Object:  View [Vendor].[ParentIDStandardizedVendorNameHistoryPartial]    Script Date: 3/16/2017 12:26:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



Create VIEW [Vendor].[ParentIDStandardizedVendorNameHistoryPartial]
AS

Select 
	dtpch.parentid
	,dtpch.standardizedtopcontractor
	,dtpch.FiscalYear
	,sum(dtpch.obligatedamount) as SumOfobligatedamount
	,sum(dtpch.fed_funding_amount) as SumOffed_funding_amount
	,sum(dtpch.TotalAmount) as TotalAmount
	FROM contractor.DunsnumberToParentContractorHistory as dtpch
	GROUP BY 
	dtpch.parentid
	,dtpch.standardizedtopcontractor
	,dtpch.FiscalYear
	


GO
