%% 180507 djy
commandwindow;

%% Participants Info
SN = [1:12,14:17];

%% Directory Info
root_dir = '/Users/dojoonyi/cn/CLT/ActionRep';
cd(root_dir);

%% ROIs saved with bspmviewer based on neurosynth --> native space transformed
ROIs_dir = 'rois_native_neurosynth180502';
% ROIs{1} = {'ROIs_MZS_k75_sm6_r6', 'ROI_L_MidTemporal_x=-48_y=-56_z=20_s12.nii',	'MZS_L_MidTemporal.nii'};
% ROIs{2} = {'ROIs_MZS_k75_sm6_r6', 'ROI_L_Precuneus_x=0_y=-54_z=40_s12.nii',		'MZS_L_Precuneus.nii'};
% ROIs{3} = {'ROIs_MZS_k75_sm6_r6', 'ROI_R_InfTemporal_x=50_y=2_z=-32_s12.nii',	'MZS_R_InfTemporal.nii'};
% ROIs{4} = {'ROIs_MZS_k75_sm6_r6', 'ROI_R_SupMedFrontal_x=4_y=54_z=24_s12.nii',	'MZS_R_SupMedFrontal.nii'};
% ROIs{5} = {'ROIs_MNS_k75_sm6_r6', 'ROI_L_InfFrontal_x=-56_y=10_z=28_s12.nii',	'MNS_L_InfFrontal.nii'};
% ROIs{6} = {'ROIs_MNS_k75_sm6_r6', 'ROI_L_InfTemporal_x=-50_y=-72_z=0_s12.nii',	'MNS_L_InfTemporal.nii'};
% ROIs{7} = {'ROIs_MNS_k75_sm6_r6', 'ROI_L_SupParietal_x=-26_y=-54_z=70_s12.nii',	'MNS_L_SupParietal.nii'};
% ROIs{8} = {'ROIs_MNS_k75_sm6_r6', 'ROI_R_InfTemporal_x=52_y=-64_z=0_s12.nii',	'MNS_R_InfTemporal.nii'};
% ROIs{9} = {'ROIs_MNS_k75_sm6_r6', 'ROI_R_Postcentral_x=54_y=-30_z=56_s12.nii',	'MNS_R_Postcentral.nii'};
ROIs{1} = {'ROIs_MZS_k75_sm6_r6', 'ROI_R_SupMedFrontal_x=4_y=54_z=24_s12.nii',	'MZS_R_SupMedFrontal.nii'};
ROIs{2} = {'ROIs_MZS_k75_sm6_r6', 'ROI_L_Precuneus_x=0_y=-54_z=40_s12.nii',		'MZS_L_Precuneus.nii'};


%% Directory Info
beta_dir = 'beta_series'; % where beta files are found.

mvpa_dir = fullfile(root_dir, 'mvpa_ActionRep'); 
if exist(mvpa_dir, 'dir')~=7, mkdir(mvpa_dir);	end

targ_dir = fullfile(mvpa_dir, 'native_neurosynth'); 
if exist(targ_dir, 'dir')~=7, mkdir(targ_dir);	end

mat_name = 'mvp_native_neurosynth';

nTOTAL = 192;	% total # of trials in experiment
nTpB = 48;		% # trial per block

addpath /Users/dojoonyi/Dropbox/MatlabToolbox/spm12/;

for xsn=SN
	
	xSS = sprintf('s%02d', xsn);
	S_dir = fullfile(root_dir, xSS);
	R_dir = fullfile(S_dir, ROIs_dir);
		
	for xid=1:length(ROIs)
		%% Loading a roi
		xroi = spm_vol(fullfile(R_dir, sprintf('resliced_%s_%s', xSS, ROIs{xid}{3})));
		RR = spm_read_vols(xroi);
		tIDX = find(RR>0.5);
		
		[xx, yy, zz] = ind2sub(xroi.dim, tIDX);	% xyz coordinates
		
		data{xid}.name = sprintf('%s', ROIs{xid}{3}(1:end-4));
		data{xid}.x = xx';
		data{xid}.y = yy';
		data{xid}.z = zz';
		data{xid}.vv = zeros(nTOTAL, length(xx));
		
		for it=1:nTOTAL
			%% Read a beta image
			xrun = fix((it-1)/nTpB)+1;
			xtrl = mod(it-1,nTpB)+1;
			xbeta = spm_vol(fullfile(S_dir, beta_dir, sprintf('beta%03dr%dt%02d.nii', it, xrun, xtrl)));
			BB = spm_read_vols(xbeta);
			
			data{xid}.vv(it,:) = BB(tIDX);
			clear xrun xtrl xbeta BB;
		end
 		clear xroi RR TT tIDX xx yy zz;
	end
 	save(fullfile(targ_dir, sprintf('%s%s', mat_name, xSS)), 'data');
	fprintf(sprintf('%s%s.mat has been saved.\n', mat_name, xSS));
	clear data;
end
