path_to_repos = '/dartfs-hpc/rc/home/1/f0040y1/repositories/';
load(fullfile(path_to_repos, 'OLP4CBP', 'data','subject_metadata.mat'));
% select for Time 1 subjects only
mytabl = tabl(tabl.time==1, :);
proj_basedir = '/dartfs-hpc/rc/home/1/f0040y1/CANlab/labdata/projects/OLP4CBP/';



clean_regressors = zeros(1613, 1);
clean_regressors_offsize = zeros(1609, 1);
orig_regressors = zeros(1613, 1);
orig_regressors_offsize = zeros(1609, 1);


for i = 1:height(mytabl)
    
    confound_pain_fname = fullfile(proj_basedir, 'first_level', sprintf('sub-%04d', mytabl.id(i)),'ses-01', 'spm_modeling', 'bladder_confounds.mat');
    
    if isfile(confound_pain_fname) == 0 % if pain data DNE, skip participant
       disp('No Pain Data. Skipping Participant: ')
       mytabl.id(i)
       mytabl.URSI(i, :)
       continue 
    end
    
    load(confound_pain_fname);
    if size(R(:,1),1) == 1613
        orig_regressors = [orig_regressors R(:,1)];
        %clean_regressor_stds = [clean_regressor_stds std(rpain(:))];
    else
        orig_regressors_offsize = [orig_regressors_offsize R(:,1)];
        %clean_regressor_stds_offsize = [clean_regressor_stds_offsize mean(rpain(:))];
    end
    
    
    pain_reg = R(:,1);
    nuis_covs = R(:, 2:end);
    [rpain, Xpain] = resid(nuis_covs, pain_reg, 1);
    if size(rpain,1) == 1613
        clean_regressors = [clean_regressors rpain];
        %clean_regressor_stds = [clean_regressor_stds std(rpain(:))];
    else
        clean_regressors_offsize = [clean_regressors_offsize rpain];
        %clean_regressor_stds_offsize = [clean_regressor_stds_offsize mean(rpain(:))];
    end
    
end

clean_regressors = clean_regressors(:,2:end);
clean_regressors_offsize = clean_regressors_offsize(:,2:end);
orig_regressors = orig_regressors(:,2:end);
orig_regressors_offsize = orig_regressors_offsize(:,2:end);

save('clean_regressors.mat', 'clean_regressors');
save('clean_regressors_offsize.mat', 'clean_regressors_offsize');
save('orig_regressors.mat', 'orig_regressors');
save('orig_regressors_offsize.mat', 'orig_regressors_offsize');
