
#Performing logic sampling and generating probability for each stage

library(bnlearn)


###### Fitting network with all data ##########

print('Select the file containing whole feature set')

node_data=read.csv(file = file.choose(), header = TRUE,sep = ",")
node_data_<-data.frame(node_data)

#remove rows with NaN
node_data_ = node_data_[complete.cases(node_data_), ]

#Scaling data
node_data_scale = data.frame(scale(node_data_[,1:14]))
node_data_df = cbind(node_data_scale,node_data_["DN_Stage"])


#Testing data (10% of full data)
ratio = 0.9

train_size = floor(ratio*nrow(node_data_df))
#set.seed(123)
train_idx = sample(seq_len(nrow(node_data_df)),size=train_size)
test_node_data_df = node_data_df[-train_idx, ]

#fitting network
bn_fit = bn.fit(hc(node_data_df),node_data_df)


###### Generating random samples, iterating through with specific criteria #########

#number of samples to generate
n <- 10^6
#generating samples
sim = rbn(bn_fit,n,node_data_df)

#Filter samples

# For DN features, all but NormEdgeLength features must be >0
filt = data.frame(lapply(sim[1:10],abs),sim[11:12],lapply(sim[13:15],abs))

#First set criteria for inclusion (P (What | blank))
event_node <- "DN_Stage"
#put features in order in which they appear in data column ordering
evidence_nodes <- bn_fit[["DN_Stage"]][["parents"]]

#number of std within to include a sample 
s<-1
std_rows = apply(filt,2,sd)
std_ev = std_rows[which(names(std_rows)%in%evidence_nodes)]

#iterate through rows of test node data, going through each calculated sample
### Main Loop ######
problist=list()
ct<-1
#For each example image
for (i in 1:nrow(test_node_data_df)){
  
  print(paste('On sample',i,'of',nrow(test_node_data_df)))
  #For each stage of DN
  for (DN in 0:6){
    
    #print(paste('On DN stage:',DN))
    test_data = test_node_data_df[i,which(names(test_node_data_df)%in% evidence_nodes)]
    
    new_df = sim[,which(names(sim) %in% c(evidence_nodes,event_node))]
    
    #Trimming down new dataframe containing rows which meet all evidence nodes
    #For each evidence node
    for (j in 1:length(evidence_nodes)){
      new_df = subset(new_df,(new_df[,j]>=(test_data[[j]]-(s*std_ev[[j]])))&(new_df[,j]<=(test_data[[j]]+(s*std_ev[[j]]))))
      if (nrow(new_df)==0){break}
      
    }  
    
    if (nrow(new_df)!=0){
      #number of samples which meet evidence criteria
      num_meet = nrow(new_df)
      
      #Probability of DN stage = DN
      probz = nrow(subset(new_df,new_df['DN_Stage']<=DN))/nrow(new_df)
    } else {probz = 0}
    
    dat<-data.frame(DN_Stage = DN, prob = probz, Samp_Img = i)
    
    problist[[ct]]<-dat   
    ct<-ct+1
    
  }
}

fullproblist= do.call(rbind,problist)

#Change to desired filename
save_filename = 'Output.csv'
write.csv(fullproblist,save_filename)


