

  update [DIIG].[ProductOrServiceCode].[PlatformPortfolio]
  set Isplat='Electronics & Communications'
  ,IsLikelyInterlinked=1
  where PlatformPortfolio in ('Electronics, Comms, & Sensors')

  delete [ProductOrServiceCode].[PlatformPortfolio]
  where PlatformPortfolio='Unmanned'

  /****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [PlatformPortfolio]
      ,[IsLikelyInterlinked]
      ,[ProductOrServiceArea]
      ,[IsPlatform]
      ,[NewPlatformPortfolio]
  FROM [DIIG].[ProductOrServiceCode].[PlatformPortfolio]

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [ProductOrServiceArea]
      ,[SimpleBucket]
      ,[IsService]
      ,[PlatformPortfolio]
  FROM [DIIG].[ProductOrServiceCode].[ProductOrServiceArea]


UPDATE psa
SET PlatformPortfolio = pp.NewPlatformPortfolio
FROM [DIIG].[ProductOrServiceCode].[ProductOrServiceArea] psa
inner join [ProductOrServiceCode].PlatformPortfolio pp
on pp.PlatformPortfolio = psa.PlatformPortfolio
where pp.PlatformPortfolio <> pp.NewPlatformPortfolio

UPDATE psc
SET PlatformPortfolio = pp.NewPlatformPortfolio
FROM FPDSTypeTable.[ProductOrServiceCode] psc
inner join [ProductOrServiceCode].PlatformPortfolio pp
on pp.PlatformPortfolio = psc.PlatformPortfolio
where pp.PlatformPortfolio <> pp.NewPlatformPortfolio

UPDATE proj
SET PlatformPortfolio = pp.NewPlatformPortfolio
FROM Project.ProjectID proj
inner join [ProductOrServiceCode].PlatformPortfolio pp
on pp.PlatformPortfolio = proj.PlatformPortfolio
where pp.PlatformPortfolio <> pp.NewPlatformPortfolio

UPDATE proj
SET TopPlatformPortfolio = pp.NewPlatformPortfolio
FROM Project.ProjectID proj
inner join [ProductOrServiceCode].PlatformPortfolio pp
on pp.PlatformPortfolio = proj.TopPlatformPortfolio
where pp.PlatformPortfolio <> pp.NewPlatformPortfolio


update  s
set Replacement=case
when s.Replacement=''
then NULL
when s.Replacement='"Electronics'
then 'Electronics, Comms, & Sensors'
when left(s.Replacement,11)='Electronics'
then 'Electronics, Comms, & Sensors'
when s.Replacement='Aircraft and Drones'
then 'Aircraft'
when s.Replacement='Space'
then 'Space Systems'
when s.Replacement='Ships and Submarines'
then 'Ships & Submarines'
when s.Replacement='Ordnance & Missiles'
then 'Ordnance and Missiles'
when s.Replacement='Facilities & Construction'
then 'Facilities and Construction'
when left(s.Replacement,4)='Land'
then 'Land Vehicles'
when left(s.Replacement,9)='Other R&D'
then 'Other R&D and Knowledge Based'
when left(s.Replacement,7)='Weapons'
then 'Ordnance and Missiles'
when s.Replacement='Unmanned Aircraft'
then 'Aircraft'
when s.Replacement='Baltics Missile Defense System'
then 'Missile Defense'
else s.Replacement
end 
,IsRemotelyOperated =iif(s.Replacement='Unmanned Aircraft'
	,1,IsRemotelyOperated )
from [DIIG].[Project].[Lookup_ProjectIDplatformPortfolio] s
left outer join ProductOrServiceCode.PlatformPortfolio pp
on s.Replacement=pp.PlatformPortfolio
where pp.PlatformPortfolio is null and s.Replacement is not null

select distinct s.replacement
,pp.PlatformPortfolio 
from [Project].[Lookup_ProjectIDplatformPortfolio] s
full outer join ProductOrServiceCode.PlatformPortfolio pp
on s.Replacement=pp.PlatformPortfolio

select *

--update p
--set PlatformPortfolio=MinOfFiscalYear
--,wrong = notes
--,notes=[column 20]
from [Project].[Lookup_ProjectIDplatformPortfolio] p
where Replacement='Baltics Missile Defense System'

alter table [Project].[Lookup_ProjectIDplatformPortfolio]
add IsRemotelyOperated bit

select *
from FPDSTypeTable.newpp s
left outer join FPDSTypeTable.ProductOrServiceCode psc
on s.ProductOrServiceCode=psc.ProductOrServiceCode
where [New Platform Portfolio]='TBD'

update FPDSTypeTable.newpp 
set [New Platform Portfolio]='Other Services'
where productorservicecode='V111'

select psc.ProductOrServiceCode,
psc.ProductOrServiceCodeText,
 psc.PlatformPortfolio as originalPP
,s.[New Platform Portfolio] as newPP
from FPDSTypeTable.newpp s
left outer join FPDSTypeTable.ProductOrServiceCode psc
on s.ProductOrServiceCode=psc.ProductOrServiceCode
where [New Platform Portfolio]<>psc.PlatformPortfolio

update psc
set PlatformPortfolio=[New Platform Portfolio]
from FPDSTypeTable.newpp s
left outer join FPDSTypeTable.ProductOrServiceCode psc
on s.ProductOrServiceCode=psc.ProductOrServiceCode
where [New Platform Portfolio]<>psc.PlatformPortfolio

/****** Script for SelectTopNRows command from SSMS  ******/
/****** Script for SelectTopNRows command from SSMS  ******/
SELECT pid.ProjectID
      ,pid.[ProjectName]
      ,pid.[ProjectPrettyName]
      ,pid.[ProjectAbbreviation]
      --,pid.[IsJointDevelopmentCaseStudy]
      --,pid.[CSISmodifiedDate]
      --,pid.[CSISmodifiedBy]
      --,pid.[IsPerformanceBasedLogistics]
      ,pid.[PlatformPortfolio] 
	  ,newpp.[PlatformPortfolio]
      ,pid.[ObligatedAmount]
      ,pid.[MinOfFiscalYear]
      ,pid.[MaxOfFiscalYear]
      ,pid.[TopPlatformPortfolio]
      ,pid.[TopPlatformPortfolioObligatedAmount]
      ,pid.[TopParentID]
      ,pid.[TopParentIDObligatedAmount]
      ,newpp.[Investigate]
      ,newpp.[Wrong]
      ,newpp.[Replacement]
      ,newpp.[Notes]
      ,newpp.[Column 20]
  FROM [DIIG].[Project].[Lookup_ProjectIDplatformPortfolio] NewPP
  left outer join project.ProjectID pid
  on newpp.projectID=pid.ProjectID
   