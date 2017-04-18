function [ u_trial, u_final] = frame_loop_new( M, psi0, u0, uprev, Parameters, SHAPE, CONDYLE, ShapeRegion, AlphaControlRegion, nPlot1, nPlot2 )

sgmphi0     = Parameters.sgmphi;
Kgaussian 	= fspecial('gaussian', [2*round(sgmphi0)+1 2*round(sgmphi0)+1], sgmphi0);

%% trial segmentation
[ u1,psi1 ] = trial_segmentation(  M, psi0, u0, uprev, Parameters, AlphaControlRegion, nPlot1 );

if SHAPE == 0  
    u1 = SignedDistance(u1);    
    u_trial = imfilter(u1, Kgaussian);
    u_final = u1;%u_trial;
   return; 
end

%% Over/Under segmented region
OverUnderSegm = over_under_segmentation( u1,psi1 );
OverUnderSegm(ShapeRegion<=0) = -1;
if CONDYLE == 1    
    R = double(u0>-3);
else
    R = double(imfill(u1,'holes')>=0 | psi1>=0| u0>0);
end

%% correct segmentation
[ u2,~ ] = correct_segmentation( M, psi0, u0, Parameters, AlphaControlRegion, R, OverUnderSegm, nPlot2 );

%%%%%% hole filling %%%%%%
u2f = imfill(u2,'holes');
u2f = SignedDistance(u2f);    
%%%%%% smoothing %%%%%%
u_trial = u1;
u_final = imfilter(u2f, Kgaussian);

% im(M); cn(u_final);pause;

end


