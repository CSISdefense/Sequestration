USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[sp_SmallBusinessClassificationCustomer]    Script Date: 3/16/2017 12:26:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [Vendor].[sp_SmallBusinessClassificationCustomer]
@Customer VARCHAR(255)

AS

IF (@Customer is not null) --Begin sub path where all product and services but only one Customer will be returned
	BEGIN
		--Copy the start of your query here
		SELECT S.fiscal_year
			,S.Query_Run
			,S.Customer
			,S.typeofsetaside
			,S.Firm8A
			,S.HUBZone
			,S.MinorityOwned
			,S.MinoritySetAside
			,S.NativeGroupOwned
			,S.SmallDisadvantagedBusiness
			,S.VeteranOwned
			,S.WomanOwned
			,sum(S.SubOfObligatedAmount)
			
		FROM Vendor.SmallBusinessSetAsideClassification as S
		--Here's the where clause for @ServicesOnly is null and Customer is not null
		WHERE S.Customer=@Customer
		--Copy the end of your query here
		GROUP BY S.fiscal_year
			,S.Query_Run
			,S.Customer
			,S.typeofsetaside
			,S.Firm8A
			,S.HUBZone
			,S.MinorityOwned
			,S.MinoritySetAside
			,S.NativeGroupOwned
			,S.SmallDisadvantagedBusiness
			,S.VeteranOwned
			,S.WomanOwned
		--End of your query
		END
	ELSE --Begin sub path where all products and services amd all Customers will be returned
		BEGIN
		--Copy the start of your query here
		SELECT S.fiscal_year
			,S.Query_Run
			,S.Customer
			,S.typeofsetaside
			,S.Firm8A
			,S.HUBZone
			,S.MinorityOwned
			,S.MinoritySetAside
			,S.NativeGroupOwned
			,S.SmallDisadvantagedBusiness
			,S.VeteranOwned
			,S.WomanOwned
			,sum(S.SubOfObligatedAmount)
		FROM Vendor.SmallBusinessSetAsideClassification as S
		--There is no Where clause, because everything is being returned
		--Copy the end of your query here
		GROUP BY S.fiscal_year
			,S.Query_Run
			,S.Customer
			,S.typeofsetaside
			,S.Firm8A
			,S.HUBZone
			,S.MinorityOwned
			,S.MinoritySetAside
			,S.NativeGroupOwned
			,S.SmallDisadvantagedBusiness
			,S.VeteranOwned
			,S.WomanOwned
		--End of your query
		END














GO
