USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[sp_VendorSizeHistoryPlatformPortfolioSubCustomer]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE PROCEDURE [Vendor].[sp_VendorSizeHistoryPlatformPortfolioSubCustomer]
@Customer VARCHAR(255)
AS

IF (@Customer is not null) --Begin sub path where all product and services but only one Customer will be returned
		BEGIN
		--Copy the start of your query here
		SELECT 
			S.fiscal_year
			,S.Customer
			,S.SubCustomer
			,S.PlatformPortfolio
			,S.Simple
			,S.ProductOrServiceArea
			,S.VendorSize
			,sum(S.SumOfobligatedAmount) as SumOfobligatedAmount
			,sum(S.SumOfnumberOfActions) as SumOfnumberOfActions
			,S.Legacy
		FROM [Vendor].[VendorSizeFPDShistoryBucketCustomerCountry] as S
		--Here's the where clause for @ServicesOnly is null and Customer is not null
		WHERE S.Customer=@Customer
		--Copy the end of your query here
		GROUP BY S.fiscal_year
			,S.Customer
			,S.SubCustomer
			,S.PlatformPortfolio
			,S.Simple
			,S.ProductOrServiceArea
			,S.VendorSize
			,S.Legacy
		--End of your query
		END
ELSE --Begin sub path where all products and services amd all Customers will be returned
		BEGIN
		--Copy the start of your query here
		SELECT 
			S.fiscal_year
			,S.Customer
			,S.SubCustomer
			,S.PlatformPortfolio
			,S.Simple
			,S.ProductOrServiceArea
			,S.VendorSize
			,sum(S.SumOfobligatedAmount) as SumOfobligatedAmount
			,sum(S.SumOfnumberOfActions) as SumOfnumberOfActions
			,S.Legacy
		FROM [Vendor].[VendorSizeFPDShistoryBucketCustomerCountry]  as S
		--Copy the end of your query here
		GROUP BY S.fiscal_year
			,S.Customer
			,S.SubCustomer
			,S.PlatformPortfolio
			,S.Simple
			,S.ProductOrServiceArea
			,S.VendorSize
			,S.Legacy
		--End of your query
		END















GO
