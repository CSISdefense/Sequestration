USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_CompetitionVendorSizeHistoryBucketPlatformSubCustomer]    Script Date: 3/16/2017 12:26:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE PROCEDURE [Vendor].[SP_CompetitionVendorSizeHistoryBucketPlatformSubCustomer]

@Customer VARCHAR(255),
@SubCustomer VARCHAR(255) 
AS

IF (@SubCustomer is not null) --Begin sub path where all product and services but only one Customer will be returned
	BEGIN
		--Copy the start of your query here
		SELECT S.fiscal_year
			,S.Customer
			,S.SubCustomer
			,s.ServicesCategory
			,S.PlatformPortfolio
			,S.ProductOrServiceCodeText
			,S.Size as VendorSize
			,S.CompetitionClassification
			,S.ClassifyNumberOfOffers
			,sum(S.SumOfobligatedAmount) as SumOfobligatedAmount
			,sum(S.SumOfnumberOfActions) as SumOfnumberOfActions
		FROM Vendor.CompetitionVendorSizeHistoryBucketSubCustomerClassification as S
		--Here's the where clause for @ServicesOnly is null and Customer is not null
		WHERE S.SubCustomer =@SubCustomer 
		--Copy the end of your query here
		GROUP BY S.fiscal_year
				,S.Customer
				,S.SubCustomer
				,s.ServicesCategory
				,S.PlatformPortfolio
				,S.ProductOrServiceCodeText
				,S.CompetitionClassification
				,S.ClassifyNumberOfOffers
				,S.Size
		--End of your query
		END
ELSE --Begin sub path where all products and services amd all Customers will be returned
	BEGIN
		--Copy the start of your query here
		SELECT S.fiscal_year
			,S.Customer
			,S.SubCustomer
			,s.ServicesCategory
			,S.PlatformPortfolio
			,S.Size as VendorSize
			,S.CompetitionClassification
			,S.ClassifyNumberOfOffers
			,sum(S.SumOfobligatedAmount) as SumOfobligatedAmount
			,sum(S.SumOfnumberOfActions) as SumOfnumberOfActions
		FROM Vendor.CompetitionVendorSizeHistoryBucketSubCustomerClassification as S
		--There is no Where clause, because everything is being returned
		WHERE S.Customer =@Customer
		--Copy the end of your query here
		GROUP BY 
			S.fiscal_year
			,S.Customer
			,S.SubCustomer
			,s.ServicesCategory
			,S.PlatformPortfolio
			,S.CompetitionClassification
			,S.ClassifyNumberOfOffers
			,S.Size
		--End of your query
	END










GO
