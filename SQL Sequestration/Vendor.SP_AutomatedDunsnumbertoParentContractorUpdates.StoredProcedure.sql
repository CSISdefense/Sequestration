USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_AutomatedDunsnumbertoParentContractorUpdates]    Script Date: 3/16/2017 12:26:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









-- =============================================
-- Author:		Greg Sanders
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
alter PROCEDURE [Vendor].[SP_AutomatedDunsnumbertoParentContractorUpdates]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



--Update AnyIsSmall/AlwaysIsSmall

  update dtpch
  set AnyIsSmall=mIsSmall.AnyIsSmall
  ,AlwaysIsSmall=mIsSmall.AlwaysIsSmall
  ,ObligatedAmountIsSmall=mIsSmall.ObligatedAmountIsSmall
  ,ObligatedAmount=mIsSmall.ObligatedAmount
  ,CSISmodifiedDate=getdate()
  ,CSISmodifiedBy='IsSmall automated update by'+SYSTEM_USER
  from [Contractor].[DunsnumberToParentContractorHistory] dtpch
  inner join (select s.dunsnumber
	,s.fiscal_year
	,max(s.IsSmall) as AnyIsSmall
	,min(s.IsSmall) as AlwaysIsSmall
	,sum(ObligatedAmountIsSmall) as ObligatedAmountIsSmall
	,sum(ObligatedAmount) as ObligatedAmount
	from (select f.contractingofficerbusinesssizedetermination
	,iif(f.contractingofficerbusinesssizedetermination='s' or f.contractingofficerbusinesssizedetermination='y',1,0) as IsSmall
	,iif(f.contractingofficerbusinesssizedetermination='s' or f.contractingofficerbusinesssizedetermination='y',
		ObligatedAmount,0) as ObligatedAmountIsSmall
	,ObligatedAmount
	,f.dunsnumber
	,f.fiscal_year
  from contract.FPDS as f) as s
  group by s.dunsnumber
  ,s.fiscal_year
  ) as mIsSmall
  on dtpch.DUNSnumber=mIsSmall.dunsnumber
  and dtpch.FiscalYear=mIsSmall.fiscal_year
  where dtpch.AnyIsSmall is null or  dtpch.AnyIsSmall<>mIsSmall.AnyIsSmall
	or dtpch.AlwaysIsSmall is null or dtpch.AlwaysIsSmall<>mIsSmall.AlwaysIsSmall
  or dtpch.ObligatedAmountIsSmall is null or dtpch.ObligatedAmountIsSmall <>mIsSmall.ObligatedAmountIsSmall
  or (dtpch.ObligatedAmount is null and mIsSmall.ObligatedAmount is not null) 
  or (dtpch.ObligatedAmount is not null and mIsSmall.ObligatedAmount is  null) 
  or dtpch.ObligatedAmount <>mIsSmall.ObligatedAmount

  
  update d
  set IsOnePercentPlusSmall=case 
	when AnyIsSmall=0
	then 0
	when AlwaysIsSmall=1
	then 1
	when ObligatedAmount=0 and ObligatedAmountIsSmall>0
	then 1
	when ObligatedAmount=0
	then NULL
	else iif(ObligatedAmountIsSmall/ObligatedAmount>=0.01,1,0)
	end
  from contractor.dunsnumbertoparentcontractorhistory d


--select Dunsnumber
--,FiscalYear
--,ObligatedAmount
--,ObligatedAmountisSmall
--,ObligatedAmountisSmall/nullif(ObligatedAmount,0) as percentSmall
--,AnyIsSmall
--,AlwaysIsSmall
--from contractor.DunsnumberToParentContractorHistory
--where ObligatedAmount is not null 

--***************** Updating Contractor.Dunsnumber
--Clear out '' parentdunsnumbers and headquartercode from Contract.fpds
--That should be tracked as a unknownvendorparent, but since it contains literally no information
--It's simpler to treat it as a null and to all for is null tests and the like
update contract.fpds
set parentdunsnumber=nullif(parentdunsnumber,''),
headquartercode=nullif(headquartercode,''),
CSISModifiedDate=getdate()
where parentdunsnumber='' or
headquartercode=''



--Update support fields in in contractor.DUNSnumber using contract.FPDS. 
--We fill in each category that is not controversial. E.g. it only has a single value or NULLs.
--In some cases, even when there are multiple variants, this means all three fields are filled in.
--This means only nulls were excluded.
update base
set ParentDUNSnumber=iif(isnull(aggregated.maxofParentDUNSnumber,'')=isnull(aggregated.minofParentDUNSnumber,'') 
		,aggregated.maxofParentDUNSnumber
		,NULL
	)
,HeadquarterCode=iif(isnull(aggregated.maxofHeadquarterCode,'')=isnull(aggregated.minofHeadquarterCode,'') 
		,aggregated.maxofHeadquarterCode
		,NULL
	)
, ParentDUNSnumberFirstFiscalYear=iif(isnull(aggregated.maxofParentDUNSnumber,'')=isnull(aggregated.minofParentDUNSnumber,'') 
		,aggregated.ParentDUNSnumberFirstFiscalYear
		,NULL
	)
,HeadquarterCodeFirstFiscalYear=iif(isnull(aggregated.maxofHeadquarterCode,'')=isnull(aggregated.minofHeadquarterCode,'') 
		,aggregated.HeadquarterCodeFirstFiscalYear
		,NULL
	)
,CAGE=iif(isnull(aggregated.maxofCAGE,'')=isnull(aggregated.minofCAGE,'') 
		,aggregated.maxofCAGE
		,NULL
	)
from Contractor.DUNSnumber base
 inner join 
	(select innermost.DUNSnumber
	,max(nullif(ParentDUNSnumber,'')) as MaxOfParentDUNSnumber
	,min(nullif(ParentDUNSnumber,'')) as MinOfParentDUNSnumber
	,max(nullif(HeadquarterCode,'')) as MaxOfHeadquarterCode
	,min(nullif(HeadquarterCode,'')) as MinOfHeadquarterCode
	,max(nullif(CAGE,'')) as MaxOfCAGE
	,min(nullif(CAGE,'')) as MinOfCAGE
	,min(iif(nullif(ParentDUNSnumber,'') is null,null,Fiscal_year)) as ParentDUNSnumberFirstFiscalYear 
	,min(iif(nullif(HeadquarterCode,'') is null,null,Fiscal_year)) as HeadquarterCodeFirstFiscalYear 
	from contract.FPDS as innermost
	group by innermost.DUNSnumber
	) as aggregated
