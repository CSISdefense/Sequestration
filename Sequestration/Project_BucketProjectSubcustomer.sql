USE [DIIG]
GO

/****** Object:  View [Project].[ProjectIDplatformPortfolioPartial]    Script Date: 6/23/2017 5:22:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO










ALTER  VIEW [Project].PlatformPortfolioBreakdown
AS

SELECT 
	f.ProjectID
	,pid.PlatformPortfolio as ProjectIDplatformPortfolio
	,f.ProductOrServiceCode
	,psc.ProductOrServiceCodeText
	,psc.PlatformPortfolio as PSCplatformPortfolio
	,f.ClaimantProgramCode
	, cpc.PlatformPortfolio as CPCplatformPortfolio
	--,f.AgencyID
	,a.PlatformPortfolio as AgencyPlatformPortfolio
	, Sum(f.obligatedamount) AS SumOfobligatedamount
FROM [Project].[BucketProjectSubCustomer]  as f
left outer join project.projectid pid
on f.ProjectID=pid.ProjectID
left outer join FPDSTypeTable.ProductOrServiceCode psc
on psc.ProductOrServiceCode=psc.ProductOrServiceCode
left outer join FPDSTypeTable.ClaimantProgramCode cpc
on f.ClaimantProgramCode=cpc.ClaimantProgramCode
left outer join FPDSTypeTable.AgencyID a
on a.AgencyID=f.agencyID
GROUP BY 
	f.ProjectID
	,pid.PlatformPortfolio 
	,f.ProductOrServiceCode
	,psc.PlatformPortfolio 
	,f.ClaimantProgramCode
	, cpc.PlatformPortfolio
	,psc.ProductOrServiceCodeText
		--,f.AgencyID
	,a.PlatformPortfolio





GO


