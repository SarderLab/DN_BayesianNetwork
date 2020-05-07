## Making iteratable MSE calculator for different combinations of a set number+name of features

library(bnlearn)
library(readxl)
library(bnviewer)

###########Reading in data####################
inst = "Combined"

filename = paste(paste("C:/Users/spborder/Desktop/BN_Project/All_Data/",inst),"_feats_filtered.csv")
filename = gsub(" ","",filename)

node_data=read.csv(file = filename, header = TRUE,sep = ",")
node_data_df<-data.frame(node_data)

#train/test split
ratio = 0.7

train_size = floor(ratio*nrow(node_data_df))
set.seed(123)
train_idx = sample(seq_len(nrow(node_data_df)),size=train_size)

train = node_data_df[train_idx,]
test = node_data_df[-train_idx,]


########### Identifying combinations and looping through ####################

#Constructing sub-networks
#feats = c("Leaf_Fraction","Deg.node","EdgeLength.sig.","Eccentricity.mu.")
feats = c("Leaf_Fraction","Deg.node","EdgeLength.sig.","EdgeLength.mu.","Max_Betweenness","Eccentricity.mu.","NormEdgeLength.sig.")

#calculating number of possible combinations
n_com <- 0

for (i in 1:length(feats)){
  n_com <- n_com + (factorial(length(feats)) / (factorial(i)*factorial(length(feats)-i)))

}

#creating list of different feature combos
feature_combos = list()
count <- 1
for (j in 1:length(feats)){
  
  combns = combn(length(feats),j)
  for (k in 1:choose(length(feats),j)){
    feature_combos[[count]]<-c(feats[combns[,k]],"DN_Stage")

    count<-count+1
  }
}

#main loop
MSE_combo = list()
count3 <- 1
for (l in 1:n_com){
  
  subl = feature_combos[l]
  subl_data = train[ ,which(names(train) %in% subl[[1]])]
  subl_test = test[ ,which(names(test) %in% subl[[1]])]
  
  subl_fit = bn.fit(hc(subl_data),subl_data)
  
  subl_preds = list()
  SEl = list()
  count2 <- 0
  
  for (m in 1:nrow(subl_test)){
    prediction = predict(subl_fit, node = "DN_Stage", data = subl_test[m,])
    #print(prediction)
    count2 <- count2+1
    
    pred_diff = (prediction - subl_test[m,length(subl[[1]])])**2
    #print(pred_diff)
    
    SEl[[count2]] <- pred_diff
    subl_preds[[count2]] <- prediction
    
  }
  SEl_vector <- unlist(SEl)
  MSE_combo[[count3]] <- mean(SEl_vector)
  
  count3<-count3+1
}

#Saving output to csv
save_name = paste(paste("C:/Users/spborder/Desktop/BN_Project/Feature_Combo_Output/",inst),"_ComboMSE.csv")
write.csv(MSE_combo, save_name)

MSE_v = unlist(MSE_combo)
min_idx = which.min(MSE_v)

print(paste(paste("The minimum MSE for",inst), "combo is : ", feature_combos[min_idx]))

plot((1:length(MSE_v)),MSE_v, 
     main = "Mean Squared Error across Test combination", 
     xlab = "Test Set combination #", 
     ylab = "Squared Error")

hist((unlist(MSE_v))^(0.5),
     main = "Mean Absolute Error across all Test Combinations",
     sub = "Averaged from 10 cross-validations",
     xlab = "Mean Absolute Error",
     xlim = c(1.25, 1.48))


#### Viewing Pruned Network ############

pr_data = node_data_df[ ,which(names(node_data_df) %in% feature_combos[[min_idx]])]


DN_thresh=boot.strength(pr_data,R=100,algorithm = "hc")
avgDN_thresh=averaged.network(DN_thresh,threshold = 0.5)

#Strength Viewer
strength.viewer(avgDN_thresh,DN_thresh,bayesianNetwork.background = "#ffffff",
                bayesianNetwork.arc.strength.threshold.expression = c("@threshold >0.8 & @threshold <=0.9",
                                                                      "@threshold >0.9 & @threshold <= 0.95",
                                                                      "@threshold >0.95 & @threshold <=1"),
                bayesianNetwork.arc.strength.threshold.expression.color = c("red","green","blue"),
                bayesianNetwork.arc.strength.threshold.alternative.color = "yellow",
                bayesianNetwork.arc.strength.label = TRUE,
                bayesianNetwork.arc.strength.label.prefix = "",
                bayesianNetwork.arc.strength.label.color = "black",
                bayesianNetwork.width = "120%",
                bayesianNetwork.height = "900px",
                bayesianNetwork.arc.strength.tooltip = TRUE,
                bayesianNetwork.layout = "layout_nicely",
                node.colors = list(background = "#077dc6",
                                   border = "black",
                                   highlight = list(background = "#1fd4f4",
                                                    border = "#ffffff")),
                edges.colors = list(opacity = 0.1),
                node.font = list(color = "white", face="Arial Black"),
                edges.dashes = FALSE,
                node.shape = "ellipse")