on base.DUNSnumber=aggregated.DUNSnumber
where 
 isnull(base.HeadquarterCodeFirstFiscalYear,0)<>iif(aggregated.maxofParentDUNSnumber=aggregated.minofParentDUNSnumber
	,aggregated.HeadquarterCodeFirstFiscalYear
	,-0
	)
	or isnull(base.ParentDUNSnumberFirstFiscalYear,0)<>iif(aggregated.maxofHeadquarterCode=aggregated.minofHeadquarterCode
	,aggregated.ParentDUNSnumberFirstFiscalYear
	,0
	)
	or 
	isnull(base.ParentDUNSnumber,'')<>iif(aggregated.maxofParentDUNSnumber=aggregated.minofParentDUNSnumber
	,maxofParentDUNSnumber
	,''
	)
	or isnull(base.HeadquarterCode,'')<>iif(aggregated.maxofHeadquarterCode=aggregated.minofHeadquarterCode
	,maxofHeadquarterCode
	,''
	)
		or isnull(base.CAGE,'')<>iif(aggregated.maxofCAGE=aggregated.minofCAGE
	,maxofCAGE
	,''
	)


--***********Inserting and updating new dyads into into dunsnumbertoparentcontractorhistory
 	-- Insert new FPDS Dunsnumber/fiscal year pairs into dunsnumbertoparentcontractorhistory
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

 	-- Insert new FPDS ParentDunsnumber/fiscal year pairs into dunsnumbertoparentcontractorhistory
	insert into contractor.DunsnumberToParentContractorHistory (dunsnumber, FiscalYear)
	select
		c.parentdunsnumber
		,C.fiscal_year
	from contract.fpds as C
	left outer join Contractor.DunsnumberToParentContractorHistory as d
		on c.parentdunsnumber=d.DUNSnumber and c.fiscal_year=d.FiscalYear
	where d.dunsnumber is null and c.parentdunsnumber is not null and c.fiscal_year is not null
	group by 	c.parentdunsnumber
		,C.fiscal_year

 	
 --	 Insert new FPDS Dunsnumber/fiscal year pairs into dunsnumbertoparentcontractorhistory
		insert into contractor.DunsnumberToParentContractorHistory (dunsnumber, FiscalYear)
	select
		c.headquartercode
		,C.fiscal_year
	from contract.fpds as C
	left outer join Contractor.DunsnumberToParentContractorHistory as d
		on c.headquartercode=d.DUNSnumber and c.fiscal_year=d.FiscalYear
	where d.dunsnumber is null and c.headquartercode is not null and c.fiscal_year is not null
	group by 	c.headquartercode
		,C.fiscal_year


	
	-- Insert new FAADS Dunsnumber/fiscal year pairs into dunsnumbertoparentcontractorhistory
	insert into contractor.DunsnumberToParentContractorHistory (dunsnumber, FiscalYear)
	select
		g.duns_no
		,g.fiscal_year
	from GrantLoanAssistance.faads as g
	left outer join Contractor.DunsnumberToParentContractorHistory as d
		on g.duns_no=d.DUNSnumber and g.fiscal_year=d.FiscalYear
	where d.dunsnumber is null and g.duns_no is not null and g.fiscal_year is not null
	group by 	g.duns_no
		,g.fiscal_year


 	-- Insert new Phoenix  Dunsnumber/fiscal year pairs into dunsnumbertoparentcontractorhistory
	insert into contractor.DunsnumberToParentContractorHistory (dunsnumber, FiscalYear)
	select 
		p.DUNS_NUM
		,p.FY
	from Assistance.USAIDphoenix as p
	left outer join Contractor.DunsnumberToParentContractorHistory as d
		on p.DUNS_NUM=d.DUNSnumber and p.FY=d.FiscalYear
	where d.dunsnumber is null and p.DUNS_NUM is not null and p.FY is not null
	group by p.DUNS_NUM , p.fy
	



		--*************************Kludge to update standardized vendor names

		
--Public Function StandardizeContractor(strText As String) As String
--On Error GoTo Error_Handler
--'
--'This subroutine tries to eliminate erroneous variation to allow consolidation of corporation names in FPDS
--'
--'INPUT:
--'    strText     Base text
--'OUTPUT:
--'    ReplaceString  The base text with old string replaced by new string
--'
--' Note: requires Microsoft VBScript Regular Expressions 5.5

--Dim cnt As Integer
--Dim myRegExp As RegExp
--Dim myMatches As MatchCollection
--Dim myMatch As Match
--Dim strReplacedMatch As String
--Dim strOriginalText As String
--Dim strBlankCheck As String
--Set myRegExp = New RegExp
--myRegExp.IgnoreCase = True
--myRegExp.Global = True

--strOriginalText = strText

--'Error handling code
--If Len(strText) = 0 Then
--    StandardizeContractor = ""
--    Exit Function
--End If

--'1)  Convert all text to upper case (this is the default anyways).

--strText = UCase(strText)

--'2)  Drop any "." and [-]s

--myRegExp.Pattern = "[\.\-]+"
--strText = myRegExp.Replace(strText, " ")

--'3)  " and " becomes " & "

--myRegExp.Pattern = "\s+AND\s+"
--strText = myRegExp.Replace(strText, " & ")

--'4)  Make sure all "&"s have spaces (e.g. are " & "s)

--myRegExp.Pattern = "\s*&\s*"
--strText = myRegExp.Replace(strText, " & ")

--'5)  Make sure all ","s are followed by a " "

--myRegExp.Pattern = ",\s*"
--strText = myRegExp.Replace(strText, ", ")

--'6)  Switch any double spaces ("  ") to single spaces (" ")

--myRegExp.Pattern = "\s\s+"
--strText = myRegExp.Replace(strText, " ")

--'7)  Drop any " "s between multiple single letter words. (e.g. "K B R" -> "KBR" and "A J JACKSON" -> "AJ JACKSON")

--myRegExp.Pattern = "(\s|^)\w\s(\w(\s|$|,))+"

--Set myMatches = myRegExp.Execute(strText)
--For Each myMatch In myMatches
--    myRegExp.Pattern = "\s"
--    strReplacedMatch = " " & myRegExp.Replace(myMatch.Value, "") & " "
--    myRegExp.Pattern = myMatch.Value
--    strText = myRegExp.Replace(strText, strReplacedMatch)
--Next


--'8)  Drop any "("s as well as all text trailing them. (These tend to be sub-divisions or locations. In one case I noted a company called "K (M) 2" but that sort of thing seems to be so rare as to be ignorable. I was considering doing the same with ","s but that would cost us first names.

--'First take out "(" ... ")" pairings
--strBlankCheck = strText

--myRegExp.Pattern = "\s*\(.*?\)\s*"
--strText = myRegExp.Replace(strText, "")

--If strText = "" Then
--    'If the entire thing is contained within a () pairing, cancel the previous action and drop the ()s
--    strText = strBlankCheck
--    myRegExp.Pattern = "\s*[\(\)]\s*"
--    strText = myRegExp.Replace(strText, "")
--End If
--'Since I add space on both ends of the string, remove any spaces at the start of the string
--myRegExp.Pattern = "^\s+"
--strText = myRegExp.Replace(strText, "")


