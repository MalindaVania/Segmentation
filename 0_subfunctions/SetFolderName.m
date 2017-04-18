function [out_str, leng_deserted_name] = SetFolderName( in_str, in_sc, nb_sc )
% 2015.03.17

%% 읽어들인 스트링(in_str)에서 nb_sc갯수 만큼의 in_sc기호를 체크해서 뒷부분만 이름(out_str)으로 선택
%% input
%       in_str : input string
%       in_sc : special character (ex: \,%,...)
%       nb_sc : the number of special character 
%% output
%       out_str : nb_sc개의 in_sc 다음 문자부터 끝까지가 
%       leng_deserted_name : 버려진 문자의 갯수
%% Ex 
%  	in_str = 'D:asdbd\kldsjf\lnjido3847\kldjf'
% 	in_sc = 'W'
%  	nb_sc = 2
%       =>  out_str = 'lnjido3847\kldjf'
%           leng_deserted_name = 'D:asdbd\kldsjf\'

leng_str = length(in_str);
encounterC = 0;
for k=leng_str:-1:1
    if strcmp(in_str(k),in_sc)
        encounterC = encounterC+1;
    end
    if encounterC == nb_sc
        break;
    end
end

out_str             = in_str(k+1:leng_str);
leng_deserted_name  = k;
end

