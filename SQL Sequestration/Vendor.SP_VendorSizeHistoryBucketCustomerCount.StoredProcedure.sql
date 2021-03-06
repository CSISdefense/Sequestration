USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_VendorSizeHistoryBucketCustomerCount]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE PROCEDURE [Vendor].[SP_VendorSizeHistoryBucketCustomerCount]
@Customer VARCHAR(255),
@IsService Bit


AS

IF (@IsService is not null)
BEGIN --Begin path where only service entries will be returned.
	IF (@Customer is not null) --Begin sub path where only services only one Customer will be returned
		begin
		SELECT AllContractor.fiscal_year
			,max(getdate()) as query_run_date
			,Customer
			
			,ProductOrServiceArea
			,RoughUniqueEntitySize
			,ClassifyMaxcontractSize
			, COUNT(DISTINCT AllContractor.RoughUniqueEntity) AS CountOfVendors
			, SUM(AllContractor.SumOfobligatedAmount) AS SumOfobligatedAmount
			, SUM(AllContractor.SumOfnumberOfActions) AS SumOfnumberOfActions
		FROM VendorSizeFPDShistoryBucketCustomerCountry as AllContractor
			--LEFT JOIN Contractor.ParentContractor as ParentContractor 
			--ON AllContractor.AllContractor=ParentContractor.[ParentID]
		where Customer=@customer and IsService=@IsService
		GROUP BY AllContractor.fiscal_year
			,Customer
			
			,ProductOrServiceArea
			,RoughUniqueEntitySize
			,ClassifyMaxcontractSize
		order by fiscal_year
			,customer
			
			,ProductOrServiceArea
			,RoughUniqueEntitySize
			,ClassifyMaxcontractSize
		end
	ELSE --Begin the path where only product or only service codes and all customers will be returned
		BEGIN
		--Copy the start of your query here
		SELECT AllContractor.fiscal_year
			, Customer
			
			,ProductOrServiceArea
			,max(getdate()) as query_run_date
			,RoughUniqueEntitySize
			,ClassifyMaxcontractSize
			, COUNT(DISTINCT AllContractor.roughuniqueEntity) AS CountOfVendors
			, SUM(AllContractor.SumOfobligatedAmount) AS SumOfobligatedAmount
			, SUM(AllContractor.SumOfnumberOfActions) AS SumOfnumberOfActions
		FROM VendorSizeFPDShistoryBucketCustomerCountry as AllContractor
			--LEFT JOIN Contractor.ParentContractor as ParentContractor 
			--ON AllContractor.AllContractor=ParentContractor.[ParentID]
		Where IsService=@IsService
		GROUP BY AllContractor.fiscal_year
			, Customer
			
			,ProductOrServiceArea
			,  RoughUniqueEntitySize
			,ClassifyMaxcontractSize
		order by fiscal_year
			,customer
			
			,ProductOrServiceArea
			,RoughUniqueEntitySize
			,ClassifyMaxcontractSize
		END
	end
else
BEGIN
	IF (@Customer is not null) --Begin sub path where all product and services but only one Customer will be returned
	BEGIN
		--Copy the start of your query here
	SELECT AllContractor.fiscal_year
		,max(getdate()) as query_run_date
		,Customer
		
		,ServicesCategory
		,RoughUniqueEntitySize
		,ClassifyMaxcontractSize
		, COUNT(DISTINCT AllContractor.roughuniqueEntity) AS CountOfVendors
		, SUM(AllContractor.SumOfobligatedAmount) AS SumOfobligatedAmount
		, SUM(AllContractor.SumOfnumberOfActions) AS SumOfnumberOfActions
	FROM VendorSizeFPDShistoryBucketCustomerCountry as AllContractor
		--LEFT JOIN Contractor.ParentContractor as ParentContractor 
		--ON AllContractor.AllContractor=ParentContractor.[ParentID]
	where Customer=@customer
	GROUP BY AllContractor.fiscal_year
		,Customer
		
		,ServicesCategory
		,RoughUniqueEntitySize
		,ClassifyMaxcontractSize
	order by fiscal_year
			,customer
			
			,ServicesCategory
			,RoughUniqueEntitySize
			,ClassifyMaxcontractSize
		--End of your query
	END
	ELSE --Begin sub path where all products and services amd all Customers will be returned
	BEGIN
		--Copy the start of your query here
	SELECT AllContractor.fiscal_year
		, Customer
		
		,ServicesCategory
		,max(getdate()) as query_run_date
		,RoughUniqueEntitySize
		,ClassifyMaxcontractSize
		, COUNT(DISTINCT AllContractor.roughuniqueEntity) AS CountOfVendors
		, SUM(AllContractor.SumOfobligatedAmount) AS SumOfobligatedAmount
		, SUM(AllContractor.SumOfnumberOfActions) AS SumOfnumberOfActions
	FROM VendorSizeFPDShistoryBucketCustomerCountry as AllContractor
		--LEFT JOIN Contractor.ParentContractor as ParentContractor 
		--ON AllContractor.AllContractor=ParentContractor.[ParentID]
	GROUP BY AllContractor.fiscal_year
		, Customer
		
		,  RoughUniqueEntitySize
		,ServicesCategory
		,ClassifyMaxcontractSize
	order by fiscal_year
			,customer
			
			,ServicesCategory
			,RoughUniqueEntitySize
			,ClassifyMaxcontractSize
	END
END


	















GO
