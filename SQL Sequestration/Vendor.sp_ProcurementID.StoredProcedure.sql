USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[sp_ProcurementID]    Script Date: 3/16/2017 12:26:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--=============================================================================
--Author: Jing You
--Creation data: 2014-8-4
--Description:Pass the procurement identifier and IDV procurement identifier
--==============================================================================

CREATE PROCEDURE [Vendor].[sp_ProcurementID]
    --Add the parameters for the stored procedure 

	@idvpiid nvarchar(255)

AS

BEGIN

if @idvpiid is null

   --SET NOCOUNT ON added to prevent extra result sets from
   --interfering with SELECT statements
   SET NOCOUNT ON;
   if @idvpiid is null
   raiserror('The value for @idvpiid should not be null.',15,1)

select 'Contract.CSISidvpiidID' as SourceTable
        ,[idvpiid]
  ,[multipleorsingleawardidc]
  ,[typeofidc]
  ,[contractactiontype]
  ,[MinOfFiscal_Year]
  ,[MaxOfFiscal_Year]
  ,[VariationCount]
  ,[CSISidvpiidID]
  from contract.CSISidvpiidID as P
  where p.idvpiid like ('%'+@idvpiid+'%') or p.idvpiid=@idvpiid

END
GO
