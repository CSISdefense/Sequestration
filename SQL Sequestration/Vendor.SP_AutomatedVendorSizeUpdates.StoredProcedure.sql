USE [DIIG]
GO
/****** Object:  StoredProcedure [Vendor].[SP_AutomatedVendorSizeUpdates]    Script Date: 3/16/2017 12:26:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












-- =============================================
-- Author:		Greg Sanders
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Vendor].[SP_AutomatedVendorSizeUpdates]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


alter table contractor.DunsnumbertoParentContractorHistory 
add MaxOfCSIScontractIDObligatedAmount decimal(19,4)


--Direct Dunsnumber assignment 
Update DtPCH
set AnyIsSmall=vendorrollup.MaxofContractingOfficerBusinesssizedetermination
	,AlwaysIsSmall=vendorrollup.MinofContractingOfficerBusinesssizedetermination
	,MaxOfCSIScontractIDObligatedAmount =vendorrollup.MaxOfCSIScontractIDObligatedAmount
from contractor.DunsnumbertoParentContractorHistory  as DtPCH
inner join (select 
	fiscal_year
	,dunsnumber
	,max(contractrollup.MaxofContractingOfficerBusinesssizedetermination) as MaxofContractingOfficerBusinesssizedetermination
	,min(contractrollup.MinofContractingOfficerBusinesssizedetermination) as MinofContractingOfficerBusinesssizedetermination
	,max(CSIScontractIDObligatedAmount) as MaxOfCSIScontractIDObligatedAmount
	from (select c.fiscal_year
		,c.dunsnumber
		,max(iif(c.contractingofficerbusinesssizedetermination='S',1,0)) as MaxofContractingOfficerBusinesssizedetermination
		,min(iif(c.contractingofficerbusinesssizedetermination='S',1,0)) as MinofContractingOfficerBusinesssizedetermination
		,sum(c.obligatedamount) as CSIScontractIDObligatedAmount
		from contract.fpds c
		inner join contract.CSIStransactionID ctid
			on c.CSIStransactionID=ctid.CSIStransactionID
		group by ctid.CSIScontractID
		,c.dunsnumber
		,c.fiscal_year
	) as contractrollup
	group by dunsnumber
	,fiscal_year
) as vendorrollup 
on dtpch.FiscalYear=vendorrollup.fiscal_year
and dtpch.DUNSnumber=vendorrollup.dunsnumber


--ParentDuns assignment
Update DtPCH
set AnyIsSmall=iif(AnyIsSmall=0
			,isnull(vendorrollup.MaxofContractingOfficerBusinesssizedetermination,AnyIsSmall)
			,isnull(DtPCH.AnyIsSmall,vendorrollup.MaxofContractingOfficerBusinesssizedetermination)
			)
	,AlwaysIsSmall=iif(AlwaysIsSmall=1
			,isnull(vendorrollup.MinofContractingOfficerBusinesssizedetermination,AlwaysIsSmall)
			,isnull(AlwaysIsSmall,vendorrollup.MinofContractingOfficerBusinesssizedetermination)
			)
	,MaxOfCSIScontractIDObligatedAmount =iif(DtPCH.MaxOfCSIScontractIDObligatedAmount<vendorrollup.MaxOfCSIScontractIDObligatedAmount
			,isnull(vendorrollup.MaxOfCSIScontractIDObligatedAmount,DtPCH.MaxOfCSIScontractIDObligatedAmount)
			,isnull(DtPCH.MaxOfCSIScontractIDObligatedAmount,vendorrollup.MaxOfCSIScontractIDObligatedAmount)
			)
		
from contractor.DunsnumbertoParentContractorHistory  as DtPCH
inner join (select 
	fiscal_year
	,parentdunsnumber
	,max(contractrollup.MaxofContractingOfficerBusinesssizedetermination) as MaxofContractingOfficerBusinesssizedetermination
	,min(contractrollup.MinofContractingOfficerBusinesssizedetermination) as MinofContractingOfficerBusinesssizedetermination
	,max(CSIScontractIDObligatedAmount) as MaxOfCSIScontractIDObligatedAmount
	from (select c.fiscal_year
		,c.parentdunsnumber
		,max(iif(c.contractingofficerbusinesssizedetermination='S',1,0)) as MaxofContractingOfficerBusinesssizedetermination
		,min(iif(c.contractingofficerbusinesssizedetermination='S',1,0)) as MinofContractingOfficerBusinesssizedetermination
		,sum(c.obligatedamount) as CSIScontractIDObligatedAmount
		from contract.fpds c
		inner join contract.CSIStransactionID ctid
			on c.CSIStransactionID=ctid.CSIStransactionID
		group by ctid.CSIScontractID
		,c.parentdunsnumber
		,c.fiscal_year
	) as contractrollup
	group by parentdunsnumber
	,fiscal_year
) as vendorrollup 
on dtpch.FiscalYear=vendorrollup.fiscal_year
and dtpch.DUNSnumber=vendorrollup.parentdunsnumber

--ParentDuns lookups
Update DtPCH
set AnyIsSmall=NULL
	,AlwaysIsSmall=NULL
	,MaxOfCSIScontractIDObligatedAmount =NULL
from contractor.DunsnumbertoParentContractorHistory  as DtPCH
inner join contractor.parentcontractor parent
on dtpch.parentid=parent.parentid
where parent.UnknownCompany=1








--Direct VendorName assignment 
Update SVNH
set AnyIsSmall=vendorrollup.MaxofContractingOfficerBusinesssizedetermination
	,AlwaysIsSmall=vendorrollup.MinofContractingOfficerBusinesssizedetermination
	,MaxOfCSIScontractIDObligatedAmount =vendorrollup.MaxOfCSIScontractIDObligatedAmount
from vendor.StandardizedVendorNameHistory  as SVNH
inner join (select 
	fiscal_year
	,StandardizedVendorName
	,max(contractrollup.MaxofContractingOfficerBusinesssizedetermination) as MaxofContractingOfficerBusinesssizedetermination
	,min(contractrollup.MinofContractingOfficerBusinesssizedetermination) as MinofContractingOfficerBusinesssizedetermination
	,max(CSIScontractIDObligatedAmount) as MaxOfCSIScontractIDObligatedAmount
	from (select c.fiscal_year
		,vname.StandardizedVendorName
		,max(iif(c.contractingofficerbusinesssizedetermination='S',1,0)) as MaxofContractingOfficerBusinesssizedetermination
		,min(iif(c.contractingofficerbusinesssizedetermination='S',1,0)) as MinofContractingOfficerBusinesssizedetermination
		,sum(c.obligatedamount) as CSIScontractIDObligatedAmount
		from contract.fpds c
		inner join contract.CSIStransactionID ctid
			on c.CSIStransactionID=ctid.CSIStransactionID
		inner join Vendor.VendorName vname
			on c.vendorname=vname.vendorname
		group by ctid.CSIScontractID
		,vname.StandardizedVendorName
		,c.fiscal_year
	) as contractrollup
	group by StandardizedVendorName
	,fiscal_year
) as vendorrollup 
on SVNH.Fiscal_Year=vendorrollup.fiscal_year
and SVNH.StandardizedVendorName=vendorrollup.StandardizedVendorName




--interior.RoughUniqueEntity
--, CASE
--	WHEN parent.Top6=1 and parent.JointVenture=1
--	THEN 'Large: Big 6 JV'
--	WHEN Top6=1
--	THEN 'Large: Big 6'
--	WHEN parent.LargeGreaterThan3B=1
--	THEN 'Large'
--	WHEN parent.LargeGreaterThan1B=1
--	THEN 'Medium >1B'
--	WHEN AnyIsSmall=1 and AlwaysIsSmall=1
--	THEN 'Always Small'
--	WHEN AnyIsSmall=1 and AlwaysIsSmall=0
--	THEN 'Sometimes Small'
--	when parent.UnknownCompany=1
--	Then 'Unlabeled'
--	ELSE 'Medium <1B'
--END AS VendorSize
--,AllContractor
--,interior.fiscal_year
----,interior.LargeGreaterThan1B
----,interior.LargeGreaterThan3B
--,interior.MaxOfobligatedAmountMultiyear
----,interior.AnyIsSmall
----,interior.AlwaysIsSmall
--,interior.SumOfnumberOfActions
----,interior.Top100Federal
----,interior.Top6
----,interior.UnknownCompany
--from 
--	(
--	SELECT 
--	C.fiscal_year
--	, CASE
--	WHEN Parent.ParentID is not null and isnull(Parent.UnknownCompany,0)=0 
--	THEN Parent.ParentID 
--	WHEN c.parentdunsnumber is not null and isnull(ParentSquared.UnknownCompany,0)=0 
--	THEN c.parentdunsnumber
--	WHEN c.dunsnumber is not null and isnull(Parent.UnknownCompany,0)=0 
--	THEN c.dunsnumber
--	ELSE coalesce(c.vendorname
--		, c.vendorlegalorganizationname
--		, c.vendordoingasbusinessname
--		, c.vendoralternatename
--		, c.divisionname
--	)
--	END as RoughUniqueEntity 
--	, Max(IIF(C.contractingofficerbusinesssizedetermination='S'
--			,1
--			,0)) AS AnyIsSmall
--	, Min(IIF(C.contractingofficerbusinesssizedetermination='S'
--			,1
--			,0)) AS AlwaysIsSmall
--	--, C.IDVPIID
--	--, C.PIID
--	, Sum(C.obligatedamount) AS SumOfobligatedAmount
--	, max(contracttotal.SumOfbaseandexercisedoptionsvalue) AS MaxOfobligatedAmountMultiyear
--	--, sum(contracttotal.SumOfbaseandexercisedoptionsvalue) as SumOfMulbaseandexercisedoptionsvalueMultiyear
--	--, Max(contracttotal.SumOfbaseandexercisedoptionsvalue) as MaxOfbaseandexercisedoptionsvalueMultiyear
--	--, sum(contracttotal.SumOfbaseandalloptionsvalue) as SumOfbaseandalloptionsvalueMultiyear
--	--, Max(contracttotal.SumOfbaseandalloptionsvalue) as MaxOfSumOfbaseandalloptionsvalueMultiyear
--	, Sum(C.numberOfActions) AS SumOfnumberOfActions
--	--, ProdServ.ServicesCategory
--	--, Prodserv.isservice
--	--, parent.JointVenture
--	--, parent.UnknownCompany
--	--, parent.Top100Federal
--	--, parent.JointVenture
--	--, parent.LargeGreaterThan3B
--	--, parent.LargeGreaterThan1B
--	--, parent.Top6
--	--, Max(C.obligatedAmount) AS MaxOfobligatedAmount
--	, isnull(parent.parentid,C.dunsnumber)  AS AllContractor
--	,parent.parentid
--FROM
-- Contract.FPDS as C
--	LEFT OUTER JOIN Contractor.DunsnumbertoParentContractorHistory as DUNS
--		ON C.fiscal_year = DUNS.FiscalYear AND C.DUNSNumber = DUNS.DUNSNUMBER
--	LEFT OUTER JOIN Contractor.ParentContractor as PARENT
--		ON DUNS.ParentID = PARENT.ParentID
--	LEFT OUTER JOIN Contractor.DunsnumbertoParentContractorHistory as ParentDUNS
--		ON C.fiscal_year = ParentDUNS.FiscalYear AND C.parentdunsnumber = ParentDUNS.DUNSnumber
--	LEFT OUTER JOIN Contractor.ParentContractor as PARENTsquared
--		ON ParentDUNS.ParentID = PARENTsquared.ParentID
--	LEFT OUTER JOIN FPDSTYPETABLE.AgencyID as AGENCY
--		ON C.contractingOfficeAgencyID = Agency.AGENCYID 
--	--LEFT OUTER JOIN FPDSTYPETable.productorservicecode as ProdServ
--	--	ON C.productOrServiceCode = ProdServ.productorservicecode
--	left outer join contract.CSIStransactionID ctid
--		on c.CSIStransactionID=ctid.CSIStransactionID
--	--left outer join contract.CSIScontractID ccid
--	--	on ctid.CSIScontractID=ccid.CSIScontractID
--	left outer join contract.ContractDiscretization contracttotal
--		on ctid.CSIScontractID=contracttotal.CSIScontractID	

--GROUP BY 
--	C.fiscal_year
--	, CASE
--	WHEN Parent.ParentID is not null and isnull(Parent.UnknownCompany,0)=0 
--	THEN Parent.ParentID 
--	WHEN c.parentdunsnumber is not null and isnull(ParentSquared.UnknownCompany,0)=0 
--	THEN c.parentdunsnumber
--	WHEN c.dunsnumber is not null and isnull(Parent.UnknownCompany,0)=0 
--	THEN c.dunsnumber
--	ELSE coalesce(c.vendorname
--		, c.vendorlegalorganizationname
--		, c.vendordoingasbusinessname
--		, c.vendoralternatename
--		, c.divisionname
--	)
--	END
--	--, parent.UnknownCompany
--	--, parent.Top100Federal
--	--, parent.LargeGreaterThan3B
--	--, parent.LargeGreaterThan1B
--	--, parent.JointVenture
--	--, parent.Top6
--	,parent.parentid
--	, isnull(parent.parentid,C.dunsnumber) 
--	) as interior
--	LEFT OUTER JOIN Contractor.ParentContractor as PARENT
--		ON interior.ParentID = PARENT.ParentID






END



















GO
