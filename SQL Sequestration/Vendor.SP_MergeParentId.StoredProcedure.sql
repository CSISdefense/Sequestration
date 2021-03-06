USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_MergeParentId]    Script Date: 3/16/2017 12:26:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Rhys McCormick>
-- Create date: <03/26/2013>
-- Description:	<Change the Name of a Parent Contractor	>
-- =============================================
CREATE PROCEDURE [Vendor].[SP_MergeParentId]
	-- Add the parameters for the stored procedure here
	@oldparentid nvarchar(255)
	,@mergedparentid nvarchar(255)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
if @oldparentid is null
		raiserror('The value for @oldparentid shold not be null. To create a parentid, use contractor.sp_CreateParentID',15,1)
if @mergedparentid is null
		raiserror('The value for @newparentid shold not be null. To change a parentid, use contractor.sp_ChangeParentID',15,1)
    
	-- Insert statements for procedure here
/*INSERT INTO Contractor.ParentContractor(ParentID, Ticker, ShortName, BloombergID, DIIGIndex, LargeGreaterThan1B, LargeGreaterThan3B, PMC, HRFprivatemilitary, SIGIRprivemilitary, SIGIRDuns, Subsidiary, MergerYear, BgovID, HooverID, LexisNexisID, RevenueInMillions, RevenueYear, RevenueSourceLink, Replace, DropEntry, JointVenture, LastYear, FirstYear, SizeGuess, NumberOfYears, DACIM, UnknownCompany, FPDSannualRevenue, Top100Federal, AlwaysDisplay, Owners, MergerDate, MergerURL, OverrideBgovid, FirstURl, SpunOffFrom, Top6, StandardizedParentID)
SELECT @newparentid, Ticker, ShortName, BloombergID, DIIGIndex, LargeGreaterThan1B, LargeGreaterThan3B, PMC, HRFprivatemilitary, SIGIRprivemilitary, SIGIRDuns, Subsidiary, MergerYear, BgovID, HooverID, LexisNexisID, RevenueInMillions, RevenueYear, RevenueSourceLink, Replace, DropEntry, JointVenture, LastYear, FirstYear, SizeGuess, NumberOfYears, DACIM, UnknownCompany, FPDSannualRevenue, Top100Federal, AlwaysDisplay, Owners, MergerDate, MergerURL, OverrideBgovid, FirstURl, SpunOffFrom, Top6, StandardizedParentID
FROM Contractor.ParentContractor WHERE ParentID = @oldparentid*/

UPDATE Contractor.DunsnumberToParentContractorHistory 
SET ParentID = @mergedparentid
WHERE ParentId = @oldparentid


UPDATE Vendor.ParentIDtoOwnerParentID
SET ParentID = @mergedparentid
WHERE ParentId = @oldparentid


UPDATE Vendor.ParentIDtoOwnerParentID 
SET OwnerParentID = @mergedparentid
WHERE OwnerParentID = @oldparentid


--Delete entries where both the old and the merged parent had proper names for the year
delete
from contractor.parentcontractornamehistory
where ParentId =@oldparentid and
fiscalyear in
(select FiscalYear
from  Contractor.ParentContractorNameHistory p
WHERE ParentId in (@oldparentid,@mergedparentid)
group by FiscalYear
having count(*)>1)

--Transfer over the names from the old to the new
UPDATE p
SET ParentID = @mergedparentid
from  Contractor.ParentContractorNameHistory p
WHERE ParentId = @oldparentid



update assistance.USAIDforwardLocalOrganization
SET ParentID = @mergedparentid
WHERE ParentId = @oldparentid

update Vendor.VendorName
SET ParentID = @mergedparentid
WHERE ParentId = @oldparentid



DELETE FROM Contractor.ParentContractor
WHERE ParentId = @oldparentid

END











GO
