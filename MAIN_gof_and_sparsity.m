clear;clc;close all
% Starting from two MV-patterns (either simulated or real), this script can 
% be used for estimating 1) the linear transformation by using the Tikhonov
% regularization method, 2) the goodness-of-fit (GOF) and 3) the percentage of
% sparsity (via Monte Carlo procedure that takes into account both the GOF
% value and the rate of decay of the density curve (RDD)) as in Basti et
% al. 2019.

%%   
% In order to understand how the script works, let us simulate the data 
dimx=100; % number of voxels in the first ROI (ROIX)
dimy=150; % number of voxels in the second ROI (ROIY)
dimt=90;  % number of stimuli
levelofnoise=0.3; % weight of the noise, the one of the signal is (1-levelofnoise)
levelofsparsity=75; % simulated percentage of sparsity. 0 denotes two fully 
                    % connected regions while e.g. 80 denotes a transformation
                    % in which the 80% of entries are equal to 0, i.e. on average
                    % each voxel in the ROIX interact with only 20%
                    % of the voxels in the other region
levelofdeformation=[]; % in this toy example let us only consider the sparsity
numberofsubjs=4; % number of subjects to simulate
% simulate linear MV-interaction between ROIX and ROIY
[x,y]=simulateMVlinearinteraction(dimx,dimy,dimt,levelofnoise,levelofsparsity,levelofdeformation,numberofsubjs);

%%
% Let us estimate the transformations and the metrics
lambdas=10.^(-2:0.1:5); %set of regularization parameters
results=featuresevaluation(x,y,lambdas);

% In order to associate to each pair (GOF, RDD) a specific percentage of 
% sparsity, let us use the Monte Carlo (MC) approach
sparsities=[50, 70, 80, 90]; % percentage of sparsity to investigate
numberofrep=10; % number of simulations for each level of sparsity and noise in the MC
resultsMCsparsity=MCproceduresparsity(x,dimx,dimy,dimt,lambdas,sparsities,numberofrep);

%% 
% plot (equivalent to that used in Basti et al. 2019). The black square (
% with the error bars) denotes the average (and std) GOF and RDD across the
% subjects (either on real or on the data simulated as above), while the 
% coloured squares denotes the results obtained with the MC approach. By
% looking at the position of the black square with respect to those of the
% coloured squares, it is possible to estimate the percentage of sparsity
% of the transformation of interest: for instance, if the
% black square lies between the curve representing the 70% and the 80% of 
% sparsity in the MC, it means that the estimated percentage of sparsity 
% for the transformation of interest is in the range 70-80%.
color={'m';'c';'g';'r';'b';'y'};
figure('Position',[50 50 900 900])
for ispar=1:numel(sparsities)
   hold on
   errorbar(mean(squeeze(resultsMCsparsity.gof(ispar,:,1,:)),2),mean(squeeze(resultsMCsparsity.rdd(ispar,:,:)),2),std(squeeze(resultsMCsparsity.rdd(ispar,:,:)),0,2),std(squeeze(resultsMCsparsity.rdd(ispar,:,:)),0,2),std(squeeze(resultsMCsparsity.gof(ispar,:,1,:)),0,2),std(squeeze(resultsMCsparsity.gof(ispar,:,1,:)),0,2),'-sb','MarkerSize',6,'MarkerEdgeColor',color{ispar},'MarkerFaceColor',color{ispar},'DisplayName',strcat('Sparsity=',num2str(sparsities(ispar)),'%'))
end
hold on
errorbar(mean(results.gof),mean(results.rdd),std(results.rdd),std(results.rdd),std(results.gof),std(results.gof),'-sk','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor','k','DisplayName','Estimate for the data of interest')
title(strcat('Estimated percentage of sparsity (original value=',num2str(levelofsparsity),'%)'))
xlabel('Goodness-of-fit')
ylabel('Rate of decay of the density')
legend('Location','southwest')

%save('Results_sparsity.mat','results','resultsMCsparsity') 