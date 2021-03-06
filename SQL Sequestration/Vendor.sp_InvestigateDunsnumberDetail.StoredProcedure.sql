USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[sp_InvestigateDunsnumberDetail]    Script Date: 3/16/2017 12:26:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		Greg Sanders
-- Create date: 2013-03-13
-- Description:	Assign a parent ID to a dunsnumber for a range of years
-- =============================================
CREATE PROCEDURE [Vendor].[sp_InvestigateDunsnumberDetail]
	-- Add the parameters for the stored procedure here
	@dunsnumber varchar(13)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if @dunsnumber is null
		raiserror('The value for @dunsnumber shold not be null.',15,1)
	
    -- Insert statements for procedure here
	select
	f.[DUNSnumber]
      ,f.[Fiscal_Year]
	  ,f.productorservicecode
	  ,psc.ProductOrServiceCodeText
	  ,f.agencyid
	  ,f.descriptionofcontractrequirement
      ,d.[ParentID]
	  ,d.[StandardizedTopContractor]
	  ,f.vendoralternatename
	  ,f.vendoralternatesitecode
	  ,f.vendordoingasbusinessname
	  ,f.vendor_cd
	  ,f.vendor_state_code
	  ,f.vendorcountrycode
	  ,f.vendorenabled
	  ,f.vendorlegalorganizationname
	  ,f.vendorlocationdisableflag
	  ,f.vendorname
	  ,f.vendorsitecode
	  ,f.streetaddress
	from contract.fpds as f
	inner join contractor.DunsnumberToParentContractorHistory as D
	on f.dunsnumber=d.dunsnumber and f.fiscal_year=d.FiscalYear
	left outer join FPDSTypeTable.ProductOrServiceCode psc
	on f.productorservicecode=psc.ProductOrServiceCode
	where d.dunsnumber=@dunsnumber or  d.dunsnumber=right('000000000'+left(@dunsnumber,9),9)
END






GO
