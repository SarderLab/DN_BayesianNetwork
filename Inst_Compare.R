# Comparing networks generated from multiple institutions worth of data

library(bnlearn)


##### Read in all data and fit network for each ############
Beans = list()
ct<- 1
inst = c("Combined","Gloms","VUMC","Brazil")
for (i in inst){
  
  filename = paste(paste("C:/Users/spborder/Desktop/BN_Project/All_Data/",i),"_feats_filtered.csv")
  filename = gsub(" ","",filename)
  
  node_data=read.csv(file = filename, header = TRUE,sep = ",")
  
  
  node_data_df<-data.frame(node_data)
  #remove rows with NaN
  node_data_df = node_data_df[complete.cases(node_data_df), ]
  
  Beans[[ct]]<- hc(node_data_df)
  ct<-ct+1
  
  print(paste(i," Finished"))

}


####### Calculating Structural Hamming Distance for each pair of networks ######

shds = list()
kt<-1
for (j in 1:length(inst)){
  for (k in 1:length(inst)){
    
    dat<- data.frame(Inst1 = inst[j],Inst2 = inst[k], SHD = shd(Beans[[j]],Beans[[k]]))
    
    shds[[kt]]<-dat
    kt<-kt+1
    
  }
}

Full_SHD = do.call(rbind, shds)



