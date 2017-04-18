function Name = ParaSet(varargin)
% ParaSet Create Structure.
% Usage: ParaEdgeFunc = ParaSet('ParaEdgeFunc',Lambda,Mu,Alpha,Potential,DeltaEps,Eps,Hsize,Sigma,EdgeMu,Dt,MaxIterOut,MaxIterIn);


Name = inputname(1);
for i = 2:nargin
    Name.(inputname(i)) = varargin{i};
end
