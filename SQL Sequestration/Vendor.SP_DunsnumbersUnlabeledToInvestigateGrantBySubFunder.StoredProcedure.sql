USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_DunsnumbersUnlabeledToInvestigateGrantBySubFunder]    Script Date: 3/16/2017 12:26:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












-- =============================================
-- Author:		Greg Sanders
-- Create date: 2013-03-13
-- Description:	List the top unlabeled DUNSnumbers
-- =============================================
CREATE PROCEDURE [Vendor].[SP_DunsnumbersUnlabeledToInvestigateGrantBySubFunder]
	-- Add the parameters for the stored procedure here
	
	@subcomponent varchar(255)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	if (@subcomponent is null) 
	begin
		-- Insert statements for procedure here
		SELECT top 1000 min(D.[fiscalyear]) as  MinFiscalYear
			,max(D.[fiscalyear]) as  MaxFiscalYear
			,D.[DUNSNumber]
			,sum(d.ConstantFedFundedBillions) as SumOfFedFundedConstantBillions
			,max(d.ConstantFedFundedBillions) as MaxOfFedFundedConstantBillions
			,D.[StandardizedTopContractor]
			,d.parentdunsnumberparentidsuggestion
		FROM contractor.DunsnumbersToInvestigateFast as D
		where d.parentid is null 

		group by
			D.[DUNSNumber]
			,D.[StandardizedTopContractor]
			,d.parentdunsnumberparentidsuggestion 
		having max(d.ConstantFedFundedBillions)>=0.25 or sum(d.ConstantFedFundedBillions)>=1
		Order by max(d.ConstantFedFundedBillions) desc
	end
	else
	begin
	-- Insert statements for procedure here
		SELECT top 1000 @subcomponent as FundingOrContractingSubcomponent 
			,min(D.[fiscalyear]) as  MinFiscalYear
			,max(D.[fiscalyear]) as  MaxFiscalYear
			,D.[DUNSNumber]
			,sum(D.ConstantFedFundingBillions) as TotalConstantObligatedBillions
			,max(D.ConstantFedFundingBillions) as MaxAnnualConstantObligatedBillions
			,D.[StandardizedTopContractor]
			,d.parentdunsnumberparentidsuggestion
		FROM (
			SELECT D.[fiscalyear]
				,D.[DUNSNumber]
				,sum(D.ConstantFedFundingBillions) as ConstantFedFundingBillions
				,D.[StandardizedTopContractor]
				,d.parentdunsnumberparentidsuggestion
			FROM vendor.DunsnumbersToInvestigateGrantSubFunder as D
			where d.parentid is null and @subcomponent in (d.fundingsubcomponent, d.contractingsubcomponent)
			group by
				d.fiscalyear
				,D.[DUNSNumber]
				,D.[StandardizedTopContractor]
				,d.parentdunsnumberparentidsuggestion 
			) as d
		group by
			D.[DUNSNumber]
			,D.[StandardizedTopContractor]
			,d.parentdunsnumberparentidsuggestion 
		having max(D.ConstantFedFundingBillions)>=0.1 or sum(D.ConstantFedFundingBillions)>=0.25
		Order by max(d.ConstantFedFundingBillions) desc
	end
	


END













GO