--'Then take out stand alone "("s
--strBlankCheck = strText
--myRegExp.Pattern = "\s*\(.*$"
--strText = myRegExp.Replace(strText, "")

--If strText = "" Then
--    'If the entire thing is contained within a () pairing, cancel the previous action and drop the ()s
--    strText = strBlankCheck
--    myRegExp.Pattern = "\s*[\(\)]\s*"
--    'strText = myRegExp.Replace(strText, "")
--End If

--'9)  Drop the following terms if they are the last word in the name. This will be length adjusted so "CORP or even "CO" would be flagged as "CORPORATION" (I'll set a minimum limit of 2 characters, so "C" doesn't get dropped.
--'First strip any trailing commas and white spaces.
--myRegExp.Pattern = "[\s,]+$"
--strText = myRegExp.Replace(strText, "")

--'a.  CORPORATION (Which automatically includes CORP and CO)
--myRegExp.Pattern = "\sCO(R|RP|RPO|RPOR|RPORA|RPORAT|RPORATI|RPORATIO|RPORATION)?$"
--strText = myRegExp.Replace(strText, "")

--'b.  LLC (Which automatically includes LL)
--myRegExp.Pattern = "\sLLC?$"
--strText = myRegExp.Replace(strText, "")

--'c.  LP
--myRegExp.Pattern = "\sLP$"
--strText = myRegExp.Replace(strText, "")

--'d.  LIMITED
--myRegExp.Pattern = "\sLI(M|MI|MIT|MITE|MITED|MITED\s+|MITED\s+|MITED\s+L|MITED\s+LI|MITED\s+LIA|MITED\s+LIAB|MITED\s+LIABI|MITED\s+LIABIL|MITED\s+LIABILI|MITED\s+LIABILIT|MITED\s+LIABILITY)?$"
--strText = myRegExp.Replace(strText, "")

--'e.  LTD
--myRegExp.Pattern = "\sLTD?$"
--strText = myRegExp.Replace(strText, "")
--'f.  INCORPORATED (Which automatically includes INC)
--myRegExp.Pattern = "\sIN(C|CO|COR|CORP|CORPO|CORPOR|CORPORA|CORPORAT|CORPORATE|CORPORATED)?$"
--strText = myRegExp.Replace(strText, "")

--'g.  THE
--myRegExp.Pattern = "\sTHE?$"
--strText = myRegExp.Replace(strText, "")

--'10) Drop any trailing "," and " "s

--myRegExp.Pattern = "[\s,]+$"
--strText = myRegExp.Replace(strText, "")


--StandardizeContractor = strText
	--Insert any ParentIDs that haven't been otherwise captured into Vendor.VendorName
	insert into Vendor.VendorName
	(vendorname)
	select p.parentid
	from contractor.ParentContractor p
	left outer join Vendor.VendorName v
	on p.ParentID=v.vendorname
	where v.vendorname is null

	

	--List any vendornames that need standardization. Sigh, fix this.
	select *
	from errorlogging.VendorNamesToStandardize
	

	--List the new assignments
	select v.vendorname, d.StandardizedVendorName
	from Vendor.VendorName v
	inner join dbo.VendorNamesToStandardize d
	on d.vendorname=v.vendorname
	where v.StandardizedVendorName is null 

	-- Insert new standardizedvendornames into vendorname. Sigh, fix this.
	insert into Vendor.VendorName (vendorname, standardizedvendorname)
	select 
		d.StandardizedVendorName, d.StandardizedVendorName
	from ErrorLogging.VendorNames_2018_01_14 d
	left outer join Vendor.VendorName as v
		on d.StandardizedVendorName=v.vendorname
	where v.vendorname is null and d.StandardizedVendorName is not null
	group by d.StandardizedVendorName
	order by d.StandardizedVendorName


		-- Update the new standardized vendor names. Sigh, fix this.
	update v
	set StandardizedVendorName=d.StandardizedVendorName
	from Errorlogging.VendorNames_2018_01_14 d
	inner join Vendor.VendorName v
	on d.VendorName=v.vendorname
	where v.StandardizedVendorName is null and d.StandardizedVendorName is not null


--Update support fields in in contractor.DUNSnumberToParentContractorHistory using contract.FPDS. 
--We fill in each category that is not controversial. E.g. it only has a single value or NULLs.
--In some cases, even when there are multiple variants, this means all three fields are filled in.
--This means only nulls were excluded.
update base
set ParentDUNSnumber=iif(isnull(aggregated.maxofParentDUNSnumber,'')=isnull(aggregated.minofParentDUNSnumber,'') 
		,aggregated.maxofParentDUNSnumber
		,NULL
	)
,HeadquarterCode=iif(isnull(aggregated.maxofHeadquarterCode,'')=isnull(aggregated.minofHeadquarterCode,'') 
		,aggregated.maxofHeadquarterCode
		,NULL
	)
,CAGE=iif(isnull(aggregated.maxofCAGE,'')=isnull(aggregated.minofCAGE,'') 
		,aggregated.maxofCAGE
		,NULL
	)
from Contractor.DunsnumberToParentContractorHistory base
 inner join 
	(select innermost.DUNSnumber
	,innermost.fiscal_year
	,max(nullif(ParentDUNSnumber,'')) as MaxOfParentDUNSnumber
	,min(nullif(ParentDUNSnumber,'')) as MinOfParentDUNSnumber
	,max(nullif(HeadquarterCode,'')) as MaxOfHeadquarterCode
	,min(nullif(HeadquarterCode,'')) as MinOfHeadquarterCode
	,max(nullif(CAGE,'')) as MaxOfCAGE
	,min(nullif(CAGE,'')) as MinOfCAGE
	from contract.FPDS as innermost
	group by innermost.DUNSnumber
	,innermost.fiscal_year
	) as aggregated
