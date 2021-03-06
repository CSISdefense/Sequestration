alter View Contract.FSRSinFPDShistory
as 

  select c.fiscal_year
  ,sum(obligatedamount) as PrimeObligatedAmount
  ,NULL as SubawardAmount
  ,sum(numberofactions) as NumberOfActions
  ,count(distinct t.CSIScontractID) as NumberOfContracts
  ,iif(p.CSIScontractID is not null, 1,0) as IsInFSRS
  from contract.FPDS c
  inner join contract.CSIStransactionID t
  on t.CSIStransactionID = c.CSIStransactionID
  left outer join [Contract].[FSRSprimeHistory] p
  on c.fiscal_year=p.PrimeFiscalYear
	and t.CSIScontractID=p.CSIScontractID
  group by c.fiscal_year
  ,iif(p.CSIScontractID is not null, 1,0) 
  union all
  select p.PrimeFiscalYear
  ,NULL 
  ,sum(SubawardAmount) as SubawardAmount
  ,NULL
  ,NULL
  ,1
  from [Contract].[FSRSprimeHistory] p
  group by  p.PrimeFiscalYear
  