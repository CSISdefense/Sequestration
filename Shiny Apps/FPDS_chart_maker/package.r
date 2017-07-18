PrepareLabelsAndColors<-function(VAR.Coloration
                                 ,VAR.long.DF
                                 ,VAR.y.series
                                 ,ReplaceNAs=FALSE
                                 #                                  ,VAR.override.coloration=NA
)
{
  if(ReplaceNAs==TRUE){
    VAR.long.DF<-replace_nas_with_unlabeled(VAR.long.DF,VAR.y.series)
  }
  
  VAR.long.DF<-as.data.frame(VAR.long.DF)
  #Confirm that the category is even available in the data set.
  if(!VAR.y.series %in% names(VAR.long.DF)){
    stop(paste(VAR.y.series,"is not found in data frame passed to PrepareLabelsAndColors"))
  }
  
  
  #Translate the category name into the appropriate coloration.key
  #This is used because we have more category names than coloration.key
  Coloration.Key<-read.csv(
    paste(Path,"Lookups\\","lookup_coloration_key.csv",sep=""),
    header=TRUE, sep=",", na.strings="", dec=".", strip.white=TRUE, 
    stringsAsFactors=FALSE
  )
  Coloration.Key<-subset(Coloration.Key, category==VAR.y.series)  
  
  if(nrow(Coloration.Key)==0){
    stop(paste(VAR.y.series,"is missing from Lookup_Coloration.Key.csv"))
  }
  
  
  #Limit the lookup table to those series that match the variable   
  labels.category.DF<-subset(VAR.Coloration, coloration.key==Coloration.Key$coloration.key[1] )
  
  #Fix oddities involving text
  labels.category.DF$variable <- gsub("\\\\n","\n",labels.category.DF$variable)
  labels.category.DF$Label <- gsub("\\\\n","\n",labels.category.DF$Label)
  
  if(anyDuplicated(labels.category.DF$variable)>0){
    print(labels.category.DF$variable[
      duplicated(labels.category.DF$variable)])
    stop(paste("Lookup_Coloration.csv has"
               ,sum(duplicated(labels.category.DF$variable))
               ,"duplicate value(s) for category="
               ,Coloration.Key$coloration.key[1], ". See above for a list of missing labels")
    )
  }
  
  
  #Check for any values in the VAR.y.series field that are not assigned a color.
  NA.labels<-subset(VAR.long.DF,!(data.frame(VAR.long.DF)[,VAR.y.series] %in% labels.category.DF$variable))
  
  if (nrow(NA.labels)>0){
    print(unique(NA.labels[,VAR.y.series]))
    stop(paste("Lookup_Coloration.csv is missing"
               ,length(unique(NA.labels[,VAR.y.series]))
               ,"label(s) for category="
               ,Coloration.Key$coloration.key[1], ". See above for a list of missing labels")
    )
  } 
  rm(NA.labels,Coloration.Key)
  
  names.DF<-subset(labels.category.DF
                   , variable %in% unique(VAR.long.DF[,VAR.y.series]))
  
  rm(labels.category.DF)
  
  #Order the names.DF and then pass on the same order to the actual data in VAR.long.DF
  names.DF<-names.DF[order(names.DF$Display.Order),]

  
  names.DF
}


#************************************Remove NAs
replace_nas_with_unlabeled<- function(VAR.df,VAR.column){
  VAR.df<-as.data.frame(VAR.df)
  if(any(is.na(VAR.df[VAR.column,]))){
    #Make sure unlabeled is within the list of levels
    if (!("Unlabeled" %in% levels(VAR.df[,VAR.column]))){
      VAR.df[,VAR.column]<-addNA(VAR.df[,VAR.column],ifany=TRUE)
      levels(VAR.df[,VAR.column])[is.na(levels(VAR.df[,VAR.column]))] <- "Unlabeled"
    }
  }
  VAR.df
}


NA.check<-function(VAR.df
                   , VAR.input
                   , VAR.output
                   , VAR.file
){
  #Limit just to relevant columns
  NA.check.df<-subset(VAR.df
                      , select=c(VAR.input,VAR.output)
  )
  #Drop all rows
  NA.check.df<-NA.check.df[!complete.cases(NA.check.df),]
  
  if(nrow(NA.check.df)>0){
    print(unique(NA.check.df))
    stop(paste(nrow(NA.check.df)
               ,"rows of NAs generated in "
               ,paste(VAR.output,collapse=", ")
               ,"from "
               ,VAR.file)
    )
  }
}


