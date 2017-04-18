function [L3D, sgm, omg] = multiphase_satisfaction(M3D,Index)

[nRows,nCols,nDims] = size(M3D);
% Index = 1:nRows*nCols*nDims;

%% ********* sigma¿Í omega ¼±ÅÃ ********* %%
def         = {'5','0.5','100'};

sgm         = str2double(def(1));
omg         = str2double(def(2));
tmp_frame	= str2double(def(3));
tic
[~, L3D] = MultiPhaseSegmentationNew(M3D, sgm, omg, Index);
AGMC_time = toc
figure('units','normalized','outerposition',[0 0 1 1])
subplot(121); im(M3D(:,:,tmp_frame),[]); title(sprintf('frame# : %d', tmp_frame)); colorbar;
subplot(122); im(L3D(:,:,tmp_frame),[]); title(sprintf('sigma: %d, omega: %1.2f', sgm, omg)); colorbar;


options1.Interpreter = 'tex';
options1.Default = 'yes';
qstring = 'Are you satisfied ?';
satisfaction = questdlg(qstring,'multiphase segmentation','yes','no','exit',options1);     

while strcmp(satisfaction,'no')    
     %% input
    prompt      = {'Enter sigma:','Enter omega:','Enter sample frame:'};
    dlg_title   = 'Input';
    num_lines   = 1;
    answer      = inputdlg(prompt,dlg_title,num_lines,def);

    sgm         = str2double(answer(1));
    omg         = str2double(answer(2));
    tmp_frame	= str2double(answer(3));

    tic;
    [~, L3D] = MultiPhaseSegmentationNew(M3D, sgm, omg, Index);
    multiphase_time = toc

     %% show input result
    subplot(121); im(M3D(:,:,tmp_frame),[]); title(sprintf('frame# : %d', tmp_frame)); colorbar;
    subplot(122); im(L3D(:,:,tmp_frame),[]); title(sprintf('sigma: %d, omega: %1.2f', sgm, omg)); colorbar;

    %% check satisfaction
    options1.Interpreter = 'tex';
    options1.Default = 'yes';
    qstring = 'Are you satisfied ?';
    satisfaction = questdlg(qstring,'multiphase segmentation','yes','no','exit',options1);      
    

    if strcmp(satisfaction,'exit')   
        break;
    end
end
