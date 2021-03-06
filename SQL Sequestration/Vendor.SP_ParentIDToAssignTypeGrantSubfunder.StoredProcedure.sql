USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_ParentIDToAssignTypeGrantSubfunder]    Script Date: 3/16/2017 12:26:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















-- =============================================
-- Author:		Greg Sanders
-- Create date: 2013-03-13
-- Description:	List the top unlabeled DUNSnumbers
-- =============================================
CREATE PROCEDURE [Vendor].[SP_ParentIDToAssignTypeGrantSubfunder]
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
			,D.parentid
			,d.isenterprise
			,d.isfaithbased
			,d.isgovernment
			,d.ismultilateral
			,d.isnetwork
			,d.isngo
			,d.ispublicprivatepartnership
			,d.isUniversityorResearchInstitute

			,sum(d.ConstantFedFundedBillions) as SumOfFedFundedConstantBillions
			,max(d.ConstantFedFundedBillions) as MaxOfFedFundedConstantBillions
		FROM contractor.DunsnumbersToInvestigateFast as D

	where not (isnull(d.isenterprise,0)=1 or
			isnull(d.isfaithbased,0)=1 or
			isnull(d.isgovernment,0)=1 or
			isnull(d.ismultilateral,0)=1 or
			isnull(d.isnetwork,0) =1 or
			isnull(d.isngo,0)=1 or 
			isnull(d.ispublicprivatepartnership,0)=1 or
			isnull(d.isUniversityorResearchInstitute,0)=1)
			and d.parentid is not null 

		group by
			D.parentid
			,d.isenterprise
			,d.isfaithbased
			,d.isgovernment
			,d.ismultilateral
			,d.isnetwork
			,d.isngo
			,d.ispublicprivatepartnership
			,d.isUniversityorResearchInstitute
			
		
		having max(d.ConstantFedFundedBillions)>=0.25 or sum(d.ConstantFedFundedBillions)>=1

		Order by max(d.ConstantFedFundedBillions) desc
	end
	else
	begin
	-- Insert statements for procedure here
		SELECT top 1000 @subcomponent as FundingOrContractingSubcomponent 
			,min(D.[fiscalyear]) as  MinFiscalYear
			,max(D.[fiscalyear]) as  MaxFiscalYear
			,D.parentid
			,d.isenterprise
			,d.isfaithbased
			,d.isgovernment
			,d.ismultilateral
			,d.isnetwork
			,d.isngo
			,d.ispublicprivatepartnership
			,d.isUniversityorResearchInstitute
			,sum(D.ConstantFedFundingBillions) as TotalConstantObligatedBillions
			,max(D.ConstantFedFundingBillions) as MaxAnnualConstantObligatedBillions
		FROM (
			SELECT D.[fiscalyear]
				,D.parentid
				,d.isenterprise
			,d.isfaithbased
			,d.isgovernment
			,d.ismultilateral
			,d.isnetwork
			,d.isngo
			,d.ispublicprivatepartnership
			,d.isUniversityorResearchInstitute
				,sum(D.ConstantFedFundingBillions) as ConstantFedFundingBillions
				
			FROM vendor.DunsnumbersToInvestigateGrantSubFunder as D
			where  @subcomponent in (d.fundingsubcomponent, d.contractingsubcomponent)
			and not (isnull(d.isenterprise,0)=1 or
			isnull(d.isfaithbased,0)=1 or
			isnull(d.isgovernment,0)=1 or
			isnull(d.ismultilateral,0)=1 or
			isnull(d.isnetwork,0) =1 or
			isnull(d.isngo,0)=1 or 
			isnull(d.ispublicprivatepartnership,0)=1 or
			isnull(d.isUniversityorResearchInstitute,0)=1)
			and d.parentid is not null 
			group by
				d.fiscalyear
				,D.parentid
				,d.isenterprise
			,d.isfaithbased
			,d.isgovernment
			,d.ismultilateral
			,d.isnetwork
			,d.isngo
			,d.ispublicprivatepartnership
			,d.isUniversityorResearchInstitute
			) as d
		group by
			D.parentid
			,d.isenterprise
			,d.isfaithbased
			,d.isgovernment
			,d.ismultilateral
			,d.isnetwork
			,d.isngo
			,d.ispublicprivatepartnership
			,d.isUniversityorResearchInstitute
			
		having max(D.ConstantFedFundingBillions)>=0.1 or sum(D.ConstantFedFundingBillions)>=0.25
		Order by max(d.ConstantFedFundingBillions) desc
	end
	
















END
















GO
