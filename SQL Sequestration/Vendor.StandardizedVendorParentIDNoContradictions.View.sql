USE [DIIG]
GO
/****** Object:  View [Vendor].[StandardizedVendorParentIDNoContradictions]    Script Date: 3/16/2017 12:26:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [Vendor].[StandardizedVendorParentIDNoContradictions]
AS


SELECT 
	SCP.[StandardizedTopContractor]
	,iif(SCP.MinOfParentID=SCP.MaxOfParentID,SCP.MaxOfParentID,NULL) as ParentID
	,case
		when SCP.MinOfParentID<>SCP.MaxOfParentID
			then NULL
		when len(SCP.[StandardizedTopContractor])=len(scp.MaxOfStandardizedParentID)
			then iif(SCP.[StandardizedTopContractor]=scp.MaxOfStandardizedParentID,1,0)
		when len(SCP.[StandardizedTopContractor])>len(scp.MaxOfStandardizedParentID)
			then iif(left(scp.[StandardizedTopContractor],len(scp.MaxOfStandardizedParentID))=scp.MaxOfStandardizedParentID,1,0)
		when len(SCP.[StandardizedTopContractor])<len(scp.MaxOfStandardizedParentID)
			then iif(scp.[StandardizedTopContractor]=left(scp.MaxOfStandardizedParentID,len(scp.[StandardizedTopContractor])),1,0)
	end as ParentIDnameMatch
	
FROM (
	SELECT 
		dtpch.StandardizedTopContractor
		,max(parent.parentid) as MaxOfParentID
		,min(parent.parentid) as MinOfParentID
		,max(standardizedparent.standardizedvendorname) as MaxOfStandardizedParentID
		,min(standardizedparent.standardizedvendorname) as MinOfStandardizedParentID
	FROM	
		contractor.DunsnumberToParentContractorHistory as Dtpch 
	left outer JOIN contractor.parentcontractor as parent
		ON parent.Parentid = Dtpch.parentid 
	left outer JOIN Vendor.VendorName as standardizedparent
		ON parent.Parentid = standardizedparent.VendorName 
	where
		Dtpch.parentid is not null 
		and dtpch.StandardizedTopContractor is not null
	GROUP BY 
		dtpch.StandardizedTopContractor
	) 	 as SCP


	













GO
