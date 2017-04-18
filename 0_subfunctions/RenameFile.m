function new_folder_directory= RenameFile( )
% 2015.07.30
% ���� �̸��� axial00, axial01,...,axial99, axial 101,...�� ���
% axial000, axial001, axial002,...�� ������ �ϴ� �Լ�

% ������ �ִ� ���� ã��
[file_name,data_path] = uigetfile('*');
files = dir(data_path);
% ���� ���� �ٲ� ������ "�������˰� �����̸�"
[~,ref_file_name,ref_file_format] = fileparts(file_name);
fprintf('reference file name : %s \n',ref_file_name);
% �������� ���� �̸� �Է¹ޱ�
common_words = input('�Ѣ� Input common words(��������ǥ�ȿ�) : ');
length_common_words = length(common_words);

% �̸� �ٲ� ���� ����� ���� ����
new_foler_name = 'renamed';
new_folder_directory = sprintf('%s\\%s',data_path,new_foler_name);
mkdir(new_folder_directory);

% �̸� �ٲ� �����ϱ�
for id = 3:length(files)
    [~, f,f_format] = fileparts(files(id).name);
    if strcmp(f_format,ref_file_format)==1
        d = length(f)-length_common_words;
        file = sprintf('%s%s',data_path,files(id).name);
        copyfile(file, sprintf('%s\\%s%03d%s', new_folder_directory,common_words,str2double(f(end-d+1:end)),ref_file_format));  
    end
end

end

