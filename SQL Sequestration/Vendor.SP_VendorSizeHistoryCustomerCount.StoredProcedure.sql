USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_VendorSizeHistoryCustomerCount]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [Vendor].[SP_VendorSizeHistoryCustomerCount]
@Customer VARCHAR(255),
@ServicesOnly Bit


AS

IF (@ServicesOnly is not null)
BEGIN --Begin path where only service entries will be returned.
	IF (@Customer is not null) --Begin sub path where only services only one Customer will be returned
		begin
		SELECT AllContractor.fiscal_year
			,max(getdate()) as query_run_date
			,Customer
			,RoughUniqueEntitySize
			,ClassifyMaxcontractSize
			, COUNT(DISTINCT AllContractor.RoughUniqueEntity) AS CountOfVendors
			, SUM(AllContractor.SumOfobligatedAmount) AS SumOfobligatedAmount
			, SUM(AllContractor.SumOfnumberOfActions) AS SumOfnumberOfActions
		FROM VendorSizeFPDShistoryBucketCustomerCountry as AllContractor
			--LEFT JOIN Contractor.ParentContractor as ParentContractor 
			--ON AllContractor.AllContractor=ParentContractor.[ParentID]
		where Customer=@customer
		GROUP BY AllContractor.fiscal_year
			,Customer
			,RoughUniqueEntitySize
			,ClassifyMaxcontractSize
		order by fiscal_year
			,customer
			,RoughUniqueEntitySize
			,ClassifyMaxcontractSize
		end
	ELSE --Begin the path where all product or service codes will be returned
		BEGIN
		--Copy the start of your query here
		SELECT AllContractor.fiscal_year
			, Customer
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
			,ClassifyMaxcontractSize
		order by fiscal_year
			,customer
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
		,RoughUniqueEntitySize
		,ClassifyMaxcontractSize
	order by fiscal_year
			,customer
			,RoughUniqueEntitySize
			,ClassifyMaxcontractSize
		--End of your query
	END
	ELSE --Begin sub path where all products and services amd all Customers will be returned
	BEGIN
		--Copy the start of your query here
	SELECT AllContractor.fiscal_year
		, Customer
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
		,ClassifyMaxcontractSize
	order by fiscal_year
			,customer
			,RoughUniqueEntitySize
			,ClassifyMaxcontractSize
	END
END


	











GO
