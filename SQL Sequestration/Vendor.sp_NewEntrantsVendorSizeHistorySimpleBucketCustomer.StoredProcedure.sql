USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[sp_NewEntrantsVendorSizeHistorySimpleBucketCustomer]    Script Date: 3/16/2017 12:26:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [Vendor].[sp_NewEntrantsVendorSizeHistorySimpleBucketCustomer]
@Customer VARCHAR(255),
@Simple VARCHAR(20)

AS

IF (@Simple is not null)
BEGIN --Begin path where only service entries will be returned.
	IF (@Customer is not null) --Begin sub path where only services only one Customer will be returned
	BEGIN	
		--Copy the start of your query here
		SELECT [fiscal_year]
			,FirstFYinDataset
			,VendorSize
			,count(distinct [ParentIDorDunsNumber]) as CountOfParentIDorDunsNumber
			,[Customer]
			--,[SubCustomer]
			--,[ProductOrServiceArea]
			,[Simple]
			--,[RnD_BudgetActivity]
			,sum([obligatedamount]) as SumOfObligatedAmount     
			,min(MaxParentIDorDunsNumberTransaction) as SmallestQualifyingMaxTransaction
		FROM [DIIG].[Vendor].[NewEntrantParentIDorDunsNumberSimpleBucketCustomer]
		--Here's the where clause for @Simple=@Simple and Customer is not null
		WHERE Customer=@Customer
			AND Simple=@Simple
		--Copy the end of your query here
		group by [fiscal_year]
			,FirstFYinDataset
			,VendorSize
			,[Customer]
			--,[SubCustomer]
			--,[ProductOrServiceArea]
			,[Simple]
			--,[RnD_BudgetActivity]
		--End of your query
		END
	ELSE --Begin sub path where only services but all Customers will be returned
		BEGIN
		--Copy the start of your query here
		SELECT [fiscal_year]
			,FirstFYinDataset
			,VendorSize
			,count(distinct [ParentIDorDunsNumber]) as CountOfParentIDorDunsNumber
			,[Customer]
			--,[SubCustomer]
			--,[ProductOrServiceArea]
			,[Simple]
			--,[RnD_BudgetActivity]
			,sum([obligatedamount]) as SumOfObligatedAmount
			,min(MaxParentIDorDunsNumberTransaction) as SmallestQualifyingMaxTransaction
		FROM [DIIG].[Vendor].[NewEntrantParentIDorDunsNumberSimpleBucketCustomer]
		--Here's the where clause for @Simple=@Simple and Customer is not null
		WHERE Simple=@Simple
		--Copy the end of your query here
		group by [fiscal_year]
			,FirstFYinDataset
			,VendorSize
			,VendorSize
			,[Customer]
			--,[SubCustomer]
			--,[ProductOrServiceArea]
			,[Simple]
			--,[RnD_BudgetActivity]
		--End of your query
		END
	END
ELSE --Begin the path where all product or service codes will be returned
BEGIN
	IF (@Customer is not null) --Begin sub path where all product and services but only one Customer will be returned
	BEGIN
	--declare @customer varchar(50) Added for estimating purposes.
	--set @customer='Defense'
		--Copy the start of your query here
				SELECT [fiscal_year]
			,FirstFYinDataset
			,VendorSize
			,count(distinct [ParentIDorDunsNumber]) as CountOfParentIDorDunsNumber
			,[Customer]
			--,[SubCustomer]
			--,[ProductOrServiceArea]
			,[Simple]
			--,[RnD_BudgetActivity]
			,sum([obligatedamount]) as SumOfObligatedAmount
			,min(MaxParentIDorDunsNumberTransaction) as SmallestQualifyingMaxTransaction
		FROM [DIIG].[Vendor].NewEntrantParentIDorDunsNumberSimpleBucketCustomer
		--Here's the where clause for @Simple=@Simple and Customer is not null
		WHERE Customer=@Customer
		--Copy the end of your query here
		group by [fiscal_year]
			,FirstFYinDataset
			,VendorSize
			,[Customer]
			--,[SubCustomer]
			--,[ProductOrServiceArea]
			,[Simple]
			--,[RnD_BudgetActivity]
		--End of your query
		END
	ELSE --Begin sub path where all products and services amd all Customers will be returned
		BEGIN
		--Copy the start of your query here
				SELECT [fiscal_year]
			,FirstFYinDataset
			,VendorSize
			,count(distinct [ParentIDorDunsNumber]) as CountOfParentIDorDunsNumber
			,[Customer]
			--,[SubCustomer]
			--,[ProductOrServiceArea]
			,[Simple]
			--,[RnD_BudgetActivity]
			,sum([obligatedamount]) as SumOfObligatedAmount
			,min(MaxParentIDorDunsNumberTransaction) as SmallestQualifyingMaxTransaction
		FROM [DIIG].[Vendor].[NewEntrantParentIDorDunsNumberSimpleBucketCustomer]
		--Here's the where clause for all =NULL
		--Copy the end of your query here
		group by [fiscal_year]
			,FirstFYinDataset
			,VendorSize
			,[Customer]
			--,[SubCustomer]
			--,[ProductOrServiceArea]
			,[Simple]
			--,[RnD_BudgetActivity]
		--End of your query
		END
	END



















GO
