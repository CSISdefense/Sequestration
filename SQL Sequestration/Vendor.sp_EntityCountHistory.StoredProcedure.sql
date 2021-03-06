USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[sp_VendorHistoryCustomer]    Script Date: 3/16/2017 12:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






Alter PROCEDURE [Vendor].[sp_EntityCountHistory]


AS
--Copy the start of your query here
			--SELECT [fiscal_year]
			--,ent.EntitySizeCode      
			--,esc.EntitySizeText
			--,EntityCategory
		 -- ,AnyEntityUSplaceOfPerformance
		 -- ,IsEntityAbove1990constantReportingThreshold
		 -- ,IsEntityAbove2016constantReportingThreshold
		 -- ,count(distinct [Entity]) [EntityCount]
		 -- ,count(distinct [AllContractor]) as [AllContractorCount]
		 -- ,sum([numberOfActions]) as SumOfNumberOfActions
		 -- ,sum([ObligatedAmount]) as [SumOfObligatedAmount]

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [fiscal_year]
			,ent.EntitySizeCode      
			,esc.EntitySizeText
,EntityCategory
      ,[AnyEntityUSplaceOfPerformance]	
        ,[IsEntityAbove1990constantReportingThreshold]
      ,[IsEntityAbove2016constantReportingThreshold]
,count(distinct EntityText ) as EntityCount
      ,count(distinct [AllContractor]) as  [AllContractor]
	  ,sum([NumberOfActions]) as SumOfNumberOfActions
      ,sum([ObligatedAmount]) as  SumOfObligatedAmount
  FROM [DIIG].[Vendor].[EntityIDhistory] ent
  left outer join Vendor.EntitySizeCode esc
  on esc.EntitySizeCode=ent.EntitySizeCode
  group by       [fiscal_year]
  			,ent.EntitySizeCode      
			,esc.EntitySizeText
  ,EntityCategory
      ,[IsEntityAbove1990constantReportingThreshold]
      ,[IsEntityAbove2016constantReportingThreshold]
      ,[AnyEntityUSplaceOfPerformance]





GO
