USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_Silicon_Valley_Matchups]    Script Date: 3/16/2017 12:26:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Vendor].[SP_Silicon_Valley_Matchups]
	-- Add the parameters for the stored procedure here
	--<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
	--<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
update sv
set standardizedvendorname= ltrim(rtrim(replace(standardizedvendorname,' ',' ')))
FROM [DIIG].[Vendor].[SiliconValley] sv
where standardizedvendorname <> ltrim(rtrim(replace(standardizedvendorname,' ',' ')))

SELECT sv.[StandardizedVendorName]
,sv.parentid
	  ,vn.standardizedvendorname
	  --,vn.parentid SuggestedVNparentID
	  --,svnh.parentid as SuggestedSVNHparentID
	  --,dtpch.parentid as SuggestedDTPCHparentID
   --   --,[List]
      --,[Sales]
      --,[Profit]
      --,[Capex]
      --,[RnD]
      --,[Employees]
      --,[Cash]
      --,[Debt]
      --,[Dividends]
      --,[Repurchase]
      --,[Tax]
      --,[Rank]
  FROM [DIIG].[Vendor].[SiliconValley] sv
  left outer join Vendor.VendorName vn
  on sv.StandardizedVendorName=vn.vendorname
 -- left outer join vendor.StandardizedVendorNameHistory svnh
 -- on sv.StandardizedVendorName=svnh.StandardizedVendorName
 -- left outer join contractor.DunsnumberToParentContractorHistory dtpch
 -- on sv.StandardizedVendorName=dtpch.StandardizedTopContractor
	--and dtpch.ParentID is not null
  group by  sv.[StandardizedVendorName]
  ,sv.parentid
	  ,vn.standardizedvendorname
	  --,vn.parentid
	  --,svnh.parentid
	  --,dtpch.parentid
	  order by sv.standardizedvendorname
  	

	
update sv
set parentid =vn.parentid 
  FROM [DIIG].[Vendor].[SiliconValley] sv
  left outer join Vendor.VendorName vn
  on sv.StandardizedVendorName=vn.vendorname
  where sv.ParentID is null and vn.parentid is not null




  	


  
SELECT sv.[StandardizedVendorName]
,sv.parentid
	  ,vn.standardizedvendorname
	  ,vn.parentid SuggestedVNparentID
	  ,svnh.parentid as SuggestedSVNHparentID
	  ,dtpch.parentid as SuggestedDTPCHparentID
      --,[List]
      --,[Sales]
      --,[Profit]
      --,[Capex]
      --,[RnD]
      --,[Employees]
      --,[Cash]
      --,[Debt]
      --,[Dividends]
      --,[Repurchase]
      --,[Tax]
      --,[Rank]
  FROM [DIIG].[Vendor].[SiliconValley] sv
  left outer join Vendor.VendorName vn
  on sv.StandardizedVendorName=vn.vendorname
  left outer join vendor.StandardizedVendorNameHistory svnh
  on sv.StandardizedVendorName=svnh.StandardizedVendorName
  left outer join contractor.DunsnumberToParentContractorHistory dtpch
  on sv.StandardizedVendorName=dtpch.StandardizedTopContractor
	and dtpch.ParentID is not null
where sv.parentid is null 
and dtpch.parentid is not null
  group by  sv.[StandardizedVendorName]
  ,sv.parentid
	  ,vn.standardizedvendorname
	  ,vn.parentid
	  ,svnh.parentid
	  ,dtpch.parentid
	  order by sv.standardizedvendorname


update sv
set parentid ='KLA TENCOR'
fROM [DIIG].[Vendor].[SiliconValley] sv
  where sv.ParentID is null and 
  sv.StandardizedVendorName='KLA TENCOR'


update p
set IsSiliconValley=1
from contractor.ParentContractor p
where IsSiliconValley is null
and ParentID ='BRISTOL MYERS SQUIBB & GILEAD SCIENCES'

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT  iif(p.parentid is null,sv.[StandardizedVendorName],p.parentid) as NameOrParentID
	,p.parentid
	,p.IsSiliconValley
      ,min([List]) as List
      ,min([Sales]) as Sales
      ,min([Profit]) as Profit
      ,min([Capex]) as Capex
      ,min([RnD]) as RnD
      ,min([Employees]) as Employees
      ,min([Cash]) as Cash
      ,min([Debt]) as Debt
      ,min([Dividends]) as Dividends
      ,min([Repurchase]) as Repurchase
      ,min([Tax]) as Tax
      ,min([Rank]) as Rank
  FROM [DIIG].[Vendor].[SiliconValley] sv
    left outer join Vendor.VendorName vn
  on sv.StandardizedVendorName=vn.vendorname
  full outer join contractor.ParentContractor p
  on sv.ParentID=p.ParentID
  where rank is not null
  or (isSiliconValley=1 and sv.rank is null)
  group by   iif(p.parentid is null,sv.[StandardizedVendorName],p.parentid)
	        ,p.[ParentID]
			,p.IsSiliconValley	  
  order by min(rank)



  update p 
  set IsSiliconValley=1
  from contractor.ParentContractor  p
  inner join [DIIG].[Vendor].[SiliconValley] sv
  on p.ParentID=sv.ParentID
  where sv.rank is not null and sv.rank<=30 and IsSiliconValley is null

  update p 
  set IsSiliconValley=1
  from contractor.ParentContractor  p
  where p.ParentID in ('LSI','KLA TENCOR')
   and IsSiliconValley is null

  
  update p 
  set IsSiliconValley=NULL
  from contractor.ParentContractor  p
  where p.ParentID in ('VARIAN SEMICONDUCTOR EQUIPMENT','VARIAN ASSOCIATES')
   and IsSiliconValley is null
 

END



GO
