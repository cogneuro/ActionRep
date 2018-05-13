function c01_ActionRep_native_filtering()
% 180315 djy

	%% SET MATLAB PATH & INITIALIZE SPM DEFAULTS
% 	addpath /Users/dojoonyi/Dropbox/MatlabToolbox/spm12/;
	spm('Defaults','fMRI');
	spm_jobman('initcfg');

	%% PATH FOR DATA
	data_dir = spm_select(1, 'dir', 'Choose the study directory',{},{},'ActionRep');
	cd(data_dir);

	%% SUBJECTS SPECIFICATION
 	SN = [1:12,14:17];
	
	%% BATCH JOB
	spmbatch_ActionRep_regress(SN, data_dir);
	spmbatch_ActionRep_3Dto4D(SN, data_dir);
	
	for xsn=SN
		rmdir(fullfile(data_dir, sprintf('s%02d', xsn), 'stats_regress'), 's');
	end
	
end

function spmbatch_ActionRep_regress(SN, data_dir)
	
	for xsn=SN
		clear jobs;
		
		xSS = sprintf('s%02d', xsn);
		work_dir = fullfile(data_dir, xSS);
		stat_dir = fullfile(work_dir, 'stats_regress');
		ons_dir  = fullfile(work_dir, 'ons');
	
		%% Output Directory
		if exist(stat_dir, 'dir')~=7
			mkdir(stat_dir);
		end

		%% Model Specification
		jobs{1}.stats{1}.fmri_spec.dir = cellstr(stat_dir);
		jobs{1}.stats{1}.fmri_spec.timing.units = 'scans';
		jobs{1}.stats{1}.fmri_spec.timing.RT = 2;
		jobs{1}.stats{1}.fmri_spec.timing.fmri_t = 16;
		jobs{1}.stats{1}.fmri_spec.timing.fmri_t0 = 1;

		ff=[];
		ff = [ff; spm_select('ExtFPList', work_dir, '^rexp1.nii', Inf)];
		ff = [ff; spm_select('ExtFPList', work_dir, '^rexp2.nii', Inf)];
		ff = [ff; spm_select('ExtFPList', work_dir, '^rexp3.nii', Inf)];
		ff = [ff; spm_select('ExtFPList', work_dir, '^rexp4.nii', Inf)];
		jobs{1}.stats{1}.fmri_spec.sess.scans = cellstr(ff);
		jobs{1}.stats{1}.fmri_spec.sess.multi_reg = cellstr(fullfile(ons_dir, sprintf('par3dmc+scrubbed_%s.txt', xSS)));
		jobs{1}.stats{1}.fmri_spec.sess.hpf = 128;
		jobs{1}.stats{1}.fmri_spec.mask = {fullfile(work_dir, sprintf('mask_optthr_%s.nii,1', xSS))};
		jobs{1}.stats{1}.fmri_spec.cvi = 'AR(1)';

		%% Estimation
		jobs{1}.stats{2}.fmri_est.spmmat = cellstr(fullfile(stat_dir, 'SPM.mat'));
		jobs{1}.stats{2}.fmri_est.write_residuals = 1;
		jobs{1}.stats{2}.fmri_est.method.Classical = 1;

		save(fullfile(work_dir, 'stats_reg_spec.mat'),'jobs');

		% RUN
		spm_jobman('run',jobs);
	end
end

function spmbatch_ActionRep_3Dto4D(SN, data_dir)
	
	for xsn=SN
		clear jobs;
		
		xSS = sprintf('s%02d', xsn);
		work_dir = fullfile(data_dir, xSS);
		stat_dir = fullfile(work_dir, 'stats_regress');
	
		% 3D -> 4D
		ss = spm_select('FPList', stat_dir, '^Res_0.*\.nii$');
		jobs{1}.spm.util.cat.vols = cellstr(ss);
		jobs{1}.spm.util.cat.name = fullfile(work_dir, sprintf('Res4D_%s.nii', xSS));
		jobs{1}.spm.util.cat.dtype = 4;

		% RUN
		spm_jobman('run',jobs);
	end
end
% ---------------------------- EOF.