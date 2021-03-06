USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_VendorHistoryBucketCrosstabCount]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [Vendor].[SP_VendorHistoryBucketCrosstabCount]
	@Customer VARCHAR(255)
	,@ServicesOnly Bit

AS

IF (@Customer is not null) --Begin sub path where only services with only one Customer will be returned
BEGIN
	select fiscal_year, max(getdate()) as QueryRunDate
		,@customer as customer
       ,'ERS' as category
       ,sum(pams) as Pams
       ,sum(rnd) as RnD
       ,sum(ICT) as ICT
       ,sum(ers) as ERS
       ,sum(FRS_C) as FRS_C
       ,sum(med) as med
	   ,sum(products) as products
       ,sum(fuel) as fuel

	from contractor.AllContractorHistoryBucketCrosstabCustomerPartial as crosstab
	where crosstab.ERS=1 and customer=@customer
	group by fiscal_year

	select fiscal_year, max(getdate()) as QueryRunDate
		,@customer as customer
       ,'PAMS' as category
       ,sum(pams) as Pams
       ,sum(rnd) as RnD
       ,sum(ICT) as ICT
       ,sum(ers) as ERS
       ,sum(FRS_C) as FRS_C
       ,sum(med) as med
       ,sum(products) as products
       ,sum(fuel) as fuel

	from contractor.AllContractorHistoryBucketCrosstabCustomerPartial as crosstab
	where crosstab.PAMS=1 and customer=@customer
	group by fiscal_year
	
	select fiscal_year, max(getdate()) as QueryRunDate
		,@customer as customer
       ,'RND' as category
       ,sum(pams) as Pams
       ,sum(rnd) as RnD
       ,sum(ICT) as ICT
       ,sum(ers) as ERS
       ,sum(FRS_C) as FRS_C
       ,sum(med) as med
       ,sum(products) as products
       ,sum(fuel) as fuel

	from contractor.AllContractorHistoryBucketCrosstabCustomerPartial as crosstab
	where crosstab.RND=1 and customer=@customer
	group by fiscal_year

	select fiscal_year, max(getdate()) as QueryRunDate
		,@customer as customer
       ,'ICT' as category
       ,sum(pams) as Pams
       ,sum(rnd) as RnD
       ,sum(ICT) as ICT
       ,sum(ers) as ERS
       ,sum(FRS_C) as FRS_C
       ,sum(med) as med
       ,sum(products) as products
       ,sum(fuel) as fuel

	from contractor.AllContractorHistoryBucketCrosstabCustomerPartial as crosstab
	where crosstab.ICT=1 and customer=@customer
	group by fiscal_year

	select fiscal_year, max(getdate()) as QueryRunDate
		,@customer as customer
       ,'FRS_C' as category
       ,sum(pams) as Pams
       ,sum(rnd) as RnD
       ,sum(ICT) as ICT
       ,sum(ers) as ERS
       ,sum(FRS_C) as FRS_C
       ,sum(med) as med
       ,sum(products) as products
       ,sum(fuel) as fuel

	from contractor.AllContractorHistoryBucketCrosstabCustomerPartial as crosstab
	where crosstab.FRS_C=1 and customer=@customer
	group by fiscal_year

	select fiscal_year, max(getdate()) as QueryRunDate
		,@customer as customer
       ,'MED' as category
       ,sum(pams) as Pams
       ,sum(rnd) as RnD
       ,sum(ICT) as ICT
       ,sum(ers) as ERS
       ,sum(FRS_C) as FRS_C
       ,sum(med) as med
       ,sum(products) as products
       ,sum(fuel) as fuel

	from contractor.AllContractorHistoryBucketCrosstabCustomerPartial as crosstab
	where crosstab.MED=1 and customer=@customer
	group by fiscal_year

	IF not(@ServicesOnly=1)
	BEGIN --Begin path where only service entries will be returned.
		select fiscal_year, max(getdate()) as QueryRunDate
			,@customer as customer
			,'products' as category
			,sum(pams) as Pams
			,sum(rnd) as RnD
			,sum(ICT) as ICT
			,sum(ers) as ERS
			,sum(FRS_C) as FRS_C
			,sum(med) as med
			,sum(products) as products
			,sum(fuel) as fuel

		from contractor.AllContractorHistoryBucketCrosstabCustomerPartial as crosstab
		where crosstab.products=1 and customer=@customer
		group by fiscal_year
	
		select fiscal_year, max(getdate()) as QueryRunDate
			,@customer as customer
			,'fuel' as category
			,sum(pams) as Pams
			,sum(rnd) as RnD
			,sum(ICT) as ICT
			,sum(ers) as ERS
			,sum(FRS_C) as FRS_C
			,sum(med) as med
			,sum(products) as products
			,sum(fuel) as fuel

		from contractor.AllContractorHistoryBucketCrosstabCustomerPartial as crosstab
		where crosstab.fuel=1 and customer=@customer
		group by fiscal_year

