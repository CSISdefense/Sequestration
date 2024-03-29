USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[sp_IndividualVendorHistoryCustomer]    Script Date: 3/16/2017 12:26:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [Vendor].[sp_IndividualVendorHistoryCustomer]
@parentid varchar(255),
@Customer VARCHAR(255),
@ServicesOnly Bit

AS
		if @parentid is null
		raiserror('The value for @parentid shold not be null. Use sp_vendorhistorycustomer for all vendors',15,1)
IF (@ServicesOnly=1)
BEGIN --Begin path where only service entries will be returned.
	IF (@Customer is not null) --Begin sub path where only services only one Customer will be returned
	BEGIN
		--Copy the start of your query here
		SELECT S.fiscal_year
			,s.ContractorDisplayName
			,s.ParentID
			,S.Customer
			,S.ProductOrServiceArea
			,sum(S.SumOfnumberOfActions) as SumOfnumberOfActions
			,sum(S.SumOfobligatedAmount) as SumOfobligatedAmount
		FROM Contractor.AllContractorHistoryBucketCustomerDirectDiscretization as S
		--Here's the where clause for @ServicesOnly=1 and Customer is not null
		WHERE S.Customer=@Customer
			AND S.IsService=1
		--Copy the end of your query here
		GROUP BY S.fiscal_year
			,s.ParentID
			,s.ContractorDisplayName
			,S.Customer
			,S.ProductOrServiceArea
		--End of your query
		END
	ELSE --Begin sub path where only services but all Customers will be returned
		BEGIN
		--Copy the start of your query here
		SELECT S.fiscal_year
			,s.ContractorDisplayName
			,s.ParentID
			,S.Customer
			,S.ProductOrServiceArea
			,sum(S.SumOfnumberOfActions) as SumOfnumberOfActions
			,sum(S.SumOfobligatedAmount) as SumOfobligatedAmount
		FROM Contractor.AllContractorHistoryBucketCustomerDirectDiscretization as S
		--Here's the where clause for @ServicesOnly=1 and Customer is null
		WHERE S.IsService=1
		--Copy the end of your query here
		GROUP BY S.fiscal_year
			,s.ContractorDisplayName
			,s.ParentID
			,S.Customer
			,S.ProductOrServiceArea
		
		--End of your query
		END
	END
ELSE --Begin the path where all product or service codes will be returned
BEGIN
	IF (@Customer is not null) --Begin sub path where all product and services but only one Customer will be returned
	BEGIN
		--Copy the start of your query here
		SELECT S.fiscal_year
			,s.ContractorDisplayName
			,s.ParentID
			,S.Customer
			,S.ProductOrServiceArea
			,sum(S.SumOfnumberOfActions) as SumOfnumberOfActions
			,sum(S.SumOfobligatedAmount) as SumOfobligatedAmount
		FROM Contractor.AllContractorHistoryBucketCustomerDirectDiscretization as S
		--Here's the where clause for @ServicesOnly is null and Customer is not null
		WHERE S.Customer=@Customer
		--Copy the end of your query here
		GROUP BY S.fiscal_year
			,s.ContractorDisplayName
			,s.ParentID
			,S.Customer
			,S.ProductOrServiceArea
		
		--End of your query
		END
	ELSE --Begin sub path where all products and services amd all Customers will be returned
		BEGIN
		--Copy the start of your query here
		SELECT S.fiscal_year
			,s.ContractorDisplayName
			,s.ParentID
			,S.Customer
			,S.ProductOrServiceArea
		
			,sum(S.SumOfnumberOfActions) as SumOfnumberOfActions
			,sum(S.SumOfobligatedAmount) as SumOfobligatedAmount
		FROM Contractor.AllContractorHistoryBucketCustomerDirectDiscretization as S
		--There is no Where clause, because everything is being returned
		--Copy the end of your query here
		GROUP BY S.fiscal_year
			,s.ParentID
			,s.ContractorDisplayName
			,S.Customer
			,S.ProductOrServiceArea
		
		--End of your query
		END
	END








GO
