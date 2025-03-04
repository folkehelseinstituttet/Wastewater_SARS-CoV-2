library(seqinr)

refs<-read.fasta("/media/nacho/Data/wastewater/ReferencesProb/Spike17022022.fasta")

poi<-c(1250:2250)

lineages<-unique(gsub(".*_","", names(refs)))
bases<-c("a","t","c","g","-")
#Generation of the probability matrix
#Parallel here
pb<-txtProgressBar(min = 1, max = length(poi),initial = 1)
for (i in 1:length(poi)) {
  setTxtProgressBar(pb,i)
  dummym<-matrix(0, ncol = length(lineages), nrow = 5 )
  
  base.m<-lapply(refs, function(x)x[poi[i]])  
  names(base.m)<-gsub(".*_","", names(base.m))
  base.m<-unlist(base.m)
  base.m2<-match(base.m, c("a","t","c","g","-"))
  names(base.m2)<-names(base.m)
  
  for (j in 1:length(lineages)) {
    for (k in c(1:5)) {
      P.L_M<-length(which(names(base.m2)==lineages[j] & base.m2==k))/ length(which(names(base.m2)==lineages[j]))
      AP.L_M<-length(which(names(base.m2)!=lineages[j] & base.m2==k))/ length(which(names(base.m2)!=lineages[j]))
      
      #Priors based on data
      P.L<-length(which(names(base.m2)==lineages[j]))/length(base.m2)
      AP.L<- length(which(names(base.m2)!=lineages[j]))/length(base.m2)
      
      #No prior
      P.L<-1/length(lineages)
      AP.L<-(length(lineages)-1)/length(lineages)
        
     dummym[k,j]<-   (P.L_M * P.L) /((P.L_M * P.L)+(AP.L_M * AP.L))
     #dummym[k,j]<-   P.L_M
    }
  }
  dummym<-as.data.frame(dummym)
  colnames(dummym)<-lineages
  rownames(dummym)<-paste(poi[i],c("A","T","C","G","D"),sep = "")
  if(!exists("dummy.out")){ 
    dummy.out<-dummym
  }else{
      dummy.out<-rbind(dummy.out, dummym)
    }
}

write.csv(dummy.out,"/media/nacho/Data/DockerImages/Wastewater_SARS-CoV-2/CommonFiles/reference/ProbMatrix.csv" )

#print(m %*% n)

