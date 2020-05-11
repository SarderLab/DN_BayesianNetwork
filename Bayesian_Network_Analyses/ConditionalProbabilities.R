
# Modeling influences of individual features on probability of higher DN stages


library(bnlearn)


#Import full dataset with feature headers
node_data<-read.csv(file = file.choose(), header = TRUE, sep = ",")

#putting data in dataframe format
node_data_df<-data.frame(node_data)

#Inferencing Network
fitted_net_hc=bn.fit(hc(node_data_df),node_data_df)


# Normalized Edge Length
NEdgeLdev=0
increment = 0.02

problist_norm=list()
for (k in 1:20){
  
  NEdgeLdev=NEdgeLdev+increment
  
  prob=cpquery(fitted_net_hc,
               event = (DN_Stage>=3),
               evidence = ((NormEdgeLength.sig. >= -NEdgeLdev)))
  
  dat <- data.frame(NormalizedEdgeLengthstd=NEdgeLdev, prob=prob)
  
  problist_norm[[k]] <- dat
}

fullproblist_norm = do.call(rbind, problist_norm)
plot(fullproblist_norm[,1],fullproblist_norm[,2],
     xlab = "Normalized Edge Length (std)", ylab = "P(DN > 3 | Normalized Edge Length (std) > X)")

save_filename = 'Normalized_Edge_Length_probs.csv'
write.csv(fullproblist,save_filename)


# Degrees/node
DegPN = 1
increment = 0.01

problist=list()
for (j in 1:20){
  DegPN=DegPN+increment
  
  prob=cpquery(fitted_net_hc,
               event = (DN_Stage>=3),
               evidence = ((Deg.node >=DegPN)))
  
  dat <- data.frame(DegreesPerNode=DegPN, prob=prob)
  
  problist[[j]] <- dat
}
fullproblist_dpn = do.call(rbind, problist)
plot(fullproblist_dpn[,1],fullproblist_dpn[,2],
     xlab = "Degrees Per Node", ylab = "P(DN > 3 | Degrees Per Node > X)")

save_filename = 'Degrees_Per_Node_probs.csv'
write.csv(fullproblist_dpn,save_filename)


#Average Eccentricity
EccMu = 0
increment = 600

problist=list()
for (i in 1:20){
  EccMu=EccMu+increment
  
  prob=cpquery(fitted_net_hc,
               event = (DN_Stage>=3),
               evidence = ((Eccentricity.mu. >=EccMu)))
  
  dat <- data.frame(EccentricityMu=EccMu, prob=prob)
  
  problist[[i]] <- dat
}
fullproblist_eccmu = do.call(rbind, problist)

plot(fullproblist_eccmu[,1],fullproblist_eccmu[,2],
     xlab = "Average Eccentricity", ylab = "P(DN > 3 | Average Eccentricity > X)")

save_filename = 'Average_Eccentricity_probs.csv'
write.csv(fullproblist_eccmu,save_filename)



#Glomerular Area
Area=20000
increment = 50000

problist_A=list()
for(l in 1:20){
  Area=Area+increment
  
  prob=cpquery(fitted_net_hc,
               event = (DN_Stage>=3),
               evidence = ((Glom_Area >=Area)))
  dat <- data.frame(Glom_Area=Area,prob=prob)
  problist_A[[l]] <- dat
}
fullproblist_A = do.call(rbind,problist_A)

plot(fullproblist_A[,1],fullproblist_A[,2],
     xlab = "Glomerular Area", ylab = "P(DN > 3 | Glomerular Area > X)")

save_filename = 'Glomerular_Area_probs.csv'
write.csv(fullproblist_A,save_filename)


#Number of Nuclei
Nuc=5
increment = 20

problist_nuc=list()
for(l in 1:20){
  Nuc=Nuc+increment
  
  prob=cpquery(fitted_net_hc,
               event = (DN_Stage>=3),
               evidence = ((Nuclei >=Nuc)))
  dat <- data.frame(NumNuclei=Nuc,prob=prob)
  problist_nuc[[l]] <- dat
}
fullproblist_nuc = do.call(rbind,problist_nuc)

plot(fullproblist_nuc[,1],fullproblist_nuc[,2],
     xlab = "Number of Nuclei", ylab = "P(DN > 3 | #Nuclei > X)")

save_filename = 'Num_Nuclei_probs.csv'
write.csv(fullproblist_nuc,save_filename)


#Combining Average Eccentricity and Normalized Edge Length Std. Dev.
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
    
    prob=cpquery(fitted_net_hc,
                 event = (DN_Stage>=3),
                 evidence = ((Eccentricity.mu. >=EccMu_list[[i]])&(NormEdgeLength.sig. >= NormLen_list[[j]])))
    
    dat <- data.frame(Eccentricity=EccMu_list[[i]],NormLength_s=-NormLen_list[[j]],prob=prob)
    
    problist_mix[[count]] <- dat
    count=count+1
    
  }
}

fullproblist_mix = do.call(rbind,problist_mix)

save_filename = 'AvgEcc_NormEdge_std.csv'
write.csv(fullproblist_mix,save_filename")