END
END

	ELSE --Begin sub path where only services but all Customers will be returned
	BEGIN
	select fiscal_year, max(getdate()) as QueryRunDate
		,'ERS' as category
		,sum(pams) as Pams
		,sum(rnd) as RnD
		,sum(ICT) as ICT
		,sum(ers) as ERS
		,sum(FRS_C) as FRS_C
		,sum(med) as med
		,sum(products) as products
		,sum(fuel) as fuel

	from contractor.AllContractorHistoryBucketCrosstabPartial as crosstab
	where crosstab.ERS=1
	group by fiscal_year

	select fiscal_year, max(getdate()) as QueryRunDate
       ,'PAMS' as category
       ,sum(pams) as Pams
       ,sum(rnd) as RnD
       ,sum(ICT) as ICT
       ,sum(ers) as ERS
       ,sum(FRS_C) as FRS_C
       ,sum(med) as med
       ,sum(products) as products
       ,sum(fuel) as fuel

	from contractor.AllContractorHistoryBucketCrosstabPartial as crosstab
	where crosstab.PAMS=1
	group by fiscal_year
	
	select fiscal_year, max(getdate()) as QueryRunDate
       ,'RND' as category
       ,sum(pams) as Pams
       ,sum(rnd) as RnD
       ,sum(ICT) as ICT
       ,sum(ers) as ERS
       ,sum(FRS_C) as FRS_C
       ,sum(med) as med
       ,sum(products) as products
       ,sum(fuel) as fuel

	from contractor.AllContractorHistoryBucketCrosstabPartial as crosstab
	where crosstab.RND=1
	group by fiscal_year

	select fiscal_year, max(getdate()) as QueryRunDate
       ,'ICT' as category
       ,sum(pams) as Pams
       ,sum(rnd) as RnD
       ,sum(ICT) as ICT
       ,sum(ers) as ERS
       ,sum(FRS_C) as FRS_C
       ,sum(med) as med
       ,sum(products) as products
       ,sum(fuel) as fuel

	from contractor.AllContractorHistoryBucketCrosstabPartial as crosstab
	where crosstab.ICT=1
	group by fiscal_year

	select fiscal_year, max(getdate()) as QueryRunDate
       ,'FRS_C' as category
       ,sum(pams) as Pams
       ,sum(rnd) as RnD
       ,sum(ICT) as ICT
       ,sum(ers) as ERS
       ,sum(FRS_C) as FRS_C
       ,sum(med) as med
       ,sum(products) as products
       ,sum(fuel) as fuel

	from contractor.AllContractorHistoryBucketCrosstabPartial as crosstab
	where crosstab.FRS_C=1
	group by fiscal_year

	select fiscal_year, max(getdate()) as QueryRunDate
       ,'MED' as category
       ,sum(pams) as Pams
       ,sum(rnd) as RnD
       ,sum(ICT) as ICT
       ,sum(ers) as ERS
       ,sum(FRS_C) as FRS_C
       ,sum(med) as med
       ,sum(products) as products
       ,sum(fuel) as fuel

	from contractor.AllContractorHistoryBucketCrosstabPartial as crosstab
	where crosstab.MED=1
	group by fiscal_year

IF isnull(@ServicesOnly,0)=0
BEGIN --Begin path where only service entries will be returned.
	select fiscal_year, max(getdate()) as QueryRunDate
       ,'products' as category
       ,sum(pams) as Pams
       ,sum(rnd) as RnD
       ,sum(ICT) as ICT
       ,sum(ers) as ERS
       ,sum(FRS_C) as FRS_C
       ,sum(med) as med
       ,sum(products) as products
       ,sum(fuel) as fuel

	from contractor.AllContractorHistoryBucketCrosstabPartial as crosstab
	where crosstab.products=1
	group by fiscal_year
	
	select fiscal_year, max(getdate()) as QueryRunDate
       ,'fuel' as category
       ,sum(pams) as Pams
       ,sum(rnd) as RnD
       ,sum(ICT) as ICT
       ,sum(ers) as ERS
       ,sum(FRS_C) as FRS_C
       ,sum(med) as med
       ,sum(products) as products
       ,sum(fuel) as fuel

	from contractor.AllContractorHistoryBucketCrosstabPartial as crosstab
	where crosstab.fuel=1
	group by fiscal_year

END
END	






GO
