create procedure Vendor.SP_FSRSinFPDSVendorSizeHistorySubCustomerBucketPlatform

as

SELECT [fiscal_year]
      ,[Customer]
      ,[SubCustomer]
      ,[ProductOrServiceArea]
      ,[Simple]
      ,[PlatformPortfolio]
      ,[VendorSize]
	  ,[IsInFSRS]
      ,sum([PrimeObligatedAmount]) as [PrimeObligatedAmount]
      --,sum([SubawardAmount]) as SubawardAmount
      ,sum([PrimeNumberOfActions]) as PrimeNumberOfActions
	  ,count(CSIScontractID) as PrimeNumberOfRows --Not a contract count, a row count
	  --,count(f.PrimeAwardReportID) as NumberOfTransactions
  FROM [DIIG].[Vendor].[FSRSinFPDSVendorSizeHistorySubCustomerBucketPlatform]
  group by   [fiscal_year]
      ,[Customer]
      ,[SubCustomer]
      ,[ProductOrServiceArea]
      ,[Simple]
      ,[PlatformPortfolio]
      ,[VendorSize]
	  ,[IsInFSRS]
