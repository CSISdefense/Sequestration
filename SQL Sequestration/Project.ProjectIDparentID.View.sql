USE [DIIG]
GO

/****** Object:  View [Project].[ProjectIDplatformPortfolioPartial]    Script Date: 4/14/2017 1:00:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW Project.ProjectIDparentIDpartial
AS

SELECT 
	f.ProjectID
	,f.ParentID
	, Sum(f.obligatedamount) AS SumOfobligatedamount
FROM [Project].[BucketProjectSubCustomer]  as f
GROUP BY 
	f.ProjectID
	,f.ParentID








GO


