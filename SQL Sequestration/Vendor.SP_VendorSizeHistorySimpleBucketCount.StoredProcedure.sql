USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_VendorSizeHistorySimpleBucketCount]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [Vendor].[SP_VendorSizeHistorySimpleBucketCount]
@Customer VARCHAR(255),
@IsService Bit


AS

IF (@IsService is not null)
BEGIN --Begin path where only service or only product entries will be returned.
	IF (@Customer is not null) --Begin sub path where only services or only products only one Customer will be returned
		begin
		SELECT AllContractor.fiscal_year
			,max(getdate()) as query_run_date
			,Customer		
			,Simple
			,RoughUniqueEntitySize
			,ClassifyMaxcontractSize
			, COUNT(DISTINCT AllContractor.RoughUniqueEntity) AS CountOfVendors
			, SUM(AllContractor.SumOfobligatedAmount) AS SumOfobligatedAmount
			, SUM(AllContractor.SumOfnumberOfActions) AS SumOfnumberOfActions
		FROM VendorSizeFPDShistoryBucketCustomerCountry as AllContractor
			--LEFT JOIN Contractor.ParentContractor as ParentContractor 
			--ON AllContractor.AllContractor=ParentContractor.[ParentID]
		where Customer=@customer and isservice=@isservice
		GROUP BY AllContractor.fiscal_year
			,Customer
			
			,Simple
			,RoughUniqueEntitySize
			,ClassifyMaxcontractSize
		order by fiscal_year
			,customer
			
			,Simple
			,RoughUniqueEntitySize
			,ClassifyMaxcontractSize
		end
	ELSE --Begin the path where all product or service codes will be returned
		BEGIN
		--Copy the start of your query here
		SELECT AllContractor.fiscal_year
			
			
			,Simple
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
			
			
			,Simple
			,  RoughUniqueEntitySize
			,ClassifyMaxcontractSize
		order by fiscal_year
			
			
			,Simple
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
		
		,Simple
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
		
		,Simple
		,RoughUniqueEntitySize
		,ClassifyMaxcontractSize
	order by fiscal_year
			,customer
			
			,Simple
			,RoughUniqueEntitySize
			,ClassifyMaxcontractSize
		--End of your query
	END
	ELSE --Begin sub path where all products and services amd all Customers will be returned
	BEGIN
		--Copy the start of your query here
	SELECT AllContractor.fiscal_year
		
		
		,Simple
		,max(getdate()) as query_run_date
		,RoughUniqueEntitySize
		,ClassifyMaxcontractSize
		, COUNT(DISTINCT AllContractor.roughuniqueEntity) AS CountOfVendors
		, SUM(AllContractor.SumOfobligatedAmount) AS SumOfobligatedAmount
		, SUM(AllContractor.SumOfnumberOfActions) AS SumOfnumberOfActions
	FROM VendorSizeFPDShistoryBucketCustomerCountry as AllContractor
		--LEFT JOIN Contractor.ParentContractor as ParentContractor 
		--ON AllContractor.AllContractor=ParentContractor.[ParentID]
		where isservice=@isservice
	GROUP BY AllContractor.fiscal_year
		
		
		,  RoughUniqueEntitySize
		,Simple
		,ClassifyMaxcontractSize
	order by fiscal_year
			
			
			,Simple
			,RoughUniqueEntitySize
			,ClassifyMaxcontractSize
	END
END


	















GO
