USE [DIIG]
GO

/****** Object:  View [Vendor].[DunsnumberLocationVendorCountryPartial]    Script Date: 1/14/2018 7:39:08 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [Vendor].[DunsnumberLocationVendorCountryPartial]
AS

Select 
	u.dunsnumber
	,u.topISO3countrycode
	,sum(u.obligatedamount) as SumOfobligatedamount
	,sum(u.fed_funding_amount) as SumOffed_funding_amount
	,sum(u.TotalAmount) as TotalAmount
	from (SELECT 
			f.dunsnumber 
			,PartnerISO.[alpha-3] as topISO3countrycode
			, f.obligatedamount 
			, NULL as fed_funding_amount
			, f.obligatedamount AS TotalAmount
		FROM Contract.FPDS as f
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
			g.duns_no as dunsnumber
			,PartnerISO.[alpha-3] as topISO3countrycode
			, NULL AS obligatedamount
			, g.fed_funding_amount  
			, g.fed_funding_amount  AS TotalAmount
		FROM grantloanassistance.faads as g
		LEFT JOIN FPDSTypeTable.Country3lettercode as PartnerCountryCode
			ON g.recipient_country_code = PartnerCountryCode.Country3LetterCode
		left outer join location.CountryCodes as PartnerISO
			on PartnerCountryCode.isoAlpha3 = PartnerISO.[alpha-3]

	) u
	group by 
	u.dunsnumber
	,u.topISO3countrycode



GO