on base.DUNSnumber=aggregated.DUNSnumber and base.FiscalYear = aggregated.fiscal_year
where  isnull(base.ParentDUNSnumber,'')<>iif(aggregated.maxofParentDUNSnumber=aggregated.minofParentDUNSnumber
	,maxofParentDUNSnumber
	,''
	)
	or isnull(base.HeadquarterCode,'')<>iif(aggregated.maxofHeadquarterCode=aggregated.minofHeadquarterCode
	,maxofHeadquarterCode
	,''
	)
		or isnull(base.CAGE,'')<>iif(aggregated.maxofCAGE=aggregated.minofCAGE
	,maxofCAGE
	,''
	)

	-- Determine standardizedtopcontractors for all dunsnumber/fiscal year pairings
	UPDATE DtPCH 
	set StandardizedTopContractor=DVN.standardizedvendorname
		, ObligatedAmount= DFMV.sumofobligatedamount
		, totalamount=dfmv.sumoftotalamount
		, fed_funding_amount=dfmv.SumOffed_funding_amount
		, TopVendorNameTotalAmount = DFMV.MaxOfTotalAmount
		,CSISmodifiedBy='Automated from obligated amounts and standardizedname by ' +system_user
		,csismodifieddate=getdate()
	FROM Contractor.DunsnumberToParentContractorHistory as DtPCH
	inner join Vendor.DunsnumberStandardizedVendorNamePartial as DVN
	on DVN.dunsnumber=DtPCH.DUNSnumber and
		DVN.fiscal_year=Dtpch.FiscalYear
	INNER JOIN (
		SELECT 
			DVNP.DUNSNUMBER
			, DVNP.fiscal_year
			, Sum(DVNP.SumOfobligatedamount) AS SumOfobligatedamount
			, Sum(DVNP.SumOffed_funding_amount) AS SumOffed_funding_amount
			, Sum(DVNP.TotalAmount) AS SumOfTotalAmount
			, Max(DVNP.TotalAmount) AS MaxOfTotalAmount
		FROM Vendor.DunsnumberStandardizedVendorNamePartial as DVNP
			GROUP BY DVNP.DUNSNUMBER
			, DVNP.fiscal_year
	) as DFMV
	ON DVN.TotalAmount = DFMV.MaxOfTotalAmount
		AND DVN.DUNSNUMBER = DFMV.DUNSNUMBER
		 AND DVN.fiscal_year = DFMV.fiscal_year
	
	--not(nullif(StandardizedTopContractor,'')=DVN.standardizedvendorname and
	--	  nullif(ObligatedAmount,0)= nullif(DFMV.sumofobligatedamount,0) and
	--	 nullif(DtPCH.totalamount,0)=nullif(dfmv.sumoftotalamount,0) and
	--	  nullif(fed_funding_amount,0)=nullif(dfmv.SumOffed_funding_amount,0) and
	--	 nullif(TopVendorNameTotalAmount,0) = nullif(DFMV.MaxOfTotalAmount,0))
	


	-- Determine topISO3countrycode for any  dunsnumber 
	UPDATE Duns
	set topISO3countrycode=DVN.topISO3countrycode
		, topISO3countrytotalamount=dfmv.MaxOfTotalAmount
		, totalamount = dfmv.sumoftotalamount
		,CSISmodifiedBy='Automated from of amounts and vendorcountry by ' +system_user
		,csismodifieddate=getdate()
	FROM Contractor.Dunsnumber as Duns
	inner join [Vendor].[DunsnumberLocationVendorCountryPartial] as DVN
	on DVN.dunsnumber=duns.DUNSnumber 
	INNER JOIN (
		SELECT 
			DVNP.DUNSNUMBER
			, Sum(DVNP.SumOfobligatedamount) AS SumOfobligatedamount
			, Sum(DVNP.SumOffed_funding_amount) AS SumOffed_funding_amount
			, Sum(DVNP.TotalAmount) AS SumOfTotalAmount
			, Max(DVNP.TotalAmount) AS MaxOfTotalAmount
		FROM [Vendor].[DunsnumberLocationVendorCountryPartial] as DVNP
			GROUP BY DVNP.DUNSNUMBER
		
	) as DFMV
	ON DVN.TotalAmount = DFMV.MaxOfTotalAmount
	where case
		when isnull(DFMV.sumoftotalamount,0)=0
		then 0
		when DFMV.MaxOfTotalAmount/DFMV.sumoftotalamount>0.90
		then 1
		else 0
		end =0 and
		not (duns.topISO3countrycode=DVN.topISO3countrycode
		and duns.topISO3countrytotalamount=dfmv.MaxOfTotalAmount
		and duns.totalamount = dfmv.sumoftotalamount)
	--where dtpch.TotalAmount is null
	--where dtpch.StandardizedTopContractor is null
	
	

	--Get a count of mismatches
	select dtpch.FiscalYear
	,count(dtpch.parentid) as DunsnumberLabeled
	,count(parent.ParentID) as ParentDunsnumberLabeled
	,sum(iif(dtpch.parentid=parent.parentid,1,0)) as ParentDUNSmatches
	,sum(iif(dtpch.parentid<>parent.parentid
		and (dunsparent.LastYear is null or dunsparent.LastYear < dtpch.FiscalYear) ,1,0)) as ParentDUNSmismatches
	,sum(iif(dtpch.parentid is null and parent.parentid is not null,1,0)) as ParentDUNSnewLabel
	,sum(iif(dtpch.parentid is null and parent.parentid is not null,dtpch.ObligatedAmount,0)) as ParentDUNSnewLabel
	,count(HQ.ParentID) as HeadquartersLabeled
	,sum(iif(dtpch.parentid=HQ.parentid,1,0)) as HQDUNSmatches
	,sum(iif(dtpch.parentid<>HQ.parentid
		and (dunsparent.LastYear is null or dunsparent.LastYear < dtpch.FiscalYear) ,1,0)) as HQDUNSmismatches
	,sum(iif(dtpch.parentid is null and HQ.parentid is not null,1,0)) as HQnewLabel
	,sum(iif(dtpch.parentid is null and HQ.parentid is not null,dtpch.ObligatedAmount,0)) as HQnewLabelDollars
	--,dtpch.ParentID as Dunsnumber, parent.parentid as ParentDunsnumber
	from contractor.DunsnumberToParentContractorHistory dtpch
	left outer join Contractor.Dunsnumber duns
	on duns.DUNSnumber=dtpch.DUNSnumber
	left outer join contractor.ParentContractor as dunsparent
	on dtpch.parentid=dunsparent.parentid
	left outer join Contractor.DunsnumberToParentContractorHistory parent
	on duns.ParentDunsnumber=parent.DUNSnumber
	left outer join Contractor.DunsnumberToParentContractorHistory HQ
	on duns.HeadquarterCode=HQ.DUNSnumber
	and dtpch.FiscalYear=HQ.fiscalyear
	group by dtpch.FiscalYear
	order by dtpch.FiscalYear

	--Examine mismatches between parentid from dunsnumber and from parentdunsnumber
	select  
	parent.ParentID as ParentDUNSnumberLabel
	,duns.ParentDUNSnumber
	,min(dtpch.fiscalyear) as MinOfFiscalYear
	,max(dtpch.fiscalyear) as MaxOfFiscalYear

	,dtpch.DUNSnumber 
	,dtpch.StandardizedTopContractor
	,dtpch.parentid as DUNSnumberLabel
	,dunsparent.Subsidiary
	,dunsparent.LastYear

	from contractor.DunsnumberToParentContractorHistory dtpch
	left outer join Contractor.Dunsnumber duns
	on duns.DUNSnumber=dtpch.DUNSnumber
	left outer join contractor.ParentContractor as dunsparent
	on dtpch.parentid=dunsparent.parentid
	left outer join Contractor.DunsnumberToParentContractorHistory parent
	on duns.ParentDunsnumber=parent.DUNSnumber
	and dtpch.FiscalYear=parent.fiscalyear
	
	where dtpch.parentid<>parent.parentid
	--Next eliminate dunsnumber that were acquired in years prior to acquisition
	and (dunsparent.LastYear is null or dunsparent.LastYear < dtpch.FiscalYear) 
	--where dtpch.ParentID is not null 
	--	and parent.parentid is not null
	group by dtpch.DUNSnumber 
	,dtpch.parentid 
	,duns.ParentDUNSnumber
	,parent.ParentID
	,dtpch.StandardizedTopContractor
		,dunsparent.Subsidiary
	,dunsparent.LastYear

	order by parent.ParentID, ParentDUNSnumber, dunsnumber


