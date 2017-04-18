function [u_trial, u_final] = crop_image_segmetation( baseMatrix, sMatrix, sConstant, Parameters )
%UNTITLED7 이 함수의 요약 설명 위치
%   자세한 설명 위치

M           = sMatrix.M;
ShapeRegion = sMatrix.ShapeRegion;
Metal       = sMatrix.Metal;
u0          = sMatrix.u0;
uprev     	= sMatrix.uprev;
psi0      	= sMatrix.psi0;

box_const   = sConstant.box_const;
nRows       = sConstant.nRows;
nCols       = sConstant.nCols;
SHAPE       = sConstant.SHAPE;
nPlot1       = sConstant.nPlot1;
nPlot2       = sConstant.nPlot2;
CONDYLE     = sConstant.CONDYLE;

%▶▶▶▶▶▶▶▶▶▶▶▶ 분할 영역 크기 조절(원본 사이즈 너무 커서..)◀◀◀◀◀◀◀◀◀◀◀%
[~,r1,r2,c1,c2] = BoundingBox( baseMatrix,0 );

uprev_cp        = CropExpandMatrix( uprev, r1,r2,c1,c2,box_const,'crop',nRows,nCols );
u0_cp           = CropExpandMatrix( u0, r1,r2,c1,c2,box_const,'crop',nRows,nCols );
psi0_cp         = CropExpandMatrix( psi0, r1,r2,c1,c2,box_const,'crop',nRows,nCols );
M_cp            = CropExpandMatrix( M, r1,r2,c1,c2,box_const,'crop',nRows,nCols );
ShapeRegion_cp  = CropExpandMatrix( ShapeRegion, r1,r2,c1,c2,box_const,'crop',nRows,nCols );
Metal_cp        = CropExpandMatrix( Metal, r1,r2,c1,c2,box_const,'crop',nRows,nCols );

AlphaControlRegion = imdilate(Metal_cp,strel('disk',10));      

%▶▶▶▶▶▶▶▶▶▶▶▶▶▶▶▶ segmentation ◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀◀%
[ u_trial_cp, u_final_cp ] = frame_loop_new( M_cp, psi0_cp, u0_cp, uprev_cp, Parameters, SHAPE, CONDYLE, ShapeRegion_cp, AlphaControlRegion, nPlot1, nPlot2 );


%▶▶▶▶▶▶▶▶▶▶▶▶ 원본 사이즈로 복원◀◀◀◀◀◀◀◀◀◀◀%
u_trial = CropExpandMatrix( u_trial_cp, r1,r2,c1,c2,box_const,'expand',nRows,nCols );
u_final = CropExpandMatrix( u_final_cp, r1,r2,c1,c2,box_const,'expand',nRows,nCols );

end

