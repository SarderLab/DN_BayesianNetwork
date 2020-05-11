%% Setting up for 2D MST pipeline
clc
close all
clear all

% Loading single glomerulus images
%imgDir should be directory containing all png images
baseDir=fullfile('C:','Users','spborder','Desktop');
imgDir=fullfile(baseDir,'BN_Project','Diabetes - DN data from Brazil-selected','results');

imgMat=dir(fullfile(imgDir));
imgMat={imgMat.name};

%Reading all glomerulus images into Matlab cell
% cell(1,length(imgMat)-2); may need to be changed depending on the
% location of image directory compared to baseDir.  Look in imgMat and see
% the number of beginning cells occupied by '.' or '..' and adjust
% accordingly.
glom_imgs=cell(1,length(imgMat)-2);
for i = 1:length(imgMat)-2
    glom_imgs{1,i}=imread(imgMat{i+2});
end
%% Pipeline Implementation

%Augmenting the number of images wanted to calculate features of.  Adjust
%'scale' variable between 0-1 as necessary.
scale=1;
numpics=ceil(scale*length(glom_imgs));  
first=glom_imgs{1};

%Initializing feature vectors
btwn_centrality=cell(1,numpics);
node_ecc=cell(1,numpics);
diameter=zeros(1,numpics);
num_branches=cell(1,numpics);
deg_per_node=cell(1,numpics);
norm_length=cell(1,numpics); 
leaf_fract=cell(1,numpics);

nfeat = 14;
node_data=zeros(numpics,nfeat);

%Count of glomerulus images with no segmented nuclei
not_enough_nuc=0;

%% Generating glomerular Minimum Spanning Trees (MSTs)

OS_GlomStack2dMSTpipeline

%% Calculating features from individual MSTs for each glomerulus image

%Average MST edge length and normalized edge length
for it=1:numpics
    
    if num_nuclei{it}==0 || num_nuclei{it}==1
        not_enough_nuc=not_enough_nuc+1;
        continue
    end
    
    avglength=mean(weightLists{1,it});
    norm_length{1,it}=zeros(1,length(weightLists{1,it}));
    for il=1:length(weightLists{1,it})
        norm_length{1,it}(1,il)=log(weightLists{1,it}(il,1)/avglength);
    end
end

% Leaf Fraction
for ik=1:numpics
    
    if num_nuclei{ik}==0 || num_nuclei{ik}==1
        continue
        not_enough_nuc=not_enough_nuc+1;
    end
      
    leaf_fract{1,ik}=sum(degreeLists{1,ik}(:)==1)/(num_nuclei{1,ik}-1);
end


% Aggregating features and organizing into node_data matrix
for ij=1:numpics
    
    if num_nuclei{ij}==0 || num_nuclei{ij}==1
        continue
    end
        
    ecc_mu=mean(node_ecc{ij});
    ecc_sig=std(node_ecc{ij});
    
    edge_mu = mean(weightLists{ij});
    edge_sig = std(weightLists{ij});
    
    norm_mu = mean(norm_length{ij});
    norm_sig = std(norm_length{ij});
    
    
%     edge_fit=gevfit(weightLists{ij});
%     [~,msgid]=lastwarn;
%     if strcmp(msgid,'stats:gevfit:IterLimit') | strcmp(msgid,'stats:gevfit:ConvergedToBoundary')
%         edge_fit(1)=0;
%         edge_fit(2)=mean(weightLists{ij});
%         edge_fit(3)=std(weightLists{ij});
%     end
%     
%     norm_fit=gevfit(norm_length{ij});
%     [~,msgid]=lastwarn;
%     if strcmp(msgid,'stats:gevfit:IterLimit') | strcmp(msgid,'stats:gevfit:ConvergedToBoundary')
%         norm_fit(1)=0;
%         norm_fit(2)=mean(norm_length{ij});
%         norm_fit(3)=std(norm_length{ij});
%     end
    
    max_btwn=max(btwn_centrality{ij});
    num_btwn=length(btwn_centrality{ij}>0.9*max_btwn);
    
    node_data(ij,1)=num_nuclei{ij};
    node_data(ij,2)=num_branches{ij};
    node_data(ij,3)=deg_per_node{ij};
    node_data(ij,4)=pixel_span{ij};
    node_data(ij,5)=leaf_fract{ij};
    node_data(ij,6)=diameter(ij);
    node_data(ij,7)=ecc_mu;
    node_data(ij,8)=ecc_sig;
    node_data(ij,9)=edge_mu;
    node_data(ij,10)=edge_sig;
    node_data(ij,11)=norm_mu;
    node_data(ij,12)=norm_sig;
    node_data(ij,13)=max_btwn;
    node_data(ij,14)=num_btwn;
end



 
save ('node_data.mat','node_data','num_nuclei','num_branches','deg_per_node'...
    ,'pixel_span','leaf_fract','diameter','btwn_centrality','norm_length','node_ecc'...
    ,'weightLists');
NodeData=load('node_data.mat');

%Saving calculated node data, change name of file as necessary
csvwrite('NodeData.csv',NodeData.node_data);
 
    
