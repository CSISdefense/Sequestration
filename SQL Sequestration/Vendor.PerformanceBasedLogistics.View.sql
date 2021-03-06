USE [DIIG]
GO
/****** Object:  View [Vendor].[PerformanceBasedLogistics]    Script Date: 3/16/2017 12:26:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















CREATE VIEW [Vendor].[PerformanceBasedLogistics]
AS


select f.fiscal_year
,a.Customer
,a.SubCustomer
,p.performancebasedservicecontractText
,p.isperformancebasedcontract
,psc.ServicesCategory
,psc.ProductOrServiceCode
,isnull(ccid.IsPerformanceBasedLogistics,ciid.IsPerformanceBasedLogistics) as isperformancebasedlogistics
,ccid.IsPerformanceBasedLogistics as idvIsPerformanceBasedLogistics
,ciid.IsPerformanceBasedLogistics as piidIsPerformanceBasedLogistics

, isnull(parent.parentid,f.dunsnumber) AS AllContractor
	, parent.parentid
	, Max(IIf(f.contractingofficerbusinesssizedetermination='S' 
		And Not (parent.largegreaterthan3B=1 Or parent.Largegreaterthan3B=1)
		,1
		,0)) AS Small
	, Parent.jointventure

,sum(f.obligatedamount) as ObligatedAmount
from contract.fpds f
left outer join FPDSTypeTable.ProductOrServiceCode psc
on f.productorservicecode=psc.ProductOrServiceCode
left outer join FPDSTypeTable.AgencyID a
on f.contractingofficeagencyid=a.AgencyID
left outer join FPDSTypeTable.[performancebasedservicecontract] p
on f.performancebasedservicecontract=p.performancebasedservicecontract
inner join contract.CSIStransactionID ctid
on f.CSIStransactionID=ctid.CSIScontractID
inner join contract.CSIScontractID ccid
on ctid.CSIScontractID=ccid.CSIScontractID
inner join contract.CSISidvpiidID ciid
on ccid.CSISidvpiidID=ciid.CSISidvpiidID
	LEFT JOIN Contractor.DunsnumberToParentContractorHistory as Dunsnumber
			ON f.DUNSNumber=Dunsnumber.DUNSNUMBER
			AND f.fiscal_year=Dunsnumber.FiscalYear 
		LEFT JOIN Contractor.ParentContractor as Parent
			ON Dunsnumber.ParentID=Parent.ParentID

where a.Customer='Defense' 
group by f.fiscal_year
,a.Customer
,a.SubCustomer
,p.performancebasedservicecontractText
,psc.ServicesCategory
,psc.ProductOrServiceCode
,isnull(ccid.IsPerformanceBasedLogistics,ciid.IsPerformanceBasedLogistics)
,ccid.IsPerformanceBasedLogistics
,ciid.IsPerformanceBasedLogistics

,p.isperformancebasedcontract
,isnull(parent.parentid,f.dunsnumber) 
	, parent.parentid
	, IIf(f.contractingofficerbusinesssizedetermination='S' 
		And Not (parent.largegreaterthan3B=1 Or parent.Largegreaterthan3B=1)
		,1
		,0)
	, Parent.jointventure



--SELECT 
--F.fiscal_year
--,Max(getDate()) AS Query_Run
--,A.Customer
--,A.SubCustomer
--,PSC.ServicesCategory
--,F.typeofsetaside
--,f.firm8aflag AS Firm8A
--,f.hubzoneflag AS HUBZone
--,f.minorityownedbusinessflag AS MinorityOwned
--, CASE
--	WHEN f.saaobflag = 'Y'
--	THEN 'South Asian American Owned'
--	WHEN f.apaobflag ='Y'
--	THEN 'Asian-Pacific American Owned'
--	WHEN f.baobflag = 'Y'
--	THEN 'Black American Owned'
--	WHEN f.haobflag = 'Y'
--	THEN 'Hispanic American Owned'
--	WHEN isotherminorityowned =1
--	THEN 'Other Minority Owned'
--	ELSE 'No Set Aside'
--  END AS MinoritySetAside
--, CASE
--	WHEN f.sdbflag = 'Y' OR f.issbacertifiedsmalldisadvantagedbusiness = 1
--	THEN 'Small Disadvantaged Business'
--	ELSE 'No Set Aside'
--  END AS SmallDisadvantagedBusiness
--, CASE
--	WHEN isalaskannativeownedcorporationorfirm = 1
--	THEN 'Alaskan Native Owned'
--	WHEN F.isnativehawaiianownedorganizationorfirm = 1 
--	THEN 'Native Hawaiian Owned'
--	WHEN f.istriballyownedfirm = 1 OR f.isindiantribe =1 OR f.naobflag ='Y'
--	THEN 'Native American Owned'
--	ELSE 'No Set Aside'
--  END AS NativeGroupOwned
--, CASE
--	WHEN f.womenownedflag ='Y' OR f.iswomenownedsmallbusiness =1 OR f.isecondisadvwomenownedsmallbusiness =1
--	THEN 'Woman Owned'
--	ELSE 'No Set Aside'
--  END AS WomanOwned
--, CASE
--	WHEN f.srdvobflag ='Y' 
--	THEN 'Service-Disabled Veteran Owned'
--	WHEN f.veteranownedflag = 'Y'
--	THEN 'Veteran Owned'
--	ELSE 'No Set Aside'
--  END AS VeteranOwned
--,sum(f.obligatedamount) AS SubOfObligatedAmount

--FROM Contract.FPDS AS F
--LEFT JOIN FPDSTypeTable.AgencyID AS A
--On A.AgencyID = F.contractingofficeagencyid
--LEFT JOIN FPDSTypeTable.ProductOrServiceCode AS PSC
--on PSC.ProductOrServiceCode = F.productorservicecode

--GROUP BY
--F.fiscal_year
--,A.Customer
--,A.SubCustomer
--,PSC.ServicesCategory
--,F.typeofsetaside
--,f.firm8aflag 
--,f.hubzoneflag 
--,f.minorityownedbusinessflag 
--, CASE
--	WHEN f.saaobflag = 'Y'
--	THEN 'South Asian American Owned'
--	WHEN f.apaobflag ='Y'
--	THEN 'Asian-Pacific American Owned'
--	WHEN f.baobflag = 'Y'
--	THEN 'Black American Owned'
--	WHEN f.haobflag = 'Y'
--	THEN 'Hispanic American Owned'
--	WHEN isotherminorityowned =1
--	THEN 'Other Minority Owned'
--	ELSE 'No Set Aside'
--  END 
--, CASE
--	WHEN f.sdbflag = 'Y' OR f.issbacertifiedsmalldisadvantagedbusiness = 1
--	THEN 'Small Disadvantaged Business'
--	ELSE 'No Set Aside'
--  END 
--, CASE
--	WHEN isalaskannativeownedcorporationorfirm = 1
--	THEN 'Alaskan Native Owned'
--	WHEN F.isnativehawaiianownedorganizationorfirm = 1 
--	THEN 'Native Hawaiian Owned'
--	WHEN f.istriballyownedfirm = 1 OR f.isindiantribe =1 OR f.naobflag ='Y'
--	THEN 'Native American Owned'
--	ELSE 'No Set Aside'
--  END 
--, CASE
--	WHEN f.womenownedflag ='Y' OR f.iswomenownedsmallbusiness =1 OR f.isecondisadvwomenownedsmallbusiness =1
--	THEN 'Woman Owned'
--	ELSE 'No Set Aside'
--  END 
--, CASE
--	WHEN f.srdvobflag ='Y' 
--	THEN 'Service-Disabled Veteran Owned'
--	WHEN f.veteranownedflag = 'Y'
--	THEN 'Veteran Owned'
--	ELSE 'No Set Aside'
--  END 





GO
