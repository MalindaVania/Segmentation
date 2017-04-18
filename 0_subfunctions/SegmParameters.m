function [ SampleParameters, ForwardParameters, BackwardParameters, BackwardBoneParameters ] = SegmParameters( data_nb )

sample_u0const  = 30;
forward_u0const = 5;
backward_u0const = 5;

sample_nu   = 0;
forward_nu  = 5;
backward_nu = 5;

sample_r    = 200;
forward_r   = 100;
backward_r  = 200;

sample_lambda_l     = 50;
forward_lambda_l    = 50;
backward_lambda_l   = 30;

sample_tau      = 100;
forward_tau     = 50;
backward_tau    = 50;

sample_tau_Leak     = 0;
forward_tau_Leak    = 10000;
backward_tau_Leak   = 10000;

sample_tau_Less     = 0;
forward_tau_Less    = 150;
backward_tau_Less   = 500;

bone_tau_Less = 500;% 03
bone_nu = 8;
bone_tau = 0;

C = 2;

% SampleParameters    = GenerateParameter(sample_lambda_l, sample_nu, sample_r, ...
%                                         sample_tau, sample_tau_Leak, sample_tau_Less, sample_u0const, C); 
% ForwardParameters   = GenerateParameter(forward_lambda_l, forward_nu, forward_r, ...
%                                         forward_tau, forward_tau_Leak, forward_tau_Less, forward_u0const, C);
% BackwardParameters  = GenerateParameter(backward_lambda_l, backward_nu, backward_r, ...
%                                         backward_tau, backward_tau_Leak, backward_tau_Less, backward_u0const, C);  
% BackwardBoneParameters = GenerateParameter(bone_tau, bone_tau_Less, bone_nu, bone_FINAL_frame);

switch data_nb    
    case 02    
        forward_r   = 150;
        SampleParameters    = GenerateParameter(sample_lambda_l, sample_nu, sample_r, ...
                                                sample_tau, sample_tau_Leak, sample_tau_Less, sample_u0const, C); 
        ForwardParameters   = GenerateParameter(forward_lambda_l, forward_nu, forward_r, ...
                                                forward_tau, forward_tau_Leak, forward_tau_Less, forward_u0const, C);
        BackwardParameters  = GenerateParameter(backward_lambda_l, backward_nu, backward_r, ...
                                                backward_tau, backward_tau_Leak, backward_tau_Less, backward_u0const, C); 
        bone_FINAL_frame = 83;
        BackwardBoneParameters = ParaSet('BackwardBoneParameters', bone_tau, bone_tau_Less, bone_nu, bone_FINAL_frame);         
        
	case 03
        SampleParameters    = GenerateParameter(sample_lambda_l, sample_nu, sample_r, ...
                                                sample_tau, sample_tau_Leak, sample_tau_Less, sample_u0const, C); 
        ForwardParameters   = GenerateParameter(forward_lambda_l, forward_nu, forward_r, ...
                                                forward_tau, forward_tau_Leak, forward_tau_Less, forward_u0const, C);
        BackwardParameters  = GenerateParameter(backward_lambda_l, backward_nu, backward_r, ...
                                                backward_tau, backward_tau_Leak, backward_tau_Less, backward_u0const, C);  
        bone_FINAL_frame = 77;
        BackwardBoneParameters = ParaSet('BackwardBoneParameters', bone_tau, bone_tau_Less, bone_nu, bone_FINAL_frame);
        
	case 07 
        SampleParameters    = GenerateParameter(sample_lambda_l, sample_nu, sample_r, ...
                                                sample_tau, sample_tau_Leak, sample_tau_Less, sample_u0const, C); 
        ForwardParameters   = GenerateParameter(forward_lambda_l, forward_nu, forward_r, ...
                                                forward_tau, forward_tau_Leak, forward_tau_Less, forward_u0const, C);
        BackwardParameters  = GenerateParameter(backward_lambda_l, backward_nu, backward_r, ...
                                                backward_tau, backward_tau_Leak, backward_tau_Less, backward_u0const, C);  
        bone_FINAL_frame = 79;
        BackwardBoneParameters = ParaSet('BackwardBoneParameters', bone_tau, bone_tau_Less, bone_nu, bone_FINAL_frame); 
        
    case 10    
        forward_r   = 150;
        SampleParameters    = GenerateParameter(sample_lambda_l, sample_nu, sample_r, ...
                                                sample_tau, sample_tau_Leak, sample_tau_Less, sample_u0const, C); 
        ForwardParameters   = GenerateParameter(forward_lambda_l, forward_nu, forward_r, ...
                                                forward_tau, forward_tau_Leak, forward_tau_Less, forward_u0const, C);
        BackwardParameters  = GenerateParameter(backward_lambda_l, backward_nu, backward_r, ...
                                                backward_tau, backward_tau_Leak, backward_tau_Less, backward_u0const, C);  
        bone_FINAL_frame = 59;
        BackwardBoneParameters = ParaSet('BackwardBoneParameters', bone_tau, bone_tau_Less, bone_nu, bone_FINAL_frame);
        
 	case 13
        SampleParameters    = GenerateParameter(sample_lambda_l, sample_nu, sample_r, ...
                                                sample_tau, sample_tau_Leak, sample_tau_Less, sample_u0const, C); 
        ForwardParameters   = GenerateParameter(forward_lambda_l, forward_nu, forward_r, ...
                                                forward_tau, forward_tau_Leak, forward_tau_Less, forward_u0const, C);
        BackwardParameters  = GenerateParameter(backward_lambda_l, backward_nu, backward_r, ...
                                                backward_tau, backward_tau_Leak, backward_tau_Less, backward_u0const, C); 
        bone_FINAL_frame = 79;
        BackwardBoneParameters = ParaSet('BackwardBoneParameters', bone_tau, bone_tau_Less, bone_nu, bone_FINAL_frame);                                         
        
  	case 14
        SampleParameters    = GenerateParameter(sample_lambda_l, sample_nu, sample_r, ...
                                                sample_tau, sample_tau_Leak, sample_tau_Less, sample_u0const, C); 
        ForwardParameters   = GenerateParameter(forward_lambda_l, forward_nu, forward_r, ...
                                                forward_tau, forward_tau_Leak, forward_tau_Less, forward_u0const, C);
        BackwardParameters  = GenerateParameter(backward_lambda_l, backward_nu, backward_r, ...
                                                backward_tau, backward_tau_Leak, backward_tau_Less, backward_u0const, C);  
        bone_FINAL_frame = 84;
        BackwardBoneParameters = ParaSet('BackwardBoneParameters', bone_tau, bone_tau_Less, bone_nu, bone_FINAL_frame);
        
    otherwise
        warning('¢Â¢Â There is no the given parameters... ¢Â¢Â')
end

% bone_FINAL_frame = bone_FINAL_frame-2;
  

function Parameters = GenerateParameter(lambda_l, nu, r, tau, tau_Leak, tau_Less, u0const, C)

%----- fixed parameters -----%
nIter	= 30;      
dt      = 0.5;          
EPS     = 2.0;     
sgmphi	= 1.5;  
alpha	= 1.0;      
Option	= 'average';    
sgml	= 10;      
mu      = 5;


Parameters = ParaSet('Parameters', nIter, dt, EPS, sgmphi, alpha, Option, sgml, ...
                                        lambda_l, mu, nu, r, tau, tau_Leak, tau_Less, u0const, C);                                    