--*******************Inserting and updating dyads for Vendor.StandardizedVendorNameHistory
	-- Insert new FPDS vendornames into standardized vendorname
	insert into vendor.standardizedvendornamehistory (standardizedvendorname, fiscal_year)
	select
		sv.StandardizedVendorName
		,c.fiscal_year
	from contract.fpds as C
	left outer join Vendor.VendorName sv
		on sv.vendorname=c.vendorname
	left outer join Vendor.StandardizedVendorNameHistory as v
		on sv.Standardizedvendorname=v.Standardizedvendorname
		and c.fiscal_year=v.fiscal_year
	where v.Standardizedvendorname is null 
		and sv.Standardizedvendorname is not null
		and c.fiscal_year is not null
	group by 	sv.StandardizedVendorName
		,c.fiscal_year
	
	-- Insert new FPDS vendoralternatename into StandardizedVendorNameHistory
	insert into vendor.standardizedvendornamehistory (standardizedvendorname, fiscal_year)
	select
		sv.StandardizedVendorName
		,c.fiscal_year
	from contract.fpds as C
	left outer join Vendor.VendorName sv
		on sv.vendorname=c.vendoralternatename
	left outer join Vendor.StandardizedVendorNameHistory as v
		on sv.Standardizedvendorname=v.Standardizedvendorname
		and c.fiscal_year=v.fiscal_year
	where v.Standardizedvendorname is null  and sv.Standardizedvendorname is not null
		and sv.Standardizedvendorname is not null
		and c.fiscal_year is not null
	group by 	sv.StandardizedVendorName
		,c.fiscal_year

	-- Insert new FPDS vendordoingasbusinessname into StandardizedVendorNameHistory
	insert into vendor.standardizedvendornamehistory (standardizedvendorname, fiscal_year)
	select
		sv.StandardizedVendorName
		,c.fiscal_year
	from contract.fpds as C
	left outer join Vendor.VendorName sv
		on sv.vendorname=c.vendordoingasbusinessname
	left outer join Vendor.StandardizedVendorNameHistory as v
		on sv.Standardizedvendorname=v.Standardizedvendorname
		and c.fiscal_year=v.fiscal_year
	where v.Standardizedvendorname is null 
		and sv.Standardizedvendorname is not null
		and c.fiscal_year is not null
	group by 	sv.StandardizedVendorName
		,c.fiscal_year

	-- Insert new FPDS vendorlegalorganizationname into StandardizedVendorNameHistory
	insert into vendor.standardizedvendornamehistory (standardizedvendorname, fiscal_year)
	select
		sv.StandardizedVendorName
		,c.fiscal_year
	from contract.fpds as C
	left outer join Vendor.VendorName sv
		on sv.vendorname=c.vendorlegalorganizationname
	left outer join Vendor.StandardizedVendorNameHistory as v
		on sv.Standardizedvendorname=v.Standardizedvendorname
		and c.fiscal_year=v.fiscal_year
	where v.Standardizedvendorname is null  
		and sv.Standardizedvendorname is not null
		and c.fiscal_year is not null
	group by 	sv.StandardizedVendorName
		,c.fiscal_year

	

	-- Insert new FPDS divisionname into StandardizedVendorNameHistory
	insert into vendor.standardizedvendornamehistory (standardizedvendorname, fiscal_year)
	select
		sv.StandardizedVendorName
		,c.fiscal_year
	from contract.fpds as C
	left outer join Vendor.VendorName sv
		on sv.vendorname=c.divisionname
	left outer join Vendor.StandardizedVendorNameHistory as v
		on sv.Standardizedvendorname=v.Standardizedvendorname
		and c.fiscal_year=v.fiscal_year
	where v.Standardizedvendorname is null  
		and sv.Standardizedvendorname is not null
		and c.fiscal_year is not null
	group by 	sv.StandardizedVendorName
		,c.fiscal_year

	-- Insert new mod_parent into StandardizedVendorNameHistory
	insert into vendor.standardizedvendornamehistory (standardizedvendorname, fiscal_year)
	select
		sv.StandardizedVendorName
		,c.fiscal_year
	from contract.fpds as C
	left outer join Vendor.VendorName sv
		on sv.vendorname=c.mod_parent
	left outer join Vendor.StandardizedVendorNameHistory as v
		on sv.Standardizedvendorname=v.Standardizedvendorname
		and c.fiscal_year=v.fiscal_year
	where v.Standardizedvendorname is null  
		and sv.Standardizedvendorname is not null
		and c.fiscal_year is not null
	group by 	sv.StandardizedVendorName
		,c.fiscal_year

		
	-- Insert new FAADS vendornames into StandardizedVendorNameHistory
	insert into vendor.standardizedvendornamehistory (standardizedvendorname, fiscal_year)
	select
		sv.StandardizedVendorName
		,g.fiscal_year
	from GrantLoanAssistance.faads as g
	left outer join Vendor.VendorName sv
		on sv.vendorname=g.recipient_name
	left outer join Vendor.StandardizedVendorNameHistory as v
		on sv.Standardizedvendorname=v.Standardizedvendorname
		and g.fiscal_year=v.fiscal_year
	where v.Standardizedvendorname is null  
		and sv.Standardizedvendorname is not null
		and g.fiscal_year is not null
	group by 	sv.StandardizedVendorName
		,g.fiscal_year
		
	-- Insert new USAID Phoenix vendornames into StandardizedVendorNameHistory
	insert into vendor.standardizedvendornamehistory (standardizedvendorname, fiscal_year)
	select
		sv.StandardizedVendorName
		,p.fy
	from assistance.usaidphoenix as p
	left outer join Vendor.VendorName sv
		on sv.vendorname=p.VENDOR_NAME
	left outer join Vendor.StandardizedVendorNameHistory as v
		on sv.Standardizedvendorname=v.Standardizedvendorname
		and p.FY=v.fiscal_year
	where v.Standardizedvendorname is null  
		and sv.Standardizedvendorname is not null
		and p.FY is not null
	group by sv.StandardizedVendorName
		,p.FY

	--Get the count of the number of filled in alternate names when the vendorname is unknown
	select
	count(*) as countofrows
	,sum(c.obligatedamount) as obligatedamount
	,sum(c.numberofactions) as numberoractions
	,name.isunknownvendorname as name_isunknownvendorname
	,legalorganizationname.isunknownvendorname as legalorganizationname_isunknownvendorname
	,doingasbusinessname.isunknownvendorname as doingasbusinessname_isunknownvendorname
	,alternatename.isunknownvendorname as alternatename_isunknownvendorname
	,divisionname.isunknownvendorname as divisionname_isunknownvendorname
	--,a.customer
	from contract.fpds as C
	--left outer join fpdstypetable.agencyid a
	--	on c.contractingofficeagencyid=a.agencyid
	left outer join Vendor.VendorName name
		on name.vendorname=c.vendorname
	left outer join Vendor.VendorName legalorganizationname
		on legalorganizationname.vendorname=c.vendorlegalorganizationname
	left outer join Vendor.VendorName doingasbusinessname
		on doingasbusinessname.vendorname=c.vendordoingasbusinessname
	left outer join Vendor.VendorName alternatename
		on alternatename.vendorname=c.vendoralternatename
	left outer join Vendor.VendorName divisionname
		on divisionname.vendorname=c.divisionname
	where isnull(name.isunknownvendorname,1)=1
	group by name.isunknownvendorname
	,legalorganizationname.isunknownvendorname
	,doingasbusinessname.isunknownvendorname
	,alternatename.isunknownvendorname
	,divisionname.isunknownvendorname
	--,a.customer

	--Get the actual values of alternate names when the vendorname is unknown
	select 
	name.isunknownvendorname as name_isunknownvendorname
	,c.vendorname
	,legalorganizationname.isunknownvendorname as legalorganizationname_isunknownvendorname
	,c.vendorlegalorganizationname
	,doingasbusinessname.isunknownvendorname as doingasbusinessname_isunknownvendorname
	,c.vendordoingasbusinessname
	,alternatename.isunknownvendorname as alternatename_isunknownvendorname
	,c.vendoralternatename
	,divisionname.isunknownvendorname as divisionname_isunknownvendorname
	,c.divisionname
	,sum(c.numberofactions)
	,sum(c.obligatedamount)
	from contract.fpds as C
	left outer join Vendor.VendorName name
		on c.vendorname=name.vendorname
	left outer join Vendor.VendorName legalorganizationname
		on c.vendorlegalorganizationname=legalorganizationname.vendorname
	left outer join Vendor.VendorName doingasbusinessname
		on c.vendordoingasbusinessname=doingasbusinessname.vendorname
	left outer join Vendor.VendorName alternatename
		on c.vendoralternatename=alternatename.vendorname
	left outer join Vendor.VendorName divisionname
		on c.divisionname=divisionname.vendorname
	where isnull(name.isunknownvendorname,1)=1
	group by name.isunknownvendorname 
	,c.vendorname
	,legalorganizationname.isunknownvendorname 
	,c.vendorlegalorganizationname
	,doingasbusinessname.isunknownvendorname 
	,c.vendordoingasbusinessname
	,alternatename.isunknownvendorname
	,c.vendoralternatename
	,divisionname.isunknownvendorname 
	,c.divisionname	





	--***********************ParentID updates

	-- Determine topISO3countrycode for any parentid 
	UPDATE pid
	set topISO3countrycode=plvc.topISO3countrycode
		, topISO3countrytotalamount=plvcp.MaxOfTotalAmount
		, totalamount = plvcp.sumoftotalamount
		,CSISmodifiedBy='Automated from of amounts and vendorcountry by ' +system_user
		,csismodifieddate=getdate()
	FROM Contractor.parentcontractor as pid
	inner join [Vendor].[ParentLocationVendorCountryPartial] as plvc
		on PID.parentid=plvc.parentid 
	INNER JOIN (
		SELECT 
			parentid
			, Sum(TotalAmount) AS SumOfTotalAmount
			, Max(TotalAmount) AS MaxOfTotalAmount
		FROM [Vendor].[ParentLocationVendorCountryPartial] 
			GROUP BY Parentid
	) as plvcp
	ON plvc.TotalAmount = plvcp.MaxOfTotalAmount
	--where dtpch.TotalAmount is null
	--where dtpch.StandardizedTopContractor is null
	where pid.topISO3countrycode is null and 
		plvcp.MaxOfTotalAmount/nullif(plvcp.sumoftotalamount,0)>0.90
		and not (
			pid.topISO3countrycode=plvc.topISO3countrycode
			and pid.topISO3countrytotalamount=plvcp.MaxOfTotalAmount
			and pid.totalamount = plvcp.sumoftotalamount
		)


	--Automated updates

	--Find parentids that could be moved over from the prior year. Only for last year
	declare @latestyear int
	set @latestyear =(select max(fiscalyear) from contractor.DunsnumberToParentContractorHistory)
	
	update dtpch1
