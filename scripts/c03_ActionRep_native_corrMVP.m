% 180507 djy.

commandwindow;

%% Uploading data
root_dir = '/Users/dojoonyi/cn/CLT/ActionRep/'; 
prot_dir = 'protocol';	% where raw behavioral data are saved. 

filename = fullfile(root_dir, prot_dir, 'protocol_ActionRep.csv');
delimiter = ',';
startRow = 2;
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';

fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, ...
	'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,startRow-1, ...
	'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
TT = [dataArray{1:end-1}];
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

%% ROIs saved with bspmviewer based on neurosynth --> native space transformed
mvpa_dir = fullfile(root_dir, 'mvpa_ActionRep', 'native_neurosynth');
ROIs{1} = {'ROIs_MZS_k75_sm6_r6', 'ROI_L_MidTemporal_x=-48_y=-56_z=20_s12.nii',	'MZS_L_MidTemporal.nii'};
ROIs{2} = {'ROIs_MZS_k75_sm6_r6', 'ROI_L_Precuneus_x=0_y=-54_z=40_s12.nii',		'MZS_L_Precuneus.nii'};
ROIs{3} = {'ROIs_MZS_k75_sm6_r6', 'ROI_R_InfTemporal_x=50_y=2_z=-32_s12.nii',	'MZS_R_InfTemporal.nii'};
ROIs{4} = {'ROIs_MZS_k75_sm6_r6', 'ROI_R_SupMedFrontal_x=4_y=54_z=24_s12.nii',	'MZS_R_SupMedFrontal.nii'};
ROIs{5} = {'ROIs_MNS_k75_sm6_r6', 'ROI_L_InfFrontal_x=-56_y=10_z=28_s12.nii',	'MNS_L_InfFrontal.nii'};
ROIs{6} = {'ROIs_MNS_k75_sm6_r6', 'ROI_L_InfTemporal_x=-50_y=-72_z=0_s12.nii',	'MNS_L_InfTemporal.nii'};
ROIs{7} = {'ROIs_MNS_k75_sm6_r6', 'ROI_L_SupParietal_x=-26_y=-54_z=70_s12.nii',	'MNS_L_SupParietal.nii'};
ROIs{8} = {'ROIs_MNS_k75_sm6_r6', 'ROI_R_InfTemporal_x=52_y=-64_z=0_s12.nii',	'MNS_R_InfTemporal.nii'};
ROIs{9} = {'ROIs_MNS_k75_sm6_r6', 'ROI_R_Postcentral_x=54_y=-30_z=56_s12.nii',	'MNS_R_Postcentral.nii'};

%% Study info
SN = unique(TT(:,1));

nTOTAL = 192;	% total # of trials in experiment
nTpB = 48;		% # trial per run

% 1_SN, 2_run, 3_trial, 4_cond, 5_IM, 6_plan, 7_TTL, 8_stim, 9_scale, 10_resp, 11_rt
TT(:,end+1)=TT(:,3) + (TT(:,2)-1)*48;		% 12_concatenated trial #

sumCorr = cell(1,length(ROIs));
for xroi=1:length(ROIs)
	sumCorr{xroi} = zeros(4,4,length(SN));
end

%% Log info
filename = fullfile(root_dir, 'mvpa_ActionRep', 'check_order_rois.csv');
fileID = fopen(filename, 'w');
fprintf(fileID, 'c03_ActionRep_native_corrMVP.m on %s\n\n', date);

%% SN loop
for it=1:length(SN)
	xsn = SN(it);    	
	xSS = sprintf('s%02d', xsn);
	S_dir = fullfile(root_dir, xSS);
	fprintf(fileID , '%s', xSS);
	
	%% sort trials according to conditions & responses
	clear SS;
	SS = TT(TT(:,1)==xsn, :);    
    % 1_SN, 2_run, 3_trial, 4_cond (1_self, 2_other, 3_how, 4_why), 
	% 5_IM, 6_plan, 7_TTL, 8_stim, 9_scale, 10_resp, 11_rt, 12_concatenated trial number 
    
	trialpIM = zeros(48, 8);	% 48 trials/con, 4 conditions x 2 columns
	for xcon=1:4
		WW = SS(SS(:,4)==xcon,:);
		[~,idx] = sort(WW(:,5));
		sortedWW = WW(idx,:);
		
		trialpIM(:,(xcon-1)*2+1:xcon*2) = sortedWW(:,[10,12]);		
		
		clear WW idx sortedWW;
	end
	
	[idx,~] = find(trialpIM==0);
	trialpIM(idx,:)=[];	% remove no-response trials
	trialpIM = trialpIM(:,[2,4,6,8]);
	numValTrial = size(trialpIM,1);
	fprintf('s%02d has %d valid trials: ', xsn, numValTrial);
	
	%% load mvp data
	xmvp = load(fullfile(mvpa_dir, sprintf('mvp_native_neurosynth%s.mat', xSS)));
	
	%% ROI loop
	for xroi = 1:length(ROIs)
		clear DD;
		fprintf(fileID, ',%s', xmvp.data{xroi}.name);
		DD = xmvp.data{xroi}.vv;		
		
		% remove NaN
		clear idx;
		[~,idx] = find(isnan(DD));
		DD(:,unique(idx)) = [];		
		fprintf('\t%d', size(DD,2));
		
		% correlation between conditions throughout trials
		tempMat = zeros(4,4,numValTrial);
		for xtrial = 1:numValTrial
			tempMat(:,:,xtrial) = corr(DD(trialpIM(xtrial,:),:)');		
		end
		
		% add to summary mat
		sumCorr{xroi}(:,:,it) = mean(tempMat,3);	
	end
	fprintf('\n');
    fprintf(fileID, '\n');
end

%% summarize
filename = fullfile(root_dir, 'mvpa_ActionRep', 'corr_SELFvOTHER.csv');
fileID2 = fopen(filename, 'w');
fprintf(fileID2, 'c03_ActionRep_native_corrMVP.m on %s\n\n', date);
fprintf(fileID2, 'SN');
for xroi=1:length(ROIs)
	fprintf(fileID2, ',%s', ROIs{xroi}{3}(1:end-4));
end
fprintf(fileID2, '\n');

for it=1:length(SN)
	xsn = SN(it);
	fprintf(fileID2, 's%02d', xsn);
	for xroi=1:length(ROIs)
		fprintf(fileID2, ',%1.10f', sumCorr{xroi}(1,2,it));
	end
	fprintf(fileID2, '\n');
end

%% Fisher transformation 
sumCorrFT = cell(1,length(ROIs)); 
for xroi=1:length(ROIs)
	sumCorrFT{xroi} = zeros(4,4,length(SN));
end
for xroi = 1:length(ROIs)
	sumCorrFT{xroi} = atanh(sumCorr{xroi});	
end	
fprintf(fileID2, '\n\n');

fprintf(fileID2, 'Fisher transformation\n\n');
fprintf(fileID2, 'SN');
for xroi=1:length(ROIs)
	fprintf(fileID2, ',%s', ROIs{xroi}{3}(1:end-4));
end
fprintf(fileID2, '\n');

for it=1:length(SN)
	xsn = SN(it);
	fprintf(fileID2, 's%02d', xsn);
	for xroi=1:length(ROIs)
		fprintf(fileID2, ',%1.10f', sumCorrFT{xroi}(1,2,it));
	end
	fprintf(fileID2, '\n');
end

fclose('all');
% ------- EOF.
