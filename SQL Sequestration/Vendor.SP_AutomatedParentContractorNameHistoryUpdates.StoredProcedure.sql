USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_AutomatedParentContractorNameHistoryUpdates]    Script Date: 3/16/2017 12:26:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		Greg Sanders
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Vendor].[SP_AutomatedParentContractorNameHistoryUpdates]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;




	insert into contractor.ParentContractorNameHistory (fiscalyear, parentid)
	select duns.FiscalYear , duns.ParentID
	from contractor.DunsnumberToParentContractorHistory as duns
	left outer join contractor.ParentContractorNameHistory as name
	on duns.FiscalYear=name.FiscalYear and duns.parentid=name.ParentID
	where name.parentid is null and duns.parentid is not null
	group by duns.FiscalYear , duns.ParentID;


		-- Determine standardizedtopcontractors for any new parentid
	UPDATE PCNH 
	set TopStandardizedVendorName=exterior.standardizedtopcontractor
		, SumOfTotalAmount=aggregated.SumOfTotalAmount
		, MaxOfTopVendorNameTotalAmount = aggregated.MaxOfTotalAmount
		,CSISmodifiedBy='Automated from total amounts and standardizedname by ' +system_user
		,csismodifieddate=getdate()
	FROM Contractor.ParentContractorNameHistory as PCNH
	inner join Vendor.ParentIDStandardizedVendorNameHistoryPartial as Exterior
	on Exterior.parentid=pcnh.parentid and
		Exterior.fiscalyear=pcnh.FiscalYear
	INNER JOIN (
		SELECT 
			interior.parentid
			, interior.FiscalYear
			, Sum(interior.TotalAmount) AS SumOfTotalAmount
			, Max(interior.TotalAmount) AS MaxOfTotalAmount
		FROM Vendor.ParentIDStandardizedVendorNameHistoryPartial as interior
			GROUP BY interior.parentid
			, interior.fiscalyear
	) as aggregated
	ON exterior.TotalAmount = aggregated.MaxOfTotalAmount
		AND exterior.parentid = aggregated.parentid
		 AND exterior.fiscalyear = aggregated.fiscalyear
	where TopStandardizedVendorName<>exterior.standardizedtopcontractor 
		and standardizedtopcontractor is not null


	update name
	set csisname=prevname.csisname
		,SourceURL=prevname.sourceurl
		,longname=prevname.longname
	FROM Contractor.ParentContractorNameHistory as Name
	inner join Contractor.ParentContractorNameHistory as Prevname
	on name.parentid=Prevname.parentid 
	where name.TopStandardizedVendorName<>''
		and name.FiscalYear=prevname.FiscalYear+1
		and name.csisname is null 
		and prevname.csisname is not null
		and case
		when len(name.TopStandardizedVendorName)=len(prevname.TopStandardizedVendorName)
			then iif(name.TopStandardizedVendorName=prevname.TopStandardizedVendorName,1,0)
		when len(name.TopStandardizedVendorName)>len(prevname.TopStandardizedVendorName)
			then iif(left(name.TopStandardizedVendorName,len(prevname.TopStandardizedVendorName))=prevname.TopStandardizedVendorName,1,0)
		when len(name.TopStandardizedVendorName)<len(prevname.TopStandardizedVendorName)
			then iif(name.TopStandardizedVendorName=left(prevname.TopStandardizedVendorName,len(name.TopStandardizedVendorName)),1,0)
		end=1

	update name
	set csisname=nextname.csisname
		,SourceURL=nextname.sourceurl
		,longname=nextname.longname
	FROM Contractor.ParentContractorNameHistory as Name
	inner join Contractor.ParentContractorNameHistory as nextname
	on name.parentid=nextname.parentid 
	where name.TopStandardizedVendorName<>''
		and name.FiscalYear=nextname.FiscalYear+1
		and name.csisname is null 
		and nextname.csisname is not null
		and case
		when len(name.TopStandardizedVendorName)=len(nextname.TopStandardizedVendorName)
			then iif(name.TopStandardizedVendorName=nextname.TopStandardizedVendorName,1,0)
		when len(name.TopStandardizedVendorName)>len(nextname.TopStandardizedVendorName)
			then iif(left(name.TopStandardizedVendorName,len(nextname.TopStandardizedVendorName))=nextname.TopStandardizedVendorName,1,0)
		when len(name.TopStandardizedVendorName)<len(nextname.TopStandardizedVendorName)
			then iif(name.TopStandardizedVendorName=left(nextname.TopStandardizedVendorName,len(name.TopStandardizedVendorName)),1,0)
		end=1
