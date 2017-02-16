USE [DIIG]
GO

/****** Object:  View [Contract].[FSRSprimeHistory]    Script Date: 2/16/2017 12:38:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/****** Script for SelectTopNRows command from SSMS  ******/

ALTER View [Contract].[FSRSprimeHistory] as
SELECT u.CSIScontractID
      ,[PrimeAwardPIID]
      ,[PrimeAwardIDVPIID]
      ,[PrimeAwardFederalAwardID]
      --,[TypeOfSpending]
      --,[PrimeAwardDateSubmitted]
      --,[PrimeAwardReportMonth]
      --,[PrimeAwardReportYear]
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
	  ,year(dateadd(month,3,f.PrimeAwardDateSigned)) as PrimeFiscalYear
  FROM [DIIG].[Contract].[FSRS] f
  left outer join Contract.PrimeAwardReportID u
  on f.PrimeAwardReportID = u.PrimeAwardReportID
  group by u.CSIScontractID
      ,[PrimeAwardPIID]
      ,[PrimeAwardIDVPIID]
      ,[PrimeAwardFederalAwardID]
  ,year(dateadd(month,3,f.PrimeAwardDateSigned))


GO


