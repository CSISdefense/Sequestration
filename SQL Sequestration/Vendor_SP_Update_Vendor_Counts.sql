USE [DIIG]
GO

DECLARE	@return_value int

EXEC	@return_value = [Vendor].[sp_EntityCountHistoryCustomer]
		@Customer = NULL

SELECT	'Return Value' = @return_value

Go

DECLARE	@return_value int

EXEC	@return_value = [Vendor].[sp_EntityCountHistoryPlatformCustomer]
		@Customer = N'Defense'

SELECT	'Return Value' = @return_value

GO

DECLARE	@return_value int

EXEC	@return_value = [Vendor].[sp_EntityCountHistoryPlatformSubCustomer]
		@Customer = N'Defense'

SELECT	'Return Value' = @return_value

GO

DECLARE	@return_value int

EXEC	@return_value = [Vendor].[sp_EntityCountHistorySubCustomer]
		@Customer = N'Defense'

SELECT	'Return Value' = @return_value

GO
