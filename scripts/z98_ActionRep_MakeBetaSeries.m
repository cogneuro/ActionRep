clear all;
 
%% Participants Info
SN={};
SN{end+1} = {'s01', 'KSJ'};	% directory, initials, runs, series
SN{end+1} = {'s02', 'LJH'};
SN{end+1} = {'s03', 'SIH'};
SN{end+1} = {'s04', 'KSH'};
SN{end+1} = {'s05', 'JSH'};
SN{end+1} = {'s06', 'HBS'};
SN{end+1} = {'s07', 'DJR'};
SN{end+1} = {'s08', 'JMK'};
SN{end+1} = {'s09', 'CJY'};
SN{end+1} = {'s10', 'YJS'};
SN{end+1} = {'s11', 'KDW'};
SN{end+1} = {'s12', 'HMO'};
SN{end+1} = {'s14', 'JYJ'};
SN{end+1} = {'s15', 'YHJ'};
SN{end+1} = {'s16', 'LSC'};
SN{end+1} = {'s17', 'KSA'};

%% Directory Info
root_dir = '/home/yi.269/data/ActionRep/';	
beta_dir = 'beta_series';	% where all the trial-specific beta files will be saved. Here 'canonical' only (see line 86).
stat_dir = 'stats_temp';		% where an SPM.mat will be temporally saved and deleted.
prot_dir = 'protocol';			% where a participant's spm onset .mat is saved.

durSTM=2;						% stimulus event in TR, 0 for event-related designs
durRSP=0;						% response event

nRUN = 4;						% # runs
nTR = 245;						% # TR of each run
initTR = [001, 246, 491, 736];	% The 1st TR of each run
endTR  = [245, 490, 735, 980];	% The last TR of each run

addpath /home/yi.269/spm8;
spm('Defaults','fMRI');
spm_jobman('initcfg');

%% Each subject
for xsn=1:size(SN,2)
	S_dir = [SN{xsn}{1}, SN{xsn}{2}];
	
	mkdir(fullfile(root_dir, SN{xsn}{1}, beta_dir));

	W_dir = fullfile(root_dir, SN{xsn}{1}, stat_dir);
	mkdir(W_dir);		
	cd(W_dir);

	%% Protocol file
	clear data_dir;
	data_dir = fullfile(root_dir, prot_dir, S_dir);
	
	%% Movement parameter
	clear MM;
	MM = load(fullfile(root_dir, SN{xsn}{1}, 'rp_apexp1.txt'));	% 3DMC

	%% Temporary onset file
	clear mat_name durations names;
	mat_name  = fullfile(W_dir, 'ons');	% temporary onset file
	durations = cell(1,2);	
	for mm=1:2, durations{mm} = durSTM;	end		% stimulus duration

	names	  = {'ONE','OTHER'};

	bc = 0;				% beta file counter
	nTRIALperRUN = 48;	% # trials/run

	%% Each run: To make a quick job, we do not concatenate runs.
	for xrun=1:nRUN
		clear SS;
		SS = load(fullfile(data_dir, sprintf('datRawActionRep_%s_%d.txt', S_dir, xrun)));
		% 1_SN, 2_run, 3_trial, 4_cond, 5_IM, 6_plan, 7_TTL, 8_stim, 9_scale, 10_resp, 11_rt

		clear mv;
		mv = MM(initTR(xrun):endTR(xrun), :);	% Extracting a run-specific movement parameters from a concatenated one.

		bc = (xrun-1)*nTRIALperRUN;

		%% Model Specification
		jobs{1}.stats{1}.fmri_spec.dir = cellstr(W_dir);
		jobs{1}.stats{1}.fmri_spec.timing.units = 'scans';
		jobs{1}.stats{1}.fmri_spec.timing.RT = 2;
		jobs{1}.stats{1}.fmri_spec.timing.fmri_t = 16;
		jobs{1}.stats{1}.fmri_spec.timing.fmri_t0 = 1;
		
		ff = spm_select('ExtFPList', fullfile(root_dir, SN{xsn}{1}), sprintf('cwrapexp%d.nii',xrun), Inf);
		jobs{1}.stats{1}.fmri_spec.sess.scans = cellstr(ff);

 		jobs{1}.stats{1}.fmri_spec.sess.multi_reg = cellstr('mv.txt');	% see line 124
		jobs{1}.stats{1}.fmri_spec.sess.hpf = 128;

		jobs{1}.stats{1}.fmri_spec.bases.hrf.derivs = [0,0];
		jobs{1}.stats{1}.fmri_spec.volt = 1;
		jobs{1}.stats{1}.fmri_spec.global = 'None';
		jobs{1}.stats{1}.fmri_spec.mask = cellstr(fullfile(root_dir, SN{xsn}{1}, 'mask.nii'));
		jobs{1}.stats{1}.fmri_spec.cvi = 'AR(1)';

		%% Estimation
		jobs{1}.stats{2}.fmri_est.spmmat = cellstr(fullfile(root_dir, SN{xsn}{1}, stat_dir, 'SPM.mat'));
		jobs{1}.stats{2}.fmri_est.method.Classical = 1;

		%% Each trial
		for xtr=1:nTRIALperRUN
			clear onsets;
			% 1_SN, 2_run, 3_trial, 4_cond, 5_IM, 6_plan, 7_TTL, 8_stimT, 9_scaleT, 10_resp, 11_rt
			onsets{1} = SS(SS(:,3)==xtr, 8)/2;		% current trial	
			onsets{2} = SS(SS(:,3)~=xtr, 8)/2;		% all the other trials
	
			save(mat_name, 'onsets', 'names', 'durations');	

			clear CON;
			CON=load(fullfile(W_dir, 'ons.mat'));
			for con=1:length(CON.names)
				jobs{1}.stats{1}.fmri_spec.sess.cond(con).name = CON.names{con};
				jobs{1}.stats{1}.fmri_spec.sess.cond(con).onset = CON.onsets{con};
				jobs{1}.stats{1}.fmri_spec.sess.cond(con).duration = CON.durations{con};
				jobs{1}.stats{1}.fmri_spec.sess.cond(con).tmod = 0;
				jobs{1}.stats{1}.fmri_spec.sess.cond(con).pmod = struct('name', {}, 'param', {}, 'poly', {});
			end

			save(fullfile(W_dir, 'mv.txt'), 'mv', '-ASCII', '-DOUBLE','-TABS');

			%% Run job
			spm_jobman('run',jobs);
			
			% move beta files from a temporary 'stat_dir' to 'beta_dir'
			bc = bc+1;
			movefile(fullfile(W_dir, 'beta_0001.hdr'),...
					fullfile(root_dir, SN{xsn}{1}, beta_dir, sprintf('beta%03dr%dt%02d.hdr',bc,xrun,xtr)));
			movefile(fullfile(W_dir, 'beta_0001.img'),...
					fullfile(root_dir, SN{xsn}{1}, beta_dir, sprintf('beta%03dr%dt%02d.img',bc,xrun,xtr)));			
			delete(fullfile(W_dir, '*.*'));
		end% xtr
	end%xrun

	cd(root_dir);
	rmdir(W_dir, 's');	% remove 'stat_dir'
end%xsn
