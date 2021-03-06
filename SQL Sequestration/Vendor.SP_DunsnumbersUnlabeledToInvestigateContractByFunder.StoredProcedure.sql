USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_DunsnumbersUnlabeledToInvestigateContractByFunder]    Script Date: 3/16/2017 12:26:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
















-- =============================================
-- Author:		Greg Sanders
-- Create date: 2013-03-13
-- Description:	List the top unlabeled DUNSnumbers
-- =============================================
CREATE PROCEDURE [Vendor].[SP_DunsnumbersUnlabeledToInvestigateContractByFunder]
	-- Add the parameters for the stored procedure here
	
	@component varchar(255)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	if (@component is null) 
	begin
		-- Insert statements for procedure here
		SELECT top 1000 min(D.[fiscalyear]) as  MinFiscalYear
			,max(D.[fiscalyear]) as  MaxFiscalYear
			,D.[DUNSNumber]
			,sum(D.[ConstantObligatedBillions]) as TotalConstantObligatedBillions
			,max(D.[ConstantObligatedBillions]) as MaxAnnualConstantObligatedBillions
			,D.[StandardizedTopContractor]
			,d.parentdunsnumberparentidsuggestion
		FROM Contractor.DunsnumbersToInvestigateFast as D
		where d.parentid is null 

		group by
			D.[DUNSNumber]
			,D.[StandardizedTopContractor]
			,d.parentdunsnumberparentidsuggestion 
		having max(D.[ConstantObligatedBillions])>=0.125 or sum(D.[ConstantObligatedBillions])>=.5
		Order by max(d.[ConstantObligatedBillions]) desc
	end
	else
	begin
	-- Insert statements for procedure here
		SELECT top 1000 min(D.[fiscalyear]) as  MinFiscalYear
			,max(D.[fiscalyear]) as  MaxFiscalYear
			,D.[DUNSNumber]
			,sum(D.[ConstantObligatedBillions]) as TotalConstantObligatedBillions
			,max(D.[ConstantObligatedBillions]) as MaxAnnualConstantObligatedBillions
			,D.[StandardizedTopContractor]
			,d.parentdunsnumberparentidsuggestion
		FROM (SELECT D.[fiscalyear]
				,D.[DUNSNumber]	
				,D.[StandardizedTopContractor]
				,d.parentdunsnumberparentidsuggestion
				,sum(d.ConstantObligatedBillions) as ConstantObligatedBillions
			FROM vendor.DunsnumbersToInvestigateContractSubFunder as D
			where d.parentid is null and @component in (d.FundingComponent, d.ContractingComponent)
			group by
				d.fiscalyear
				,D.[DUNSNumber]
				,D.[StandardizedTopContractor]
				,d.parentdunsnumberparentidsuggestion 
		) as D
		group by
			D.[DUNSNumber]
			,D.[StandardizedTopContractor]
			,d.parentdunsnumberparentidsuggestion 
		having max(D.[ConstantObligatedBillions])>=0.05 or sum(D.[ConstantObligatedBillions])>=0.125
		Order by max(d.[ConstantObligatedBillions]) desc
	end
	


END

















GO
