USE [DIIG]
GO

/****** Object:  View [Contract].[ContractFSRSprimeHistory]    Script Date: 2/21/2017 5:50:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





/****** Script for SelectTopNRows command from SSMS  ******/

alter View [Contract].[ContractFSRSprime] as
SELECT u.CSIScontractID
      ,[PrimeAwardIDVPIID]
      ,[PrimeAwardPIID]
      ,[PrimeAwardFederalAwardID]
      --,[TypeOfSpending]
      --,[PrimeAwardReportType]
      --,[PrimeAwardPrincipalPlaceStreet]
      --,[PrimeAwardPrincipalPlaceCity]
      --,[PrimeAwardPrincipalPlaceState]
      --,[PrimeAwardPrincipalPlaceZIP]
      --,[PrimeAwardPrincipalPlaceDistrict]
      --,[PrimeAwardPrincipalPlaceCountry]
      --,[PrimeAwardeeParentDuns]
      --,[PrimeAwardeeParentContractorName]
      --,[PrimeAwardContractingAgencyID]
      --,[PrimeAwardContractingAgencyName]
      --,[PrimeAwardContractingOfficeID]
      --,[PrimeAwardContractingOfficeName]
      --,[PrimeAwardFundingAgencyID]
      --,[PrimeAwardFundingAgencyName]
      --,[PrimeAwardFundingOfficeID]
      --,[PrimeAwardFundingOfficeName]
      --,[PrimeAwardProgramSourceAgency]
      --,[PrimeAwardProgramSourceAccount]
      --,[PrimeAwardProgramSourceSubaccount]
      --,[PrimeAwardeeExecutive1]
      --,[PrimeAwardeeExecutive1Compensation]
      --,[PrimeAwardeeExecutive2]
      --,[PrimeAwardeeExecutive2Compensation]
      --,[PrimeAwardeeExecutive3]
      --,[PrimeAwardeeExecutive3Compensation]
      --,[PrimeAwardeeExecutive4]
      --,[PrimeAwardeeExecutive4Compensation]
      --,[PrimeAwardeeExecutive5]
      --,[PrimeAwardeeExecutive5Compensation]
      --,[PrimeAwardPrincipalNaicsCode]
      --,[PrimeAwardPrincipalNaicsDesc]
      --,[PrimeAwardCFDAprogramNumberTitleCodes]
      --,[PrimeAwardAmount]
      ,min([PrimeAwardDateSigned]) as MinOfPrimeAwardDateSigned
	  ,max([PrimeAwardDateSigned]) as MaxOfPrimeAwardDateSigned
      ,min([PrimeAwardDateSubmitted]) as MinOfPrimeAwardDateSubmitted
	  ,max([PrimeAwardDateSubmitted]) as MaxOfPrimeAwardDateSubmitted
      ,min(cast(cast([PrimeAwardReportYear] as varchar)+'-'+
		cast(PrimeAwardReportMonth as varchar)+'-01' as date)) as MinOfPrimeAwardReportMonthYear
	  ,max(cast(cast([PrimeAwardReportYear] as varchar)+'-'+
		cast(PrimeAwardReportMonth as varchar)+'-01' as date)) as MaxOfPrimeAwardReportMonthYear
      --,[PrimeAwardProjectDescription]
      --,[PrimeAwardTransactionType]
      --,[PrimeAwardProgramTitle]
      --,[PrimeAwardeeRecoveryModelQ1]
      --,[PrimeAwardeeRecoveryModelQ2]
      --,[PrimeAwardFiscalYear]
      --,[PrimeAwardContractingMajorAgencyID]
      --,[PrimeAwardContractingMajorAgencyName]
      --,[PrimeAwardFundingMajorAgencyID]
      --,[PrimeAwardFundingMajorAgencyName]
      --,[PrimeAwardAgencyID]
      --,[PrimeAwardIDVagencyID]
	  ,sum(f.SubawardAmount) as SubawardAmount
	  ,count(f.PrimeAwardReportID) as NumberOfTransactions

  FROM [DIIG].[Contract].[FSRS] f
  left outer join Contract.PrimeAwardReportID u
  on f.PrimeAwardReportID = u.PrimeAwardReportID
  group by u.CSIScontractID
      ,[PrimeAwardPIID]
      ,[PrimeAwardIDVPIID]
      ,[PrimeAwardFederalAwardID]



GO


