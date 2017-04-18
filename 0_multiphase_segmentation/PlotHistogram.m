function PlotHistogram(Intv_str,Intv_end,bin0,h0)

N=length(Intv_str);

figure; plot(bin0,h0,'k-','LineWidth',1.5)   
for k=1:N-1
    Color = choose_color(k);
    hold on; plot(bin0(Intv_str(k):Intv_end(k)+1),h0(Intv_str(k):Intv_end(k)+1),Color,'LineWidth',4);   
end
Color = choose_color(N);
hold on;plot(bin0(Intv_str(N)-1:Intv_end(N)),h0(Intv_str(N)-1:Intv_end(N)),Color,'LineWidth',4);
title(['# of clusters : ', num2str(N)]);
drawnow;


function Color = choose_color(k)

if mod(k,5)==1
   Color = 'r-';
elseif mod(k,5)==2
   Color = 'b-'; 
elseif mod(k,5)==3
   Color = 'g-'; 
elseif mod(k,5)==4
   Color = 'c-'; 
elseif mod(k,5)==0
   Color = 'm-'; 
end