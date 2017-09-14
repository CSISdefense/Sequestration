USE [DIIG]
GO

/****** Object:  View [Vendor].[FSRSinFPDSVendorSizeHistorySubCustomerBucketPlatform]    Script Date: 9/1/2017 4:57:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER View [Vendor].[FSRSinFPDSVendorSizeHistorySubCustomerBucketPlatform]
as 

  select c.fiscal_year
  ,Agency.Customer 
  ,Agency.SubCustomer 
  ,psc.ProductOrServiceArea
 ,psc.Simple
  ,coalesce(proj.PlatformPortfolio
	, Agency.PlatformPortfolio
	, cpc.PlatformPortfolio
	, psc.platformPortfolio) as platformPortfolio

 ,F.typeofcontractpricingtext
    ,NULL as IsSomeCompetition
   ,NULL as NumberOfOffersReceived
 ,0 as IsSubContract
 , CASE
		WHEN Parent.Top6=1 and Parent.JointVenture=1
		THEN 'Large: Big 5 JV'
		WHEN Parent.Top6=1
		THEN 'Large: Big 5'
		WHEN Parent.IsPreTop6=1
		THEN 'Large: Pre-Big 5'
		WHEN Parent.LargeGreaterThan3B=1
		THEN 'Large'
		WHEN Parent.LargeGreaterThan1B=1
		THEN 'Medium >1B'
		--WHEN C.contractingofficerbusinesssizedetermination='s' or C.contractingofficerbusinesssizedetermination='y'
		--THEN 'Small'
		WHEN pch.AlwaysIsSmall =1 
		THEN 'Always Small'
		when Parent.UnknownCompany=1
		Then 'Unlabeled'
		WHEN pch.AnyIsSmall =1 
		THEN 'Sometimes Small'
		ELSE 'Medium <1B'
	END AS VendorSize	
  ,c.obligatedamount as PrimeObligatedAmount
  ,c.numberofactions as PrimeNumberOfActions
  ,NULL as SubawardAmount
  ,c.obligatedamount as PrimeOrSubObligatedAmount
 ,ctid.CSIScontractID
  ,iif(p.CSIScontractID is not null, 1,0) as IsInFSRS
  ,iif(cd.SumOfUnmodifiedbaseandalloptionsvalue >=fth.Threshold or
  cd.SumofObligatedAmount >=fth.Threshold,1,0) as IsFSRSreportable
  from contract.fpds as c
  --(

  --SELECT        C.fiscal_year, 
		--	GETDATE() AS Query_Run_Date, 
		--	ISNULL(Agency.Customer, Agency.AgencyIDtext) AS Customer,
		--	PSC.ServicesCategory,
		--	PSC.IsService,
		--	PSC.Simple,
		--	PSC.ProductOrServiceCode,
		--	PSC.ProductOrServiceCodeText,
		--	coalesce(proj.PlatformPortfolio, Agency.PlatformPortfolio, cpc.PlatformPortfolio, psc.platformPortfolio) as platformPortfolio,
		--	PSC.ProductOrServiceArea,
		--	SYS.systemequipmentcode,
		--	SYS.systemequipmentcodeText,
		--	state.statecode,
		--	Agency.SubCustomer, 
		--	mcid.majorcommandid,
		--	mcid.ContractingOfficeID,
		--	mcid.ContractingOfficeName,
		--	CountryCode.Region,
		--	CountryCode.Country3LetterCodeText,
		--	notcompeted.isfollowontocompetedaction,
		--	notcompeted.is6_302_1exception,
		--	notcompeted.reasonnotcompetedText,
		--	notcompeted.isfollowontocompetedaction as ReasonNotisfollowontocompetedaction,
		--	competed.IsOnlyOneSource as ExtentIsOnlyOneSource,
		--	competed.IsFullAndOpen as ExtentIsFullAndOpen,
		--	competed.IsSomeCompetition as ExtentIsSomeCompetition,
		--	Fairopp.isfollowontocompetedaction as FairIsfollowontocompetedaction,
		--	Fairopp.isonlyonesource as FairIsonlyonesource,
		--	Fairopp.IsSomeCompetition as FairIsSomeCompetition,
		--	Fairopp.statutoryexceptiontofairopportunityText,
		--	setaside.typeofsetaside2category
  --          ,c.numberofoffersreceived 
		--	,CASE 
		--		--Award or IDV Type show only (‘Definitive Contract’, ‘IDC’, ‘Purchase Order’)
		--		WHEN ctype.ForAwardUseExtentCompeted=1
		--		then 0 --Use extent competed
		--		--Award or IDV Type show only (‘Delivery Order’, ‘BPA Call’)
		--		--IDV Part 8 or Part 13 show only (‘Part 13’)
		--		--When  **Part 8 or Part 13  is not available!**
		--		--then 0 --Use extent competed

		--		--Award or IDV Type show only (‘Delivery Order’)
		--		--IDV Multiple or Single Award IDV show only (‘S’)
		--		when ctype.isdeliveryorder=1
		--			and isnull(IDVmulti.ismultipleaward, Cmulti.ismultipleaward) =0
		--		then 0
				
		--		--Fair Opportunity / Limited Sources show only (‘Fair Opportunity Given’)
		--		--Award or IDV Type show only (‘Delivery Order’)
		--		--IDV Type show only (‘FSS’, ‘GWAC’, ‘IDC’)
		--		--	IDV Multiple or Single Award IDV show only (‘M’)
		--		when idvtype.ForIDVUseFairOpportunity=1 and 
		--			ctype.isdeliveryorder=1 and 
		--			isnull(IDVmulti.ismultipleaward, Cmulti.ismultipleaward) =1
		--		then 1 --Use fair opportunity

		--		--	Number of Offers Received show only (‘1’)
		--		-- Award or IDV Type show only (‘BPA Call’, ‘BPA’)
		--		-- Part 8 or Part 13 show only (‘Part 8’)
		--		--When  **Part 8 or Part 13  is not available!**
		--		--then 0 --Use extent competed

		--		when fairopp.statutoryexceptiontofairopportunitytext is not null
		--		then 1
		--		else 0
		--	end as UseFairOpportunity,
		--	--SUM(C.obligatedamount) AS SumOfobligatedAmount,  
		--	--SUM(C.numberofactions) AS SumOfnumberOfActions
		--	C.obligatedamount,
		--	C.numberofactions


--FROM            Contract.FPDS AS C
--	LEFT OUTER JOIN FPDSTypeTable.ProductOrServiceCode AS PSC 
--		ON C.productorservicecode = PSC.ProductorServiceCode 
--		left outer join FPDSTypeTable.ClaimantProgramCode  as cpc on cpc.ClaimantProgramCode=c.claimantprogramcode
----Block of office joincs
--	LEFT OUTER JOIN FPDSTypeTable.AgencyID AS Agency 
--		ON C.contractingofficeagencyid = Agency.AgencyID 
--	left outer join office.ContractingAgencyIDofficeIDtoMajorCommandIDhistory as mcid
--		on c.contractingofficeagencyid=mcid.contractingagencyid and
--		c.contractingofficeid=mcid.contractingofficeid and
--		c.fiscal_year=mcid.fiscal_year
----Other joins
--	LEFT OUTER JOIN FPDSTypeTable.TypeOfSetAside AS SetAside 
--		ON C.typeofsetaside = SetAside.TypeOfSetAside 
--	LEFT OUTER JOIN FPDSTypeTable.extentcompeted AS Competed 
--		ON C.extentcompeted = Competed.extentcompeted 
--	LEFT OUTER JOIN FPDSTypeTable.ReasonNotCompeted AS NotCompeted 
--		ON C.reasonnotcompeted = NotCompeted.reasonnotcompeted 
--	LEFT OUTER JOIN FPDSTypeTable.Country3lettercode as CountryCode 
--		ON (C.placeofperformancecountrycode=CountryCode.Country3LetterCode)
--	LEFT OUTER JOIN FPDSTypeTable.statutoryexceptiontofairopportunity as FairOpp 
--		ON C.statutoryexceptiontofairopportunity=FAIROpp.statutoryexceptiontofairopportunity
		
--	LEFT JOIN Contractor.DunsnumberToParentContractorHistory AS PCH
--		ON (C.Dunsnumber=PCH.Dunsnumber)
--		AND (C.fiscal_year=PCH.FiscalYear)
--	LEFT JOIN Contractor.ParentContractor As PC
--		ON (PCH.ParentID=PC.ParentID)
--	left join fpdstypetable.statecode state
--		on c.pop_state_code= state.statecode
----Block of CSISIDjoins
    left join contract.csistransactionid as CTID
                     on ctid.CSIStransactionID=c.CSIStransactionID
              left join contract.CSISidvmodificationID as idvmod
                     on idvmod.CSISidvmodificationID=ctid.CSISidvmodificationID
              left join contract.CSISidvpiidID as idv
                     on idv.CSISidvpiidID=idvmod.CSISidvpiidID
              left join contract.CSIScontractID as cid
                     on cid.CSIScontractID=ctid.CSIScontractID
			LEFT OUTER JOIN Contract.ContractDiscretization AS CD
					ON CD.CSIScontractID = CTID.CSIScontractID

----Block of Contract Label and ProjectID 
--              left join Contract.ContractLabelID label
--                     on coalesce(ctid.ContractLabelID,cid.COntractlabelid,idv.ContractLabelID) = label.ContractLabelID
--              LEFT JOIN Project.SystemEquipmentCodetoProjectIDhistory as SYS
--                     ON SYS.systemequipmentcode=C.systemequipmentcode
--                     and SYS.StartFiscalYear <= c.fiscal_year
--                     and isnull(SYS.EndFiscalYear,9999) >= c.fiscal_year
--              left join project.projectID Proj
--                     on proj.projectid=isnull(sys.projectid,label.PrimaryProjectID)




--			--Block of vehicle lookups
--		Left JOIN FPDSTypeTable.multipleorsingleawardidc as Cmulti
--			on C.multipleorsingleawardidc=Cmulti.multipleorsingleawardidc
--		Left JOIN FPDSTypeTable.multipleorsingleawardidc as IDVmulti
--			on isnull(idvmod.multipleorsingleawardidc,idv.multipleorsingleawardidc)=IDVMulti.multipleorsingleawardidc
--		Left JOIN FPDSTypeTable.ContractActionType as Ctype
--			on C.ContractActionType=Ctype.unseperated
--		Left JOIN FPDSTypeTable.ContractActionType as IDVtype
--			on isnull(idvmod.ContractActionType,idv.ContractActionType)=IDVtype.unseperated
		
--  ) as c
  
  


  left outer join contract.ContractFSRSprimeHistory p
  on ctid.CSIScontractID=  p.CSIScontractID
  and c.fiscal_year=p.PrimeAwardDateSignedFiscalYear
  	LEFT OUTER JOIN FPDSTypeTable.AgencyID AS Agency
		ON (C.contractingofficeagencyid=Agency.AgencyID)
	LEFT OUTER JOIN FPDSTypeTable.ProductOrServiceCode AS PSC
		ON (C.productorservicecode=PSC.ProductOrServiceCode)
	left OUTER join FPDSTypeTable.ClaimantProgramCode as cpc
		on cpc.ClaimantProgramCode=c.claimantprogramcode
	--Vendor
	LEFT OUTER JOIN Contractor.DunsnumberToParentContractorHistory AS PCH
		ON (C.Dunsnumber=PCH.Dunsnumber)
		AND (C.fiscal_year=PCH.FiscalYear)
	LEFT OUTER JOIN Contractor.ParentContractor As Parent
		ON (PCH.ParentID=Parent.ParentID)
LEFT OUTER JOIN FPDSTypeTable.typeofcontractpricing AS F 
	ON C.TypeofContractPricing = F.TypeofContractPricing
	left outer join Contract.FSRSthresholdHistory fth
	on fth.StartSignedDate<=cd.MinOfSignedDate and 
		fth.EndSignedDate>=cd.MinOfSignedDate


--Block of Contract Label and ProjectID 
  left join Contract.ContractLabelID label
          on coalesce(ctid.ContractLabelID,cid.COntractlabelid,idv.ContractLabelID) = label.ContractLabelID
        LEFT JOIN Project.SystemEquipmentCodetoProjectIDhistory as SYS
                     ON SYS.systemequipmentcode=C.systemequipmentcode
                     and SYS.StartFiscalYear <= c.fiscal_year
                     and isnull(SYS.EndFiscalYear,9999) >= c.fiscal_year
              left join project.projectID Proj
                     on proj.projectid=isnull(sys.projectid,label.PrimaryProjectID)



UNION ALL
  select 
  s.SubawardFiscalYear
  ,Agency.Customer 
  ,Agency.SubCustomer 
  ,plat.ProductOrServiceArea
  ,plat.SimpleArea
  ,plat.[PlatformPortfolio]
   ,fundtext.typeofcontractpricingtext
   ,comp.IsSomeCompetition
   ,comp.NumberOfOffersReceived
  ,1 as IsSubContract
 , CASE
		WHEN Parent.Top6=1 and Parent.JointVenture=1
		THEN 'Large: Big 5 JV'
		WHEN Parent.Top6=1
		THEN 'Large: Big 5'
		WHEN Parent.IsPreTop6=1
		THEN 'Large: Pre-Big 5'
		WHEN Parent.LargeGreaterThan3B=1
		THEN 'Large'
		WHEN Parent.LargeGreaterThan1B=1
		THEN 'Medium >1B'
		WHEN pch.AlwaysIsSmall =1 
		THEN 'Always Small'
		when Parent.UnknownCompany=1
		Then 'Unlabeled'
		WHEN pch.AnyIsSmall =1 
		THEN 'Sometimes Small'
		WHEN pch.AlwaysIsSmall is null and pch.AnyIsSmall is null
		THEN 'No Prime Business Size Determination Available'
		ELSE 'Medium <1B'
	END AS VendorSize	
,NULL -- ,c.obligatedamount as PrimeObligatedAmount
,NULL -- ,c.numberofactions as PrimeNumberOfActions
,s.SubawardAmount 
,s.SubawardAmount  as PrimeOrSubObligatedAmount
,u.CSIScontractID
--,NULL --,p.CSIScontractID
  ,1 as IsInFSRS
  ,iif(cd.SumOfUnmodifiedbaseandalloptionsvalue >=fth.Threshold or
  cd.SumofObligatedAmount >=fth.Threshold,1,0) as IsFSRSreportable
  from contract.FSRS s
    inner join Contract.PrimeAwardReportID u
  on s.PrimeAwardReportID = u.PrimeAwardReportID
  	LEFT OUTER JOIN Contract.ContractDiscretization AS CD
		ON CD.CSIScontractID = u.CSIScontractID
	left outer join [Contract].[ContractPlatformBucket] plat
		on u.CSIScontractID=plat.CSIScontractID
	left outer join contract.ContractPricing fund
		on fund.CSIScontractID=u.CSIScontractID
	LEFT OUTER JOIN FPDSTypeTable.typeofcontractpricing AS Fundtext
		ON fund.TypeofContractPricing = Fundtext.TypeofContractPricing
	LEFT OUTER JOIN Contract.ContractCompetitionVehicle AS Comp
		ON Comp.CSIScontractID= u.CSIScontractID
	LEFT OUTER JOIN FPDSTypeTable.AgencyID AS Agency
		ON (s.PrimeAwardContractingAgencyID=Agency.AgencyID)
	--Vendor
	LEFT OUTER JOIN Contractor.DunsnumberToParentContractorHistory AS PCH
		ON (s.SubawardeeDunsnumber=PCH.Dunsnumber)
		AND (s.SubawardFiscalYear=PCH.FiscalYear)
	LEFT OUTER JOIN Contractor.ParentContractor As Parent
		ON (PCH.ParentID=Parent.ParentID)
	left outer join Contract.FSRSthresholdHistory fth
	on fth.StartSignedDate<=CD.MinOfSignedDate and 
		fth.EndSignedDate>=cd.MinOfSignedDate



GO