#### Testing how the minimum MSE combo is with increasing sample size #########

#Using only data from the nodes with the minimum MSE
node_data_sel = node_data_df[ ,which(names(node_data_df) %in% feature_combos[[min_idx]])]


MSE_SScv=list()
count1<-0
MSE_samp = list()
n_list = list()


delta = 10
start = 100
n <- start

#for each sample size
for (k in 1:((1000-start)/delta)){
  
  #n_idx = sample(seq_len(nrow(node_data_sel)), size = n)
  #data_n = node_data_sel[n_idx,]
  
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
    train_idx = sample(seq_len(nrow(node_data_sel)),size=train_size)
    
    train = node_data_sel[train_idx,]
    test = node_data_sel[-train_idx,]
    
    bn_fit = bn.fit(hc(train),train)
    
    count2<-0
    SE = list()
    sub_pred = list()
    
    for (m in 1:nrow(test)){
      prediction = predict(bn_fit, node = "DN_Stage", data = test[m,])
      #print(prediction)
      count2 <- count2+1
      
      pred_diff = (prediction - test[m,length(node_data_sel)])**2
      
      diff = prediction - test[m,length(node_data_sel)]
      
      SE[[count2]] <- pred_diff
      sub_pred[[count2]] <- prediction
      
    }
    
    SE_v = unlist(SE)
    MSE = mean(SE_v)
    
    MSE_samp[[count]]<- MSE
  }
  
  count1<-count1+1
  n_list[[count1]] <- n
  MSE_SScv[[count1]] <- mean(unlist(MSE_samp))
  n<-n+delta
  
}

plot(n_list,(unlist(MSE_allnode))^(0.5),
     main = "Absolute Error with Increasing Sample Size",
     sub = "Absolute Errors of 10-fold cross-validations at each sample size",
     xlab = "Sample Size",
     ylab = "Mean Absolute Error",
     col = "blue")
     
points(n_list,(unlist(MSE_SScv))^(0.5), col = "red")
     legend("topleft",
            c("All Nodes","Select Nodes"),
            fill = c("blue","red"))


#boxplot(unlist(MSE_Scv))



###### Performance of pruned network #########

count<-0
Error = list()     
SE = list()
sub_pred = list()
Error_df = list()
ME_cv = list()
MSE_cv = list()

#For each fold
for (l in 1:100){
  count<-count+1
  
  #train/test split
  ratio = 0.7
  
  train_size = floor(ratio*nrow(pr_data))
  #set.seed(123)
  train_idx = sample(seq_len(nrow(pr_data)),size=train_size)
  
  train = pr_data[train_idx,]
  test = pr_data[-train_idx,]
  
  bn_fit = bn.fit(hc(train),train)
  
  count2<-0
  SE = list()
  sub_pred = list()
  Error = list()
  
  for (m in 1:nrow(test)){
    prediction = predict(bn_fit, node = "DN_Stage", data = test[m,])
    #print(prediction)
    count2 <- count2+1
    
    pred_diff = (prediction - test[m,length(test)])**2
    
    diff = prediction - test[m,length(test)]
    
    Error[[count2]]<- diff
    SE[[count2]] <- pred_diff
    sub_pred[[count2]] <- prediction
    
  }
  
  SE_v = unlist(SE)
  MSE = mean(SE_v)
  
  ME = mean(unlist(Error))
  
  Error_df[[count]]<-Error
  
  ME_cv[[count]]<- ME
  MSE_cv[[count]]<- MSE
}


boxplot((unlist(MSE_Fcv))^(0.5),(unlist(MSE_cv))^(0.5), 
        main = "Boxplot of Absolute Error values during 10-fold Cross Validation",
        ylab = "Absolute Error",
        at = c(1,2),
        names = c("Full Network", "Pruned Network"),
        las = 0,
        horizontal = FALSE,
        notch = FALSE)


hist((unlist(MSE_Fcv))^(0.5), breaks = 20,
     main = "Histogram of Absolute Error values during 10-fold Cross Validation",
     xlab = "Absolute Error",
     col = rgb(1,0,0,0.5),
     xlim = c(1.18,1.35))
hist((unlist(MSE_cv))^(0.5), breaks = 20,
     add = T,
     col = rgb(0,0,1,0.5))
  legend("topleft",
         c("All Nodes","Select Nodes"),
         fill = c("red","blue"))
box()

#boxplots for each fold on one set of axes
#boxplot(unlist(error$V1),unlist(error$V2),unlist(error$V3),unlist(error$V4),unlist(error$V5),unlist(error$V6),
#unlist(error$V7),unlist(error$V8),unlist(error$V9),unlist(error$V10),
#main = "Raw Error at each of 10 folds",
#xlab = "n-fold",
#ylab = "Raw Error",
#at = c(1,2,3,4,5,6,7,8,9,10),
#names = c("1","2","3","4","5","6","7","8","9","10"),
#las = 0,
#col = "blue",
#border = "black",
#horizontal = FALSE,
#notch = FALSE)



###############

     
     
     
     
     
     
     