USE [DIIG]
GO

/****** Object:  StoredProcedure [Vendor].[SP_RenameParentID]    Script Date: 3/25/2017 4:35:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO













-- =============================================
-- Author:		<Rhys McCormick>
-- Create date: <03/26/2013>
-- Description:	<Change the Name of a Parent Contractor	>
-- =============================================
ALTER PROCEDURE [Vendor].[SP_RenameParentID]
	-- Add the parameters for the stored procedure here
	@oldparentid nvarchar(255)
	,@newparentid nvarchar(255)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
if @oldparentid is null
		raiserror('The value for @oldparentid shold not be null. To create a parentid, use contractor.sp_CreateParentID',15,1)
if @newparentid is null
		raiserror('The value for @newparentid shold not be null. To erase a parentid, use contractor.sp_EraseParentID',15,1)
    
	-- Insert statements for procedure here
INSERT INTO Contractor.ParentContractor(ParentID, Ticker, ShortName, BloombergID, DIIGIndex, LargeGreaterThan1B, LargeGreaterThan3B, PMC, HRFprivatemilitary, SIGIRprivemilitary, SIGIRDuns, Subsidiary, MergerYear, HooverID, LexisNexisID, RevenueInMillions, RevenueYear, RevenueSourceLink, Replace, JointVenture, LastYear, FirstYear, SizeGuess, NumberOfYears, DACIM, UnknownCompany, FPDSannualRevenue, Top100Federal, AlwaysDisplay, MergerDate, MergerURL, FirstURl, SpunOffFrom, Top6
   ,[overrideparentdunsnumber]
      ,[parentheadquarterscountrycode]
      ,[isforeign]
      ,[isinternationalNGO]
      ,[isenterprise]
      ,[ismultilateral]
      ,[isngo]
      ,[isgovernment]
      ,[multilateraltype]
      ,[isfaithbased]
      ,[isnetwork]
      ,[ispublicprivatepartnership]
      ,[isUniversityorResearchInstitute]
      ,[topISO3countrycode]
      ,[totalamount]
      ,[topISO3countrytotalamount]
      ,[isInNeedOfInvestigation])
SELECT @newparentid, Ticker, ShortName, BloombergID, DIIGIndex, LargeGreaterThan1B, LargeGreaterThan3B, PMC, HRFprivatemilitary, SIGIRprivemilitary, SIGIRDuns, Subsidiary, MergerYear, HooverID, LexisNexisID, RevenueInMillions, RevenueYear, RevenueSourceLink, Replace, JointVenture, LastYear, FirstYear, SizeGuess, NumberOfYears, DACIM, UnknownCompany, FPDSannualRevenue, Top100Federal, AlwaysDisplay,  MergerDate, MergerURL, FirstURl, SpunOffFrom, Top6
   ,[overrideparentdunsnumber]
      ,[parentheadquarterscountrycode]
      ,[isforeign]
      ,[isinternationalNGO]
      ,[isenterprise]
      ,[ismultilateral]
      ,[isngo]
      ,[isgovernment]
      ,[multilateraltype]
      ,[isfaithbased]
      ,[isnetwork]
      ,[ispublicprivatepartnership]
      ,[isUniversityorResearchInstitute]
      ,[topISO3countrycode]
      ,[totalamount]
      ,[topISO3countrytotalamount]
      ,[isInNeedOfInvestigation]
FROM Contractor.ParentContractor WHERE ParentID = @oldparentid

UPDATE Contractor.DunsnumberToParentContractorHistory 
SET ParentID = @newparentid
WHERE ParentId = @oldparentid


UPDATE Contractor.ParentContractorNameHistory 
SET ParentID = @newparentid
WHERE ParentId = @oldparentid

if (not exists (select vendorname from vendor.vendorname where vendorname=@newparentid))
begin
	insert Vendor.VendorName (vendorname,standardizedvendorname,parentid) values (@newparentid,@newparentid,@newparentid)
end

UPDATE Vendor.VendorName
SET ParentID = @newparentid
WHERE ParentId = @oldparentid

UPDATE Vendor.ParentIDtoOwnerParentID
SET ParentID = @newparentid
WHERE ParentId = @oldparentid

UPDATE Vendor.SiliconValley
SET ParentID = @newparentid
WHERE ParentId = @oldparentid



UPDATE Vendor.EntityID
SET EntityText = @newparentid
,ParentID = @newparentid
,VendorName= @newparentid
where EntityText=@oldparentID




UPDATE Vendor.ParentIDHistory
SET ParentID = @newparentid
where ParentID=@oldparentID


DELETE FROM Contractor.ParentContractor
WHERE ParentId = @oldparentid

END













GO


