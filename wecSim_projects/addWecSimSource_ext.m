clear;clc;
addSource = 1;
switch getenv('COMPUTERNAME')
    case {"VERMILLIONLAB13", "BRYANTLABLAPTOP", "VERMLABLAPTOP6"}
        % wecSimFolder = 'D:\WEC-Sim-6.1.2';
        wecSimFolder = 'C:\Users\cmmcguir\OneDrive - North Carolina State University\iSSRL\Research\WEC-Sim-6.1.2-SourceOnly';
        noodle_PTO_folder = "C:\Users\cmmcguir\OneDrive - North Carolina State University\iSSRL\Research\variable-stiffness-WEC\Source";
    case "DESKTOP-8E6TRFQ"
        % wecSimFolder = 'Z:\NCSU_Desktop\WEC-Sim-6.1.2';
        wecSimFolder = 'C:\Users\Carson\OneDrive - North Carolina State University\iSSRL\Research\WEC-Sim-6.1.2-SourceOnly';
        noodle_PTO_folder = "C:\Users\Carson\OneDrive - North Carolina State University\iSSRL\Research\variable-stiffness-WEC\Source";
    case {"MAE-DT-001"}
        % wecSimFolder = 'C:\Users\cmmcguir\Documents\WEC-Sim-6.1.2';
        wecSimFolder = 'C:\Users\cmmcguir\OneDrive - North Carolina State University\iSSRL\Research\WEC-Sim-6.1.2-SourceOnly';
        noodle_PTO_folder = "C:\Users\cmmcguir\OneDrive - North Carolina State University\iSSRL\Research\variable-stiffness-WEC\Source";
    case {"DESKTOP-U8OU8C5"}
        wecSimFolder = 'C:\Users\server\OneDrive - North Carolina State University\iSSRL\Research\WEC-Sim-6.1.2-SourceOnly';
        noodle_PTO_folder = "C:\Users\server\OneDrive - North Carolina State University\iSSRL\Research\variable-stiffness-WEC\Source";
    case "" % empty
        if ismac % check if using macbook
            % wecSimFolder = '/Users/carrmcg/Documents/WEC-Sim-6.1.2';
            wecSimFolder = '/Users/carrmcg/Library/CloudStorage/OneDrive-NorthCarolinaStateUniversity/iSSRL/Research/WEC-Sim-6.1.2-SourceOnly';
            noodle_PTO_folder = '/Users/carrmcg/Library/CloudStorage/OneDrive-NorthCarolinaStateUniversity/iSSRL/Research/variable-stiffness-WEC/Source';
        end
    otherwise
        % add other computers here
        disp('!!! No WEC-Sim repo folder specified !!!')
        addSource = 0;
end

if exist('wecSimFolder', 'var')
    returnDir = pwd;
    cd(wecSimFolder);
    addWecSimSource;
    cd(returnDir);
    addpath(genpath(noodle_PTO_folder))
else
    disp('!!! No source folders added to path !!!')
end