--select
--	dtpch2.ParentID as NewParentID
--	,dtpch1.Parentdunsnumber
--	,min(dtpch1.FiscalYear) as MinOfFiscalYear
--	,max(dtpch1.FiscalYear) as MinOfFiscalYear
--	,dtpch1.DUNSnumber
--	,dtpch1.StandardizedTopContractor
--	,count(dtpch1.FiscalYear) as NumberOfEntries
--	,sum(dtpch1.ObligatedAmount) as ObligatedAmount
		set parentid=dtpch2.parentid
		,CSISmodifiedBy='Automated from prior year with matching standardized vendor name by ' +system_user
		,csismodifieddate=getdate()
	from contractor.DunsnumberToParentContractorHistory dtpch1
	inner join contractor.DunsnumberToParentContractorHistory dtpch2
		on dtpch1.DUNSnumber=dtpch2.DUNSnumber 
		and dtpch1.FiscalYear-1=dtpch2.FiscalYear
	left outer join vendor.StandardizedVendorParentIDHistoryNoContradictions svh
		on dtpch1.StandardizedTopContractor=svh.StandardizedTopContractor
		and dtpch1.FiscalYear=svh.FiscalYear
	left outer join vendor.StandardizedVendorParentIDNoContradictions sv
		on dtpch1.StandardizedTopContractor=sv.StandardizedTopContractor
	where dtpch1.parentid is null
		and dtpch2.parentid is not null
		and dtpch1.fiscalyear=@latestyear
		and ((dtpch1.StandardizedTopContractor <>''
		and case
		when len(dtpch1.StandardizedTopContractor)=len(dtpch2.StandardizedTopContractor)
			then iif(dtpch1.StandardizedTopContractor=dtpch2.StandardizedTopContractor,1,0)
		when len(dtpch1.StandardizedTopContractor)>len(dtpch2.StandardizedTopContractor)
			then iif(left(dtpch1.StandardizedTopContractor,len(dtpch2.StandardizedTopContractor))=dtpch2.StandardizedTopContractor,1,0)
		when len(dtpch1.StandardizedTopContractor)<len(dtpch2.StandardizedTopContractor)
			then iif(dtpch1.StandardizedTopContractor=left(dtpch2.StandardizedTopContractor,len(dtpch1.StandardizedTopContractor)),1,0)
	end=1) or svh.ParentID=dtpch2.ParentID
	or sv.ParentID=dtpch2.ParentID
	)

