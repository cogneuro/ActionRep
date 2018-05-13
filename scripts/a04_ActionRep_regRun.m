% Setups
root_dir = '/Users/dojoonyi/cn/ActionRep/';
ons_dir	 = 'ons';

% Experimental design
SN = [1:12,14:17];

for mm = 1:length(SN)
	xSS = sprintf('s%02d', SN(mm));
	mv = load(fullfile(root_dir, xSS, 'rp_exp1.txt'));

	if exist(fullfile(root_dir, xSS, ons_dir), 'dir')~=7
		mkdir(fullfile(root_dir, xSS, ons_dir));
	end
	
	% add run-specific regressors to 3DMC
	mv(001:245, end+1) = 1;
	mv(246:490, end+1) = 1;
	mv(491:735, end+1) = 1;

	mv_name = fullfile(root_dir, xSS, ons_dir, sprintf('par3dmc_%s.txt', xSS));
	dlmwrite(mv_name, mv, 'delimiter', '\t', 'precision', '%.7e');
	clear mv_name mv;
end