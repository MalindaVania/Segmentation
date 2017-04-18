function [sample_frame,RL,phi0tmpe, phi0tmp_label] = supraspinatus_satisfaction(f3D,L3D)

[nRows,nCols,nDims] = size(f3D);

%% ********* sample frame과 bone label(BL) 선택 ********* %%
def         = {'30','5','3'};

prompt      = {'Enter sample frame:','Enter rotate cuff label:','Enter strel size:'};
dlg_title   = 'Input';
num_lines   = [1 50];
answer      = inputdlg(prompt,dlg_title,num_lines,def);

sample_frame    = str2double(answer(1));
RL              = str2double(answer(2));
strel_size     	= str2double(answer(3));

f = f3D(:,:,sample_frame);
L = L3D(:,:,sample_frame);

phi0tmp = zeros(nRows,nCols)-1;   phi0tmp( L==RL ) = 1;   %% Label 미만인 부분을 1, 이상인 부분을 -1
phi0tmp = imfill(phi0tmp,'hole');
phi0tmpe = imerode(phi0tmp,strel('disk',strel_size));
phi0tmp_label = bwlabel(phi0tmpe>0);  %% u0tmp labelling

figure('units','normalized','outerposition',[0 0 1 1])
subplot(121); im(L,[]);  title(sprintf('frame# : %d', sample_frame));
subplot(122); im(phi0tmpe,[]); title(sprintf('erode with strel size %d', strel_size));

options1.Interpreter = 'tex';
options1.Default = 'yes';
qstring = 'Are you satisfied ?';
satisfaction = questdlg(qstring,'initial test for sample frame','yes','no','exit',options1);     

while strcmp(satisfaction,'no')    
     %% input
    prompt      = {'Enter sample frame:','Enter rotate cuff label:','Enter strel size:'};
    dlg_title   = 'Input';
    num_lines   = [1 50];
    answer      = inputdlg(prompt,dlg_title,num_lines,def);

    sample_frame = str2double(answer(1));
    RL          = str2double(answer(2));
    strel_size  = str2double(answer(3));

    f = f3D(:,:,sample_frame);
    L = L3D(:,:,sample_frame);
    
    phi0tmp = zeros(nRows,nCols)-1;   phi0tmp( L==RL ) = 1;   %% Label 미만인 부분을 1, 이상인 부분을 -1
    phi0tmp = imfill(phi0tmp,'hole');
    phi0tmpe = imerode(phi0tmp,strel('disk',strel_size));
    phi0tmp_label = bwlabel(phi0tmpe>0);  %% u0tmp labelling

     %% show input result
     figure('units','normalized','outerposition',[0 0 1 1])
     subplot(121); im(L,[]);  title(sprintf('frame# : %d', sample_frame));
    subplot(122); im(phi0tmpe,[]); title(sprintf('erode with strel size %d', strel_size));

    %% check satisfaction
    options1.Interpreter = 'tex';
    options1.Default = 'yes';
    qstring = 'Are you satisfied ?';
    satisfaction = questdlg(qstring,'initial test for sample frame','yes','no','exit',options1);   
    
    if strcmp(satisfaction,'exit')   
        break;
    end
end