--	group by	dtpch2.ParentID 
--,dtpch1.Parentdunsnumber
--,dtpch1.DUNSnumber
--,dtpch1.StandardizedTopContractor
--	order by dtpch2.ParentID 
--,dtpch1.Parentdunsnumber
--,dtpch1.DUNSnumber
--,min(dtpch1.fiscalyear)
--,dtpch1.StandardizedTopContractor
		
	----Find parentids that could be moved over from the prior year. Only for last year
	--declare @firstyear int
	--set @firstyear=1990
	
	--update dtpch1
	--	set parentid=dtpch2.parentid
	--	,CSISmodifiedBy='Automated from prior year with matching standardized vendor name by ' +system_user
	--	,csismodifieddate=getdate()
	--from contractor.DunsnumberToParentContractorHistory dtpch1
	--inner join contractor.DunsnumberToParentContractorHistory dtpch2
	--on dtpch1.DUNSnumber=dtpch2.DUNSnumber and dtpch1.StandardizedTopContractor=dtpch2.StandardizedTopContractor
	--where dtpch1.FiscalYear=dtpch2.FiscalYear-1
	--	and dtpch1.parentid is null
	--	and dtpch2.parentid is not null
	--	and dtpch1.fiscalyear=@firstyear
	--	and case
	--	when len(dtpch1.StandardizedTopContractor)=len(dtpch2.StandardizedTopContractor)
	--		then iif(dtpch1.StandardizedTopContractor=dtpch2.StandardizedTopContractor,1,0)
	--	when len(dtpch1.StandardizedTopContractor)>len(dtpch2.StandardizedTopContractor)
	--		then iif(left(dtpch1.StandardizedTopContractor,len(dtpch2.StandardizedTopContractor))=dtpch2.StandardizedTopContractor,1,0)
	--	when len(dtpch1.StandardizedTopContractor)<len(dtpch2.StandardizedTopContractor)
	--		then iif(dtpch1.StandardizedTopContractor=left(dtpch2.StandardizedTopContractor,len(dtpch1.StandardizedTopContractor)),1,0)
	--	end=1


	--***************************************13 and 9 digit dunsnumbers
	-- Create 9 digit versions of dunsnumbers that are shorter or longer than 9 digits
update contractor.dunsnumber
set CECtext9digit=right('000000000'+left(dunsnumber,len(dunsnumber)-4),9)
where (len(CECtext9digit)<>9 or right(dunsnumber,4)='0000' )
	and CECtext9digit is null
	and dunsnumber is not null

	-- Create versions of dunsnumbers without leading zeros 
update contractor.dunsnumber
set CECnoleadingzero = SUBSTRING(CECtext9digit, PATINDEX('%[^0]%', CECtext9digit+'.'), LEN(CECtext9digit))
where CECtext9digit is not null and CECnoleadingzero is null 
--Source for leading zero remover: http://stackoverflow.com/questions/662383/better-techniques-for-trimming-leading-zeros-in-sql-server/662437#662437

--Transfer parentids from dunsnumbers without leading zeros to those with
update dtpch
set parentid=dtpch2.parentid
	,CSISmodifiedBy='Automated update dunsnumber w/o leading zeros by ' +system_user
	,csismodifieddate=getdate()
from contractor.DunsnumberToParentContractorHistory as dtpch
inner join contractor.Dunsnumber as d
	on d.CECnoleadingzero=dtpch.dunsnumber
inner join contractor.DunsnumberToParentContractorHistory as dtpch2
	on dtpch2.DUNSnumber=d.dunsnumber and dtpch.fiscalyear=dtpch2.fiscalyear
where dtpch.parentid is null and dtpch2.parentid is not null


--Transfer parentids from dunsnumbers that are not 9 characters to those that are
update dtpch
set parentid=dtpch2.parentid
	,CSISmodifiedBy='Automated update dunsnumber w/ leading zeros by ' +system_user
	,csismodifieddate=getdate()
from contractor.DunsnumberToParentContractorHistory as dtpch
inner join contractor.Dunsnumber as d
on d.CECtext9digit=dtpch.dunsnumber
inner join contractor.DunsnumberToParentContractorHistory as dtpch2
	on dtpch2.DUNSnumber=d.dunsnumber and dtpch.fiscalyear=dtpch2.fiscalyear
where dtpch.parentid is null and dtpch2.parentid is not null

--******************************Automate updates based on parentdunsnumbers or headquartercodes





--Update dunsnumbertoparentid based on uncontroversial parentdunsnumber with standardizedtopcontractor match
update dtpch
set 
--select
--parentdtpch.ParentID as NewParentID
--,dtpch.Parentdunsnumber
--,min(dtpch.FiscalYear) as MinOfFiscalYear
--,max(dtpch.FiscalYear) as MinOfFiscalYear
--,dtpch.DUNSnumber
--,dtpch.StandardizedTopContractor
--,count(dtpch.FiscalYear) as NumberOfEntries
--,sum(dtpch.ObligatedAmount) as ObligatedAmount
ParentID=parentdtpch.parentid
	,CSISmodifiedBy='Automated update by parentdunsnumber by ' +system_user
	,csismodifieddate=getdate()
from contractor.DunsnumberToParentContractorHistory as dtpch
left outer join contractor.parentcontractor as dp
on dtpch.ParentID=dp.ParentID
inner join contractor.dunsnumber as dunsnumber
	on dtpch.dunsnumber=dunsnumber.dunsnumber 
inner join contractor.DunsnumberToParentContractorHistory as parentdtpch
	on dunsnumber.parentdunsnumber=parentdtpch.dunsnumber 
		 and dtpch.fiscalyear=parentdtpch.fiscalyear 
inner join  contractor.parentcontractor as parentdunsp
	on parentdtpch.ParentID=parentdunsp.ParentID
inner join Vendor.VendorName as StandardizedParent
	on parentdunsp.ParentID=StandardizedParent.vendorname
left outer join vendor.StandardizedVendorParentIDHistoryNoContradictions svh
	on dtpch.StandardizedTopContractor=svh.StandardizedTopContractor
	and dtpch.FiscalYear=svh.FiscalYear
left outer join vendor.StandardizedVendorParentIDNoContradictions sv
	on dtpch.StandardizedTopContractor=sv.StandardizedTopContractor
