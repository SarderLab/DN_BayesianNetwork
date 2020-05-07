library(bnlearn)
library(bnviewer)
library(readxl)
library(bnstruct)

#import node_data_stage_nolabel dataset
node_data_filtered <-read.csv(file = "C:/Users/spborder/Desktop/BN_Project/All_Data/Combined_feats_filtered.csv", header = TRUE, sep = ",")

#putting data in dataframe format
node_data_df<-data.frame(node_data_filtered)

#Inferencing Network
#data(node_data_df)
fitted_net_hc=bn.fit(hc(node_data_df),node_data_df)

NEdgeLdev = 0
DegPN = 1
EccMu = 0
count=0

problist = list()

for (i in 1:20){
  for (j in 1:20){
    for (k in 1:20){
      NEdgeLdev=NEdgeLdev+(2/100)
  
      prob=cpquery(fitted_net_hc,
                   event = (DN_Stage>=3),
                   evidence = ((NormEdgeLength.sig. >= -NEdgeLdev)&(Deg.node >=DegPN)&(Eccentricity.mu. >=EccMu)))
      
      dat <- data.frame(NormalizedEdgeLengthstd=NEdgeLdev, DegreesPerNode=DegPN, EccentricityMu=EccMu, prob=prob)
      
      count=count+1
      problist[[count]] <- dat
      
    
    DegPN=DegPN+(1/100)
  
    prob=cpquery(fitted_net_hc,
                 event = (DN_Stage>=3),
                 evidence = ((NormEdgeLength.sig. >= -NEdgeLdev)&(Deg.node >=DegPN)&(Eccentricity.mu. >=EccMu)))
    
    dat <- data.frame(NormalizedEdgeLengthstd=NEdgeLdev, DegreesPerNode=DegPN, EccentricityMu=EccMu, prob=prob)
    
    count=count+1
    problist[[count]] <- dat
    
    
  EccMu=EccMu+(60000/100)
  
  prob=cpquery(fitted_net_hc,
               event = (DN_Stage>=3),
               evidence = ((NormEdgeLength.sig. >= -NEdgeLdev)&(Deg.node >=DegPN)&(Eccentricity.mu. >=EccMu)))
  
  dat <- data.frame(NormalizedEdgeLengthstd=NEdgeLdev, DegreesPerNode=DegPN, EccentricityMu=EccMu, prob=prob)
  
  count=count+1
  problist[[count]] <- dat
  
print(count)
#print(NEdgeLdev)
#print(DegPN)
#print(DegPN)
    }
  }
}

fullproblist = do.call(rbind, problist)

#write.csv(fullproblist,"C:/Users/spborder/Desktop/BN_Project/All_probs.csv")
plot(fullproblist[1:250,1],fullproblist[1:250,4],
     xlab = "Norm Edge Length (std)",ylab = "P(DN > 3 | Norm Edge Length (std) > X)")

plot(fullproblist[1:250,2],fullproblist[1:250,4],
     xlab = "Degrees/Node",ylab = "P(DN > 3 | Degrees/Node > X)")

plot(fullproblist[1:250,1],fullproblist[1:250,4],
     xlab = "Eccentricity (avg)",ylab = "P(DN > 3 | Eccentricity (avg) > X)")

NEdgeLdev=0
problist_norm=list()
for (k in 1:20){
  NEdgeLdev=NEdgeLdev+(2/100)
  
  prob=cpquery(fitted_net_hc,
               event = (DN_Stage>=3),
               evidence = ((NormEdgeLength.sig. >= -NEdgeLdev)))
  
  dat <- data.frame(NormalizedEdgeLengthstd=NEdgeLdev, prob=prob)
  
  problist_norm[[k]] <- dat
}

fullproblist_norm = do.call(rbind, problist_norm)
plot(fullproblist_norm[,1],fullproblist_norm[,2],
     xlab = "Normalized Edge Length (std)", ylab = "P(DN > 3 | Normalized Edge Length (std) > X)")




#write.csv(fullproblist,"C:/Users/spborder/Desktop/BN Project/fullproblist_Norm.csv")

DegPN = 1
problist=list()
for (j in 1:20){
  DegPN=DegPN+(1/100)
  
  prob=cpquery(fitted_net_hc,
               event = (DN.Stage>=3),
               evidence = ((Deg.node >=DegPN)))
  
  dat <- data.frame(DegreesPerNode=DegPN, prob=prob)
  
  problist[[j]] <- dat
}
#fullproblist = do.call(rbind, problist)

