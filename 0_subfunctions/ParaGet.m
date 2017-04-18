function varargout = ParaGet(Str)
% ParaSet Get variables from the given structure.
% Usage : [Lambda,Mu,Alpha,Potential,DeltaEps,Eps,Hsize,Sigma,EdgeMu,Dt,MaxIterOut,MaxIterIn] = ParaGet(ParaEdgeFunc)

fname = fieldnames(Str);
for i=1:length(fname)
    varargout{i} = Str.(fname{i});
end