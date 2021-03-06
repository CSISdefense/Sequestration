USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[sp_EraseParentID]    Script Date: 3/16/2017 12:26:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Greg Sanders
-- Create date: 2013-03-13
-- Description:	Assign a parent ID to a dunsnumber for a range of years
-- =============================================
CREATE PROCEDURE [Vendor].[sp_EraseParentID]
	-- Add the parameters for the stored procedure here
	@dunsnumber varchar(13)
	,@startyear int
	,@endyear int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if @dunsnumber is null
		raiserror('The value for @dunsnumber should not be null.',15,1)
	if @startyear is null
		raiserror('The value for @startyear should not be null. If assigning a single year, @startyear and @endyear should match.',15,1)
	if @endyear is null
		raiserror('The value for @endyear should not be null. If assigning a single year, @startyear and @endyear should match.',15,1)
	if @endyear<@startyear
		raiserror('The value for @endyear must be greater than or equal to @startyear',15,1)
    -- Insert statements for procedure here
	update contractor.DunsnumberToParentContractorHistory
	set parentid=NULL
	,CSISmodifiedBy=system_user
	,csismodifieddate=getdate()
	where dunsnumber=@dunsnumber and
		fiscalyear>=@startyear and
		fiscalyear<=@endyear
END



GO
