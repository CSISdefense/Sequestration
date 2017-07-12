USE [DIIG]
GO

/****** Object:  View [Contract].[ContractPlatformBucket]    Script Date: 7/11/2017 11:02:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO














ALTER VIEW [Contract].[ContractPlatformBucket]
AS
select M.CSIScontractID
--SimpleArea
,iif(M.MinOfPlatformPortfolio=MaxOfPlatformPortfolio,
	MaxOfPlatformPortfolio
	,NULL) as PlatformPortfolio
,iif(M.MinOfUnmodifiedPlatformPortfolio=MaxOfUnmodifiedPlatformPortfolio,
	MaxOfUnmodifiedPlatformPortfolio
	,NULL) as UnmodifiedPlatformPortfolio
--Platform Portfolio
,ObligatedAmountIsAir
,ObligatedAmountIsEnC
,ObligatedAmountIsFRSnC
,ObligatedAmountIsLand
,ObligatedAmountIsMnS
,ObligatedAmountIsOtherPP
,ObligatedAmountIsVessel
,ObligatedAmountIsWnA
--ProductOrServiceArea
,iif(M.MinOfProductOrServiceArea=MaxOfProductOrServiceArea,
	MaxOfProductOrServiceArea
	,NULL) as ProductOrServiceArea
,iif(M.MinOfUnmodifiedProductOrServiceArea=MaxOfUnmodifiedProductOrServiceArea,
	MaxOfUnmodifiedProductOrServiceArea
	,NULL) as UnmodifiedProductOrServiceArea
--SimpleArea
,iif(M.MinOfSimpleArea=MaxOfSimpleArea,
	MaxOfSimpleArea
	,NULL) as SimpleArea
,iif(M.MinOfUnmodifiedSimpleArea=MaxOfUnmodifiedSimpleArea,
	MaxOfUnmodifiedSimpleArea
	,NULL) as UnmodifiedSimpleArea

--IsProducts
,ObligatedAmountIsProducts
--IsServices	
,ObligatedAmountIsServices
--IsRnD
,ObligatedAmountIsRnD
,MaxOfIsPossibleSoftwareEngineering
from (SELECT  
	ctid.CSIScontractID    
	--PlatformPortfolio
	, min(coalesce(proj.PlatformPortfolio, Agency.PlatformPortfolio, cpc.PlatformPortfolio, psc.platformPortfolio)) as MinOfPlatformPortfolio
	, max(coalesce(proj.PlatformPortfolio, Agency.PlatformPortfolio, cpc.PlatformPortfolio, psc.platformPortfolio)) as MaxOfPlatformPortfolio
	, min(iif(C.modnumber='0' or C.modnumber is null,coalesce(proj.PlatformPortfolio, Agency.PlatformPortfolio, cpc.PlatformPortfolio, psc.platformPortfolio),NULL)) as MinOfUnmodifiedPlatformPortfolio
	, max(iif(C.modnumber='0' or C.modnumber is null,coalesce(proj.PlatformPortfolio, Agency.PlatformPortfolio, cpc.PlatformPortfolio, psc.platformPortfolio),NULL)) as MaxOfUnmodifiedPlatformPortfolio
	--Platform Binaries
	,sum(iif(coalesce(proj.PlatformPortfolio, Agency.PlatformPortfolio
		, cpc.PlatformPortfolio, psc.platformPortfolio) in ('Aircraft')
		,c.ObligatedAmount,NULL)) as ObligatedAmountIsAir
	,sum(iif(coalesce(proj.PlatformPortfolio, Agency.PlatformPortfolio
		, cpc.PlatformPortfolio, psc.platformPortfolio)='Electronics, Comms, & Sensors'
		,c.ObligatedAmount,NULL)) as ObligatedAmountIsECnS
	,sum(iif(coalesce(proj.PlatformPortfolio, Agency.PlatformPortfolio
		, cpc.PlatformPortfolio, psc.platformPortfolio)='Facilities and Construction'
		,c.ObligatedAmount,NULL)) as ObligatedAmountIsFRSnC
	,sum(iif(coalesce(proj.PlatformPortfolio, Agency.PlatformPortfolio
		, cpc.PlatformPortfolio, psc.platformPortfolio)='Land Vehicles'
		,c.ObligatedAmount,NULL)) as ObligatedAmountIsLand
	,sum(iif(coalesce(proj.PlatformPortfolio, Agency.PlatformPortfolio
		, cpc.PlatformPortfolio, psc.platformPortfolio)='Missile Defense'
		,c.ObligatedAmount,NULL)) as ObligatedAmountIsMisDef
	,sum(iif(coalesce(proj.PlatformPortfolio, Agency.PlatformPortfolio
		, cpc.PlatformPortfolio, psc.platformPortfolio)='Space Systems'
		,c.ObligatedAmount,NULL)) as ObligatedAmountIsSpace
	,sum(iif(coalesce(proj.PlatformPortfolio, Agency.PlatformPortfolio
		, cpc.PlatformPortfolio, psc.platformPortfolio) in ('Other Products'
			,'Other R&D and Knowledge Based','Other Services')
		,c.ObligatedAmount,NULL)) as ObligatedAmountIsOtherPP
	,sum(iif(coalesce(proj.PlatformPortfolio, Agency.PlatformPortfolio
		, cpc.PlatformPortfolio, psc.platformPortfolio)='Ships & Submarines'
		,c.ObligatedAmount,NULL)) as ObligatedAmountIsVessel
	,sum(iif(coalesce(proj.PlatformPortfolio, Agency.PlatformPortfolio
		, cpc.PlatformPortfolio, psc.platformPortfolio)='Weapons and Ammunition'
		,c.ObligatedAmount,NULL)) as ObligatedAmountIsWnA
	--ProductOrServiceArea
	, min(psc.ProductOrServiceArea) as MinOfProductOrServiceArea
	, max(psc.ProductOrServiceArea) as MaxOfProductOrServiceArea
	, min(iif(C.modnumber='0' or C.modnumber is null,psc.ProductOrServiceArea,NULL)) as MinOfUnmodifiedProductOrServiceArea
	, max(iif(C.modnumber='0' or C.modnumber is null,psc.ProductOrServiceArea,NULL)) as MaxOfUnmodifiedProductOrServiceArea
	--SimpleArea
	, min(psc.Simple) as MinOfSimpleArea
	, max(psc.Simple) as MaxOfSimpleArea
	, min(iif(C.modnumber='0' or C.modnumber is null,psc.Simple,NULL)) as MinOfUnmodifiedSimpleArea
	, max(iif(C.modnumber='0' or C.modnumber is null,psc.Simple,NULL)) as MaxOfUnmodifiedSimpleArea
	--Simple Area Binaries IsProducts
	,sum(iif(psc.Simple='Products',c.ObligatedAmount,NULL)) as ObligatedAmountIsProducts
	--Simple Area Binaries IsServices
	,sum(iif(psc.Simple='Services',c.ObligatedAmount,NULL)) as ObligatedAmountIsServices
	--Simple Area Binaries R&D
	,sum(iif(psc.Simple='R&D',c.ObligatedAmount,NULL)) as ObligatedAmountIsRnD
	,max(convert(int,IsPossibleSoftwareEngineering)) as MaxOfIsPossibleSoftwareEngineering
  FROM contract.FPDS as C
  left outer join fpdstypetable.productorservicecode psc
  on c.ProductOrServiceCode =psc.ProductOrServiceCode

  left outer join
			FPDSTypeTable.ClaimantProgramCode  as cpc
				on cpc.ClaimantProgramCode=c.claimantprogramcode
	LEFT OUTER JOIN FPDSTypeTable.AgencyID AS Agency 
		ON C.contractingofficeagencyid = Agency.AgencyID 

--Block of CSISIDjoins
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

--Block of Contract Label and ProjectID 
              left join Contract.ContractLabelID label
                     on coalesce(ctid.ContractLabelID,cid.COntractlabelid,idv.ContractLabelID) = label.ContractLabelID
              LEFT JOIN Project.SystemEquipmentCodetoProjectIDhistory as SYS
                     ON SYS.systemequipmentcode=C.systemequipmentcode
                     and SYS.StartFiscalYear <= c.fiscal_year
                     and isnull(SYS.EndFiscalYear,9999) >= c.fiscal_year
              left join project.projectID Proj
                     on proj.projectid=isnull(sys.projectid,label.PrimaryProjectID)

	

group by ctid.CSIScontractID ) as M
















GO


