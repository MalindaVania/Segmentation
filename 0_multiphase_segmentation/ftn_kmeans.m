function [mu,mask]=ftn_kmeans(h,k,h_ind)

% figure; plot(h,'*-')
% ind=find(h>0);
ind=h_ind;
hl=length(ind);
[~,maxIdx] = max(h);
% mu = [ind(1) maxIdx+length(ind)/3];
% mu = median(ind)*(1:k)/(k)
mu = [ ind(1) ind(length(ind))]; %

% mu = [ median(ind) ind(length(ind))];

max_iter = 3;
iter = 0;

%% start process
while(true) && iter<max_iter
    iter = iter+1;
    oldmu=mu;
  
    % current classification   
    for i=1:hl
      c=abs(ind(i)-mu);
      cc=find(c==min(c));
      hc(ind(i))=cc(1);
%         if h(i) ~= 0 
%             c=abs(i-mu);
%             cc=find(c==min(c));
%             hc(i)=cc(1);
%         else
%             hc(i) = 0;
%         end
    end
    
    %recalculation of means    
    for i=1:k 
        a=find(hc==i);
        if sum(h(a))==0
            mu(i) = mean(a);
        else            
            mu(i)=sum(a.*h(a))/sum(h(a)+eps);
        end
    end
    mask = hc;
    if(mu==oldmu) mask = hc; break;end;
  
end
