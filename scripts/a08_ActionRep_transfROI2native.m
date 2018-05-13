%% 180504 djy
commandwindow;

%% Participants Info
SN = [1:12,14:17];

%% Directory Info
data_dir = '/Users/dojoonyi/cn/CLT/ActionRep';
cd(data_dir);

%% ROIs saved with bspmviewer based on neurosynth
src_dir = '/Users/dojoonyi/cn/CLT/Neurosynth180502';
ROIs{1} = {'ROIs_MZS_k75_sm6_r6', 'ROI_L_MidTemporal_x=-48_y=-56_z=20_s12.nii',	'MZS_L_MidTemporal.nii'};
ROIs{2} = {'ROIs_MZS_k75_sm6_r6', 'ROI_L_Precuneus_x=0_y=-54_z=40_s12.nii',		'MZS_L_Precuneus.nii'};
ROIs{3} = {'ROIs_MZS_k75_sm6_r6', 'ROI_R_InfTemporal_x=50_y=2_z=-32_s12.nii',	'MZS_R_InfTemporal.nii'};
ROIs{4} = {'ROIs_MZS_k75_sm6_r6', 'ROI_R_SupMedFrontal_x=4_y=54_z=24_s12.nii',	'MZS_R_SupMedFrontal.nii'};
ROIs{5} = {'ROIs_MNS_k75_sm6_r6', 'ROI_L_InfFrontal_x=-56_y=10_z=28_s12.nii',	'MNS_L_InfFrontal.nii'};
ROIs{6} = {'ROIs_MNS_k75_sm6_r6', 'ROI_L_InfTemporal_x=-50_y=-72_z=0_s12.nii',	'MNS_L_InfTemporal.nii'};
ROIs{7} = {'ROIs_MNS_k75_sm6_r6', 'ROI_L_SupParietal_x=-26_y=-54_z=70_s12.nii',	'MNS_L_SupParietal.nii'};
ROIs{8} = {'ROIs_MNS_k75_sm6_r6', 'ROI_R_InfTemporal_x=52_y=-64_z=0_s12.nii',	'MNS_R_InfTemporal.nii'};
ROIs{9} = {'ROIs_MNS_k75_sm6_r6', 'ROI_R_Postcentral_x=54_y=-30_z=56_s12.nii',	'MNS_R_Postcentral.nii'};

%% Specify source masks
fmni = cell(length(ROIs), 1);	% roi files in MNI space
for mm=1:length(ROIs)
	fmni{mm, 1} = fullfile(src_dir, ROIs{mm}{1}, ROIs{mm}{2}); 
end

%% SET MATLAB PATH & INITIALIZE SPM DEFAULTS
% addpath /Users/dojoonyi/Dropbox/MatlabToolbox/spm12/;
spm('Defaults','fMRI');
spm_jobman('initcfg');

%% Process all participants
for xsn=SN
	clear jobs;

	%% Output Directory
	xSS = sprintf('s%02d', xsn);
	disp(['***********Running ', xSS]);	
	
	work_dir = fullfile(data_dir, xSS);
	rois_dir = fullfile(work_dir, 'rois_native_neurosynth180502');
	if exist(rois_dir, 'dir')~=7
		mkdir(rois_dir);
	end

	for mm=1:length(ROIs)
		copyfile(fmni{mm}, fullfile(rois_dir, ROIs{mm}{3}));
	end

	%% Inverse normalization
	ff = cell(length(ROIs), 1);
	for mm=1:length(ROIs)
		ff{mm, 1} = fullfile(rois_dir, ROIs{mm}{3});
	end
	
	jobs{1}.spatial{1}.normalise{1}.write.subj.def = cellstr(fullfile(data_dir, xSS, 'iy_hires.nii'));
	jobs{1}.spatial{1}.normalise{1}.write.subj.resample = cellstr(ff);
	jobs{1}.spatial{1}.normalise{1}.write.woptions.bb = [NaN NaN NaN; NaN NaN NaN];
	jobs{1}.spatial{1}.normalise{1}.write.woptions.vox = [2 2 2];
	jobs{1}.spatial{1}.normalise{1}.write.woptions.interp = 4;
	jobs{1}.spatial{1}.normalise{1}.write.woptions.prefix = sprintf('s%02d_', xsn);

	
	%% Reslice
	clear ff;
	ff = cell(length(ROIs), 1);
	for mm=1:length(ROIs)
		ff{mm, 1} = fullfile(rois_dir, sprintf('s%02d_%s', xsn, ROIs{mm}{3}));
	end
	
	jobs{2}.spatial{1}.coreg{1}.write.ref = cellstr(fullfile(data_dir, xSS, 'meanexp1.nii'));
	jobs{2}.spatial{1}.coreg{1}.write.source = cellstr(ff);
	jobs{2}.spatial{1}.coreg{1}.write.roptions.interp = 4;
	jobs{2}.spatial{1}.coreg{1}.write.roptions.wrap = [0 0 0];
	jobs{2}.spatial{1}.coreg{1}.write.roptions.mask = 0;
	jobs{2}.spatial{1}.coreg{1}.write.roptions.prefix = 'resliced_';
	
	%% RUN
	spm_jobman('run',jobs);
	
	%% Clean up
	delete(fullfile(rois_dir, 'M*.nii'));
	delete(fullfile(rois_dir, 's*.nii'));

	
end	