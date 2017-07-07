USE [DIIG]
GO

/****** Object:  StoredProcedure [Vendor].[SP_FSRSinFPDSVendorSizeHistorySubCustomerBucketPlatform]    Script Date: 6/12/2017 12:57:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [Vendor].[SP_FSRSinFPDSVendorSizeHistorySubCustomerBucketPlatform]

as

SELECT [fiscal_year]
      ,[Customer]
      ,[SubCustomer]
      ,[ProductOrServiceArea]
      ,[Simple]
      ,[PlatformPortfolio]
	  ,typeofcontractpricingtext
      ,[VendorSize]
	   ,[IsSubContract]
	   ,sum([PrimeObligatedAmount]) as [PrimeObligatedAmount]
	   ,sum([PrimeNumberOfActions]) as PrimeNumberOfActions
      ,sum([SubawardAmount]) as SubawardAmount
	   ,sum([PrimeOrSubObligatedAmount]) as [PrimeOrSubObligatedAmount]
      --,[CSIScontractID]
      ,[IsInFSRS]
  FROM [DIIG].[Vendor].[FSRSinFPDSVendorSizeHistorySubCustomerBucketPlatform]
  group by   [fiscal_year]
      ,[Customer]
      ,[SubCustomer]
      ,[ProductOrServiceArea]
      ,[Simple]
      ,[PlatformPortfolio]
	  ,typeofcontractpricingtext
	  ,[VendorSize]
	  ,[IsSubContract]
	  ,[IsInFSRS]

GO


