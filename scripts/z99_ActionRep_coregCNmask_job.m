%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
matlabbatch{1}.spm.spatial.coreg.write.ref = {'/home/yi.269/data/ActionRep/s01/swrapexp1.nii,1'};
matlabbatch{1}.spm.spatial.coreg.write.source = {'/home/yi.269/spm8/cn_mask/cn_mask25.nii,1'};
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 1;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
matlabbatch{2}.cfg_basicio.file_move.files(1) = cfg_dep;
matlabbatch{2}.cfg_basicio.file_move.files(1).tname = 'Files to move/copy/delete';
matlabbatch{2}.cfg_basicio.file_move.files(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{2}.cfg_basicio.file_move.files(1).tgt_spec{1}(1).value = 'image';
matlabbatch{2}.cfg_basicio.file_move.files(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{2}.cfg_basicio.file_move.files(1).tgt_spec{1}(2).value = 'e';
matlabbatch{2}.cfg_basicio.file_move.files(1).sname = 'Coregister: Reslice: Resliced Images';
matlabbatch{2}.cfg_basicio.file_move.files(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{2}.cfg_basicio.file_move.files(1).src_output = substruct('.','rfiles');
matlabbatch{2}.cfg_basicio.file_move.action.moveto = {'/home/yi.269/data/ActionRep/grp_analysis/'};
