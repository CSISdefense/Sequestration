USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[sp_VendorSizeHistoryCOCOM]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE PROCEDURE [Vendor].[sp_VendorSizeHistoryCOCOM]
@COCOM VARCHAR(255)


AS

IF (@COCOM is not null) --Begin sub path where all product and services but only one Customer will be returned
		BEGIN
		--Copy the start of your query here
		SELECT 
			
			S.fiscal_year
			,S.Customer
			,S.SubCustomer
			,S.Country3LetterCodeText
			,S.COCOM
			,S.PlatformPortfolio
			,S.VendorSize
			,sum(S.SumOfobligatedAmount) as SumOfobligatedAmount
			,sum(S.SumOfnumberOfActions) as SumOfnumberOfActions
			,S.Legacy
		FROM [Vendor].[VendorSizeFPDShistoryBucketCustomerProgramCountry] as S
		--Here's the where clause for @ServicesOnly is null and Customer is not null
		WHERE S.COCOM =@COCOM		--Copy the end of your query here
		GROUP BY 
			S.fiscal_year
			,S.Customer
			,S.SubCustomer
			,S.Country3LetterCodeText
			,S.COCOM
			,S.PlatformPortfolio
			,S.VendorSize
			,S.Legacy
		--End of your query
END














GO
