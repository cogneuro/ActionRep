clear all;
SN = {};
SN{end+1} = {'s01', 'KSJ', '20140704', 1:4, 4:7};
SN{end+1} = {'s02', 'LJH', '20140704', 1:4, 4:7};
SN{end+1} = {'s03', 'SIH', '20140707', 1:4, 5:8};
SN{end+1} = {'s04', 'KSH', '20140707', 1:4, 4:7};
SN{end+1} = {'s05', 'JSH', '20140707', 1:4, 4:7};
SN{end+1} = {'s06', 'HBS', '20140707', 1:4, 4:7};
SN{end+1} = {'s07', 'DJR', '20140707', 1:4, 4:7};
SN{end+1} = {'s08', 'JMK', '20140708', 1:4, 5:8};
SN{end+1} = {'s09', 'CJY', '20140708', 1:4, 4:7};
SN{end+1} = {'s10', 'YJS', '20140708', 1:4, 4:7};
SN{end+1} = {'s11', 'KDW', '20140708', 1:4, 4:7};
SN{end+1} = {'s12', 'HMO', '20140708', 1:4, 4:7};
SN{end+1} = {'s14', 'JYJ', '20150126', 1:4, 3:6};
SN{end+1} = {'s15', 'YHJ', '20150126', 1:4, 4:7};
SN{end+1} = {'s16', 'LSC', '20150126', 1:4, 4:7};
SN{end+1} = {'s17', 'KSA', '20150126', 1:4, 4:7};

% Information & Parameters
root_dir ='/Users/dojoonyi/Documents/cn/ActionRep';

%% Rename!
for xsn=1:length(SN)
	DD = {};
	DD{end+1} = {'1_ep2d_pace',	'exp1.nii'};
	DD{end+1} = {'2_ep2d_pace',	'exp2.nii'};
	DD{end+1} = {'3_ep2d_pace',	'exp3.nii'};
	DD{end+1} = {'4_ep2d_pace',	'exp4.nii'};
	DD{end+1} = {'mpr_sag',		'hires.nii'};
	
	mkdir(fullfile(root_dir, SN{xsn}{1}));
	mkdir(fullfile(root_dir, SN{xsn}{1}, 'info'));
	
	work_dir = fullfile(root_dir, sprintf('%s-%s', SN{xsn}{3}, SN{xsn}{2}));
	
	% rename
    listdir = dir(fullfile(work_dir, '*.nii'));
	for nn=1:length(DD)
		for mm=1:length(listdir)
			if strfind(listdir(mm).name, DD{nn}{1})
				listdir(mm).name
 				movefile(fullfile(work_dir, listdir(mm).name), fullfile(root_dir, SN{xsn}{1}, DD{nn}{2}));
			end
		end
	end
	
	% move 
	movefile(fullfile(work_dir, '*'), fullfile(root_dir, SN{xsn}{1}, 'info'));
	rmdir(work_dir,'s');
end
% ---- EOF.