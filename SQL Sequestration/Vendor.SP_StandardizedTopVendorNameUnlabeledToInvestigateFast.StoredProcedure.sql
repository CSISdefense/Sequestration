USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_StandardizedTopVendorNameUnlabeledToInvestigateFast]    Script Date: 3/16/2017 12:26:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












-- =============================================
-- Author:		Greg Sanders
-- Create date: 2013-03-13
-- Description:	List the top unlabeled DUNSnumbers
-- =============================================
CREATE PROCEDURE [Vendor].[SP_StandardizedTopVendorNameUnlabeledToInvestigateFast]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select 
	dtpch.StandardizedTopContractor
	,dtpch.DUNSnumber
	,min(dtpch.[fiscalyear]) as  MinFiscalYear
		,max(dtpch.[fiscalyear]) as  MaxFiscalYear
	  ,sum(dtpch.[ConstantObligatedBillions]) as SumOfConstantObligatedBillions
	  ,sum(dtpch.[ConstantFedFundedBillions]) as SumOfConstantFedFundedBillions
	  ,sum(dtpch.[ConstantTotalBillions]) as SumOfConstantTotalBillions
	  ,max(dtpch.[ConstantTotalBillions]) as MaxOfConstantTotalBillions

	from contractor.DunsnumbersToInvestigateFast dtpch
	where dtpch.ParentID is null and 
	dtpch.StandardizedTopContractor in
	(
		select 
	--SELECT top 1000 
		      d.StandardizedTopContractor
		--,D.ParentDunsnumber

		--,d.parentdunsnumberparentidsuggestion
	FROM Contractor.DunsnumbersToInvestigateFast as D
	--inner join contractor.DunsnumberToParentContractorHistory as DTPCH
	--	on DTPCH.FiscalYear=d.fiscalyear and DTPCH.DUNSNumber=d.Parentdunsnumber
	where 
	d.StandardizedTopContractor is not null
	and d.parentid is null
	--d.parentdunsnumberparentidsuggestion is null
	--	and d.parentdunsnumber is not null
	group by
      --D.ParentDunsnumber
	        --,dtpch.StandardizedTopContractor
      D.[StandardizedTopContractor]
		--,d.parentdunsnumberparentidsuggestion 
	having max(D.ConstantObligatedBillions)>=0.5 or sum(D.ConstantObligatedBillions)>=2
	) 
	--Order by max(VendorNameList.ConstantObligatedBillions) desc
	group by 	dtpch.StandardizedTopContractor
	,dtpch.DUNSnumber
	having max(dtpch.[ConstantTotalBillions])>=0.125 or sum(dtpch.[ConstantTotalBillions])>=.5
	order by StandardizedTopContractor
	,max(dtpch.[ConstantTotalBillions]) desc
	


END













GO
