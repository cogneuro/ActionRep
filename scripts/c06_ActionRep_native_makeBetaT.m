% 180531 djy
% Based on HML's suggestion (Misaki, Kim, Bandettini, Kriegeskorte, 2010,
% NI), this script generates T-maps rather than Beta maps.

commandwindow;

%% Uploading data
prot_dir = '/Users/dojoonyi/Documents/GitHub/ActionRep'; 
filename = fullfile(prot_dir, 'protocol', 'protocol_ActionRep.csv');
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

%% Study info
SN = unique(TT(:,1));

durSTM=2;						% stimulus event in TR, 0 for event-related designs

nRUN = 4;						% # runs
nTR = 245;						% # TR of each run
initTR = [001, 246, 491, 736];	% The 1st TR of each run
endTR  = [245, 490, 735, 980];	% The last TR of each run

root_dir = '/Users/dojoonyi/cn/CLT/ActionRep/'; 

addpath /Users/dojoonyi/Dropbox/MatlabToolbox/spm12/;
spm('Defaults','fMRI');
spm_jobman('initcfg');

%% Each subject
for it=1:length(SN)
	xsn = SN(it);
	
	xSS = sprintf('s%02d', xsn);
	S_dir = fullfile(root_dir, xSS);
	
	% where all the trial-specific beta files will be saved. 
	% Here 'canonical' only (see line 86).
	beta_dir = fullfile(S_dir, 'beta_series_nativeT'); 
	if exist(beta_dir, 'dir')~=7, mkdir(beta_dir);	end
	
	% where an SPM.mat will be temporally saved and deleted.
	stat_dir = fullfile(S_dir, 'stats_temp');
	if exist(stat_dir, 'dir')~=7, mkdir(stat_dir);	end
	
	%% Movement parameter
	clear MM;
	MM = load(fullfile(S_dir, 'rp_exp1.txt'));	% 3DMC

	%% Temporary onset file
	clear mat_name durations names;
	mat_name  = fullfile(stat_dir, 'ons');	% temporary onset file
	durations = cell(1,2);	
	for mm=1:2, durations{mm} = durSTM;	end		% stimulus duration
	names	  = {'ONE','OTHERS'};

	bc = 0;				% beta file counter
	nTRIALperRUN = 48;	% # trials/run

	%% Each run: To make a quick job, we do not concatenate runs.
	for xrun=1:nRUN		
		clear SS;
		SS = TT(TT(:,1)==xsn & TT(:,2)==xrun, :);

		%% Extracting a run-specific movement parameters from a concatenated one.
		clear mv;
		mv = MM(initTR(xrun):endTR(xrun), :);	
		if exist(fullfile(S_dir, sprintf('dvars_rexp%d.txt', xrun)),'file')==2
			clear xreg;
			xreg = load(fullfile(S_dir, sprintf('dvars_rexp%d.txt', xrun)));
			mv = horzcat(mv, xreg);
		end
		
		if exist(fullfile(S_dir, 'mv_temp.txt'),'file')==2 	% save runs-specific 3DMC
			delete(fullfile(S_dir, 'mv_temp.txt'));
		end
		save(fullfile(S_dir, 'mv_temp.txt'), 'mv', '-ASCII', '-DOUBLE','-TABS');
		
		%% Functional data
		ff = spm_select('ExtFPList', S_dir, sprintf('^rexp%d.nii',xrun), Inf);

		%% Model Specification
		jobs{1}.stats{1}.fmri_spec.dir = cellstr(stat_dir);
		jobs{1}.stats{1}.fmri_spec.timing.units = 'scans';
		jobs{1}.stats{1}.fmri_spec.timing.RT = 2;
		jobs{1}.stats{1}.fmri_spec.timing.fmri_t = 16;
		jobs{1}.stats{1}.fmri_spec.timing.fmri_t0 = 1;		
		jobs{1}.stats{1}.fmri_spec.sess.scans = cellstr(ff);
 		jobs{1}.stats{1}.fmri_spec.sess.multi_reg = cellstr(fullfile(S_dir, 'mv_temp.txt'));
		jobs{1}.stats{1}.fmri_spec.sess.hpf = 128;
		jobs{1}.stats{1}.fmri_spec.bases.hrf.derivs = [0,0];
		jobs{1}.stats{1}.fmri_spec.volt = 1;
		jobs{1}.stats{1}.fmri_spec.global = 'None';
% 		jobs{1}.stats{1}.fmri_spec.mask = cellstr(fullfile(S_dir, sprintf('mask_optthr_%s.nii,1', xSS)));		
		jobs{1}.stats{1}.fmri_spec.mask = {''};
		jobs{1}.stats{1}.fmri_spec.cvi = 'AR(1)';

		%% Estimation
		jobs{1}.stats{2}.fmri_est.spmmat = cellstr(fullfile(stat_dir, 'SPM.mat'));
		jobs{1}.stats{2}.fmri_est.method.Classical = 1;

		%% Contrast Specification
		jobs{1}.stats{3}.con.spmmat = cellstr(fullfile(stat_dir, 'SPM.mat'));		

		%% Each trial
		bc = (xrun-1)*nTRIALperRUN;
		for xtr=1:nTRIALperRUN
			bc = bc+1;
			
			clear onsets;
			% 1_SN, 2_run, 3_trial, 4_cond, 5_IM, 6_plan, 7_TTL, 8_stimT, 9_scaleT, 10_resp, 11_rt
			onsets{1} = SS(SS(:,3)==xtr, 8)/2;		% current trial	
			onsets{2} = SS(SS(:,3)~=xtr, 8)/2;		% all the other trials

			save(mat_name, 'onsets', 'names', 'durations');	

			clear CON;
			CON=load(fullfile(stat_dir, 'ons.mat'));
			for con=1:length(CON.names)
				jobs{1}.stats{1}.fmri_spec.sess.cond(con).name = CON.names{con};
				jobs{1}.stats{1}.fmri_spec.sess.cond(con).onset = CON.onsets{con};
				jobs{1}.stats{1}.fmri_spec.sess.cond(con).duration = CON.durations{con};
				jobs{1}.stats{1}.fmri_spec.sess.cond(con).tmod = 0;
				jobs{1}.stats{1}.fmri_spec.sess.cond(con).pmod = struct('name', {}, 'param', {}, 'poly', {});
			end

			jobs{1}.stats{3}.con.consess{1}.tcon = struct('name',sprintf('trial%03d', bc),'convec',[1,0,0],'sessrep','none');
			
			%% Run job
			spm_jobman('run',jobs);
			
			% move beta files from a temporary 'stat_dir' to 'beta_dir'
			movefile(fullfile(stat_dir, 'spmT_0001.nii'),...
					fullfile(beta_dir, sprintf('T%03dr%dt%02d.nii',bc,xrun,xtr)));
 			delete(fullfile(stat_dir, '*.*'));
		end% xtr
	end%xrun

	cd(root_dir);
	rmdir(stat_dir, 's');	% remove 'stat_dir'
	delete(fullfile(S_dir, 'mv_temp.txt'));
end%xsn
