%% http://www0.cs.ucl.ac.uk/staff/g.ridgway/masking/
% This script requires the 'masking' toolbox.

%% Participants Info
SN = [1:12,14:17];

%% Directory Info
data_dir = '/Users/dojoonyi/cn/ActionRep';
cd(data_dir);

%% SET MATLAB PATH & INITIALIZE SPM DEFAULTS
% addpath /Users/dojoonyi/Dropbox/MatlabToolbox/spm12/;
spm('Defaults','fMRI');
spm_jobman('initcfg');

%%
for xsn=SN
	clear jobs;

	xSS = sprintf('s%02d', xsn);
	work_dir = fullfile(data_dir, xSS);

	% Masking toolbox
	ff=[];
	ff = [ff; spm_select('ExtFPList', work_dir, '^rexp1.nii', Inf)];
	ff = [ff; spm_select('ExtFPList', work_dir, '^rexp2.nii', Inf)];
	ff = [ff; spm_select('ExtFPList', work_dir, '^rexp3.nii', Inf)];
	ff = [ff; spm_select('ExtFPList', work_dir, '^rexp4.nii', Inf)];
		
	jobs{1}.spm.tools.masking{1}.makeavg.innames = cellstr(ff);
	jobs{1}.spm.tools.masking{1}.makeavg.avgexpr = 'mean(X)';
	jobs{1}.spm.tools.masking{1}.makeavg.outname = sprintf('avg_%s.nii', xSS);
	jobs{1}.spm.tools.masking{1}.makeavg.outdir = {work_dir};
	
	jobs{2}.spm.tools.masking{1}.optthr.inname(1) = cfg_dep('Make Average: Average Image', ...
		substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
	jobs{2}.spm.tools.masking{1}.optthr.optfunc = '@opt_thr_corr';
	jobs{2}.spm.tools.masking{1}.optthr.outname = sprintf('mask_optthr_%s.nii', xSS);
	jobs{2}.spm.tools.masking{1}.optthr.outdir = {work_dir};
	
	jobs{3}.spm.util.checkreg.data(1) = cfg_dep('Make Average: Average Image', ...
		substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
	jobs{3}.spm.util.checkreg.data(2) = cfg_dep('Optimal Thresholding: Mask Image', ...
		substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','outname'));
	
	% RUN
	spm_jobman('run',jobs);
end
% ---------------------------- EOF.