USE [DIIG]
GO

/****** Object:  StoredProcedure [Vendor].[sp_EraseParentIDSubsidiaryStatus]    Script Date: 3/25/2017 12:12:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		Greg Sanders
-- Create date: 2013-03-13
-- Description:	Assign a parent ID to a dunsnumber for a range of years
-- =============================================
ALTER PROCEDURE [Vendor].[sp_EraseParentIDSubsidiaryStatus]
	-- Add the parameters for the stored procedure here
	@parentid nvarchar(255)
	,@Note nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if @parentid is null
		raiserror('The value for @parentid should not be null.',15,1)
    -- Insert statements for procedure here
	update parent
	set MergerYear=NULL
	,MergerDate =NULL
	,MergerURL =@Note 
	,Subsidiary=0
	,CSISmodifiedBy=system_user
	,csismodifieddate=getdate()
	from contractor.ParentContractor as parent
	where parent.parentid=@parentid

	delete p
	from Vendor.ParentIDtoOwnerParentID p
	where p.ParentID=@parentID

	
END





GO


