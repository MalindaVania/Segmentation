function [ Intv_str,Intv_end ] = AGMC_New( h,sgm,omg,bin0,M3D )
%AGMC Summary of this function goes here

confirm_ind=[]; del_ind=[]; live_ind=[]; Intv_str=[]; Intv_end=[];
out_Max_iter=10;
h0=h;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for out_iter=1:out_Max_iter
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    if out_iter==1
        str_in_iter=0;
        h_ind=1:256;
    else
        str_in_iter=0;
    end
    in_Max_iter=10;             

    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for in_iter=str_in_iter:in_Max_iter 
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pre_h_ind=h_ind;
        if in_iter==1
            plot_ind=pre_h_ind;
        end
        %% k-means clustering         
        [mu,mask]=ftn_kmeans(h,2,h_ind);        
        ind1=find(mask==1);  [~,tmp_ind1 ]=max(h(ind1)); Max1=ind1(tmp_ind1);
        ind2=find(mask==2);  [~,tmp_ind2 ]=max(h(ind2)); Max2=ind2(tmp_ind2);    
        if ind1(tmp_ind1)>ind2(tmp_ind2)
            Max1=ind2(tmp_ind2);
            Max2=ind1(tmp_ind1);
        end      
%         figure,plot(bin0(ind1),h0(ind1),'r*-'); 
%         hold on, plot(bin0(ind2),h0(ind2),'b*-'); hold off
% %         axis([0 1 0 max(h0)])%
%         axis([min(M3D(:)) max(M3D(:)) 0 max(h0)])
%         pause;

        %% --------------- RULE 1 :: 더 큰 cluster K 찾기 ----------%   
        %% max값이 더 큰 쪽 Cluster 번호 찾기
%         max(h(ind1))
%         max(h(ind2))
        if max(h(ind1))>max(h(ind2))
            Cluster=1; Mu=mu(1); Max=Max1;
        else
            Cluster=2; Mu=mu(2); Max=Max2;
        end

        %% Cluster 번호에 해당하는 histogram 값들은 살리고, 아닌데는 histogram 값 죽이기
           if Cluster==1
               h_ind=ind1; h(ind2)=0;                   
           else
               h_ind=ind2; h(ind1)=0;
           end  
           
           % index에 jump 있는 경우        
        if Cluster==1
            dind1= ind1(2:end)-ind1(1:end-1);
         	if sum(dind1~=1)~=0
                Nb=1; tmp_area=[];
                for q=1:length(ind1)-1
                    tmp_area(q)=Nb;
                    if dind1(q)~=1
                        Nb=Nb+1;
                    end
                end
                tmp_area(length(ind1))=Nb;
                for p=1:Nb
                    if sum(ind1(tmp_area==p)==Max1)~=0
                        h_ind=ind1(tmp_area==p);  
                    else
                        h(ind1(tmp_area==p))=0;  
                    end
                end
            else
                h_ind=ind1;            
            end
            h(ind2)=0;                                
        else
            dind2= ind2(2:end)-ind2(1:end-1);
           if sum(dind2~=1)~=0
                Nb=1; tmp_area=[];
                for q=1:length(ind2)-1
                    tmp_area(q)=Nb;
                    if dind2(q)~=1
                        Nb=Nb+1;
                    end
                end
                tmp_area(length(ind2))=Nb;
                for p=1:Nb
                    if sum(ind2(tmp_area==p)==Max2)~=0  %% 수정 ind1->ind2
                        h_ind=ind2(tmp_area==p);
                    else
                        h(ind2(tmp_area==p))=0;  
                    end
                end
            else
                h_ind=ind2;            
            end
            h(ind1)=0;  
       end  

        %% ------------------ RULE 2 :: 두 max가 아주 가까우면 STOP ----------%
        %% ---------------------- in_iter STOP Criterion --------------------%
%         pre_h_ind=h_ind;
%         abs(Max-Mu)
%         if abs(Max-Mu)<sgm
% Max1
% Max2
        if abs(Max1-Max2)<sgm
            del_ind=[];
            if isempty(live_ind)
                i_ind=1:256;
            else
                i_ind=sort(live_ind,'ascend');
            end
            for i=i_ind(1):i_ind(length(i_ind))                 
                if sum(i==pre_h_ind)==0                         
                    h(i)=h0(i);
                elseif sum(i==pre_h_ind)~=0 
                    del_ind=[del_ind i];
                    h(i)=0;
                end
            end   
            confirm_ind=[del_ind confirm_ind];
           break;
        end
    end
    %% ======================= the end of Inner Iteration =========================%

    uu=[plot_ind del_ind]; uu=sort(uu);
    plot_ind=[];

    %% ---------- RULE 3 :: 남은 hogram이 original에 비해 엄청 작으면 STOP ----------%
    %% --------------------------- out_iter STOP Criterion -------------------------%
    h_ind=[];
    for i=1:256
        if sum(i==confirm_ind)==0
            h_ind=[h_ind i];
        end
    end

    live_ind=h_ind;

    if isempty(live_ind) || max(h(live_ind)) < omg*mean(h0) %|| sum(h) < eps             
        Intv_str(out_iter)=pre_h_ind(1);
        Intv_end(out_iter)=pre_h_ind(length(pre_h_ind));
        break;
    end
    Intv_str(out_iter)=del_ind(1);
    Intv_end(out_iter)=del_ind(length(del_ind));

    if isempty(live_ind)
        break;
    end      
end

Intv_str=sort(Intv_str,'ascend');
Intv_end=sort(Intv_end,'ascend');
N=length(Intv_str);
K=N;


