USE [DIIG]
GO

/****** Object:  View [Vendor].[DunsnumberFindMaxParentDunsnumberPartial]    Script Date: 4/14/2017 1:44:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW Project.[ProjectIDfindMaxPlatformPortfolioPartial]
AS


SELECT 
DP.projectid
, Max(DP.SumOfobligatedamount) AS MaxOfSumOfobligatedamount
, Sum(DP.SumOfobligatedamount) AS SumOfobligatedamount
FROM Project.ProjectIDplatformPortfolioPartial as DP
GROUP BY DP.projectid












GO


