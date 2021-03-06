USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_DunsnumbersUnlabeledToInvestigateContractGrantFast]    Script Date: 3/16/2017 12:26:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









-- =============================================
-- Author:		Greg Sanders
-- Create date: 2013-03-13
-- Description:	List the top unlabeled DUNSnumbers
-- =============================================
CREATE PROCEDURE [Vendor].[SP_DunsnumbersUnlabeledToInvestigateContractGrantFast]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT top 1000 min(D.[fiscalyear]) as  MinFiscalYear
		,max(D.[fiscalyear]) as  MaxFiscalYear
		,D.[DUNSNumber]
      ,sum(D.[ConstantObligatedBillions]) as SumOfConstantObligatedBillions
	  ,sum(D.ConstantFedFundedBillions) as SumOfConstantFedFundedBillions
	  ,sum(D.ConstantTotalBillions) as SumOfConstantTotalBillions
	  ,max(D.ConstantTotalBillions) as MaxOfConstantTotalBillions
      ,D.[StandardizedTopContractor]
		,d.parentdunsnumberparentidsuggestion
	FROM Contractor.DunsnumbersToInvestigateFast as D
	where d.parentid is null
	group by
      D.[DUNSNumber]
      ,D.[StandardizedTopContractor]
		,d.parentdunsnumberparentidsuggestion 
	having max(D.ConstantTotalBillions)>=0.25 or sum(D.ConstantTotalBillions)>=1
	Order by max(d.ConstantTotalBillions) desc
	


END










GO
