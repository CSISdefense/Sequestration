USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_HeadquarterCodeDunsnumbersDisagreementsToInvestigateFast]    Script Date: 3/16/2017 12:26:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Greg Sanders
-- Create date: 2013-03-13
-- Description:	List the top unlabeled DUNSnumbers
-- =============================================
CREATE PROCEDURE [Vendor].[SP_HeadquarterCodeDunsnumbersDisagreementsToInvestigateFast]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT top 10 
	
     d.ParentDUNSStatus
	 --,d.HQcodestatus
		,min(D.[fiscalyear]) as  MinFiscalYear
		,max(D.[fiscalyear]) as  MaxFiscalYear
		,D.[DUNSNumber]
      ,sum(D.[ConstantObligatedBillions]) as TotalConstantObligatedBillions
	  ,max(D.[ConstantObligatedBillions]) as MaxAnnualConstantObligatedBillions
      ,D.[StandardizedTopContractor]
	  ,[parentid]
	   ,d.MergerYear
	   ,d.firstyear
      ,[ParentDUNSParentID]
	  ,d.Parentdunsnumber
	  ,d.ParentDunsStandardizedTopContractor
	  ,ParentDunsIgnoreBeforeYear
	        --,d.[HQcodeParentID]
	  ,d.Headquartercode
	  --,d.HQcodeStandardizedTopContractor
	  ,HQcodeIgnoreBeforeYear
	  

	FROM [Vendor].[HeadquartersCodeDunsnumbersDisagreementsFast] as D
	where 
	--(d.mergeryear is null or d.mergeryear<d.fiscalyear) and
	(d.HQcodeParentID is not null or d.ParentDunsParentID is not null)
	and 
	  ParentDUNSStatus in 
		('ParentDunsOverall Contradiction' 
			,'ParentDunsHistory Contradiction'
			,'ParentID is NULL, ParentDuns is not'
			) 
		or d.HQcodeParentID is not null
					--or 	  HQcodeStatus ='HQcodeOverall Contradiction' 
		--or 	  HQcodeStatus in 
		--('HQcodeOverall Contradiction' 
		--	,'HQcodeHistory Contradiction'
		--	,'ParentID is NULL, HQcode is not'
		--	)
	group by
		
      d.ParentDUNSStatus
	  --,d.HQcodestatus
      ,D.[DUNSNumber]
      ,D.[StandardizedTopContractor]
	    ,[parentid]
	   ,d.MergerYear
	   ,d.firstyear
        ,d.[HQcodeParentID]
	  ,d.Headquartercode
	  ,d.HQcodeStandardizedTopContractor
	  ,HQcodeIgnoreBeforeYear
      ,[ParentDUNSParentID]
	  	  ,d.Parentdunsnumber
	  ,d.ParentDunsStandardizedTopContractor
	  ,ParentDunsIgnoreBeforeYear
	  
	having max(D.[ConstantObligatedBillions])>=0.5 or sum(D.[ConstantObligatedBillions])>=2
	Order by d.dunsnumber, max(d.[ConstantObligatedBillions]) desc
	


END





















GO
