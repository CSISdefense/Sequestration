

  update [DIIG].[ProductOrServiceCode].[PlatformPortfolio]
  set Isplat='Electronics & Communications'
  ,IsLikelyInterlinked=1
  where PlatformPortfolio in ('Electronics, Comms, & Sensors')

  select *
  from [ProductOrServiceCode].[PlatformPortfolio]

  delete [ProductOrServiceCode].[PlatformPortfolio]
  where PlatformPortfolio='Missile and Space Systems'

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
when s.PlatformPortfolio=''
then NULL
when s.PlatformPortfolio='"Electronics'
then 'Electronics, Comms, & Sensors'
when left(s.PlatformPortfolio,11)='Electronics'
then 'Electronics, Comms, & Sensors'
when s.PlatformPortfolio='Aircraft and Drones'
then 'Aircraft'
when s.PlatformPortfolio='Space'
then 'Space Systems'
when s.PlatformPortfolio='Ships and Submarines'
then 'Ships & Submarines'
when s.PlatformPortfolio='Ordnance & Missiles'
then 'Ordnance and Missiles'
when s.PlatformPortfolio='Facilities & Construction'
then 'Facilities and Construction'
when left(s.PlatformPortfolio,4)='Land'
then 'Land Vehicles'
when left(s.PlatformPortfolio,9)='Other R&D'
then 'Other R&D and Knowledge Based'
when left(s.PlatformPortfolio,7)='Weapons'
then 'Ordnance and Missiles'
when left(s.PlatformPortfolio,8)='Ordnance'
then 'Ordnance and Missiles'
when s.PlatformPortfolio='Ordnance & Missiles'
then 'Ordnance and Missiles'
when s.PlatformPortfolio='Unmanned Aircraft'
then 'Aircraft'
when s.PlatformPortfolio='Baltics Missile Defense System'
then 'Missile Defense'
else s.PlatformPortfolio
end 
,IsRemotelyOperated =iif(s.PlatformPortfolio='Unmanned Aircraft'
	,1,IsRemotelyOperated )
from [DIIG].[Project].[Lookup_ProjectIDplatformPortfolio] s
left outer join ProductOrServiceCode.PlatformPortfolio pp
on s.PlatformPortfolio=pp.PlatformPortfolio
where pp.PlatformPortfolio is null and s.PlatformPortfolio is not null



select distinct s.PlatformPortfolio
,pp.PlatformPortfolio 
from [Project].[Lookup_ProjectIDplatformPortfolio] s
full outer join ProductOrServiceCode.PlatformPortfolio pp
on s.PlatformPortfolio=pp.PlatformPortfolio

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
      ,pid.[PlatformPortfolio] as OldMethodPlatformPortfolio
	  ,newpp.[PlatformPortfolio] as ReplacementPlatformPortfolio
	        ,newpp.IsUnknown
      ,newpp.[Wrong]
      ,newpp.[Notes]
      ,pid.[ObligatedAmount]
      ,pid.[MinOfFiscalYear]
      ,pid.[MaxOfFiscalYear]
      ,pid.[TopPlatformPortfolio]
      ,pid.[TopPlatformPortfolioObligatedAmount]
      ,pid.[TopParentID]
      ,pid.[TopParentIDObligatedAmount]
  FROM [DIIG].[Project].[Lookup_ProjectIDplatformPortfolio] NewPP
  left outer join project.ProjectID pid
  on newpp.projectID=pid.ProjectID
   where (NewPP.PlatformPortfolio <> pid.PlatformPortfolio
   or newpp.IsUnknown=1
   or pid.PlatformPortfolio is null
   or newpp.PlatformPortfolio='Missiles and Space Systems')
   and pid.MaxOfFiscalYear>2004

--Tag Investigated Projects
update pid
set CSISmodifiedBy=SYSTEM_USER
,CSISmodifiedDate=getdate()
,IsUninvestigated=0
  FROM [DIIG].[Project].[Lookup_ProjectIDplatformPortfolio] NewPP
  inner join project.ProjectID pid
    on newpp.projectID=pid.ProjectID
where IsUninvestigated=1