read_and_join<-function(VAR.path,
                        VAR.file,
                        VAR.existing.df,
                        directory="Lookups\\",
                        by=NULL,
                        ReplaceNAsColumns=NULL,
                        LookupTrumps=TRUE,
                        NA.check.columns=NULL,
                        OnlyKeepCheckedColumns=FALSE){
  
  if(!is.null(ReplaceNAsColumns)){
    VAR.existing.df<-replace_nas_with_unlabeled(VAR.existing.df,ReplaceNAsColumns)
  }
  

  lookup.file<-read.csv(
    paste(VAR.path,directory,VAR.file,sep=""),
    header=TRUE, sep=ifelse(substring(VAR.file,nchar(VAR.file)-3)==".csv",",","\t"), na.strings=c("NA","NULL"), dec=".", strip.white=TRUE,
    stringsAsFactors=FALSE  #This can get weird when true, as sometimes it confuses numerical variables and factors
  )
  
  #Remove nonsense characters sometimes added to start of files
  colnames(VAR.existing.df)[substring(colnames(VAR.existing.df),1,3)=="?.."]<-
    substring(colnames(VAR.existing.df)[substring(colnames(VAR.existing.df),1,3)=="?.."],4)
  
  #Remove nonsense characters sometimes added to start of files
  colnames(lookup.file)[substring(colnames(lookup.file),1,3)=="?.."]<-
    substring(colnames(lookup.file)[substring(colnames(lookup.file),1,3)=="?.."],4)
  
  
  #Clear out any fields held in common not used in the joining
  if(!is.null(by)){
    droplist<-names(lookup.file)[names(lookup.file) %in% names(VAR.existing.df)]
    droplist<-droplist[droplist!=by]
    if(NewColumnsTrump)
      VAR.existing.df<-VAR.existing.df[,!names(VAR.existing.df) %in% droplist]
    else
      lookup.file<-lookup.file[,!names(lookup.file) %in% droplist]
  }
  
  
  #Fixes for Excel's penchant to drop leading 0s.
  if("Contracting.Agency.ID" %in% names(lookup.file) & "VAR.existing.df" %in% names(lookup.file)){
    lookup.file$Contracting.Agency.ID<-factor(str_pad(lookup.file$Contracting.Agency.ID,4,side="left",pad="0"))
    VAR.existing.df$Contracting.Agency.ID<-as.character(VAR.existing.df$Contracting.Agency.ID)
    VAR.existing.df$Contracting.Agency.ID[is.na(VAR.existing.df$Contracting.Agency.ID=="")]<-"0000"
    VAR.existing.df$Contracting.Agency.ID<-factor(str_pad(VAR.existing.df$Contracting.Agency.ID,4,side="left",pad="0"))
  }
  
  if("CSIScontractID" %in% colnames(lookup.file)){
    if(!is.numeric(lookup.file$CSIScontractID)){
      lookup.file$CSIScontractID<-as.numeric(as.character(lookup.file$CSIScontractID))
    }
  }
  
  if(is.null(by)){
    VAR.existing.df<- plyr::join(
      VAR.existing.df,
      lookup.file,
      match="first"
    )
  }
  else{
    VAR.existing.df<- plyr::join(
      VAR.existing.df,
      lookup.file,
      match="first",
      by=by
      
    )
    
  }
  
  if(!is.null(by)&!is.null(NA.check.columns)){
    NA.check(VAR.existing.df,
             VAR.input=by,
             VAR.output=NA.check.columns,
             VAR.file=VAR.file)
    #Clear out any fields held in common not used in the joining
    
    if(OnlyKeepCheckedColumns==TRUE){
      droplist<-names(lookup.file)[!names(lookup.file) %in% by
                                   &!names(lookup.file) %in% NA.check.columns]
      
      VAR.existing.df<-VAR.existing.df[,!names(VAR.existing.df) %in% droplist]
    }
  }
  
  VAR.existing.df
}



#***********************Standardize Variable Names
standardize_variable_names<- function(VAR.Path,VAR.df){
  #Remove nonsense characters sometimes added to start of files
  colnames(VAR.df)[substring(colnames(VAR.df),1,3)=="?.."]<-
    substring(colnames(VAR.df)[substring(colnames(VAR.df),1,3)=="?.."],4)
  
  
  #Consider removing non-alphanumerics _s .s etc.
  
  #***Standardize variable names
  NameList<-read.csv(
    paste(
      VAR.Path,
      "Lookups\\","Lookup_StandardizeVariableNames.csv",sep=""),
    header=TRUE, sep=",", na.strings=c("NA","NULL"), dec=".", strip.white=TRUE, 
    stringsAsFactors=FALSE
  )
  
  
  #     NameList<-subset(NameList,toupper(Original) %in% toupper(colnames(VAR.df)))
  for(x in 1:nrow(NameList)){
    #         if(toupper(NameList$Original[[x]]) %in% OldNameListUpper){
    colnames(VAR.df)[toupper(colnames(VAR.df))==toupper(NameList$Original[[x]])]<-
      NameList$Replacement[[x]]
    #         }
  }
  
  VAR.df
}
