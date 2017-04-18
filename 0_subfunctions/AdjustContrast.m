function M3D = AdjustContrast( M3Dorg,initial_frame,final_frame,min_ints,max_ints )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

M3D = zeros(size(M3Dorg));    
for k=initial_frame:final_frame
    f=M3Dorg(:,:,k);
    f(f<=min_ints)=min_ints;
    f(f>=max_ints)=max_ints;   
    M3D(:,:,k)=f;
%     subplot(121), imshow(M3Dorg(:,:,k),[]);  title(sprintf('resized [%d,%d]',min(M3Dorg(:)),max(M3Dorg(:))));
%     subplot(122), imshow(M3D(:,:,k),[]); title(sprintf('resized [%d,%d]',min(M3D(:)),max(M3D(:))));
%     title(sprintf('k = %d [%d,%d]',k, min_ints, max_ints)); 
%     drawnow;
% %     pause(.5);
% %     saveas(gcf,sprintf('adjust_contrast_%d_%d_%d.jpg',k,min_ints,max_ints))     
end

end

