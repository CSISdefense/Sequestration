USE [DIIG]
GO

/****** Object:  View [Contract].[FSRSinFPDShistory]    Script Date: 6/12/2017 12:16:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER View [Contract].[FSRSinFPDShistory]
as 

  select c.fiscal_year
  ,agency.Customer as Customer	
  ,sum(obligatedamount) as PrimeObligatedAmount
  ,sum(p.SubawardAmount) as SubawardAmount
  ,sum(numberofactions) as NumberOfActions
 
  ,count(distinct t.CSIScontractID) as NumberOfContracts
  ,iif(p.CSIScontractID is not null, 1,0) as IsInFSRS
  from contract.FPDS c
  inner join contract.CSIStransactionID t
  on t.CSIStransactionID = c.CSIStransactionID
  left outer join FPDSTypeTable.AgencyID  as Agency
	on c.agencyid = agency.AgencyID
  left outer join [Contract].[FSRSprimeHistory] p
  on c.fiscal_year=p.PrimeFiscalYear
	and t.CSIScontractID=p.CSIScontractID
  group by c.fiscal_year, Customer
  ,iif(p.CSIScontractID is not null, 1,0)

GO


