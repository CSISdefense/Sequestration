USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[sp_ChangeParentIDYear]    Script Date: 3/16/2017 12:26:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		Alex Stephenson
-- Create date: 2013-10-25
-- Description:	Change a ParentID for a range of years
-- =============================================
CREATE PROCEDURE [Vendor].[sp_ChangeParentIDYear]
	-- Add the parameters for the stored procedure here
	@oldparentid nvarchar(255)
	,@newparentid nvarchar(255)
	,@startyear int
	,@endyear int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if @oldparentid is null
		raiserror('The value for @oldparentid should not be null.',15,1)
	if @newparentid is null
		raiserror('The value for @newparentid shold not be null.',15,1)
	if @startyear is null
		raiserror('The value for @startyear shold not be null. If assigning a single year, @startyear and @endyear should match.',15,1)
	if @endyear is null
		raiserror('The value for @endyear shold not be null. If assigning a single year, @startyear and @endyear should match.',15,1)
	if @endyear<@startyear
		raiserror('The value for @endyear must be greater than or equal to @startyear',15,1) 
	if NOT EXISTS(SELECT ParentID FROM Contractor.ParentContractor WHERE parentid = @newparentid) 
		raiserror('The value for @newparentid does not exist',15,1) 

	update contractor.DunsnumberToParentContractorHistory
	set parentid=@newparentid
	,CSISmodifiedBy=system_user
	,csismodifieddate=getdate()
	where parentid = @oldparentid and
		fiscalyear>=@startyear and
		fiscalyear<=@endyear
END





GO
