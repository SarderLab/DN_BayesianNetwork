
#Calculating the number of possible models that can be generated conserving different numbers of features



#calculating number of possible combinations
feats=c("test","test","test","test","test","test","test","test","test","test","test","test","test","test","test")
com_list=list()
foot_list = list()
foot2_list=list()
foot3_list=list()
foot4_list=list()

ct<-0
for (j in 1:length(feats)){
  feats_j = feats[1:j]
  n_com <- 0

  for (i in 1:length(feats_j)){
    
    n_com <- n_com + (1/i)*length(combn(length(feats_j),i))
  }
  ct<-ct+1
  com_list[[ct]]<-n_com
  foot_list[[ct]]<-2^(length(feats_j)-1)
  foot2_list[[ct]]<-2^(length(feats_j)-2)
  foot3_list[[ct]]<-2^(length(feats_j)-3)
  foot4_list[[ct]]<-2^(length(feats_j)-4)
}
plot((1:length(com_list)),com_list,
     main = "Number of possible combinations with increasing number of nodes",
     xlab = "Number of nodes included",
     ylab = "Number of possible combinations",
     col = "blue")

points((1:length(com_list)),foot_list, col = "red")
legend("topleft",
       c("#total models","#models for each node"),
       fill = c("blue","red"))

foot_rat=list()
foot2_rat=list()
foot3_rat=list()
foot4_rat=list()
c<-0
for (m in 1:length(feats)){
  ratio = com_list[[m]]/foot_list[[m]]
  ratio2 = com_list[[m]]/foot2_list[[m]]
  ratio3 = com_list[[m]]/foot3_list[[m]]
  ratio4 = com_list[[m]]/foot4_list[[m]]
  
  c<-c+1
  foot_rat[[c]]<- ratio
  foot2_rat[[c]]<- ratio2
  foot3_rat[[c]]<- ratio3
  foot4_rat[[c]]<- ratio4
}

plot.default((1:length(foot_rat)),foot_rat,
     main = "Ratio of #total models to #models for each node",
     xlab = "Number of nodes",
     ylim = c(1,20),
     ylab = "Ratio",
     col = "red")
points((1:length(foot_rat)),foot2_rat,col = "yellow")
points((1:length(foot_rat)),foot3_rat,col = "green")
points((1:length(foot_rat)),foot4_rat,col = "blue")
legend("topleft",
       c("1-node","2-node","3-node","4-node"),
       fill = c("red","yellow","green","blue"))




