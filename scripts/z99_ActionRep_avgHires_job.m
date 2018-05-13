%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
matlabbatch{1}.spm.util.imcalc.input = {
                                        '/home/yi.269/data/ActionRep/s01/wmhires.nii,1'
                                        '/home/yi.269/data/ActionRep/s02/wmhires.nii,1'
                                        '/home/yi.269/data/ActionRep/s03/wmhires.nii,1'
                                        '/home/yi.269/data/ActionRep/s04/wmhires.nii,1'
                                        '/home/yi.269/data/ActionRep/s05/wmhires.nii,1'
                                        '/home/yi.269/data/ActionRep/s06/wmhires.nii,1'
                                        '/home/yi.269/data/ActionRep/s07/wmhires.nii,1'
                                        '/home/yi.269/data/ActionRep/s08/wmhires.nii,1'
                                        '/home/yi.269/data/ActionRep/s09/wmhires.nii,1'
                                        '/home/yi.269/data/ActionRep/s10/wmhires.nii,1'
                                        '/home/yi.269/data/ActionRep/s11/wmhires.nii,1'
                                        '/home/yi.269/data/ActionRep/s12/wmhires.nii,1'
                                        '/home/yi.269/data/ActionRep/s14/wmhires.nii,1'
                                        '/home/yi.269/data/ActionRep/s15/wmhires.nii,1'
                                        '/home/yi.269/data/ActionRep/s16/wmhires.nii,1'
                                        '/home/yi.269/data/ActionRep/s17/wmhires.nii,1'
                                       };
matlabbatch{1}.spm.util.imcalc.output = 'avg16_ActionRep.nii';
matlabbatch{1}.spm.util.imcalc.outdir = {'/home/yi.269/data/ActionRep/grp_analysis/'};
matlabbatch{1}.spm.util.imcalc.expression = '(i1+i2+i3+i4+i5+i6+i7+i8+i9+i10+i11+i12+i13+i14+i15+i16)/16';
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