/*
 	-- Insert new Dunsnumber/fiscal year pairs into dunsnumbertoparentcontractorhistory
	insert into contractor.DunsnumberToParentContractorHistory (dunsnumber, FiscalYear)
	select
		c.dunsnumber
		,C.fiscal_year
	from contract.fpds as C
	left outer join Contractor.DunsnumberToParentContractorHistory as d
		on c.dunsnumber=d.DUNSnumber and c.fiscal_year=d.FiscalYear
	where d.dunsnumber is null and c.dunsnumber is not null and c.fiscal_year is not null
	group by 	c.dunsnumber
		,C.fiscal_year

	-- Insert new vendornames into vendorname
	insert into contractor.vendorname (vendorname)
	select
		c.vendorname
	from contract.fpds as C
	left outer join Contractor.vendorname as v
		on c.vendorname=v.vendorname
	where v.vendorname is null 
	group by 	c.vendorname
		

	-- Determine standardizedtopcontractors for any new dunsnumber/fiscal year pairings
	UPDATE Name 
	set StandardizedTopContractor=PVN.standardizedvendorname
		, ObligatedAmount= PFMV.sumofobligatedamount
		, TopContractorObligated = PFMV.maxofsumofobligatedamount
	FROM Contractor.DunsnumberToParentContractorHistory as Name
	inner join Contractor.DunsnumberStandardizedVendorNamePartial as PVN
	on PVN.dunsnumber=Name.DUNSnumber and
		PVN.fiscal_year=Name.FiscalYear
	INNER JOIN Contractor.DunsnumberFindMaxStandardizedVendorNamePartial as PFMV
	ON PVN.sumofobligatedamount = PFMV.MaxOfSumOfobligatedamount
		AND PVN.DUNSNUMBER = PFMV.DUNSNUMBER
		 AND PVN.fiscal_year = PFMV.fiscal_year
	where Name.StandardizedTopContractor is null


	-- Create 9 digit versions of dunsnumbers that are shorter or longer than 9 digits
update contractor.dunsnumber
set CECtext9digit=right('000000000'+left(dunsnumber,len(dunsnumber)-4),9)
where len(CECtext9digit)<>9 or (right(dunsnumber,4)='0000' and CECtext9digit is null)

	-- Create versions of dunsnumbers without leading zeros 
update contractor.dunsnumber
set CECnoleadingzero = SUBSTRING(CECtext9digit, PATINDEX('%[^0]%', CECtext9digit+'.'), LEN(CECtext9digit))
where CECtext9digit is not null and CECnoleadingzero is null 
--Source for leading zero remover: http://stackoverflow.com/questions/662383/better-techniques-for-trimming-leading-zeros-in-sql-server/662437#662437

--Transfer parentids from dunsnumbers without leading zeros to those with
update Name
set parentid=Name2.parentid
from contractor.DunsnumberToParentContractorHistory as Name
inner join contractor.Dunsnumber as d
on d.CECnoleadingzero=Name.dunsnumber
inner join contractor.DunsnumberToParentContractorHistory as Name2
	on Name2.DUNSnumber=d.dunsnumber and Name.fiscalyear=Name2.fiscalyear
where Name.parentid is null


--Transfer parentids from dunsnumbers that are not 9 characters to those that are
update Name
set parentid=Name2.parentid
from contractor.DunsnumberToParentContractorHistory as Name
inner join contractor.Dunsnumber as d
on d.CECtext9digit=Name.dunsnumber
inner join contractor.DunsnumberToParentContractorHistory as Name2
	on Name2.DUNSnumber=d.dunsnumber and Name.fiscalyear=Name2.fiscalyear
where Name.parentid is null





SELECT 
	SCP.[StandardizedTopContractor]
	,Max(SCP.parentid) AS MaxOfParentID
	,Count(SCP.parentid) AS CountOfParentID
	
FROM Vendor.StandardizedVendorParentID as SCP
GROUP BY 
	SCP.[StandardizedTopContractor]
HAVING 
	Count(SCP.parentid)<2 and
	max(case
		when len(SCP.[StandardizedTopContractor])=len(scp.parentid)
			then iif(SCP.[StandardizedTopContractor]=scp.parentid,1,0)
		when len(SCP.[StandardizedTopContractor])>len(scp.parentid)
			then iif(left(scp.[StandardizedTopContractor],len(scp.parentid))=scp.parentid,1,0)
		when len(SCP.[StandardizedTopContractor])<len(scp.parentid)
			then iif(scp.[StandardizedTopContractor]=left(scp.parentid,len(scp.[StandardizedTopContractor])),1,0)
	end)=1
END

--Update standardizedvendorname when the parentid assignment is uncontroversial
update v
set parentid = s.MaxOfParentID
from contractor.standardizedvendorname as v
inner join Vendor.StandardizedVendorParentIDNoContradictions as s
on s.StandardizedTopContractor=v.StandardizedVendorName
where v.parentid is null and s.MaxOfParentID is not null

--Update dunsnumbertoparentid when standardizedvendorname has an uncontroversial parentid 
update Name
set Name.parentid=v.parentid
from contractor.DunsnumberToParentContractorHistory as Name
inner join contractor.StandardizedVendorName as v
on Name.standardizedtopcontractor = v.StandardizedVendorName
where v.parentid is not null and Name.parentid is null and Name.StandardizedTopContractor <>''


--Update dunsnumbertoparentid when the parentid assignment is uncontroversial for that year
update Name
set ParentID=h.MaxOfParentID
from contractor.DunsnumberToParentContractorHistory as Name
inner join Vendor.StandardizedVendorParentIDhistoryNoContradictions as h
on Name.StandardizedTopContractor=h.StandardizedTopContractor and Name.FiscalYear=h.FiscalYear
where Name.parentid is null and h.MaxOfParentID is not null and Name.StandardizedTopContractor <>''

--List dunsnumber rollup counts
select fiscalyear
,sum(iif(len(Name.dunsnumber)<=9 and Name.parentid is not null,1,0)) as AssignedDunsnumbers
,sum(iif(len(Name.dunsnumber)<=9,1,0)) as TotalDunsnumbers
,sum(iif(len(Name.dunsnumber)<=9 and Name.parentid is not null,Name.obligatedamount,0)) as DunsnumberDollars
,sum(iif(len(Name.dunsnumber)<=9,Name.obligatedamount,0)) as TotalDollars
from contractor.DunsnumberToParentContractorHistory as Name
group by fiscalyear

*/



update p 
set isUniversityorResearchInstitute=0
from contractor.parentcontractor p
where (isngo=1 or isenterprise =1 or isgovernment=1)
 and isUniversityorResearchInstitute is null and UnknownCompany=0

update p 
set isenterprise=0
from contractor.parentcontractor p
where (isngo=1 or isUniversityorResearchInstitute =1 or isgovernment=1)
 and isenterprise is null and UnknownCompany=0

update p 
set isgovernment =0
from contractor.parentcontractor p
where (isngo=1 or isUniversityorResearchInstitute =1 or isenterprise=1)
 and isgovernment is null and UnknownCompany=0

 


end









GO
