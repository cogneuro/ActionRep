function a02_ActionRep_spmbatch_preproc()
% 180313 djy

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
	spmbatch_ActionRep_preproc(SN, data_dir);

end

function spmbatch_ActionRep_preproc(SN, data_dir)
	%% WORKING DIRECTORY (useful for .ps only)
	work_dir = 'log_preproc';
	if exist(fullfile(data_dir, work_dir), 'dir')~=7
		mkdir(fullfile(data_dir, work_dir));
	end
	
	for xsn=SN
		clear jobs;
		
		xSS = sprintf('s%02d', xsn);
		fprintf("\nAnalysis of %s just started...\n", xSS);
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% SPATIAL PREPROCESSING
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		%% Select functional and structural scans
		%--------------------------------------------------------------------------
		clear aa;
		aa = spm_select('FPList', fullfile(data_dir, xSS), 'hires.nii');

		ff = [];
		ff = [ff; spm_select('ExtFPList', fullfile(data_dir, xSS), 'exp1.nii', Inf)];
		ff = [ff; spm_select('ExtFPList', fullfile(data_dir, xSS), 'exp2.nii', Inf)];
		ff = [ff; spm_select('ExtFPList', fullfile(data_dir, xSS), 'exp3.nii', Inf)];
		ff = [ff; spm_select('ExtFPList', fullfile(data_dir, xSS), 'exp4.nii', Inf)];

		%% REALIGN
		%--------------------------------------------------------------------------
		jobs{1}.spatial{1}.realign{1}.estwrite.data{1} = cellstr(ff);

		%% COREGISTRATION
		%--------------------------------------------------------------------------
		jobs{1}.spatial{2}.coreg{1}.estimate.ref = editfilenames(ff(1,:),'prefix','mean');
		jobs{1}.spatial{2}.coreg{1}.estimate.source = cellstr(aa);

		%% SEGMENT
		%--------------------------------------------------------------------------
		jobs{1}.spatial{3}.preproc.channel.vols = cellstr(aa);
		jobs{1}.spatial{3}.preproc.channel.write = [0 1];	% Save Bias Corrected
		jobs{1}.spatial{3}.preproc.warp.affreg = 'eastern';
		jobs{1}.spatial{3}.preproc.warp.write = [1 1];		% Inverse + Forward
		
		%% NORMALIZE
		%--------------------------------------------------------------------------
		jobs{1}.spatial{4}.normalise{1}.write.subj.def = editfilenames(aa,'prefix','y_','ext','.nii');
		fff = editfilenames(ff(1,:),'prefix','mean');
		jobs{1}.spatial{4}.normalise{1}.write.subj.resample = [editfilenames(ff,'prefix','r'); fff(1)];
		jobs{1}.spatial{4}.normalise{1}.write.woptions.vox = [3 3 3];

		jobs{1}.spatial{4}.normalise{2}.write.subj.def = editfilenames(aa,'prefix','y_','ext','.nii');
		jobs{1}.spatial{4}.normalise{2}.write.subj.resample = editfilenames(aa,'prefix','m','ext','.nii');
		jobs{1}.spatial{4}.normalise{2}.write.woptions.vox = [1 1 1];

		%% SMOOTHING
		%--------------------------------------------------------------------------
		jobs{1}.spatial{5}.smooth.data = editfilenames(ff,'prefix','wr');
		jobs{1}.spatial{5}.smooth.fwhm = [6 6 6];

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%% RUN
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		save(fullfile(data_dir, work_dir, ['preproc_' xSS '.mat']),'jobs');
		spm_jobman('run',jobs);

	end
end

function filelist = editfilenames(filelist,varargin)
% Prepend, append or change extension of a list of filenames
% FUNCTION filelist = editfilenames(filelist,action,fix, action,fix,...)
%   filelist - char array or a cell array of strings.
%   action   - either 'prefix', 'suffix' or 'ext'
%   fix      - corresponding string

	if rem(length(varargin),2)
		error('Not enough input arguments.');
	end

	if ischar(filelist), filelist = cellstr(filelist); end

	for i=1:2:length(varargin)
		chext = 0;
		switch varargin{i}
			case 'prefix'
				prefix = varargin{i+1};
				suffix = '';
			case 'suffix'
				prefix = '';
				suffix = varargin{i+1};
			case 'ext'
				prefix = '';
				suffix = '';
				chext = varargin{i+1};
			otherwise
				error('Unknown action.');
		end

		for j=1:numel(filelist)
			[pth,nam,ext,num] = spm_fileparts(deblank(filelist{j}));
			if ischar(chext), ext = chext; end
			if iscell(prefix), prfx = prefix{j}; else prfx = prefix; end
			if iscell(suffix), sfix = suffix{j}; else sfix = suffix; end
			filelist{j}  = fullfile(pth,[prfx nam sfix ext num]);
		end
	end

end
