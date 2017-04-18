function parameters = choose_MotionMeanCurv_parameters(folder_name, parameters_name, New, parameters)

if New == 0
    load(sprintf('%s_%s.mat',folder_name,parameters_name),'parameters')
    return;
else
    %% *************************** Parameters *************************** %%
    prompt = {'iterSmooth : ','sgm0 : ','dt0 : ','sgm1 : ', 'dt1 : '};
    dlg_title = 'MotionMeanCurv Parameters';
    num_lines = 1;
    nargin
    if nargin == 3
        def = {    '10',        '1.5',  	'0.2',	'5', '2'};
        parameters = str2double(inputdlg(prompt,dlg_title,num_lines,def));     
    else
        def = { num2str(parameters.iterSmooth), num2str(parameters.sgm0), num2str(parameters.dt0),...
                    num2str(parameters.sgm1), num2str(parameters.dt1)};
        parameters = str2double(inputdlg(prompt,dlg_title,num_lines,def)); 
    end

    iterSmooth   = parameters(1);    
    sgm0	= parameters(2);  	dt0   = parameters(3);     
    sgm1   	= parameters(4);    dt1  = parameters(5);   
    parameters = ParaSet('parameters', iterSmooth, sgm0, dt0, sgm1, dt1);  

    save(sprintf('%s_%s.mat',folder_name,parameters_name),'parameters'); 
end

end

