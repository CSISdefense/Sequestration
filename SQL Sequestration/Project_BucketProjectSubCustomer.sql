USE [DIIG]
GO

/****** Object:  View [Project].[BucketProjectSubCustomer]    Script Date: 4/13/2017 2:14:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO













ALTER VIEW [Project].[BucketProjectSubCustomer]
AS

SELECT 
Proj.ProjectID
	,					  proj.ProjectAbbreviation
	,					   Proj.ProjectName
, ISNULL(Agency.Customer
		, Agency.AgencyIDtext) AS Customer
	, Agency.SubCustomer
	, PSC.ServicesCategory
	,PSC.IsService
	,coalesce(cpc.PlatformPortfolio,psc.platformPortfolio) as platformPortfolio
	,dtpch.ParentID
, c.fiscal_year 
, C.obligatedAmount
, C.numberOfActions


FROM Contract.FPDS as C

--Block of CSISIDjoins
              left join contract.csistransactionid as CTID
                     on ctid.CSIStransactionID=c.CSIStransactionID
              left join contract.CSISidvmodificationID as idvmod
                     on idvmod.CSISidvmodificationID=ctid.CSISidvmodificationID
              left join contract.CSISidvpiidID as idv
                     on idv.CSISidvpiidID=idvmod.CSISidvpiidID
              left join contract.CSIScontractID as cid
                     on cid.CSIScontractID=ctid.CSIScontractID
--Block of Contract Label and ProjectID 
              left join Contract.ContractLabelID label
                     on coalesce(ctid.ContractLabelID,cid.COntractlabelid,idv.ContractLabelID) = label.ContractLabelID
              LEFT JOIN Project.SystemEquipmentCodetoProjectIDhistory as SYS
                     ON SYS.systemequipmentcode=C.systemequipmentcode
                     and SYS.StartFiscalYear <= c.fiscal_year
                     and isnull(SYS.EndFiscalYear,9999) >= c.fiscal_year
              left join project.projectID Proj
                     on proj.projectid=isnull(sys.projectid,label.PrimaryProjectID)
	LEFT OUTER JOIN Contract.ContractDiscretization AS CD
	ON CD.CSIScontractID = CTID.CSIScontractID

--ParentID
left outer join Contractor.DunsnumberToParentContractorHistory dtpch
on dtpch.DUNSnumber=c.dunsnumber
and dtpch.FiscalYear=c.fiscal_year
--Getting the agency codes from FPDSTypeTable
LEFT OUTER JOIN FPDSTypeTable.AgencyID AS Agency 
ON C.contractingofficeagencyid = Agency.AgencyID 
--Getting the PSC codes from FPDSTypeTable
LEFT OUTER JOIN FPDSTypeTable.ProductOrServiceCode AS PSC 
ON C.productorservicecode = PSC.ProductOrServiceCode 
left outer join FPDSTypeTable.ClaimantProgramCode as cpc
on cpc.ClaimantProgramCode=c.claimantprogramcode











GO


