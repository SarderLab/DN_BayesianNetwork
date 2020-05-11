**Analyzing image features relationships to stage of Diabetic Nephropathy**

**Motivation**: 
  Diabetes mellitus is currently the 7th leading cause of death in the United States, with over 1.5 million new diagnoses every year.  As a result of hyperglycemia, various internal processes are disrupted at the cellular level which can manifest as severe vascular dysfunction.  The kidneys, which are responsible for the filtration of blood, are highly sensitive to upsets in normal circulation and therefore incur a significant amount of damage over the lifetime of diabetic individuals.  Diabetic Nephropathy (DN) is clinically identified by inordinate amounts of protein in the patients’ urine and can be further assessed by histopathologists by examining needle biopsies.  Within these biopsies, the degree of damage and extent of DN progression is visible within the glomeruli, the core functional filtration units.  Histopathologists currently employ a variety of semi-quantitative measures to summarize the functional capacity of patients’ glomeruli, however this approach is time-consuming and fraught with intra-observer variability.  Our lab has defined a set of features (n=14) which are indicative of the health status of individual glomeruli revolving around the relative positions of the computationally segmented glomerular nuclei within the Bowman’s Capsule.  In order to determine the inter-dependencies of these calculated features and DN stage (as assigned by renal pathologist using Tervaert scale), we used Bayesian Networks (BN).  BNs are a type of probabilistic graphical model which uses heuristics to approximate the posterior distributions of each of the features and compiles those relationships into a directed acyclic graph.  

**Publication pending**

**Usage**:

**Generating feature matrix from individual glomerulus images.**
  •	In ‘Feature_Extraction/’ there are the Matlab codes used to calculate all the features used in this analysis.  To run, change directory names in ‘Glom_MST_full.m’ to the directory containing images and the name of the file to save containing the calculated feature values.
  
  •	Running ‘Glom_MST_full.m’ will load all of the images in the glomerular image directory into the workspace and then iterate through each one, prompting the user to create masks of the Bowman’s Capsule (BC).  Using the mouse, click and hold to drag a circle around the edges of the BC.  Once complete, unclick and the script will show the locations of the segmented nuclei before moving on to the next image.

**Bayesian Network Analysis codes: All implemented in R using ‘bnlearn’ package for learning Bayesian Networks and modeling feature #relationships.**

  •	**ProbPerStage.R**
    •	Using logic-sampling to generate probability of DN stage membership for a given set of samples
    •	In this current implementation, ‘test_node_data_df’ is corresponding to 10% of the current full dataset but if you have specific        images you want to test:
      •	Run feature extraction on folder with those specific images.
      •	Comment out line 28
      •	Replace with test_node_data_df = read.csv(‘your_filename.csv’)
    •	Output is csv file with columns = [Index, DN_Stage, Probability (DN_Stage of that sample is <= that DN_Stage, Sample Image ID]
    
  •	**ConditionalProbabilities.R**
    -	Illustrating the influence of different feature values on the probability of higher DN stages.
    -	Uses fit Bayesian network of whole dataset
    -	Saves output to csv file with columns = [Index, Feature value, Probability of DN Stage > 3]
    -	In this implementation the features under analysis are Normalized Edge Length Std. Dev., Degrees Per Node, Average Eccentricity,        Glomerular Area, Number of Nuclei, and combination of Average Eccentricity and Normalized Edge Length Std. Dev. 
    
  •	**NumberCombinations.R**
    -	Used to show the influence of number of total models to search given a certain number of features.  
    -	First figure is a scatterplot for the number of total models vs. number of features and the ratio of number of total models and       number of nodes
    -	Second figure is the changing ratio between the number of total models and the number of models for each node with examples for 1-      4 nodes.
    
  •	**Scalability_test.R**
    -	This script examines the influence of sample size on classification performance using Bayesian Networks.  
    -	It iteratively increases the number of samples randomly selected from the whole dataset and fits a network using that subset.  It     then uses a test set to determine the Mean Square Error (MSE) and Absolute Error (AE).
    
  •	**Inst_Compare.R**
    -	This script was used to examine the differences in the Bayesian Networks constructed using data from 4 different institutions.
    -	If you have multi-institutional data, change the n_inst variable to the number you are working with and it will prompt you to         select the files containing that institution’s whole dataset.
    
  •	**Gen_Feature_combos.R**
    -	Using this script, you can change how you search for the ideal model by trimming the feature set down to a smaller subset and         testing that one for how it performs in a classification task.
    -	This script iterates through the different possible combinations of these features and constructs networks for each one so the          longer your trimmed list of features is, the longer it will take to run.
    -	This script also includes interactive viewing of the trimmed network using ‘bnviewer.’
