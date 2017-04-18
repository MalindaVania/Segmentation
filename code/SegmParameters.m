function Parameters = SegmParameters(alpha)

%----- fixed parameters -----%
nIter	= 100;      
dt      = 0.5;          
EPS     = 2.0;     
sgmphi	= 1.5;   
sgml	= 15;      
mu      = 5;
%--------------------------%

u0const     = 3;
nu          = 5;
lambda_l	= 300;
tau_Less    = 0.1;

Parameters = ParaSet('Parameters',nIter, dt, EPS, sgmphi, alpha, ...
                                    sgml, mu, lambda_l, nu,...
                                    tau_Less, u0const);

