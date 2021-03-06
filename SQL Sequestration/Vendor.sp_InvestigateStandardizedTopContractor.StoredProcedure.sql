USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[sp_InvestigateStandardizedTopContractor]    Script Date: 3/16/2017 12:26:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		Greg Sanders
-- Create date: 2013-03-13
-- Description:	Assign a parent ID to a dunsnumber for a range of years
-- =============================================
CREATE  PROCEDURE [Vendor].[sp_InvestigateStandardizedTopContractor]
	-- Add the parameters for the stored procedure here
	@StandardizedTopContractor nvarchar(255)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if @StandardizedTopContractor is null
		raiserror('The value for @dunsnumber shold not be null.',15,1)


select
	'DUNSnumber order' as SourceTable
	,[DUNSnumber]
      ,[FiscalYear]
      ,[ParentID]
	  ,[StandardizedTopContractor]
	  ,[ObligatedAmount] as SumOfObligatedAmount
      ,[TopVendorNameTotalAmount] as SumOfTopVendorNameTotalAmount
      ,[Notes]
      ,[TooHard]
      ,[NotableSubdivision]
      ,[SubdivisionName]
      ,[Parentdunsnumber]
	from contractor.DunsnumberToParentContractorHistory as D
	where StandardizedTopContractor like ('%'+@StandardizedTopContractor+'%')
	order by dunsnumber,fiscalyear,[StandardizedTopContractor]


select
	'[StandardizedTopContractor order' as SourceTable
	,[DUNSnumber]
      ,min([FiscalYear]) as MinOfFY
	  ,max([FiscalYear]) as MaxOfFY
	  ,count([FiscalYear]) as CountOfFY
      ,[ParentID]
	  ,[StandardizedTopContractor]
	  ,sum([ObligatedAmount]) as SumOfObligatedAmount
      ,sum([TopVendorNameTotalAmount]) as SumOfTopVendorNameTotalAmount
      ,[Notes]
      ,[TooHard]
      ,[NotableSubdivision]
      ,[SubdivisionName]
      ,[Parentdunsnumber]
	from contractor.DunsnumberToParentContractorHistory as D
	where StandardizedTopContractor like ('%'+@StandardizedTopContractor+'%')
	group by [DUNSnumber] 
	,[ParentID]
	  ,[StandardizedTopContractor]
	     ,[Notes]
      ,[TooHard]
      ,[NotableSubdivision]
      ,[SubdivisionName]
      ,[Parentdunsnumber]
	order by [StandardizedTopContractor], dunsnumber,min(fiscalyear)
END





DECLARE	@return_value int

EXEC	@return_value = [Vendor].[sp_InvestigateParentID]
		@parentid = @StandardizedTopContractor

SELECT	'Return Value' = @return_value










GO