SELECT newpp.[ProjectID]
      ,newpp.[ProjectName]
      ,newpp.[ProjectPrettyName]
      ,newpp.[ProjectAbbreviation]
	        ,newpp.[PlatformPortfolio]
      ,newpp.[IsUnknown]
      ,newpp.[IsJointDevelopmentCaseStudy]
      ,newpp.[CSISmodifiedDate]
      ,newpp.[CSISmodifiedBy]
      ,newpp.[IsPerformanceBasedLogistics]
      ,newpp.[ObligatedAmount]
      ,newpp.[MinOfFiscalYear]
      ,newpp.[MaxOfFiscalYear]
      ,newpp.[TopPlatformPortfolio]
      ,newpp.[TopPlatformPortfolioObligatedAmount]
      ,newpp.[TopParentID]
      ,newpp.[TopParentIDObligatedAmount]
      ,newpp.[Wrong]
      ,newpp.[Replacement]
      ,newpp.[Notes]
      ,newpp.[IsRemotelyOperated]

      ,newpp.[WasUncategorizedMissilesOrSpaceSystem]

--update newpp
--set PlatformPortfolio=NULL
from [Project].[Lookup_ProjectIDplatformPortfolio] newpp
inner join ProductOrServiceCode.PlatformPortfolio pp
on newpp.PlatformPortfolio=pp.PlatformPortfolio
  inner join project.ProjectID pid
  on newpp.projectID=pid.ProjectID
where ((newpp.Isunknown =1 or pp.IsPlatformWeaponOrSystem=0) and newpp.PlatformPortfolio is not null) or 
 NewPP.PlatformPortfolio <> pid.PlatformPortfolio
   or (pid.PlatformPortfolio is null and newpp.PlatformPortfolio is not null)
   or (pid.PlatformPortfolio is not null and newpp.PlatformPortfolio is null)
   or coalesce(pid.isunknown,0)<>coalesce(NewPP.isunknown,0)
   or coalesce(pid.notes,'')<>coalesce(NewPP.notes,'')


--update newpp
--set PlatformPortfolio='Electronics, Comms, & Sensors'
----,ProjectPrettyName='Air-Launched Cruise Missile'
--,CSISmodifiedBy=SYSTEM_USER
--,CSISmodifiedDate=getdate()
--from [Project].[Lookup_ProjectIDplatformPortfolio] newpp
--where projectID=947

update pid
set CSISmodifiedBy='Brian and Ravi update implemented by '+SYSTEM_USER
,CSISmodifiedDate=GETDATE()
,IsUninvestigated=0
,IsUnknown=coalesce(newpp.IsUnknown,pid.IsUnknown)
,IsRemotelyOperated=coalesce(newpp.IsRemotelyOperated,pid.IsRemotelyOperated)
,PlatformPortfolio=newpp.PlatformPortfolio
,notes=coalesce(newpp.notes,pid.notes)
  FROM [DIIG].[Project].[Lookup_ProjectIDplatformPortfolio] NewPP
  inner join project.ProjectID pid
  on newpp.projectID=pid.ProjectID
   where NewPP.PlatformPortfolio <> pid.PlatformPortfolio
   or (pid.PlatformPortfolio is null and newpp.PlatformPortfolio is not null)
   or (pid.PlatformPortfolio is not null and newpp.PlatformPortfolio is null)
   or coalesce(pid.isunknown,0)<>coalesce(NewPP.isunknown,0)
   or coalesce(pid.notes,'')<>coalesce(NewPP.notes,'')
   or (newpp.IsRemotelyOperated<>pid.IsRemotelyOperated or
   newpp.IsRemotelyOperated is not null and pid.IsRemotelyOperated is null)



--update [Project].[Lookup_ProjectIDplatformPortfolio]
--set 

----PlatformPortfolio='Aircraft'
----,Replacement='Aircraft'
----,Notes='Advanced Tactical Airborne Reconnaisance System'
----Notes='',
----WRONG=''
--ProjectName='Joint Simulation'
--,ProjectPrettyName='Joint Simulation'
----,Notes='Reused code for SGT YORK GUN (DIVAD) '
--where projectid in (1337) and ProjectName<>'Joint Simulation'
-- --and PlatformPortfolio<> 'Missile Defense'

--update pid 
--set PlatformPortfolio=newpp.PlatformPortfolio
--  FROM [DIIG].[Project].[Lookup_ProjectIDplatformPortfolio] NewPP
--  left outer join project.ProjectID pid
--  on newpp.projectID=pid.ProjectID
--   where (NewPP.PlatformPortfolio <> pid.PlatformPortfolio
--   or investigate<>''
--   or pid.PlatformPortfolio is null
--   or newpp.PlatformPortfolio='Missiles and Space Systems')
--   and pid.MaxOfFiscalYear>2004


--Stinger ordnance and missiles

SELECT *
FROM contract.FPDS f
