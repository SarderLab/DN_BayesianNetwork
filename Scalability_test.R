## Testing the impact of sample size on classification accuracy

library(bnlearn)
library(readxl)
library(bnviewer)

## Reading in data

inst = "Combined"
filename = paste(paste("C:/Users/spborder/Desktop/BN_Project/All_Data/",inst),"_feats_filtered.csv")
filename = gsub(" ","",filename)

node_data=read.csv(file = filename, header = TRUE,sep = ",")
node_data_df<-data.frame(node_data)

node_data_df = node_data_df[complete.cases(node_data_df), ]


## Iteratively increasing sample size, new train/test split each time

MSE_Scv=list()
Error_cv=list()

count1<-0

MSE_samp = list()
ME_samp = list()
n_list = list()


delta = 10
start = 100
n <- start

#for each sample size
for (k in 1:((1000-start)/delta)){
  
  #n_idx = sample(seq_len(nrow(node_data_df)), size = n)
  #data_n = node_data_df[n_idx,]
  
  count<-0
  
  #for each of 10 cross-validations
  for (l in 1:10){
    count<-count+1
    
    #train/test split
    ratio = 0.7
    
    #train_size = floor(ratio*nrow(data_n))
    train_size = floor(ratio*n)
    #set.seed(123)
    #train_idx = sample(seq_len(nrow(data_n)),size=train_size)
    train_idx = sample(seq_len(nrow(node_data_df)),size=train_size)
    
    train = node_data_df[train_idx,]
    test = node_data_df[-train_idx,]
    
    bn_fit = bn.fit(hc(train),train)
    
    count2<-0
    SE = list()
    Error = list()
    sub_pred = list()

    for (m in 1:nrow(test)){
      prediction = predict(bn_fit, node = "DN_Stage", data = test[m,])
      #print(prediction)
      count2 <- count2+1
      
      pred_diff = (prediction - test[m,15])**2
      
      diff = prediction - test[m,15]
      
      Error[[count2]]<- diff
      
      SE[[count2]] <- pred_diff
      sub_pred[[count2]] <- prediction
      
    }
    
    SE_v = unlist(SE)
    MSE = mean(SE_v)
    
    MSE_samp[[count]]<- MSE
    ME_samp[[count]]<- mean(unlist(Error))
  }
  
  count1<-count1+1
  n_list[[count1]] <- n
  MSE_Scv[[count1]] <- mean(unlist(MSE_samp))
  Error_cv[[count1]] <- mean(unlist(ME_samp))
  n<-n+delta

}

plot(n_list,MSE_Scv,
     main = "MSE with Increasing Sample Size (All Nodes)",
     sub = "MSEs of 10-fold cross-validations at each sample size",
     xlab = "Sample Size",
     ylab = "Mean Squared Error",
     col = "blue")




plot(n_list,(unlist(MSE_Scv))^(0.5),
     main = "Absolute Error with Increasing Sample Size (All Nodes)",
     sub = "Mean Error of 10-fold cross-validations at each sample size",
     xlab = "Sample Size",
     ylab = "Mean Error",
     col = "blue")


MSE_allnode = MSE_Scv
