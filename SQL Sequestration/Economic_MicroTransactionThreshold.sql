USE [DIIG]
GO

/****** Object:  View [Economic].[MicroTransactionThreshold]    Script Date: 1/9/2018 12:25:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
ALTER view [Economic].[MicroTransactionThreshold]
as
SELECT [Fiscal_Year]
      ,3500*GDPdeflator2016 as MicroTransactionThreshold2016constant
      ,25000*GDPdeflator1990 as MicroTransactionThreshold1990constant
  FROM [DIIG].[Economic].[Deflators]

GO