where (dtpch.parentid is null or 
		((dtpch.fiscalyear>=dp.mergeryear
		or dtpch.fiscalyear<dp.FirstYear)
		and dtpch.parentid<>parentdtpch.parentid))
		and (dunsnumber.ignorebeforeyear is null or dunsnumber.ignorebeforeyear is null)
	and parentdtpch.parentid is not null 
	and ((dtpch.StandardizedTopContractor <>'' and
		case
		when len(dtpch.StandardizedTopContractor)=len(StandardizedParent.standardizedvendorname)
			then iif(dtpch.StandardizedTopContractor=StandardizedParent.standardizedvendorname,1,0)
		when len(dtpch.StandardizedTopContractor)>len(StandardizedParent.standardizedvendorname)
			then iif(left(dtpch.StandardizedTopContractor,len(StandardizedParent.standardizedvendorname))=StandardizedParent.standardizedvendorname,1,0)
		when len(dtpch.StandardizedTopContractor)<len(StandardizedParent.standardizedvendorname)
			then iif(dtpch.StandardizedTopContractor=left(StandardizedParent.standardizedvendorname,len(dtpch.StandardizedTopContractor)),1,0)
	end=1)
	or sv.ParentID=parentdtpch.ParentID
	or svh.ParentID=parentdtpch.ParentID
	)

	
----Update dunsnumbertoparentid based on headquartercode with standardizedtopcontractor match
update dtpch
set ParentID=parentdtpch.parentid
	,CSISmodifiedBy='Automated update by headquartercode by ' +system_user
	,csismodifieddate=getdate()
from contractor.DunsnumberToParentContractorHistory as dtpch
left outer join contractor.parentcontractor as dp
on dtpch.ParentID=dp.ParentID
inner join contractor.dunsnumber as dunsnumber
	on dtpch.dunsnumber=dunsnumber.dunsnumber 
inner join contractor.DunsnumberToParentContractorHistory as parentdtpch
	on (dunsnumber.HeadquarterCode=parentdtpch.dunsnumber 
	or (dunsnumber.HeadquarterCode is null and dtpch.HeadquarterCode=parentdtpch.dunsnumber)) 
		and dtpch.fiscalyear=parentdtpch.fiscalyear 
		and (dunsnumber.ignorebeforeyear is null or dunsnumber.ignorebeforeyear<dtpch.FiscalYear)
inner join  contractor.parentcontractor as parentdunsp
	on parentdtpch.ParentID=parentdunsp.ParentID
left outer join Vendor.VendorName as StandardizedParent
	on parentdunsp.ParentID=StandardizedParent.vendorname
left outer join vendor.StandardizedVendorParentIDHistoryNoContradictions svh
	on dtpch.StandardizedTopContractor=svh.StandardizedTopContractor
	and dtpch.FiscalYear=svh.FiscalYear
left outer join vendor.StandardizedVendorParentIDNoContradictions sv
	on dtpch.StandardizedTopContractor=sv.StandardizedTopContractor
where (dtpch.parentid is null or 
		((dtpch.fiscalyear>=dp.mergeryear
		or dtpch.fiscalyear<dp.FirstYear)
		and dtpch.parentid<>parentdtpch.parentid))
	and parentdtpch.parentid is not null 
	and ((dtpch.StandardizedTopContractor <>'' and
		case
		when len(dtpch.StandardizedTopContractor)=len(StandardizedParent.standardizedvendorname)
			then iif(dtpch.StandardizedTopContractor=StandardizedParent.standardizedvendorname,1,0)
		when len(dtpch.StandardizedTopContractor)>len(StandardizedParent.standardizedvendorname)
			then iif(left(dtpch.StandardizedTopContractor,len(StandardizedParent.standardizedvendorname))=StandardizedParent.standardizedvendorname,1,0)
		when len(dtpch.StandardizedTopContractor)<len(StandardizedParent.standardizedvendorname)
			then iif(dtpch.StandardizedTopContractor=left(StandardizedParent.standardizedvendorname,len(dtpch.StandardizedTopContractor)),1,0)
	end=1)
	or sv.ParentID=parentdtpch.ParentID
	or svh.ParentID=parentdtpch.ParentID
	)

--Update Vendor.Vendorname when the standardizedvendorname to parentid assignment is uncontroversial
update v
set parentid = s.ParentID
	--,CSISmodifiedBy='Automated update by ' +system_user
	--,csismodifieddate=getdate()
from Vendor.VendorName as v
inner join Vendor.StandardizedVendorParentIDNoContradictions as s
on s.StandardizedTopContractor=v.VendorName
where v.parentid is null and s.ParentID is not null and s.ParentIDnameMatch=1

--Update dunsnumbertoparentid when standardizedvendorname has an uncontroversial parentid in Vendor.VendorName
update dtpch
set dtpch.parentid=v.parentid
	,CSISmodifiedBy='Automated update uncontroversial standardizedvendorname by ' +system_user
	,csismodifieddate=getdate()
from contractor.DunsnumberToParentContractorHistory as dtpch
inner join Vendor.VendorName as v
on dtpch.standardizedtopcontractor = v.vendorname
where v.parentid is not null 
	and dtpch.parentid is null 
	and dtpch.StandardizedTopContractor <>''



--Update dunsnumbertoparentid using standardized vendor name when the parentid assignment is uncontroversial for that year
update dtpch
set ParentID=h.ParentID
	,CSISmodifiedBy='Automated update uncontroversial standardizedvendorname & fiscal_year by ' +system_user
	,csismodifieddate=getdate()
from contractor.DunsnumberToParentContractorHistory as dtpch
inner join Vendor.StandardizedVendorParentIDhistoryNoContradictions as h
on dtpch.StandardizedTopContractor=h.StandardizedTopContractor
	and dtpch.FiscalYear=h.FiscalYear
where dtpch.parentid is null 
	and h.ParentID is not null 
	and h.ParentIDnameMatch=1
	and dtpch.StandardizedTopContractor <>''


--List dunsnumber rollup counts
select fiscalyear
,sum(iif(len(dtpch.dunsnumber)<=9 and dtpch.parentid is not null,1,0)) as AssignedDunsnumbers
,sum(iif(len(dtpch.dunsnumber)<=9,1,0)) as TotalDunsnumbers
,sum(iif(len(dtpch.dunsnumber)<=9 and dtpch.parentid is not null,dtpch.obligatedamount,0)) as DunsnumberObligated
,sum(iif(len(dtpch.dunsnumber)<=9,dtpch.obligatedamount,0)) as TotalObligated
,sum(iif(len(dtpch.dunsnumber)<=9 and dtpch.parentid is not null,dtpch.fed_funding_amount,0)) as fed_funding_amount
,sum(iif(len(dtpch.dunsnumber)<=9,dtpch.fed_funding_amount,0)) as Totalfed_funding_amount
,max(iif(len(dtpch.dunsnumber)<=9 and dtpch.parentid is null,dtpch.obligatedamount,0)) as MaxOfDunsnumberUnlabeledObligated
,sum(iif(len(dtpch.dunsnumber)<=9 and dtpch.parentid is null and dtpch.obligatedamount>=250000000,1,0)) as CountOfDunsnumberUnlabeledOver250M
from contractor.DunsnumberToParentContractorHistory as dtpch
group by fiscalyear






END










GO
