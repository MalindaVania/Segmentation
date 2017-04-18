%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%      Mandible Segmentation
%%
%%      (0) Data Setting
%%      (1) Multi-phase segmentation
%%      (2) Mandible
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;

%% Add path - subfunction들이 있는 폴더 연결
parent_directory = 'F:\01 KIST\02 Code\01 Project Codes\2015 두경부과제(악악면, Fibula분할) Code_CT\2016+0518+개선';
addpath(genpath(parent_directory))

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%              (0) Data Setting
%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 데이터 디렉토리와 폴더 이름 세팅
% dataDir    = 'E:\01 KIST\01 Data\2015 두경부과제(악악면,Fibula분할) Data_CT\20151105\sorting data\dicom\03_김기옥1_얼굴_MDCT';
dataDir     = input('▶▶ Input the data directory : ');
data_name   = SetFolderName( dataDir, '\', 1 );
addpath(dataDir)
file_list = dir(dataDir); 

%% 그림파일 저장할 폴더 생성 : result_figures >> fitting_, half_, result_
mkdir('result_figures');
save_figure_folder = sprintf('result_figures\\result_%s',data_name);
status = mkdir(save_figure_folder);

%% Read Data
for k = 3:length(file_list)
    M3Dorg(:,:,k-2) = fliplr(double(dicomread(file_list(k).name)));
end
[nRowsOrg, nColsOrg, nDimsOrg] = size(M3Dorg); 

% Data_Reverse = 'y';
Data_Reverse = 'n';
%% Data Reverse
if strcmp(Data_Reverse,'y')
    M3Dorg_cp = M3Dorg;
    for k=1:nDimsOrg
        M3Dorg_cp(:,:,k) = M3Dorg(:,:,nDimsOrg-k+1);
    end
    M3Dorg = M3Dorg_cp;
end


%% frame range
initial_frame   = 95;
final_frame     = 202;

M3D = M3Dorg(:,:,initial_frame:final_frame);
[nRows, nCols, nDims] = size(M3D);

for k=1:nDims
   im(M3D(:,:,k),[]); drawnow; 
end

%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%      (1) Multi-phase segmentation
%%
%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sgm         = 20;
omg         = 1;
Index = 1:nRows*nCols*nDims;
[~, L3D_test] = MultiPhaseSegmentationNew(M3D, sgm, omg, Index);

Index = L3D_test(:)>1;
[L3D, sgm, omg] = multiphase_satisfaction(M3D, Index);

%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%          (2) Select Target Region
%%
%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
initial_frame   = 1;
final_frame     = nDims;
%%%%%% sample frame과 supraspinatus muscle을 최적으로 포함하는 label 선택 %%%%%%
[sample_frame, TL, u0tmp, u0tmp_label] = target_satisfaction(M3D,L3D);
ca;
%%%%%%%%%%%% Supraspinatus Muscle가 있는 위치를 semi-auto로 선택  %%%%%%%%%%%%
doSmoothing = 'yes';
u0 = Click_region( M3D(:,:,sample_frame), u0tmp_label, u0tmp, doSmoothing);
ca;

%% %%%%%%%%%%% metal 나타나는 범위 찾아내기 %%%%%%%%%%%%
for frame = 1:nDims
    M = M3D(:,:,frame);
    if sum(M(:)>4000)>0 
        metal_frame_str = frame;
        break;
    end
end

for frame = nDims:-1:1
    M = M3D(:,:,frame);
    if sum(M(:)>4000)>0 
        metal_frame_end = frame;
        break;
    end
end

Metal_3D = zeros(nRows, nCols, nDims);
if ~isempty(metal_frame_str)
    Mc3D = M3D;
    for frame = metal_frame_str:metal_frame_end
        M = M3D(:,:,frame);
        L = L3D(:,:,frame);

        Metal = double(M>4000);
        Metal=imerode(Metal,strel('disk',2));    
        Metal_3D(:,:,frame) = imdilate(Metal,strel('disk',2));
    end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

U3D_smoothing = zeros(nRows, nCols, nDims)-1;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                     (2.i)  Sample        
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
frame = sample_frame;
M = M3D(:,:,frame);
u = double(L3D(:,:,frame)>=TL);
L = imfill(u,'holes'); 
L0 = L;
L(round(nRows/2):end,:)=0;
u = ExtractSpecificLabel( L0, ExtractRegion_NmaxArea(L, 1) );
U3D_smoothing(:,:,frame-1) = SignedDistance(u);
figure('units','normalized','outerposition',[0 0 1 1]); 
im(M,[]); cn(U3D_smoothing(:,:,frame-1))

% [B,r1,r2,c1,c2] = BoundingBox( us,0 );
% Box_row(frame+1)=r2;
% Box_row(frame)=r2;

forward_alpha = 1;
Parameters = SegmParameters(forward_alpha);
ShapeRegion = zeros(nRows, nCols);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                     (2.i)  Forward   
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
h1 = msgbox('**** Forward Segmentation ****');
waitfor(h1);

u0const = 5;
BoxBooleanSize = 10;
TwoMoreComp=0;
EXTRACT = 0;
%%% backward %%%
Condile = 0;
cnt=0;
nPlot1=100;
nPlot2=1;
box_const = 5;
SHAPE = 0; 
for frame = sample_frame:nDims
    
    fprintf('*** frame: %d...\n', frame);    
        
    M   =  M3D(:,:,frame); 
    M   = Rescale(M, min(M(:)), max(M(:)), 0, 1);
    L   = L3D(:,:,frame);
    
%     M(L==1) = mean(M(L(:)==2));
    
    %◈◈◈◈◈ initialization ◈◈◈◈◈
    uprev   = U3D_smoothing(:,:,frame-1);     
    u0 = uprev-u0const;
    psi0 = u0;
    
    %▶▶▶▶▶▶▶▶▶▶▶▶ 분할 영역 크기 조절(원본 사이즈 너무 커서..)◀◀◀◀◀◀◀◀◀◀◀%
    [~,r1,r2,c1,c2] = BoundingBox( uprev,0 );
    u_cmp(r1-box_const:r2+box_const,c1-box_const:c2+box_const) = uprev(r1-box_const:r2+box_const,c1-box_const:c2+box_const);
    [nRows_cmp,nCols_cmp] = size(u_cmp);
    
    uprev_cp = ClopMatrix( uprev,r1-box_const,r2+box_const,c1-box_const,c2+box_const );
    u0_cp = ClopMatrix( u0,r1-box_const,r2+box_const,c1-box_const,c2+box_const );
    psi0_cp = ClopMatrix( psi0,r1-box_const,r2+box_const,c1-box_const,c2+box_const );
    M_cp = ClopMatrix( M,r1-box_const,r2+box_const,c1-box_const,c2+box_const );
    L_cp = ClopMatrix( L,r1-box_const,r2+box_const,c1-box_const,c2+box_const );
    ShapeRegion_cp = ClopMatrix( ShapeRegion,r1-box_const,r2+box_const,c1-box_const,c2+box_const );
    AlphaControlRegion = zeros(size(M_cp)); 
    
    %▶▶▶▶▶▶▶▶▶▶▶▶▶▶▶▶ segmentation ◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀%
    [ u_cp,uf_cp,us_cp, u1_cp ] = frame_loop( M_cp, psi0_cp, u0_cp, uprev_cp, Parameters, SHAPE, ShapeRegion_cp, AlphaControlRegion, nPlot1, nPlot2 );
         
    %▶▶▶▶▶▶▶▶▶▶▶▶ 원본 사이즈로 복원◀◀◀◀◀◀◀◀◀◀◀%
    u = ExpandMatrix( u_cp,r1-box_const,r2+box_const,c1-box_const,c2+box_const, nRows,nCols, min(u_cp(:)) );
    uf = ExpandMatrix( uf_cp,r1-box_const,r2+box_const,c1-box_const,c2+box_const, nRows,nCols, min(uf_cp(:)) );
    us = ExpandMatrix( us_cp,r1-box_const,r2+box_const,c1-box_const,c2+box_const, nRows,nCols, min(us_cp(:)) );
    us = SignedDistance(us);
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%          Manual Correction
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bg = figure('units','normalized','outerposition',[0 0 1 1]); 
    subplot(121); im(M,[]); title('원본 영상');
    subplot(122); im(M,[]); cn(us); title(['분할 (frame:', num2str(frame),')']);
    correction_way = my_interface;
    
    if strcmp(correction_way,'Finish') 
        FINAL_frame = frame-1;
        break;
    end
    
    while ~strcmp(correction_way,'No Correction')        
        if strcmp(correction_way,'Parameter_Ctrl')
            %◈◈◈◈◈ parameters 변경 ◈◈◈◈◈
            prompt = {'Use Shape Info.','Update size','Over:'};
            dlg_title = 'Parameters';
            num_lines=[1 50];
            def = {num2str(SHAPE), num2str(Parameters.lambda_l),num2str(Parameters.tau_Leak)};
            answer = inputdlg(prompt,dlg_title,num_lines,def);

            SHAPE = str2double(answer(1));
            Parameters.lambda_l =  str2double(answer(2));
            Parameters.tau_Leak =  str2double(answer(3));
            
            %▶▶▶▶▶▶▶▶▶▶▶▶▶▶▶▶ segmentation ◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀%
            [ u_cp,uf_cp,us_cp, u1_cp ] = frame_loop( M_cp, psi0_cp, u0_cp, uprev_cp, Parameters, SHAPE, ShapeRegion_cp, AlphaControlRegion, nPlot1, nPlot2 );
          
            subplot(121); im(M_cp,[]); title('원본 영상');
            subplot(122); im(M_cp,[]); cn(us_cp); title(['분할 (frame:', num2str(frame),')']);
           
    
            %▶▶▶▶▶▶▶▶▶▶▶▶ 원본 사이즈로 복원◀◀◀◀◀◀◀◀◀◀◀%
            us = ExpandMatrix( us_cp,r1-box_const,r2+box_const,c1-box_const,c2+box_const, nRows,nCols, min(us_cp(:)) );
            us = SignedDistance(us);    
        else
            if strcmp(correction_way,'Remove') 
                figure('units','normalized','outerposition',[0 0 1 1]); 
                subplot(121); im(M,[]); title('원본 영상');
                subplot(122); im(M,[]); cn(us); title(['분할 (frame:', num2str(frame),')']);
                correction = uicontrol(gcf,'Style','text',...
                  'String','*지울 영역을 선택!',...
                  'Position',[1160 150 120 50],...
                  'HandleVisibility','off');

                h=impoly(gca);
                position = wait(h);
                BW = double(createMask(h));
                us(BW>0) = -1;
            elseif strcmp(correction_way,'Fill')        
                figure('units','normalized','outerposition',[0 0 1 1]); 
                subplot(121); im(M,[]); title('원본 영상');
                subplot(122); im(M,[]); cn(us); title(['분할 (frame:', num2str(frame),')']);
                correction = uicontrol(gcf,'Style','text',...
                  'String','*채울 영역을 선택!',...
                  'Position',[1160 150 120 50],...
                  'HandleVisibility','off'); 

                h=impoly(gca);
                position = wait(h);
                BW = double(createMask(h));
                us(BW>0) = 1;     
            end
            us = SignedDistance(us);

            Kgaussian 	= fspecial('gaussian', [2*round(3)+1 2*round(3)+1], 3);
            us_correct = imfilter(us, Kgaussian);
            U3D_smoothing(:,:,frame) = us_correct;   

            %%%%%% satisfaction of trial segmentation %%%
            subplot(121); im(M,[]); title('원본 영상');
            subplot(122); im(M,[]); cn(us_correct); title(['수정 (frame:', num2str(frame),')']); 
        end
         correction_way = my_interface;
         ca;
    end
   U3D_smoothing(:,:,frame) = us;
   
   [B,r1,r2,c1,c2] = BoundingBox( us,0 );
    Box_row(frame)=r1;    
        
    %◈◈◈◈◈ plot ◈◈◈◈◈
    if sum(u(:)>0)~=0 
       im(M,[]); cn(U3D_smoothing(:,:,frame));  title(['현재 슬라이스의 최종 분할 (frame:', num2str(frame),')'],'color','red');
        saveas(gcf,sprintf('%s\\%s_supraspinatus_%03d.jpg',save_figure_folder,data_name,frame)) ;
        FINAL_frame = frame;
        ca;
    else
        FINAL_frame = frame-1;
       break; 
    end
    
end

ca;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%%                     (2.ii)  Backward   
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
h2 = msgbox('**** Backward Segmentation ****');
waitfor(h2);

backward_alpha = 0.5;
Parameters = SegmParameters(backward_alpha);

u0const = 5;
BoxBooleanSize = 10;
TwoMoreComp=0;
EXTRACT = 0;
%%% backward %%%
CONDYLE = 0;
TOOTH = 0;
cnt=0;
nPlot1=20;
nPlot2=10;
box_const = 20;
SHAPE = 0; 
SHIFT = 2;
arr_Height = zeros(1,nDims);
cnt=0;
for frame = sample_frame-1:-1:1
    
    fprintf('*** frame: %d...\n', frame);    
        
    M   =  M3D(:,:,frame); 
    M   = Rescale(M, min(M(:)), max(M(:)), 0, 1);    
    M0  = M; % modify 전의 영상
    L   = L3D(:,:,frame);    
    Metal = Metal_3D(:,:,frame); 
    uprev	= U3D_smoothing(:,:,frame+1);    
    
    if arr_Height(frame+1)+5<arr_Height(frame+2)
        sprintf('**** upper tooth...\n')
        im(M); cn(uprev);
        bnry_uprev = double(uprev);
        RemoveBox = zeros(nRows,nCols);
        RemoveBox(arr_Height(frame+1):arr_Height(frame+1)+20,:)=1;
        C = ExtractSpecificLabel( bnry_uprev, RemoveBox );
        uprev(C>0)=-100;
        
    end
    
%     uprev_cp = uprev;
% %     uprev_cp_pad = padarray(uprev_cp,[SHIFT 0],'replicate','post');
% %     uprev_moving = uprev_cp_pad(SHIFT+1:nRows+SHIFT,:);
%     uprev_cp_pad = padarray(uprev_cp,[SHIFT 0],'replicate','pre');
%     uprev_moving = uprev_cp_pad(1:nRows,:);
%     
%     uprev = uprev_moving;
    
    %◈◈◈◈◈ initialization ◈◈◈◈◈  
    if CONDYLE == 0
        u0      = uprev;%+u0const/2;
    else
        u0      = uprev;
    end
    psi0    = uprev;
    
    if CONDYLE ==1
    Lfill2 = imfill(double(L>=TL+1), 'hole');
%     im(M0); title('fig01 : original')
%     im(Lfill2); cn(uprev-2); title('fig02:target label & prev. contour');
    part1 = double(uprev>=0);
    part1 = imerode(part1,strel('disk',2));
    part2 = ExtractSpecificLabel( Lfill2, part1 );
    alive_part = Lfill2;
    alive_part(part2<=0) = 0;
    remove_part = Lfill2;
    part3 = ExtractSpecificLabel( Lfill2, alive_part==0 );
    part3 = imdilate(part3,strel('disk',2));
%     im(part3); title('fig03:remove part');
    M(part3>0)=mean(M0(L==TL-1));   
%      im(M); title('fig04:modified data');
    else
    %% 분할하기 용이하도록 M을 변형
    AboveTL = double(L>=TL);   AboveTL(AboveTL==0)=-1;        % target label 보다 큰 부분을 이진 영상화
%     AboveTL = imerode(AboveTL,strel('disk',5));
    extract_uprev   = imfill(ExtractSpecificLabel( AboveTL, uprev-3 ));   % 위의 이진 영상 중 이전 분할 결과와 교집합이 있는 부분만 추출
%     extract_uprev = imdilate(extract_uprev,strel('disk',5));
    M(extract_uprev~=1) = mean(M0(L==2));                    % 교집합 없는 라벨 부분을 죽임
    
    
    Metal_dilate = imdilate(Metal,strel('disk',3));
    M(Metal_dilate>0) = mean(M(L(:)==TL));
%     M(C>0) = mean(M(L(:)==2));
% M=imfill(M);
    M(L==1) = mean(M(L(:)==2));

% Me = imerode(M,strel('disk',3));
% bnry_Me = double(Me>mean(Me(:)));
%  extract_bnry_Me   = ExtractSpecificLabel( bnry_Me, uprev ); 
%  Me(extract_bnry_Me<=0)=-100;
%  M = imdilate(Me,strel('disk',3));
 M=imerode(imfill(imdilate(M,strel('disk',3))),strel('disk',3));
    end
    
    %% Condyle 포함하는 프레임 조건 : uprev의 중심 부분이 비어있고, 연결 성분의 갯수가 4이면 Condyle 존재
    bnry_uprev = double(uprev>0);  % binary uprev
    [~,r1,r2,~,~] = BoundingBox( bnry_uprev, 0 );  % uprev를 포함하는 박스의 위, 아래 인덱스
    center_r = round((r1+r2)/2);                  % 박스의 센터
    px_num_center_uprev = sum(sum(bnry_uprev(center_r-5:center_r+5,:))); % 센터로부터 5씩 떨어진 부분에서 uprev>0 있는지
    
    bwlabel_bnry_uprev = bwlabel(bnry_uprev);       % uprev의 연결 성분 계산
    maxlabel_bnry_uprev = max(bwlabel_bnry_uprev(:));     % 연결 성분의 갯수
    
    if sum(sum(uprev(:,1:round(nCols/2))>0))==0 || sum(sum(uprev(:,1:round(nCols/2))>0))==0
        cnt=cnt+1;
    end
    if cnt>3
        CONDYLE = 1
    end
    
%     if CONDYLE == 0 && px_num_center_uprev==0 && maxlabel_bnry_uprev<=3  %% uprev의 중심 부분이 비어있고, 연결 성분의 갯수가 4이면 Condyle 존재
%         CONDYLE = 1;
%     end
    
    %% Shape이 적용되는 조건 : uprev 중에 metal근처의 연결 영역/ condyle 포함 부분에서는 전체 영역
    if ~isempty(metal_frame_str) && metal_frame_str<= frame && frame<=metal_frame_end 
        SHAPE = 1;
        uprev_erode = imerode(uprev,strel('disk',5)); % uprev가 약하게 연결된 부분은 끊기 위해 erode 
        ShapeRegion_tmp = ExtractSpecificLabel( uprev_erode, Metal );   % metal 영역과 침식된 uprev와 교집합이 있는 라벨 추출 
        ShapeRegion = imdilate(ShapeRegion_tmp,strel('disk',20));  % 추출된 라벨 부분만 팽창
        ShapeRegion(ShapeRegion==0)=-1;
        [Box_Metal,~,~,~,~] = BoundingBox( Metal,0 );
        ShapeRegion = zeros(nRows, nCols)-1;
        tmp_Metal_dilate = imdilate(Box_Metal,strel('disk',30));
        ShapeRegion(tmp_Metal_dilate>0)=1;
    elseif CONDYLE == 1
        SHAPE = 1;
        ShapeRegion = ones(nRows, nCols);
    else
        SHAPE = 0;
        ShapeRegion = zeros(nRows, nCols)-1;
    end    
    
%     SHIFT =1;
%     u0_ext = padarray(u0,SHIFT,'pre');
%     u0_new = u0_ext(1:nRows,:);
%     
%     u0 = u0_new;
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% ▶▶▶▶▶▶▶▶▶▶▶▶ 영상 잘라서 작은 영상에 대해 분할 ◀◀◀◀◀◀◀◀◀◀◀%
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    baseMatrix = u0;
	sMatrix.M = M;
 	sMatrix.ShapeRegion = ShapeRegion;
 	sMatrix.Metal = Metal;
  	sMatrix.u0 = u0;
 	sMatrix.uprev = uprev;
 	sMatrix.psi0 = psi0;
    sConstant.box_const = box_const;
 	sConstant.nRows = nRows;
	sConstant.nCols = nCols;
    sConstant.SHAPE = SHAPE;
    sConstant.nPlot1 = nPlot1;
    sConstant.nPlot2 = nPlot2;
    sConstant.CONDYLE = CONDYLE;
    [u_trial, u_final] = crop_image_segmetation( baseMatrix, sMatrix, sConstant, Parameters );
        
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%          Manual Correction
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure('units','normalized','outerposition',[0 0 1 1]); 
    subplot(121); im(M0,[]); title('원본 영상');
    subplot(122); im(M0,[]); cn(u_final); title(['분할 (frame:', num2str(frame),')']);
    correction_way = my_interface;
    
    if strcmp(correction_way,'Finish') 
        INIT_frame = frame+1;
        break;
    end
    
    while ~strcmp(correction_way,'No Correction')        
        if strcmp(correction_way,'Parameter_Ctrl')
            %◈◈◈◈◈ parameters 변경 ◈◈◈◈◈
            prompt = {'Use Shape Info.','Under'};
            dlg_title = 'Parameters';
            num_lines=[1 50];
            def = {num2str(SHAPE), num2str(Parameters.tau_Less)};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
 
            %▶▶▶▶▶▶▶▶▶▶▶▶▶▶▶▶ Segmentation ◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀%
            sConstant.SHAPE = SHAPE;
            Parameters.tau_Less =  str2double(answer(2));
            [u_trial, u_final] = crop_image_segmetation( baseMatrix, sMatrix, sConstant, Parameters );
            %%%% Plot
            figure('units','normalized','outerposition',[0 0 1 1]); 
            subplot(121); im(M0,[]); title('원본 영상');
            subplot(122); im(M0,[]); cn(u_final); title(['분할 (frame:', num2str(frame),')']);
                
        else
            if strcmp(correction_way,'Remove') 
            
              figure('units','normalized','outerposition',[0 0 1 1]);  
                subplot(121); im(M0,[]); title('원본 영상');
                subplot(122); im(M0,[]); cn(u_final); title(['분할 (frame:', num2str(frame),')']);
                correction = uicontrol(gcf,'Style','text',...
                  'String','*지울 영역을 선택!',...
                  'Position',[1160 150 120 50],...
                  'HandleVisibility','off');

                h=impoly(gca);
                position = wait(h);
                BW = double(createMask(h));
                u_final(BW>0) = -1;
            elseif strcmp(correction_way,'Fill')       
                figure('units','normalized','outerposition',[0 0 1 1]);  
                subplot(121); im(M0,[]); title('원본 영상');
                subplot(122); im(M0,[]); cn(u_final); title(['분할 (frame:', num2str(frame),')']);
                correction = uicontrol(gcf,'Style','text',...
                  'String','*채울 영역을 선택!',...
                  'Position',[1160 150 120 50],...
                  'HandleVisibility','off'); 

                h=impoly(gca);
                position = wait(h);
                BW = double(createMask(h));
                u_final(BW>0) = 1;     
            end
            u_final = SignedDistance(u_final);

            Kgaussian 	= fspecial('gaussian', [2*round(3)+1 2*round(3)+1], 3);
            us_correct = imfilter(u_final, Kgaussian);
            u_final = us_correct;

            %%%%%% satisfaction of trial segmentation %%%
            figure('units','normalized','outerposition',[0 0 1 1]); 
            subplot(121); im(M0,[]); title('원본 영상');
            subplot(122); im(M0,[]); cn(u_final); title(['수정 (frame:', num2str(frame),')']);         
            
        end
         correction_way = my_interface;
        
    end
     U3D_smoothing(:,:,frame) = u_final;
     
     [~,Height,~,~,~] = BoundingBox(u_trial,0);
     arr_Height(frame) = Height;
   
    %◈◈◈◈◈ plot ◈◈◈◈◈
    if sum(u_final(:)>0)~=0 
        figure('units','normalized','outerposition',[0 0 1 1]); 
        im(M0,[]); cn(U3D_smoothing(:,:,frame));  title(['현재 슬라이스의 최종 분할 (frame:', num2str(frame),')'],'color','blue');
        saveas(gcf,sprintf('%s\\%s_supraspinatus_%03d.jpg',save_figure_folder,data_name,frame)) ;
        ca;
        INIT_frame = frame;
    else
        INIT_frame = frame+1;
       break; 
    end
    
%     im(M); cn(u_final); title('fig05 : segm+modified');
%      im(M0); cn(u_final); title('fig06 : segm+org');
    
end




MandibleBnry = zeros(nRows, nCols,nDims)-1;
for frame =1:nDims
    M = u3D(:,:,frame);
    M(M>=0)=1;
    M(M<0)=-1;
    MandibleBnry(:,:,frame)=M;
    im(M,[]); title(['frame:',num2str(frame)]); drawnow;
end


for frame=1:nDims
    Morg = M3D(:,:,frame);
    Mauto = MandibleBnry(:,:,frame);
%     Mmanual = Mmanual3D(:,:,frame);
    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(121); im(Morg,[]); title(['Original (frame : ',num2str(frame),')']);
    subplot(122); im(Morg,[]); cn(Mauto); title(['Auto (frame : ',num2str(frame),')']);
%     subplot(133); im(Morg,[]); cn(Mmanual,'b'); title(['Manual (frame : ',num2str(frame),')']);
    hold off;
    saveas( gcf,sprintf('%s\\mandible_%03d.jpg',save_figure_folder,frame) ); 
    ca;
end


surf2OBJ(MandibleBnry,0,'mimics_mandible');

fv = Isosurface( MandibleBnry, 0 );
saveas( gcf,sprintf('%s\\surface_mandible_auto.jpg',save_figure_folder) ); 
saveas( gcf,sprintf('%s\\surface_mandible_auto.fig',save_figure_folder) ); 

% surf2OBJ(Mmanual3D,0,'mimics_mandible_manual');
% 
% fv = Isosurface( Mmanual3D, 0 );
% saveas( gcf,sprintf('%s\\surface_mandible_manaul.jpg',save_figure_folder) ); 
% saveas( gcf,sprintf('%s\\surface_mandible_manaul.fig',save_figure_folder) ); 


save('4_facial.mat');


%% ###############################################################
%% Save into .dcm
%% ###############################################################
now_dir = cd;
data_directory = sprintf('%s/dcm_data',now_dir);
file_list = dir(data_directory);

ref_file_name = file_list(3).name;
ref_info = dicominfo(ref_file_name);
tmpA = dicomread(ref_file_name);
MandibleBnry_cpy = MandibleBnry;
MandibleBnry_cpy(MandibleBnry>0)=255;
MandibleBnry_cpy_int = uint16(MandibleBnry_cpy);
M3D_int = uint16(M3D);
for k = 3:length(file_list)
    dcm_file_name = sprintf('4_facial_%03d.dcm',k-2);
    dcm_file_name_org = sprintf('4_facial_org_%03d.dcm',k-2);
    ref_file_name = file_list(k).name
    ref_info = dicominfo(ref_file_name);
    A = MandibleBnry_cpy_int(:,:,k-2);
    B = M3D_int(:,:,k-2);
    dicomwrite(A,dcm_file_name,ref_info);
    dicomwrite(B,dcm_file_name_org,ref_info);
end