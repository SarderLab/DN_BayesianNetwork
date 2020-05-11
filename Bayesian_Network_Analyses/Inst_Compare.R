# Comparing networks generated from multiple institutions worth of data

library(bnlearn)


##### Read in all data and fit network for each ############
Beans = list()
ct<- 1
n_inst = 4

for (i in 1:n_inst){
  
  node_data=read.csv(file = file.choose(), header = TRUE,sep = ",")
  
  
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
for (j in 1:n_inst){
  for (k in 1:n_inst){
    
    dat<- data.frame(Inst1 = j,Inst2 = k, SHD = shd(Beans[[j]],Beans[[k]]))
    
    shds[[kt]]<-dat
    kt<-kt+1
    
  }
}

Full_SHD = do.call(rbind, shds)



