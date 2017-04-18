function out_str = RenameFileDigit( in_str, nb_digit, in_sc)
% 2015.03.17

%% 읽어들인 스트링(in_str)에서 in_sc기호 다음부터 숫자로 인식. 
%%  그 숫자들의 자릿수를 nb_digit으로 맞춰줌
%% input
%       in_str : input filename
%       nb_digit : the number of digit 
%       in_sc : special character (ex: \,%,...)
%% output
%       out_str : changed filename

%% Ex 
%  	in_str = 'world_23.jpg'
%   nb_digit = 3
% 	in_sc = '_'
%       => out_str = 'world_023.jpg'

[str0, leng_deserted_name] = SetFolderName( in_str, in_sc, 2 );
str1 = str2double(str0(1:end-4));
file_format = str0(end-2:end);

switch nb_digit
    case 1  % 0,1,...
        out_str = sprintf('%s%01d.%s',in_str(1:leng_deserted_name),str1,file_format);
    case 2  % 00,01,...
        out_str = sprintf('%s%02d.%s',in_str(1:leng_deserted_name),str1,file_format);
    case 3  % 000,001,...
        out_str = sprintf('%s%03d.%s',in_str(1:leng_deserted_name),str1,file_format);
    case 4  % 0000,0001,...
        out_str = sprintf('%s%04d.%s',in_str(1:leng_deserted_name),str1,file_format);
    case 5  % 00000,00001,...
        out_str = sprintf('%s%05d.%s',in_str(1:leng_deserted_name),str1,file_format);
    case 6  % 000000,000001,...
        out_str = sprintf('%s%06d.%s',in_str(1:leng_deserted_name),str1,file_format);
    otherwise
        warning('※※ 6 digit at most !!');
end
str2 = sprintf('%s.tif',str1);

end

