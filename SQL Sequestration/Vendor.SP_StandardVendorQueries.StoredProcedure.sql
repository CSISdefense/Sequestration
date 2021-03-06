USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_StandardVendorQueries]    Script Date: 3/16/2017 12:26:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [Vendor].[SP_StandardVendorQueries]

@Customer VARCHAR(255),
@IsService Bit

AS
SET nocount on -- to prevent errors and actually get results

DECLARE	@return_value int




/*1.*/
    EXEC	@return_value = [Vendor].[SP_TopVendorHistory]
		    @Customer,
		    @IsService 


/*2.*/
		IF (@Customer is not null) 
   BEGIN
   EXEC	@return_value =  [Vendor].[sp_TopVendorHistorySubCustomer]
		@Customer,
		@IsService 
	END
	ELSE
	BEGIN
	EXEC @return_value =  [Vendor].[sp_TopVendorHistoryCustomer]
		 @Customer,
		 @IsService 
	END

	


/*3.*/

EXEC     @return_value = [Vendor].[SP_TopVendorHistoryBucket]
		 @Customer,
		 @IsService 

		
--DECLARE	@return_value int
--declare @Customer VARCHAR(255)
--declare @IsService Bit
--set @customer='Defense'
--set @isservice=0


/*4.*/
		IF (@Customer is not null) 
   BEGIN
   EXEC	@return_value =  [Vendor].[sp_VendorSizeHistoryBucketSubCustomer]
		@Customer,
		@IsService 
	END
	ELSE
	BEGIN
	EXEC @return_value =  [Vendor].[sp_VendorSizeHistoryBucketCustomer]
		 @Customer,
		 @IsService 
	END











GO
