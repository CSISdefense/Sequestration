USE [DIIG]
GO
/****** Object:  View [Vendor].[VehicleVendorSizeHistoryBucketSubCustomerClassification]    Script Date: 3/16/2017 12:26:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









Create VIEW [Vendor].[VehicleVendorSizeHistoryBucketSubCustomerClassification]
AS
select 
	fiscal_year
	,Query_Run_Date
	,Customer
	,SubCustomer
	,ServicesCategory
	,IsService
	,CSISPortfolio
	,DoDportfolio
	,Country3LetterCodeText
	,Region
	 ,iif(addmodified=1 and ismodified=1,'Modified ','')+
		case
			when addmultipleorsingawardidc=1 
			then case 
				when multipleorsingleawardidc is null
				then 'Unlabeled '+AwardOrIDVcontractactiontype
				else multipleorsingleawardidc+' '+AwardOrIDVcontractactiontype
				--Blank multipleorsingleawardIDC
			end
			else AwardOrIDVcontractactiontype 
	end		as VehicleClassification
	,VendorSize
	--,sum(SumOfobligatedAmount) as SumOfobligatedAmount
	--,sum(SumOfnumberOfActions) as SumOfnumberOfActions
	,obligatedAmount --) as SumOfobligatedAmount
	,numberOfActions -- as SumOfnumberOfActions
FROM (
SELECT 
C.fiscal_year
,getdate() AS Query_Run_Date
,isnull(Agency.customer,Agency.agencyIDtext) AS Customer
,Agency.SubCustomer
,PSC.ServicesCategory
,Scat.IsService
,PSC.CSISPortfolio
,PSC.DoDportfolio
,CountryCode.Country3LetterCodeText
,CountryCode.Region
,isnull(idvtype.contractactiontypetext,ctype.contractactiontypetext) as AwardOrIDVcontractactiontype
,isnull(IDVmulti.multipleorsingleawardidctext, Cmulti.multipleorsingleawardidctext) 
	as multipleorsingleawardidc 
,isnull(IDVtype.addmultipleorsingawardidc,ctype.addmultipleorsingawardidc) as addmultipleorsingawardidc
,isnull(IDVtype.addmodified,ctype.addmodified) as addmodified
,idv.typeofidc as IDVtypeofIDC
,Rmod.IsModified
, CASE
	WHEN Parent.Top6=1 and Parent.JointVenture=1
	THEN 'Large: Big 6 JV'
	WHEN Parent.Top6=1
	THEN 'Large: Big 6'
	WHEN Parent.LargeGreaterThan3B=1
	THEN 'Large'
	WHEN Parent.LargeGreaterThan1B=1
	THEN 'Medium >1B'
	WHEN C.contractingofficerbusinesssizedetermination='s' or C.contractingofficerbusinesssizedetermination='y'
	THEN 'Small'
	when Parent.UnknownCompany=1
	Then 'Unlabeled'
	ELSE 'Medium <1B'
END AS VendorSize
--,Sum(C.obligatedAmount) AS SumOfobligatedAmount
--,Sum(C.numberOfActions) AS SumOfnumberOfActions
,C.obligatedAmount--) AS SumOfobligatedAmount
,C.numberOfActions--) AS SumOfnumberOfActions


FROM Contract.FPDS as C
	LEFT JOIN FPDSTypeTable.AgencyID AS Agency
		ON C.AgencyID=Agency.AgencyID
	LEFT JOIN FPDSTypeTable.ProductOrServiceCode AS PSC
		ON C.productorservicecode=PSC.ProductOrServiceCode
	LEFT JOIN FPDSTypeTable.reasonformodification as Rmod
		ON C.reasonformodification=Rmod.reasonformodification
	LEFT JOIN FPDSTypeTable.Country3lettercode as CountryCode
		ON C.placeofperformancecountrycode=CountryCode.Country3LetterCode
	LEFT JOIN ProductOrServiceCode.ServicesCategory As Scat
		ON Scat.ServicesCategory = PSC.ServicesCategory
	--Block of CSISIDjoins
		left join contract.csistransactionid as CTID
			on c.CSIStransactionID=ctid.CSIStransactionID
		left join contract.CSISidvmodificationID as idvmod
			on ctid.CSISidvmodificationID=idvmod.CSISidvmodificationID
		left join contract.CSISidvpiidID as idv
			on idv.CSISidvpiidID=idvmod.CSISidvpiidID
			--Block of vehicle lookups
		Left JOIN FPDSTypeTable.multipleorsingleawardidc as Cmulti
			on C.multipleorsingleawardidc=Cmulti.multipleorsingleawardidc
		Left JOIN FPDSTypeTable.multipleorsingleawardidc as IDVmulti
			on isnull(idvmod.multipleorsingleawardidc,idv.multipleorsingleawardidc)=IDVMulti.multipleorsingleawardidc
		Left JOIN FPDSTypeTable.ContractActionType as Ctype
			on C.ContractActionType=Ctype.unseperated
		Left JOIN FPDSTypeTable.ContractActionType as IDVtype
			on isnull(idvmod.ContractActionType,idv.ContractActionType)=IDVtype.unseperated
	--Parent lookups

	LEFT OUTER JOIN Contractor.DunsnumbertoParentContractorHistory as DUNS
		ON C.fiscal_year = DUNS.FiscalYear 
		AND C.DUNSNumber = DUNS.DUNSNUMBER
	LEFT OUTER JOIN Contractor.ParentContractor as PARENT
		ON DUNS.ParentID = PARENT.ParentID

--GROUP BY 
--C.fiscal_year
--,isnull(Agency.customer,Agency.agencyIDtext)
--,Agency.SubCustomer
--,PSC.ServicesCategory
--,Scat.IsService
--,PSC.CSISPortfolio
--,PSC.DoDportfolio 
--,CountryCode.Country3LetterCodeText
--,CountryCode.Region
--,isnull(idvtype.contractactiontypetext,ctype.contractactiontypetext) 
--,isnull(IDVmulti.multipleorsingleawardidctext, Cmulti.multipleorsingleawardidctext) 
--,idv.typeofidc 
--,isnull(IDVtype.addmultipleorsingawardidc,ctype.addmultipleorsingawardidc) 
--,isnull(IDVtype.addmodified,ctype.addmodified) 
--,Rmod.IsModified
--, CASE
--	WHEN Parent.Top6=1 and Parent.JointVenture=1
--	THEN 'Large: Big 6 JV'
--	WHEN Parent.Top6=1
--	THEN 'Large: Big 6'
--	WHEN Parent.LargeGreaterThan3B=1
--	THEN 'Large'
--	WHEN Parent.LargeGreaterThan1B=1
--	THEN 'Medium >1B'
--	WHEN C.contractingofficerbusinesssizedetermination='s' or C.contractingofficerbusinesssizedetermination='y'
--	THEN 'Small'
--	when Parent.UnknownCompany=1
--	Then 'Unlabeled'
--	ELSE 'Medium <1B'
--END 
) C
--Vendor.VehicleVendorSizeHistoryBucketSubCustomerPartial
--group by 
--	fiscal_year
--	,Query_Run_Date
--	,Customer
--	,SubCustomer
--	,ServicesCategory
--	,IsService
--	,CSISPortfolio
--	,DoDportfolio
--	,Country3LetterCodeText
--	,Region
--	 ,iif(addmodified=1 and ismodified=1,'Modified ','')+
--		case
--			when addmultipleorsingawardidc=1 
--			then case 
--				when multipleorsingleawardidc is null
--				then 'Unlabeled '+AwardOrIDVcontractactiontype
--				else multipleorsingleawardidc+' '+AwardOrIDVcontractactiontype
--				--Blank multipleorsingleawardIDC
--			end
--			else AwardOrIDVcontractactiontype 
--	end	
--	,VendorSize










GO
