/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [PrimeAwardReportID]
      ,[PrimeAwardPIID]
      ,[PrimeAwardIDVPIID]
      ,[PrimeAwardFederalAwardID]
      ,[TypeOfSpending]
      ,[PrimeAwardDateSubmitted]
      ,[PrimeAwardReportMonth]
      ,[PrimeAwardReportYear]
      ,[PrimeAwardReportType]
      ,[PrimeAwardPrincipalPlaceStreet]
      ,[PrimeAwardPrincipalPlaceCity]
      ,[PrimeAwardPrincipalPlaceState]
      ,[PrimeAwardPrincipalPlaceZIP]
      ,[PrimeAwardPrincipalPlaceDistrict]
      ,[PrimeAwardPrincipalPlaceCountry]
      ,[PrimeAwardeeParentDuns]
      ,[PrimeAwardeeParentContractorName]
      ,[PrimeAwardContractingAgencyID]
      ,[PrimeAwardContractingAgencyName]
      ,[PrimeAwardContractingOfficeID]
      ,[PrimeAwardContractingOfficeName]
      ,[PrimeAwardFundingAgencyID]
      ,[PrimeAwardFundingAgencyName]
      ,[PrimeAwardFundingOfficeID]
      ,[PrimeAwardFundingOfficeName]
      ,[PrimeAwardProgramSourceAgency]
      ,[PrimeAwardProgramSourceAccount]
      ,[PrimeAwardProgramSourceSubaccount]
      ,[PrimeAwardeeExecutive1]
      ,[PrimeAwardeeExecutive1Compensation]
      ,[PrimeAwardeeExecutive2]
      ,[PrimeAwardeeExecutive2Compensation]
      ,[PrimeAwardeeExecutive3]
      ,[PrimeAwardeeExecutive3Compensation]
      ,[PrimeAwardeeExecutive4]
      ,[PrimeAwardeeExecutive4Compensation]
      ,[PrimeAwardeeExecutive5]
      ,[PrimeAwardeeExecutive5Compensation]
      ,[PrimeAwardPrincipalNaicsCode]
      ,[PrimeAwardPrincipalNaicsDesc]
      ,[PrimeAwardCFDAprogramNumberTitleCodes]
      ,[PrimeAwardAmount]
      ,[PrimeAwardDateSigned]
      ,[PrimeAwardProjectDescription]
      ,[PrimeAwardTransactionType]
      ,[PrimeAwardProgramTitle]
      ,[PrimeAwardeeRecoveryModelQ1]
      ,[PrimeAwardeeRecoveryModelQ2]
      ,[PrimeAwardFiscalYear]
      ,[PrimeAwardContractingMajorAgencyID]
      ,[PrimeAwardContractingMajorAgencyName]
      ,[PrimeAwardFundingMajorAgencyID]
      ,[PrimeAwardFundingMajorAgencyName]
      ,[PrimeAwardAgencyID]
      ,[PrimeAwardIDVagencyID]
      ,[SubawardeeDunsnumber]
      ,[SubawardeeName]
      ,[SubawardeeDBAname]
      ,[SubawardeeStreet]
      ,[SubawardeeCity]
      ,[SubawardeeState]
      ,[SubawardeeZipcode]
      ,[SubawardeeCongressionalDistrict]
      ,[SubawardeeCountrycode]
      ,[SubawardPrincipalPlaceStreet]
      ,[SubawardPrincipalPlaceCity]
      ,[SubawardPrincipalPlaceState]
      ,[SubawardPrincipalPlaceZip]
      ,[SubawardPrincipalPlaceDistrict]
      ,[SubawardPrincipalPlaceCountry]
      ,[SubawardeeParentDuns]
      ,[SubawardeeParentContractorName]
      ,[SubawardAmount]
      ,[SubawardDate]
      ,[SubawardPrincipalNaicsCode]
      ,[SubawardPrincipalNaicsDesc]
      ,[SubawardFundingOfficeID]
      ,[SubawardFundingOfficeName]
      ,[SubawardFederalAgencyID]
      ,[SubawardFederalAgencyName]
      ,[SubawardMajorAgencyID]
      ,[SubawardMajorAgencyName]
      ,[SubawardNumber]
      ,[SubawardProjectDescription]
      ,[SubawardeeRecoveryModelQ1]
      ,[SubawardeeRecoveryModelQ2]
      ,[SubawardReportMonth]
      ,[SubawardReportYear]
      ,[SubawardFiscalYear]
      ,[SubawardeeExecutive1]
      ,[SubawardeeExecutive1Compensation]
      ,[SubawardeeExecutive2]
      ,[SubawardeeExecutive2Compensation]
      ,[SubawardeeExecutive3]
      ,[SubawardeeExecutive3Compensation]
      ,[SubawardeeExecutive4]
      ,[SubawardeeExecutive4Compensation]
      ,[SubawardeeExecutive5]
      ,[SubawardeeExecutive5Compensation]
      ,[SubawardeeBusinessTypes]
      ,[SubawardCFDAprogramNumberTitleCodes]
      ,[CSISmodifiedDate]
      ,[CSIScreatedDate]
  FROM [DIIG].[Contract].[FSRS]



  SELECT  [PrimeAwardReportID]
      ,count(distinct [PrimeAwardAmount])
  FROM [DIIG].[Contract].[FSRS]
  group by [PrimeAwardReportID]
  having count(distinct [PrimeAwardAmount])>1

    SELECT  [PrimeAwardReportID]
      ,count(distinct SubawardAmount)
  FROM [DIIG].[Contract].[FSRS]
  group by [PrimeAwardReportID]
  having count(distinct SubawardAmount)>1


  SELECT    
  sum(UniquePrimeAwardAmount)  as UniquePrimeAwardAmount
  ,sum(SumOfPrimeAwardAmount)  as SumOfPrimeAwardAmount
  ,sum([SubawardAmount]) as SubawardAmount
  FROM (select [PrimeAwardAmount] as UniquePrimeAwardAmount
  ,sum([PrimeAwardAmount])  as SumOfPrimeAwardAmount
  ,sum([SubawardAmount]) as SubawardAmount
  from [DIIG].[Contract].[FSRS]
  group by [PrimeAwardAmount]
  ) as p
  --group by [PrimeAwardFiscalYear]
  --order by [PrimeAwardFiscalYear]

  
  SELECT    
  sum(UniquePrimeAwardAmount)  as UniquePrimeAwardAmount
  ,sum(SumOfPrimeAwardAmount)  as SumOfPrimeAwardAmount
  ,sum([SubawardAmount]) as SubawardAmount
  FROM (select PrimeAwardReportID
  ,[PrimeAwardAmount] as UniquePrimeAwardAmount
  ,sum([PrimeAwardAmount])  as SumOfPrimeAwardAmount
  ,sum([SubawardAmount]) as SubawardAmount
  from [DIIG].[Contract].[FSRS]
  group by PrimeAwardReportID,
  [PrimeAwardAmount]
  ) as p
  --group by [PrimeAwardFiscalYear]
  --order by [PrimeAwardFiscalYear]


   SELECT    
  sum(UniquePrimeAwardAmount)  as UniquePrimeAwardAmount
  ,sum(SumOfPrimeAwardAmount)  as SumOfPrimeAwardAmount
  ,sum([SubawardAmount]) as SubawardAmount
  FROM (select [PrimeAwardAmount] as UniquePrimeAwardAmount
  ,sum([PrimeAwardAmount])  as SumOfPrimeAwardAmount
  ,sum([SubawardAmount]) as SubawardAmount
  from [DIIG].[Contract].[FSRS]
  group by [PrimeAwardAmount],
  PrimeAwardAgencyID
  ) as p
  --group by [PrimeAwardFiscalYear]
  --order by [PrimeAwardFiscalYear]

   SELECT    
  sum(UniquePrimeAwardAmount)  as UniquePrimeAwardAmount
  ,sum(SumOfPrimeAwardAmount)  as SumOfPrimeAwardAmount
  ,sum([SubawardAmount]) as SubawardAmount
  FROM (select [PrimeAwardAmount] as UniquePrimeAwardAmount
  ,sum([PrimeAwardAmount])  as SumOfPrimeAwardAmount
  ,sum([SubawardAmount]) as SubawardAmount
  from [DIIG].[Contract].[FSRS]
  group by [PrimeAwardAmount],
  PrimeAwardAgencyID
  ) as p
  --group by [PrimeAwardFiscalYear]
  --order by [PrimeAwardFiscalYear]



    SELECT    PrimeAwardFiscalYear,
  sum(UniquePrimeAwardAmount)  as UniquePrimeAwardAmount
 ,sum([SubawardAmount]) as SubawardAmount
  ,sum(SumOfPrimeAwardAmount)  as SumOfPrimeAwardAmount
  FROM (select [PrimeAwardFiscalYear]
  ,[PrimeAwardAmount] as UniquePrimeAwardAmount
  ,sum([PrimeAwardAmount])  as SumOfPrimeAwardAmount
   ,sum([SubawardAmount]) as SubawardAmount
  from [DIIG].[Contract].[FSRS]
  group by [PrimeAwardFiscalYear]
  ,[PrimeAwardAmount]
  ,PrimeAwardReportID
  ) as p
  group by PrimeAwardFiscalYear
  --group by [PrimeAwardFiscalYear]
  --order by [PrimeAwardFiscalYear]

      SELECT    PrimeAwardReportYear,
  sum(UniquePrimeAwardAmount)  as UniquePrimeAwardAmount
  ,sum(SumOfPrimeAwardAmount)  as SumOfPrimeAwardAmount
  FROM (select PrimeAwardReportYear
  ,[PrimeAwardAmount] as UniquePrimeAwardAmount
  ,sum([PrimeAwardAmount])  as SumOfPrimeAwardAmount
  from [DIIG].[Contract].[FSRS]
  group by PrimeAwardReportYear
  ,[PrimeAwardAmount]
  ,PrimeAwardReportID
  ) as p
  group by PrimeAwardReportYear
  --group by [PrimeAwardFiscalYear]
  --order by [PrimeAwardFiscalYear]



SELECT PrimeAwardFiscalYear
,count(distinct csiscontractID) as ContractCount
  FROM [DIIG].[Contract].[FSRS] f
  left outer join contract.CSIScontractID ccid
	on f.PrimeAwardPIID=ccid.piid
	and f.PrimeAwardIDVPIID=ccid.idvpiid
group by PrimeAwardFiscalYear


SELECT PrimeAwardReportYear
,count(distinct csiscontractID) as ContractCount
  FROM [DIIG].[Contract].[FSRS] f
  left outer join contract.CSIScontractID ccid
	on f.PrimeAwardPIID=ccid.piid
	and f.PrimeAwardIDVPIID=ccid.idvpiid
group by PrimeAwardReportYear

SELECT SubawardFiscalYear
,count(distinct csiscontractID) as ContractCount
  FROM [DIIG].[Contract].[FSRS] f
  left outer join contract.CSIScontractID ccid
	on f.PrimeAwardPIID=ccid.piid
	and f.PrimeAwardIDVPIID=ccid.idvpiid
group by SubawardFiscalYear
