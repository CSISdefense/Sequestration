USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_VehicleVendorSizeHistory]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO















CREATE PROCEDURE [Vendor].[SP_VehicleVendorSizeHistory]

@Customer VARCHAR(255),
@ServicesOnly bit 
AS

IF (@ServicesOnly is not null)
BEGIN --Begin path where only service entries will be returned.
	IF (@Customer is not null) --Begin sub path where only services only one Customer will be returned
	BEGIN
		--Copy the start of your query here
		SELECT S.fiscal_year
			,S.Query_Run_Date
			,S.Customer
			
			,S.VendorSize
			,S.VehicleClassification
			,sum(S.obligatedAmount) as SumOfobligatedAmount
			,sum(S.numberOfActions) as SumOfnumberOfActions
		FROM Vendor.VehicleVendorSizeHistoryBucketSubCustomerClassification as S
		--Here's the where clause for @ServicesOnly=1 and Customer is not null
		WHERE S.Customer=@Customer 
			and s.isservice=1
		--Copy the end of your query here
		GROUP BY S.fiscal_year
			,S.Query_Run_Date
			,S.Customer

			,S.VendorSize
			,S.VehicleClassification
		--End of your query
		END
	ELSE --Begin sub path where only services but all Customers will be returned
		BEGIN
		--Copy the start of your query here
		SELECT S.fiscal_year
			,S.Query_Run_Date

			,S.VendorSize
			,S.VehicleClassification
			,sum(S.obligatedAmount) as SumOfobligatedAmount
			,sum(S.numberOfActions) as SumOfnumberOfActions
		FROM Vendor.VehicleVendorSizeHistoryBucketSubCustomerClassification as S
		--Here's the where clause for @ServicesOnly=1 and Customer is null
		WHERE  s.isservice=1
		--Copy the end of your query here
		GROUP BY S.fiscal_year
			,S.Query_Run_Date

			,S.VendorSize
			,S.VehicleClassification
		--End of your query
		END
	END
	ELSE
BEGIN
	IF (@Customer is not null) --Begin sub path where all product and services but only one Customer will be returned
	BEGIN
		--Copy the start of your query here
		SELECT S.fiscal_year
			,S.Query_Run_Date
			,S.Customer

			,S.VendorSize
			,S.VehicleClassification
			,sum(S.obligatedAmount) as SumOfobligatedAmount
			,sum(S.numberOfActions) as SumOfnumberOfActions
		FROM Vendor.VehicleVendorSizeHistoryBucketSubCustomerClassification as S
		--Here's the where clause for @ServicesOnly is null and Customer is not null
		WHERE S.Customer=@Customer 
		--Copy the end of your query here
		GROUP BY S.fiscal_year
			,S.Query_Run_Date
			,S.Customer

			,S.VendorSize
			,S.VehicleClassification
		--End of your query
		END
	ELSE --Begin sub path where all products and services amd all Customers will be returned
		BEGIN
		--Copy the start of your query here
		SELECT S.fiscal_year
			,S.Query_Run_Date

			,S.VendorSize
			,S.VehicleClassification
			,sum(S.obligatedAmount) as SumOfobligatedAmount
			,sum(S.numberOfActions) as SumOfnumberOfActions
		FROM Vendor.VehicleVendorSizeHistoryBucketSubCustomerClassification as S
		--There is no Where clause, because everything is being returned
		--Copy the end of your query here
		GROUP BY S.fiscal_year
			,S.Query_Run_Date

			,S.VendorSize
			,S.VehicleClassification
		--End of your query
		END
	END



























GO
