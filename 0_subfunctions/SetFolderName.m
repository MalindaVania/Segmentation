function [out_str, leng_deserted_name] = SetFolderName( in_str, in_sc, nb_sc )
% 2015.03.17

%% �о���� ��Ʈ��(in_str)���� nb_sc���� ��ŭ�� in_sc��ȣ�� üũ�ؼ� �޺κи� �̸�(out_str)���� ����
%% input
%       in_str : input string
%       in_sc : special character (ex: \,%,...)
%       nb_sc : the number of special character 
%% output
%       out_str : nb_sc���� in_sc ���� ���ں��� �������� 
%       leng_deserted_name : ������ ������ ����
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

