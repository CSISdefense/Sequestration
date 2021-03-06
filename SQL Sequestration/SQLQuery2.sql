/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [PrimeAwardReportID]
      ,[CSIStransactionID]
      ,[IsInContractFPDS]
      ,[PrimeAwardReportID32]
      ,[PIID]
      ,[IDVPIID]
      ,[CSIScontractID]
      ,[PrimeAwardReportID36]
  FROM [DIIG].[Contract].[PrimeAwardReportID]


  select f.*, s.PrimeAwardDateSigned, c.signeddate 
  from contract.fsrs s
  left outer join [Contract].[PrimeAwardReportID] f
  on s.PrimeAwardReportID=f.PrimeAwardReportID
  left outer join Contract.CSIStransactionID t
  on t.CSIScontractID=f.CSIScontractID
  left outer join Contract.FPDS c
  on c.CSIStransactionid=t.CSIStransactionID
  and c.signeddate=s.PrimeAwardDateSigned


  
  select f.PrimeAwardReportID, year(dateadd(month,3,s.PrimeAwardDateSigned))
  , count(distinct c.unique_transaction_id)
  from contract.fsrs s
  left outer join [Contract].[PrimeAwardReportID] f
  on s.PrimeAwardReportID=f.PrimeAwardReportID
  left outer join Contract.CSIStransactionID t
  on t.CSIScontractID=f.CSIScontractID
  left outer join Contract.FPDS c
  on c.CSIStransactionid=t.CSIStransactionID
  and c.fiscal_year=year(dateadd(month,3,s.PrimeAwardDateSigned))
  group by f.PrimeAwardReportID, year(dateadd(month,3,s.PrimeAwardDateSigned))