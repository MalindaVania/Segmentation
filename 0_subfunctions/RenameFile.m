function new_folder_directory= RenameFile( )
% 2015.07.30
% 파일 이름이 axial00, axial01,...,axial99, axial 101,...인 경우
% axial000, axial001, axial002,...로 재정렬 하는 함수

% 데이터 있는 폴더 찾기
[file_name,data_path] = uigetfile('*');
files = dir(data_path);
% 폴더 안의 바꿀 파일의 "파일포맷과 파일이름"
[~,ref_file_name,ref_file_format] = fileparts(file_name);
fprintf('reference file name : %s \n',ref_file_name);
% 공통으로 남길 이름 입력받기
common_words = input('☞☞ Input common words(작은따옴표안에) : ');
length_common_words = length(common_words);

% 이름 바꿀 파일 저장될 폴더 생성
new_foler_name = 'renamed';
new_folder_directory = sprintf('%s\\%s',data_path,new_foler_name);
mkdir(new_folder_directory);

% 이름 바꿔 저장하기
for id = 3:length(files)
    [~, f,f_format] = fileparts(files(id).name);
    if strcmp(f_format,ref_file_format)==1
        d = length(f)-length_common_words;
        file = sprintf('%s%s',data_path,files(id).name);
        copyfile(file, sprintf('%s\\%s%03d%s', new_folder_directory,common_words,str2double(f(end-d+1:end)),ref_file_format));  
    end
end

end