#write.csv(fullproblist,"C:/Users/spborder/Desktop/BN Project/fullproblist_Deg.csv")

EccMu = 0
problist=list()
for (i in 1:20){
  EccMu=EccMu+(60000/100)
  
  prob=cpquery(fitted_net_hc,
               event = (DN_Stage>=3),
               evidence = ((Eccentricity.mu. >=EccMu)))
  
  dat <- data.frame(EccentricityMu=EccMu, prob=prob)
  
  problist[[i]] <- dat
}
#fullproblist = do.call(rbind, problist)

#write.csv(fullproblist,"C:/Users/spborder/Desktop/BN Project/fullproblist_Ecc.csv")

Area=20000
problist_A=list()
for(l in 1:20){
  Area=Area+(1000000/20)
  
  prob=cpquery(fitted_net_hc,
               event = (DN_Stage>=3),
               evidence = ((Glom_Area >=Area)))
  dat <- data.frame(Glom_Area=Area,prob=prob)
  problist_A[[l]] <- dat
}
fullproblist_A = do.call(rbind,problist_A)

plot(fullproblist_A[,1],fullproblist_A[,2],
     xlab = "Glomerular Area", ylab = "P(DN > 3 | Glomerular Area > X)")


#write.csv(fullproblist,"C:/Users/spborder/Desktop/BN Project/fullproblist_Area.csv")


Nuc=5
problist_nuc=list()
for(l in 1:20){
  Nuc=Nuc+(400/20)
  
  prob=cpquery(fitted_net_hc,
               event = (DN_Stage>=3),
               evidence = ((Nuclei >=Nuc)))
  dat <- data.frame(NumNuclei=Nuc,prob=prob)
  problist_nuc[[l]] <- dat
}
fullproblist_nuc = do.call(rbind,problist_nuc)

plot(fullproblist_nuc[,1],fullproblist_nuc[,2],
     xlab = "Number of Nuclei", ylab = "P(DN > 3 | #Nuclei > X)")

EccMu = 0
problist_ecc=list()
for(l in 1:20){
  EccMu=EccMu+(60000/20)  
  prob=cpquery(fitted_net_hc,
               event = (DN_Stage>=3),
               evidence = ((Eccentricity.mu. >=EccMu)))
  dat <- data.frame(EccMu=EccMu,prob=prob)
  problist_ecc[[l]] <- dat
}
fullproblist_ecc = do.call(rbind,problist_ecc)

plot(fullproblist_ecc[,1],fullproblist_ecc[,2],
     xlab = "Eccentricity (avg)", ylab = "P(DN > 3 | Eccentricity (avg) > X)")








#write.csv(fullproblist,"C:/Users/spborder/Desktop/BN Project/fullproblist_Nuc.csv")


EccMu = 0
EccMu_list=list()
for (i in 1:20){
  EccMu=EccMu+(60000/20)
  
  dat <- data.frame(EccMu=EccMu)
  
  EccMu_list[[i]]<-dat
  
}


NEdgeLdev = 0
NormLen_list=list()
for (i in 1:20){
  NEdgeLdev=NEdgeLdev+(2/20)
  
  dat <- data.frame(NormLen_s=NEdgeLdev)
  
  NormLen_list[[i]]<-dat
  
}


count=0
problist_mix = list()
for (i in 1:length(EccMu_list)){
  for (j in 1:length(NormLen_list)){
    
    #Ecc=EccMu_list[[i]]
    #Norm=-NormLen_list[[j]]
    print(i)
    print(j)
    
    prob=cpquery(fitted_net_hc,
                 event = (DN_Stage>=3),
                 evidence = ((Eccentricity.mu. >=EccMu_list[[i]])&(NormEdgeLength.sig. >= NormLen_list[[j]])))
    
    dat <- data.frame(Eccentricity=EccMu_list[[i]],NormLength_s=-NormLen_list[[j]],prob=prob)
    
    
    problist_mix[[count]] <- dat
    count=count+1
    
  }
}

fullproblist_mix = do.call(rbind,problist_mix)


#write.csv(fullproblist,"C:/Users/spborder/Desktop/BN Project/fullproblist_Ecc_Norm.csv")



