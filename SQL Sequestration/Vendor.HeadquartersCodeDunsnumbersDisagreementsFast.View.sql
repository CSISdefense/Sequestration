USE [DIIG]
GO
/****** Object:  View [Vendor].[HeadquartersCodeDunsnumbersDisagreementsFast]    Script Date: 3/16/2017 12:26:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Vendor].[HeadquartersCodeDunsnumbersDisagreementsFast]
AS

SELECT
	--case
	--	when DtPCH.Parentdunsnumber is null
	--	then 'No ParentDunsnumber'
	--	when isnull(ParentDUNSonlyParentID.parentID,ParentDUNShistoryParentID.parentID) is null
	--	then 'ParentDuns ParentID is NULL'
	--	when isnull(ParentDUNSonlyParentID.parentID,ParentDUNShistoryParentID.parentID) is not null and dtpch.parentid is null
	--	then 'ParentID is NULL, ParentDuns is not'
	--	when dtpch.parentid<>ParentDUNSonlyParentID.parentID 
	--	then iif(ParentDUNSonlyOwner.parentid is null or
	--		dtpch.fiscalyear<ParentDUNSonlyParentID.MergerYear,
	--		'ParentDunsOverall Contradiction' 
	--		,'ParentDunsOverall Subsidiary Match' 
	--		)
	--	when dtpch.parentid<>ParentDUNShistoryParentID.parentID 
	--	then iif(ParentDUNShistoryOwner.parentid is null or
	--		dtpch.fiscalyear<ParentDUNShistoryParentID.MergerYear,
	--		'ParentDunsHistory Contradiction'
	--		,'ParentDunsHistory Subsidiary Match' 
	--		)

	--	when dtpch.parentid=isnull(ParentDUNSonlyParentID.parentID,ParentDUNShistoryParentID.parentID)
	--	then 'ParentDuns Match'
	--	else 'ERROR'
	--end as ParentDUNSStatus
	--,
		case
		when DtPCH.HeadquarterCode is null
		then 'No HeadquartersCode'
		when isnull(HQcodeonlyParentID.parentID,HQcodehistoryParentID.parentID) is null
		then 'HQcode ParentID is NULL'
		when isnull(HQcodeonlyParentID.parentID,HQcodehistoryParentID.parentID) is not null and dtpch.parentid is null
		then 'ParentID is NULL, HQcode is not'
		when dtpch.parentid<>HQcodeonlyParentID.parentID 
		then iif(HQcodeonlyOwner.parentid is null or
			dtpch.fiscalyear<HQcodeonlyParentID.MergerYear,
			'HQcodeOverall Contradiction' 
			,'HQcodeOverall Subsidiary Match' 
			)
		when dtpch.parentid<>HQcodehistoryParentID.parentID 
		then iif(HQcodehistoryOwner.parentid is null or
			dtpch.fiscalyear<HQcodehistoryParentID.MergerYear,
			'HQcodeHistory Contradiction'
			,'HQcodeHistory Subsidiary Match' 
			)

		when dtpch.parentid=isnull(HQcodeonlyParentID.parentID,HQcodehistoryParentID.parentID)
		then 'HQcode Match'
		else 'ERROR'
	end as HQcodeStatus
	,dtpch.fiscalyear
	, dtpch.obligatedAmount/1000000000/def.GDPdeflator AS ConstantObligatedBillions
	, dtpch.DUNSNumber
	, dtpch.StandardizedTopContractor
	, dtpch.parentid
	--, isnull(ParentDUNSonlyParentID.parentID,ParentDUNShistoryParentID.parentID) as ParentDunsParentID
	, dtpch.Parentdunsnumber 
	--, isnull(ParentDunsOnly.StandardizedTopContractor,ParentDunsHistory.StandardizedTopContractor) as ParentDunsStandardizedTopContractor
	, dunsnumber.ignorebeforeyear as ParentDunsIgnoreBeforeYear
	--, isnull(ParentDUNSonlyParentID.firstyear,ParentDUNShistoryParentID.firstyear) as ParentDunsFirstYear
		, isnull(HQcodeonly.parentID,HQcodehistory.parentID) as HQcodeParentID
	, dtpch.HeadquarterCode 
	, isnull(HQcodeOnly.StandardizedTopContractor,HQcodeHistory.StandardizedTopContractor) as HQcodeStandardizedTopContractor
	, dunsnumber.ignorebeforeyear as HQcodeIgnoreBeforeYear
	--, isnull(HQcodeonlyParentID.firstyear,HQcodehistoryParentID.firstyear) as HQcodeFirstYear
	, parent.jointventure
	, parent.MergerYear
	, parent.MergerDate
	
	, parent.FirstYear
	, parent.SpunOffFrom
FROM 
	contractor.DunsnumberToParentContractorHistory as DtPCH 
	--Dunsnumber Parent
	LEFT Outer JOIN contractor.ParentContractor as Parent
		ON dtpch.Parentid = parent.parentid
	--Other info about the dunsnumber
	left outer join contractor.dunsnumber as dunsnumber
		on dtpch.dunsnumber=dunsnumber.dunsnumber 
	--Deflators
	Left outer join Economic.Deflators as def
		on DtPCH.FiscalYear=def.Fiscal_Year

		--ParentDUNS
	--left outer join contractor.DunsnumberToParentContractorHistory as ParentDunsOnly
	--	on ParentDunsOnly.dunsnumber =dunsnumber.parentdunsnumber
	--	and ParentDunsOnly.fiscalyear =dtpch.fiscalyear
	--	and (dunsnumber.ignorebeforeyear is null or dunsnumber.ignorebeforeyear<dtpch.FiscalYear)
	--left outer join contractor.parentcontractor as ParentDUNSonlyParentID
	--	on ParentDUNSonlyParentID.parentid =ParentDunsOnly.parentid
	--	and dunsnumber.ParentdunsnumberFirstFiscalYear>=DtpCH.fiscalyear
	--left outer join Vendor.ParentIDtoOwnerParentID ParentDUNSonlyOwner
	--	on ParentDUNSonlyOwner.OwnerParentID=ParentDUNSonlyParentID.parentid
	--	and dtpch.ParentID=ParentDUNSonlyOwner.parentid
	--left outer join contractor.DunsnumberToParentContractorHistory as ParentDunsHistory
	--	on ParentDunsHistory.dunsnumber =dtpch.parentdunsnumber
	--	and ParentDunsHistory.fiscalyear =dtpch.fiscalyear
	--		and (dunsnumber.ignorebeforeyear is null or dunsnumber.ignorebeforeyear<dtpch.FiscalYear)
	--left outer join contractor.parentcontractor as ParentDUNShistoryParentID
	--	on ParentDUNShistoryParentID.parentid=ParentDunsHistory.parentid
	--left outer join Vendor.ParentIDtoOwnerParentID ParentDUNShistoryOwner
	--	on ParentDUNShistoryOwner.OwnerParentID=ParentDUNShistoryParentID.parentid
	--	and dtpch.ParentID=ParentDUNShistoryOwner.parentid

	--	--HeadquartersCode
	left outer join contractor.DunsnumberToParentContractorHistory as HQcodeOnly
		on HQcodeOnly.dunsnumber =dunsnumber.Headquartercode
		and HQcodeOnly.fiscalyear =dtpch.fiscalyear
		and (dunsnumber.ignorebeforeyear is null or dunsnumber.ignorebeforeyear<dtpch.FiscalYear)
	left outer join contractor.parentcontractor as HQcodeonlyParentID
		on HQcodeonlyParentID.parentid =HQcodeOnly.parentid
		and dunsnumber.HeadquarterCodeFirstFiscalYear>=DtpCH.fiscalyear
	left outer join Vendor.ParentIDtoOwnerParentID HQcodeonlyOwner
		on HQcodeonlyOwner.OwnerParentID=HQcodeonlyParentID.parentid
		and dtpch.ParentID=HQcodeonlyOwner.parentid
	left outer join contractor.DunsnumberToParentContractorHistory as HQcodeHistory
		on HQcodeHistory.dunsnumber =dtpch.HeadquarterCode
		and HQcodeHistory.fiscalyear =dtpch.fiscalyear
			and (dunsnumber.ignorebeforeyear is null or dunsnumber.ignorebeforeyear<dtpch.FiscalYear)
	left outer join contractor.parentcontractor as HQcodehistoryParentID
		on HQcodehistoryParentID.parentid=HQcodeHistory.parentid
	left outer join Vendor.ParentIDtoOwnerParentID HQcodehistoryOwner
		on HQcodehistoryOwner.OwnerParentID=HQcodehistoryParentID.parentid
		and dtpch.ParentID=HQcodehistoryOwner.parentid


--where 
	
--	(isnull(dtpch.parentdunsnumber,dunsnumber.parentdunsnumber) is not null 
--		and isnull(dtpch.parentid,'** Blank')<>isnull(ParentDUNSonlyParentID.parentID,ParentDUNShistoryParentID.parentID)
--		and (dtpch.fiscalyear>=isnull(ParentDUNSonlyParentID.firstyear,ParentDUNShistoryParentID.firstyear) 
--			or isnull(ParentDUNSonlyParentID.firstyear,ParentDUNShistoryParentID.firstyear) is null)
--		and not(parent.overrideparentdunsnumber=1)
--		)
--	and not(parent.UnknownCompany=1)







	 
















GO
