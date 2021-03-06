USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_StandardVendorQueriesCount]    Script Date: 3/16/2017 12:26:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [Vendor].[SP_StandardVendorQueriesCount]

@Customer VARCHAR(255),
@IsService Bit

AS
SET nocount on -- to prevent errors and actually get results
Declare @return_value int

/*5.*/
    EXEC	@return_value = [Vendor].[SP_VendorSizeHistoryCount]
		    @Customer,
		    @IsService 

/*6.*/
	IF (@Customer is not null) 
   BEGIN
   EXEC	@return_value = [Vendor].[SP_VendorSizeHistoryCustomerCount]
		@Customer,
		@IsService 
	END
	ELSE
	BEGIN
	EXEC @return_value = [Vendor].[SP_VendorSizeHistorySubCustomerCount]
		 @Customer,
		 @IsService 
	END



EXEC	@return_value = [Vendor].[SP_VendorSizeHistoryBucketCount]
		@Customer =@Customer ,
		@IsService = @IsService

/*6.*/
	IF (@Customer is not null) 
   BEGIN
   EXEC	@return_value = [Vendor].[SP_VendorSizeHistoryBucketCustomerCount]
		@Customer =@Customer ,
		@IsService = @IsService
	END
	ELSE
	BEGIN
	EXEC	@return_value = [Vendor].[SP_VendorSizeHistoryBucketSubCustomerCount]
		@Customer =@Customer ,
		@IsService = @IsService

	END










GO
