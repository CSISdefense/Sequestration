USE [DIIG]
GO
/****** Object:  View [Vendor].[ParentLocationVendorCountryPartial]    Script Date: 3/16/2017 12:26:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












alter VIEW [Vendor].[ParentLocationVendorCountryPartial]
AS

Select 
	u.parentid
	,u.topISO3countrycode
	,sum(u.obligatedamount) as SumOfobligatedamount
	,sum(u.fed_funding_amount) as SumOffed_funding_amount
	,sum(u.TotalAmount) as TotalAmount
	from (SELECT 
			dtpch.ParentID
			,PartnerISO.[alpha-3] as topISO3countrycode
			, f.obligatedamount 
			, NULL as fed_funding_amount
			, f.obligatedamount AS TotalAmount
		FROM Contract.FPDS as f
		left join Contractor.DunsnumberToParentContractorHistory as dtpch
			on f.dunsnumber=dtpch.DUNSnumber
			and f.fiscal_year=dtpch.FiscalYear
		LEFT JOIN FPDSTypeTable.vendorcountrycode as PartnerCountryCodePartial
			ON f.vendorcountrycode=PartnerCountryCodePartial.vendorcountrycode
		left join FPDSTypeTable.Country3LetterCode as c3lc
		on PartnerCountryCodePartial.Country3LetterCode = c3lc.Country3LetterCode
		left outer join location.CountryCodes as PartnerISO
			on c3lc.isoAlpha3 = PartnerISO.[alpha-3]
	--GROUP BY 
	--	f.dunsnumber
	--	,f.fiscal_year
	--	,VN.StandardizedVendorName
		UNION
		SELECT
			dtpch.parentid
			,PartnerISO.[alpha-3] as topISO3countrycode
			, NULL AS obligatedamount
			, g.fed_funding_amount  
			, g.fed_funding_amount  AS TotalAmount
		FROM grantloanassistance.faads as g
		left join Contractor.DunsnumberToParentContractorHistory as dtpch
			on g.duns_no=dtpch.DUNSnumber
			and g.fiscal_year=dtpch.FiscalYear
		LEFT JOIN FPDSTypeTable.Country3lettercode as PartnerCountryCode
			ON g.recipient_country_code = PartnerCountryCode.Country3LetterCode
		left outer join location.CountryCodes as PartnerISO
			on PartnerCountryCode.isoAlpha3 = PartnerISO.[alpha-3]

	) u
	group by 
	u.parentid
	,u.topISO3countrycode



GO
