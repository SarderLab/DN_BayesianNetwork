%Use this after you've loaded in all the glom images you want to process.

%Initializing variables to store feature calculating info
positionLists = cell(1, numpics);
weightLists = cell(1, numpics);
degreeLists = cell(1, numpics);
fullgraphLengths = cell(1, numpics);
num_nuclei=cell(1,numpics); 
pixel_span=cell(1,numpics); 


%Saving nuclear masks to investigate thresholding if necessary
%nuclei_imgs=cell(1,numpics);


%Creating glomerular masks and storing numbers to calculate features from
for y = 1:numpics

    display(['On image: ',y,' of',numpics])
    im=glom_imgs{1,y};
    
    %Using color deconvolution to isolate different stains in image
    ColorDeconvolutionDemo %Currently works for mouse PAS and H&E
    im = imageout(:,:,1);
    
    %Create mask of Bowman's Capsule
    OS_quickMaskCreator

    masked_img = im.*Mask;   
    pix_span_area=masked_img>0; 
    pix_span_area=sum(sum(pix_span_area));  
    pixel_span{y}=pix_span_area;    

    %Segmenting nuclei from masked image
    nuclei = imbinarize(masked_img{y});
    nuclei = nuclei + ~Mask;
    nuclei = bwareaopen(~nuclei, 80);
    %nuclei_imgs{y}=nuclei;

    reg = regionprops(nuclei,'centroid');
    centroidPoints = struct2cell(reg);
    b = length(centroidPoints);

    num_nuclei{y}=b;    

    figure(1), imshow(im)   
    for c = 1:b
        h = impoint(gca, centroidPoints{c}); %Display all the presumptive nuclear centroids
        setColor(h, 'g');
    end
    
    positionLists{y} = reshape(cell2mat(centroidPoints), 2, b);
end


%Betweenness Centrality, Eccentricity, Diameter, Branches #, and
%Degrees/node
for z = 1:numpics
    %Control for no/one nuclei images
    if num_nuclei{z}==0 || num_nuclei{z}==1
        continue
    end
    coordinates = positionLists{z};
    
    %Generating Minimum Spanning Tree
    OS_minSpanTreeFromCoordinates
    
    weightLists{z} = M.Edges.Weight;
    degreeLists{z} = degree(M);
    fullgraphLengths{z} = G.Edges.Weight;
    
    num_branches{z}=length(weightLists{z}); 
    deg_per_node{z}=sum(degreeLists{z})/num_nuclei{z};

    %Betweenness Centrality
    btwn_centrality{z}=centrality(M,'betweenness','Cost',weightLists{z});   %SB
    
    %Node Eccentricity
    allnodes=unique(G.Edges.EndNodes);
    for Num=1:num_nuclei{z}
        thisnode=allnodes(Num);
        [~,D]=shortestpathtree(G,thisnode);
        node_ecc{1,z}(1,Num)=max(D);
    end
    
    %Diameter
    diameter(z)=max(node_ecc{1,z});
end

% figure, histogram(vertcat(weightLists{:}));
% title('Histogram of aggregated 2D MST lengths')
% figure, histogram(vertcat(degreeLists{:}));
% title('Histogram of aggregated 2D MST degrees') 
% figure, histogram(vertcat(fullgraphLengths{:}));
% title('Histogram of aggregated 2D MST lengths (full graph)') 

%to get the figure handles: 
%a = get(gca, 'children');
%set(a, 'Normalization','probability')
