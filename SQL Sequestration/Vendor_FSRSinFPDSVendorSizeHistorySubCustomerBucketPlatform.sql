USE [DIIG]
GO

/****** Object:  View [Vendor].[FSRSinFPDSVendorSizeHistorySubCustomerBucketPlatform]    Script Date: 2/16/2017 11:12:38 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER View [Vendor].[FSRSinFPDSVendorSizeHistorySubCustomerBucketPlatform]
as 

  select c.fiscal_year
  ,A.Customer 
  ,A.SubCustomer 
  ,psc.ProductOrServiceArea
 ,psc.Simple
 ,coalesce(claim.PlatformPortfolio,psc.PlatformPortfolio) as PlatformPortfolio
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
		WHEN C.contractingofficerbusinesssizedetermination='s' or C.contractingofficerbusinesssizedetermination='y'
		THEN 'Small'
		when Parent.UnknownCompany=1
		Then 'Unlabeled'
		ELSE 'Medium <1B'
	END AS VendorSize	
  ,c.obligatedamount as PrimeObligatedAmount
  ,c.numberofactions as PrimeNumberOfActions
  ,p.SubawardAmount as SubawardAmount
 ,p.CSIScontractID
  ,iif(p.CSIScontractID is not null, 1,0) as IsInFSRS
  from contract.FPDS c
  inner join contract.CSIStransactionID t
  on t.CSIStransactionID = c.CSIStransactionID
  left outer join [Contract].[ContractFSRSprimeHistory] p
  on c.fiscal_year=p.PrimeAwardDateSignedFiscalYear
	and t.CSIScontractID=p.CSIScontractID
	LEFT OUTER JOIN FPDSTypeTable.AgencyID AS A
		ON (C.contractingofficeagencyid=A.AgencyID)
	LEFT OUTER JOIN FPDSTypeTable.ProductOrServiceCode AS PSC
		ON (C.productorservicecode=PSC.ProductOrServiceCode)
	left OUTER join FPDSTypeTable.ClaimantProgramCode as Claim
		on claim.ClaimantProgramCode=c.claimantprogramcode
	--Vendor
	LEFT OUTER JOIN Contractor.DunsnumberToParentContractorHistory AS PCH
		ON (C.Dunsnumber=PCH.Dunsnumber)
		AND (C.fiscal_year=PCH.FiscalYear)
	LEFT OUTER JOIN Contractor.ParentContractor As Parent
		ON (PCH.ParentID=Parent.ParentID)



GO


