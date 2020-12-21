%% IMPORT OG OPRETTELSE AF REGN
opts = delimitedTextImportOptions("NumVariables", 3);
% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
% Specify column names and types
opts.VariableNames = ["Dates", "Intensity", "IntSum"];
opts.VariableTypes = ["datetime", "double", "double"];
opts = setvaropts(opts, 1, "InputFormat", "yyyy-MM-dd HH:mm:ss");
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
series7543 = readtable("series7543.csv", opts);
regndata = table2array(series7543(:,3));
tid = table2array(series7543(:,1));
clear opts

% Setup for udregning af nedboersmaengder
regndata = [datenum(tid) regndata];
tid_opdelt = datevec(regndata(:,1));
tid_maaneder = [tid_opdelt(:,1:4) regndata(:,2)];
tid_maaneder = tid_maaneder(41:end,:);

for i=1:length(tid_maaneder)
    if tid_maaneder(i,4) == 0
        tid_maaneder(i,4) = 24;
    end
end

no_months = 20*12;
regn_matrix = zeros(no_months,31*24);

for year = 2100:2119
    for month = 1:12
        for day = 1:31
            for hour = 1:24
                for i = 1:length(tid_maaneder)
                    if tid_maaneder(i,1) == year
                        if tid_maaneder(i,2) == month
                            if tid_maaneder(i,3) == day
                                if tid_maaneder(i,4) == hour
                                    regn_matrix(12*(year-2100)+month,(24*(day-1)+hour)) = regn_matrix(12*(year-2100)+month,(24*(day-1)+hour))...
                                        +  tid_maaneder(i,5);
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

%% Korrektion af nedboerdata og oprettelse af regnserie

regn_korr = [1.196.*ones(31*24,1); 1.251.*ones(31*24,1); 1.243.*ones(31*24,1); 1.085.*ones(31*24,1); ...
    1.065.*ones(31*24,1); 1.053.*ones(31*24,1); 1.048.*ones(31*24,1); 1.048.*ones(31*24,1); 1.062.*ones(31*24,1); ...
    1.073.*ones(31*24,1); 1.089.*ones(31*24,1); 1.186.*ones(31*24,1)];

regn_korr = [0; repmat(regn_korr,20,1)];


regn = 0;
for i =1:no_months
    regn = [regn regn_matrix(i,:)];
end

regn = regn';

regn = regn.*regn_korr;

%% OPRETTELSE OG IMPORT AF POTENTIEL FORDAMPNING
opts = spreadsheetImportOptions("NumVariables", 31);
% Specify sheet and range
opts.Sheet = "Ark1";
opts.DataRange = "F21:AJ380";
% Specify column names and types
opts.VariableNames = ["VarName6", "VarName7", "VarName8", "VarName9", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15", "VarName16", "VarName17", "VarName18", "VarName19", "VarName20", "VarName21", "VarName22", "VarName23", "VarName24", "VarName25", "VarName26", "VarName27", "VarName28", "VarName29", "VarName30", "VarName31", "VarName32", "VarName33", "VarName34", "VarName35", "VarName36"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% Import the data
KorrigeretEpot = readtable("Korrigeret_E_pot.xlsx", opts, "UseExcel", false);
% Clear temporary variables
clear opts
KorrigeretEpot = table2array(KorrigeretEpot(1:240,:));

Epot_matrix = (1/24).*[repmat(KorrigeretEpot(:,1),1,24) repmat(KorrigeretEpot(:,2),1,24) repmat(KorrigeretEpot(:,3),1,24) repmat(KorrigeretEpot(:,4),1,24) repmat(KorrigeretEpot(:,5),1,24)...
    repmat(KorrigeretEpot(:,6),1,24) repmat(KorrigeretEpot(:,7),1,24) repmat(KorrigeretEpot(:,8),1,24) repmat(KorrigeretEpot(:,9),1,24) repmat(KorrigeretEpot(:,10),1,24) ... 
    repmat(KorrigeretEpot(:,11),1,24) repmat(KorrigeretEpot(:,12),1,24) repmat(KorrigeretEpot(:,13),1,24) repmat(KorrigeretEpot(:,14),1,24) repmat(KorrigeretEpot(:,15),1,24) ... 
    repmat(KorrigeretEpot(:,16),1,24) repmat(KorrigeretEpot(:,17),1,24) repmat(KorrigeretEpot(:,18),1,24) repmat(KorrigeretEpot(:,19),1,24) repmat(KorrigeretEpot(:,20),1,24) ... 
    repmat(KorrigeretEpot(:,21),1,24) repmat(KorrigeretEpot(:,22),1,24) repmat(KorrigeretEpot(:,23),1,24) repmat(KorrigeretEpot(:,24),1,24) repmat(KorrigeretEpot(:,25),1,24) ... 
    repmat(KorrigeretEpot(:,26),1,24) repmat(KorrigeretEpot(:,27),1,24) repmat(KorrigeretEpot(:,28),1,24) repmat(KorrigeretEpot(:,29),1,24) repmat(KorrigeretEpot(:,30),1,24) ... 
    repmat(KorrigeretEpot(:,31),1,24)];

E_pot = 0;
for i =1:20*12
    E_pot = [E_pot Epot_matrix(i,:)];
end

E_pot = E_pot';

for i = 2:length(E_pot)
    if E_pot(i) == 0
        E_pot(i) = E_pot(i-1);
    end
end

%% IMPORT AND INTERCEPTION FOR BEECH
clc
opts = spreadsheetImportOptions("NumVariables", 31);
% Specify sheet and range
opts.Sheet = "Beech";
opts.DataRange = "A1:AE12";
% Specify column names and types
opts.VariableNames = ["VarName1", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15", "VarName16", "VarName17", "VarName18", "VarName19", "VarName20", "VarName21", "VarName22", "VarName23", "VarName24", "VarName25", "VarName26", "VarName27", "VarName28", "VarName29", "VarName30", "VarName31"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
% Import the data
max_Beech = readtable("LAI.xlsx", opts, "UseExcel", false);
clear opts

% Matrix
max_itc_B = table2array(max_Beech(:,:));
% Interception Beech

% Days to hours
max_itc_hr_B = [repmat(max_itc_B(:,1),1,24) repmat(max_itc_B(:,2),1,24) repmat(max_itc_B(:,3),1,24) repmat(max_itc_B(:,4),1,24) repmat(max_itc_B(:,5),1,24) ...
    repmat(max_itc_B(:,6),1,24) repmat(max_itc_B(:,7),1,24) repmat(max_itc_B(:,8),1,24) repmat(max_itc_B(:,9),1,24) repmat(max_itc_B(:,10),1,24) ...
    repmat(max_itc_B(:,11),1,24) repmat(max_itc_B(:,12),1,24) repmat(max_itc_B(:,13),1,24) repmat(max_itc_B(:,14),1,24) repmat(max_itc_B(:,15),1,24) ...
    repmat(max_itc_B(:,16),1,24) repmat(max_itc_B(:,17),1,24) repmat(max_itc_B(:,18),1,24) repmat(max_itc_B(:,19),1,24) repmat(max_itc_B(:,20),1,24) ...
    repmat(max_itc_B(:,21),1,24) repmat(max_itc_B(:,22),1,24) repmat(max_itc_B(:,23),1,24) repmat(max_itc_B(:,24),1,24) repmat(max_itc_B(:,25),1,24) ... 
    repmat(max_itc_B(:,26),1,24) repmat(max_itc_B(:,27),1,24) repmat(max_itc_B(:,28),1,24) repmat(max_itc_B(:,29),1,24) repmat(max_itc_B(:,30),1,24) repmat(max_itc_B(:,31),1,24)];

%Max interception for 20 years
itc_matrix_B = repmat(max_itc_hr_B,20,1);

% Backwards extrapolation
for i=1:length(itc_matrix_B)
    for j=1:744
        if i<13
            itc_matrix_B(i,j) = (0/19).*itc_matrix_B(i,j);
        elseif i<25
            itc_matrix_B(i,j) = (1/19).*itc_matrix_B(i,j);
        elseif i<37
            itc_matrix_B(i,j) = (2/19).*itc_matrix_B(i,j);
        elseif i<49
            itc_matrix_B(i,j) = (3/19).*itc_matrix_B(i,j);
        elseif i<61
            itc_matrix_B(i,j) = (4/19).*itc_matrix_B(i,j);
        elseif i<73
            itc_matrix_B(i,j) = (5/19).*itc_matrix_B(i,j);
        elseif i<85
            itc_matrix_B(i,j) = (6/19).*itc_matrix_B(i,j);
        elseif i<97
            itc_matrix_B(i,j) = (7/19).*itc_matrix_B(i,j);
        elseif i<109
            itc_matrix_B(i,j) = (8/19).*itc_matrix_B(i,j);
        elseif i<121
            itc_matrix_B(i,j) = (9/19).*itc_matrix_B(i,j);
        elseif i<133
            itc_matrix_B(i,j) = (10/19).*itc_matrix_B(i,j);
        elseif i<145
            itc_matrix_B(i,j) = (11/19).*itc_matrix_B(i,j);
        elseif i<157
            itc_matrix_B(i,j) = (12/19).*itc_matrix_B(i,j);
        elseif i<169
            itc_matrix_B(i,j) = (13/19).*itc_matrix_B(i,j);
        elseif i<181
            itc_matrix_B(i,j) = (14/19).*itc_matrix_B(i,j);
        elseif i<193
            itc_matrix_B(i,j) = (15/19).*itc_matrix_B(i,j);
        elseif i<205
            itc_matrix_B(i,j) = (16/19).*itc_matrix_B(i,j);
        elseif i<217
            itc_matrix_B(i,j) = (17/19).*itc_matrix_B(i,j);
        elseif i<229
            itc_matrix_B(i,j) = (18/19).*itc_matrix_B(i,j);
        elseif i<241
            itc_matrix_B(i,j) = (19/19).*itc_matrix_B(i,j);
        end
    end
end

% Matrix til kollone
itc_B = [];

itc_B = 0;
for i =1:240
    itc_B = [itc_B itc_matrix_B(i,:)];
end

itc_B = itc_B';

% INTERCEPTION MODEL
itc_box_B = zeros(length(itc_B),1);

for i=2:length(itc_box_B)
    if regn(i)>=itc_B(i)
        itc_box_B(i)=itc_B(i)-E_pot(i);
        if E_pot(i)>itc_B(i)
            itc_box_B(i)=0;
        end
    end
    if regn(i)<itc_B(i) && itc_B(i)>E_pot(i)
        itc_box_B(i)= itc_box_B(i-1)+regn(i)-E_pot(i);
        if itc_box_B(i)<0
            itc_box_B(i)=0;
        end
        if  itc_box_B(i-1)+regn(i)>itc_B(i)
            itc_box_B(i)=itc_B(i)-E_pot(i);
        end
    elseif regn(i)<itc_B(i) && itc_B(i)<=E_pot(i)
        itc_box_B(i)=0;
    end
end

% Throughfall
TF_B = zeros(length(regn),1);

for i=2:length(regn)
    if regn(i)+itc_box_B(i-1)>itc_B(i)
        TF_B(i)=regn(i)+itc_box_B(i-1)-itc_B(i);
        if regn(i)+itc_box_B(i-1)<itc_B(i)
            TF_B(i)=0;
        end
    end
end

% NY E_pot
E_pot_B = zeros(length(E_pot),1);

for i=2:length(E_pot)
    if regn(i)+itc_box_B(i-1)>itc_B(i)
        E_pot_B(i)=E_pot(i)-itc_B(i);
        if E_pot(i) < itc_B(i)
            E_pot_B(i) = 0;
        end
    elseif regn(i)+itc_box_B(i-1)<=itc_B(i)
        E_pot_B(i)=E_pot(i)-regn(i)-itc_box_B(i-1);
        if E_pot(i)-regn(i)-itc_box_B(i-1)<0
            E_pot_B(i)=0;
        end
    end
end

%% IMPORT AND INTERCEPTION FOR SPRUCE
opts = spreadsheetImportOptions("NumVariables", 31);

% Specify sheet and range
opts.Sheet = "Spruce";
opts.DataRange = "A1:AE12";

% Specify column names and types
opts.VariableNames = ["VarName1", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15", "VarName16", "VarName17", "VarName18", "VarName19", "VarName20", "VarName21", "VarName22", "VarName23", "VarName24", "VarName25", "VarName26", "VarName27", "VarName28", "VarName29", "VarName30", "VarName31"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Import the data
max_Spruce = readtable("LAI.xlsx", opts, "UseExcel", false);
clear opts

% Matrix
max_itc_S = table2array(max_Spruce(:,:));
% Interception Spruce

% Days to hours
max_itc_hr_S = [repmat(max_itc_S(:,1),1,24) repmat(max_itc_S(:,2),1,24) repmat(max_itc_S(:,3),1,24) repmat(max_itc_S(:,4),1,24) repmat(max_itc_S(:,5),1,24) repmat(max_itc_S(:,6),1,24) repmat(max_itc_S(:,7),1,24) repmat(max_itc_S(:,8),1,24) repmat(max_itc_S(:,9),1,24) repmat(max_itc_S(:,10),1,24) repmat(max_itc_S(:,11),1,24) repmat(max_itc_S(:,12),1,24) repmat(max_itc_S(:,13),1,24) repmat(max_itc_S(:,14),1,24) repmat(max_itc_S(:,15),1,24) repmat(max_itc_S(:,16),1,24) repmat(max_itc_S(:,17),1,24) repmat(max_itc_S(:,18),1,24) repmat(max_itc_S(:,19),1,24) repmat(max_itc_S(:,20),1,24) repmat(max_itc_S(:,21),1,24) repmat(max_itc_S(:,22),1,24) repmat(max_itc_S(:,23),1,24) repmat(max_itc_S(:,24),1,24) repmat(max_itc_S(:,25),1,24) repmat(max_itc_S(:,26),1,24) repmat(max_itc_S(:,27),1,24) repmat(max_itc_S(:,28),1,24) repmat(max_itc_S(:,29),1,24) repmat(max_itc_S(:,30),1,24) repmat(max_itc_S(:,31),1,24)];

% Max interception for 20 years
itc_matrix_S = repmat(max_itc_hr_S,20,1);

% Backwards extrapolation
for i=1:length(itc_matrix_S)
    for j=1:744
        if i<13
            itc_matrix_S(i,j) = (0/19).*itc_matrix_S(i,j);
        elseif i<25
            itc_matrix_S(i,j) = (1/19).*itc_matrix_S(i,j);
        elseif i<37
            itc_matrix_S(i,j) = (2/19).*itc_matrix_S(i,j);
        elseif i<49
            itc_matrix_S(i,j) = (3/19).*itc_matrix_S(i,j);
        elseif i<61
            itc_matrix_S(i,j) = (4/19).*itc_matrix_S(i,j);
        elseif i<73
            itc_matrix_S(i,j) = (5/19).*itc_matrix_S(i,j);
        elseif i<85
            itc_matrix_S(i,j) = (6/19).*itc_matrix_S(i,j);
        elseif i<97
            itc_matrix_S(i,j) = (7/19).*itc_matrix_S(i,j);
        elseif i<109
            itc_matrix_S(i,j) = (8/19).*itc_matrix_S(i,j);
        elseif i<121
            itc_matrix_S(i,j) = (9/19).*itc_matrix_S(i,j);
        elseif i<133
            itc_matrix_S(i,j) = (10/19).*itc_matrix_S(i,j);
        elseif i<145
            itc_matrix_S(i,j) = (11/19).*itc_matrix_S(i,j);
        elseif i<157
            itc_matrix_S(i,j) = (12/19).*itc_matrix_S(i,j);
        elseif i<169
            itc_matrix_S(i,j) = (13/19).*itc_matrix_S(i,j);
        elseif i<181
            itc_matrix_S(i,j) = (14/19).*itc_matrix_S(i,j);
        elseif i<193
            itc_matrix_S(i,j) = (15/19).*itc_matrix_S(i,j);
        elseif i<205
            itc_matrix_S(i,j) = (16/19).*itc_matrix_S(i,j);
        elseif i<217
            itc_matrix_S(i,j) = (17/19).*itc_matrix_S(i,j);
        elseif i<229
            itc_matrix_S(i,j) = (18/19).*itc_matrix_S(i,j);
        elseif i<241
            itc_matrix_S(i,j) = (19/19).*itc_matrix_S(i,j);
        end
    end
end

% Matrix til kollone
itc_S = [];

itc_S = 0;
for i =1:240
    itc_S = [itc_S itc_matrix_S(i,:)];
end

itc_S = itc_S';

% INTERCEPTION MODEL
itc_box_S = zeros(length(itc_S),1);

for i=2:length(itc_box_S)
    if regn(i)>=itc_S(i)
        itc_box_S(i)=itc_S(i)-E_pot(i);
        if E_pot(i)>itc_S(i)
            itc_box_S(i)=0;
        end
    end
    if regn(i)<itc_S(i) && itc_S(i)>E_pot(i)
        itc_box_S(i)= itc_box_S(i-1)+regn(i)-E_pot(i);
        if itc_box_S(i)<0
            itc_box_S(i)=0;
        end
        if  itc_box_S(i-1)+regn(i)>itc_S(i)
            itc_box_S(i)=itc_S(i)-E_pot(i);
        end
    elseif regn(i)<itc_S(i) && itc_S(i)<=E_pot(i)
        itc_box_S(i)=0;
    end
end

% Throughfall
TF_S = zeros(length(regn),1);

for i=2:length(regn)
    if regn(i)+itc_box_S(i-1)>itc_S(i)
        TF_S(i)=regn(i)+itc_box_S(i-1)-itc_S(i);
        if regn(i)+itc_box_S(i-1)<itc_S(i)
            TF_S(i)=0;
        end
    end
end

% NY E_pot
E_pot_S = zeros(length(E_pot),1);

for i=2:length(E_pot)
    if regn(i)+itc_box_S(i-1)>itc_S(i)
        E_pot_S(i)=E_pot(i)-itc_S(i);
        if E_pot(i) < itc_S(i)
            E_pot_S(i) = 0;
        end
    elseif regn(i)+itc_box_S(i-1)<=itc_S(i)
        E_pot_S(i)=E_pot(i)-regn(i)-itc_box_S(i-1);
        if E_pot(i)-regn(i)-itc_box_S(i-1)<0
            E_pot_S(i)=0;
        end
    end
end

%% PARAMETERS - ROOT DEPTH

% Making field capacity and wilting point dependent on the root depth, ie.
% the depth of the toplayer
rootdepth_max = 1.2; % [m]
rootdepth = 0:10:120;
rootdepth = rootdepth'; 
field_capacity1m = 134.4; 
wilting_point1m = 44.9; 
field_capacity = zeros(length(rootdepth),1);
wilting_point = zeros(length(rootdepth),1);

for i = 1:length(rootdepth)
    field_capacity(i) = (rootdepth(i)./10).*(field_capacity1m/10);
    wilting_point(i) = (rootdepth(i)./10).*(wilting_point1m/10);
end

Vdeficit_max = field_capacity - wilting_point;

%% DECIDUOUS VANDDEFICIT

Vdeficit_max_time_deci = zeros(length(regn),1);


deci_max = 0.49; % [m/yr]
deci_time = deci_max/(365.25*24); % [m/h] 

% deci
rootdepth_deci_time = 0:deci_time:rootdepth_max;
rootdepth_deci_time = rootdepth_deci_time';
rootdepth_deci_max = ones(length(regn)-length(rootdepth_deci_time),1);
rootdepth_deci_max1 = rootdepth_deci_max.*rootdepth_max;
rootdepth_deci_total = [rootdepth_deci_time ; rootdepth_deci_max1];

% matrice med vanddeficitet til hver time, som aendrer sig i takt med at
% roddybden bliver storre
for i = 1:length(Vdeficit_max_time_deci)
    if 0 <= rootdepth_deci_total(i) && rootdepth_deci_total(i) < 0.10
        Vdeficit_max_time_deci(i) = Vdeficit_max(2);
    elseif 0.10 <= rootdepth_deci_total(i) && rootdepth_deci_total(i) < 0.20
        Vdeficit_max_time_deci(i) = Vdeficit_max(3);
    elseif 0.20 <= rootdepth_deci_total(i) && rootdepth_deci_total(i) < 0.30
        Vdeficit_max_time_deci(i) = Vdeficit_max(4);
    elseif 0.30 <= rootdepth_deci_total(i) && rootdepth_deci_total(i) < 0.40
        Vdeficit_max_time_deci(i) = Vdeficit_max(5);
    elseif 0.40 <= rootdepth_deci_total(i) && rootdepth_deci_total(i) < 0.50
        Vdeficit_max_time_deci(i) = Vdeficit_max(6);
    elseif 0.50 <= rootdepth_deci_total(i) && rootdepth_deci_total(i) < 0.60
        Vdeficit_max_time_deci(i) = Vdeficit_max(7);
    elseif 0.60 <= rootdepth_deci_total(i) && rootdepth_deci_total(i) < 0.70
        Vdeficit_max_time_deci(i) = Vdeficit_max(8);
    elseif 0.70 <= rootdepth_deci_total(i) && rootdepth_deci_total(i) < 0.80
        Vdeficit_max_time_deci(i) = Vdeficit_max(9);
    elseif 0.80 <= rootdepth_deci_total(i) && rootdepth_deci_total(i) < 0.90
        Vdeficit_max_time_deci(i) = Vdeficit_max(10);
    elseif 0.90 <= rootdepth_deci_total(i) && rootdepth_deci_total(i) < 1.00
        Vdeficit_max_time_deci(i) = Vdeficit_max(11);
    elseif 1.00 <= rootdepth_deci_total(i) && rootdepth_deci_total(i) < 1.10
        Vdeficit_max_time_deci(i) = Vdeficit_max(12);
    elseif 1.10 <= rootdepth_deci_total(i) && rootdepth_deci_total(i) < 1.20
        Vdeficit_max_time_deci(i) = Vdeficit_max(13);
    elseif 1.20 == rootdepth_deci_total(i)
        Vdeficit_max_time_deci(i) = Vdeficit_max(13);
    end
end

E_a_deci = zeros(length(regn),1);
V_deci = [V_start_condition; zeros(length(regn)-1,1)];
K_deci = [K_start_condition; zeros(length(regn)-1,1)];

I_deci = zeros(length(regn),1);

for i = 2:length(TF_B)
    I_deci(i) = TF_B(i);
    
    if V_deci(i-1) < 0.5*Vdeficit_max_time_deci(i) && I_deci(i) >= E_pot_B(i)
        E_a_deci(i) = E_pot_B(i); % Her er ingen vanddeficit fordi vi er over field capacity og der er intet (stort) vanddeficit i forvejen
        if V_deci(i-1) < (I_deci(i) - E_a_deci(i))
            V_deci(i) = 0;                           
        elseif V_deci(i-1) > (I_deci(i) - E_a_deci(i))
            V_deci(i) = V_deci(i-1) - (I_deci(i) - E_a_deci(i));
        end
        
    elseif V_deci(i-1) < 0.5*Vdeficit_max_time_deci(i) && I_deci(i) <= E_pot_B(i)
        E_a_deci(i) = E_pot_B(i);                          
        V_deci(i) = V_deci(i-1) + abs(I_deci(i) - E_a_deci(i));
        
    elseif  V_deci(i-1) >= 0.5*Vdeficit_max_time_deci(i) && I_deci(i) <= E_pot_B(i)
        E_a_deci(i) =-(I_deci(i) - E_pot_B(i)).*2.*(1-V_deci(i-1)./Vdeficit_max_time_deci(i)) + I_deci(i);
        V_deci(i) = V_deci(i-1) + abs(I_deci(i) - E_a_deci(i));
        
    elseif  V_deci(i-1) >= 0.5*Vdeficit_max_time_deci(i) && I_deci(i) >= E_pot_B(i)
        E_a_deci(i) = E_pot_B(i);
        V_deci(i) = V_deci(i-1) - (I_deci(i) - E_a_deci(i)); %obs hvis I-E_p > V(i-1) sï¿½ negative V(i)
    end
    if V_deci(i) > Vdeficit_max_time_deci(i)
        V_deci(i) = Vdeficit_max_time_deci(i); 
    end
end

for i = 2:length(regn)
    if V_deci(i) > 0
        K_deci(i) = 0;
    elseif (I_deci(i) - E_a_deci(i)) > 0 && V_deci(i-1) == 0
        K_deci(i) = (I_deci(i) - E_a_deci(i));
    elseif (I_deci(i) - E_a_deci(i)) > 0 && V_deci(i-1) > 0
        K_deci(i) = (I_deci(i) - E_a_deci(i)) - V_deci(i-1);
    elseif V_deci(i-1) > (I_deci(i) - E_a_deci(i))        
        K_deci(i)=0;
    end
end

%% CONIFEROUS VANDDEFICIT

Vdeficit_max_time_coni = zeros(length(regn),1);


coni_max = 0.58; % [m/yr]
coni_time = coni_max/(365.25*24); % [m/h] 

% coni
rootdepth_coni_time = 0:coni_time:rootdepth_max;
rootdepth_coni_time = rootdepth_coni_time';
rootdepth_coni_max = ones(length(regn)-length(rootdepth_coni_time),1);
rootdepth_coni_max1 = rootdepth_coni_max.*rootdepth_max;
rootdepth_coni_total = [rootdepth_coni_time ; rootdepth_coni_max1];

% matrice med vanddeficitet til hver time, som aendrer sig i takt med at
% roddybden bliver storre
for i = 1:length(Vdeficit_max_time_coni)
    if 0 <= rootdepth_coni_total(i) && rootdepth_coni_total(i) < 0.10
        Vdeficit_max_time_coni(i) = Vdeficit_max(2);
    elseif 0.10 <= rootdepth_coni_total(i) && rootdepth_coni_total(i) < 0.20
        Vdeficit_max_time_coni(i) = Vdeficit_max(3);
    elseif 0.20 <= rootdepth_coni_total(i) && rootdepth_coni_total(i) < 0.30
        Vdeficit_max_time_coni(i) = Vdeficit_max(4);
    elseif 0.30 <= rootdepth_coni_total(i) && rootdepth_coni_total(i) < 0.40
        Vdeficit_max_time_coni(i) = Vdeficit_max(5);
    elseif 0.40 <= rootdepth_coni_total(i) && rootdepth_coni_total(i) < 0.50
        Vdeficit_max_time_coni(i) = Vdeficit_max(6);
    elseif 0.50 <= rootdepth_coni_total(i) && rootdepth_coni_total(i) < 0.60
        Vdeficit_max_time_coni(i) = Vdeficit_max(7);
    elseif 0.60 <= rootdepth_coni_total(i) && rootdepth_coni_total(i) < 0.70
        Vdeficit_max_time_coni(i) = Vdeficit_max(8);
    elseif 0.70 <= rootdepth_coni_total(i) && rootdepth_coni_total(i) < 0.80
        Vdeficit_max_time_coni(i) = Vdeficit_max(9);
    elseif 0.80 <= rootdepth_coni_total(i) && rootdepth_coni_total(i) < 0.90
        Vdeficit_max_time_coni(i) = Vdeficit_max(10);
    elseif 0.90 <= rootdepth_coni_total(i) && rootdepth_coni_total(i) < 1.00
        Vdeficit_max_time_coni(i) = Vdeficit_max(11);
    elseif 1.00 <= rootdepth_coni_total(i) && rootdepth_coni_total(i) < 1.10
        Vdeficit_max_time_coni(i) = Vdeficit_max(12);
    elseif 1.10 <= rootdepth_coni_total(i) && rootdepth_coni_total(i) < 1.20
        Vdeficit_max_time_coni(i) = Vdeficit_max(13);
    elseif 1.20 == rootdepth_coni_total(i)
        Vdeficit_max_time_coni(i) = Vdeficit_max(13);
    end
end

E_a_coni = zeros(length(regn),1);
V_coni = [V_start_condition; zeros(length(regn)-1,1)];
K_coni = [K_start_condition; zeros(length(regn)-1,1)];

I_coni = zeros(length(regn),1);

for i = 2:length(TF_S)
    I_coni(i) = TF_S(i); 
    
    if V_coni(i-1) < 0.5*Vdeficit_max_time_coni(i) && I_coni(i) >= E_pot_S(i)
        E_a_coni(i) = E_pot_S(i); % Her er ingen vanddeficit fordi vi er over field capacity og der er intet (stort) vanddeficit i forvejen
        if V_coni(i-1) < (I_coni(i) - E_a_coni(i))
            V_coni(i) = 0;
        elseif V_coni(i-1) > (I_coni(i) - E_a_coni(i))
            V_coni(i) = V_coni(i-1) - (I_coni(i) - E_a_coni(i));
        end
        
    elseif V_coni(i-1) < 0.5*Vdeficit_max_time_coni(i) && I_coni(i) <= E_pot_S(i)
        E_a_coni(i) = E_pot_S(i);
        V_coni(i) = V_coni(i-1) + abs(I_coni(i) - E_a_coni(i));
        
    elseif  V_coni(i-1) >= 0.5*Vdeficit_max_time_coni(i) && I_coni(i) <= E_pot_S(i)
        E_a_coni(i) =-(I_coni(i) - E_pot_S(i)).*2.*(1-V_coni(i-1)./Vdeficit_max_time_coni(i)) + I_coni(i);
        V_coni(i) = V_coni(i-1) + abs(I_coni(i) - E_a_coni(i));
        
    elseif  V_coni(i-1) >= 0.5*Vdeficit_max_time_coni(i) && I_coni(i) >= E_pot_S(i)
        E_a_coni(i) = E_pot_S(i);
        V_coni(i) = V_coni(i-1) - (I_coni(i) - E_a_coni(i)); %obs hvis I-E_p > V(i-1) sï¿½ negative V(i)
    end
    if V_coni(i) > Vdeficit_max_time_coni(i)
        V_coni(i) = Vdeficit_max_time_coni(i); 
    end
end

for i = 2:length(regn)
    if V_coni(i) > 0
        K_coni(i) = 0;
    elseif (I_coni(i) - E_a_coni(i)) > 0 && V_coni(i-1) == 0
        K_coni(i) = (I_coni(i) - E_a_coni(i));
    elseif (I_coni(i) - E_a_coni(i)) > 0 && V_coni(i-1) > 0
        K_coni(i) = (I_coni(i) - E_a_coni(i)) - V_coni(i-1);
    elseif V_coni(i-1) > (I_coni(i) - E_a_coni(i))
        K_coni(i)=0;
    end
end

%% LIMESTONE MODELLING DECIDUOS

kalk_fc = 418.3/10;
kalk_total_porosity = 475.5/10;
kalk_sat = kalk_total_porosity-3;
kalk_Ks = (0.01233); %[mm/time] 

kalk_matrix_deci = [kalk_start_condition; K_deci zeros(length(K_deci),70)];

for a = 1:length(regn)-1
    kalk_matrix_deci(2,2) = kalk_matrix_deci(1,2) - kalk_Ks;
    for b=2
        if kalk_matrix_deci(a,b-1) > 0
            kalk_matrix_deci(a+1,b) = kalk_matrix_deci(a,b-1) + kalk_matrix_deci(a,b);
        end
        
    end
end
for a = 2:length(regn)-1
    for b=2
        
        if kalk_matrix_deci(a,b) > kalk_fc && kalk_matrix_deci(a,b) < kalk_sat
            kalk_matrix_deci(a+1,b) = kalk_matrix_deci(a,b) - kalk_Ks + kalk_matrix_deci(a,b-1);
            
        elseif kalk_matrix_deci(a,b) >= kalk_sat
            kalk_matrix_deci(a,b) = kalk_sat;
            kalk_matrix_deci(a+1,b) = kalk_matrix_deci(a,b) - kalk_Ks + kalk_matrix_deci(a,b-1);
        end
        
        if kalk_matrix_deci(a,b) < kalk_fc
            kalk_matrix_deci(a,b) = kalk_fc;
        end
        if kalk_matrix_deci(a,b) == kalk_fc
            kalk_matrix_deci(a+1,b) = kalk_fc + kalk_matrix_deci(a,b-1);
        end
        
    end
end

% From 3rd and forward
for i=2:length(regn)
    if ( (kalk_matrix_deci(i-1,1) + kalk_matrix_deci(i-1,2) ) <= kalk_sat )
        for j = 3:69
            kalk_matrix_deci(i,j) = kalk_matrix_deci(i-1,j);
        end
    else 
        rest = kalk_matrix_deci(i-1,2) + kalk_matrix_deci(i-1,1) - kalk_sat;
        for j = 3:70
            if (kalk_matrix_deci(i-1,j) < kalk_sat)
                kalk_matrix_deci(i,j) = kalk_matrix_deci(i-1,j) + rest;
                spaceindex = j;
                break
            end
        end
        for j = 3:spaceindex-1
            kalk_matrix_deci(i,j) = kalk_matrix_deci(i-1,j);
        end
        for j = spaceindex:69
            if (kalk_matrix_deci(i,j) > kalk_sat)
                kalk_matrix_deci(i,j+1) = kalk_matrix_deci(i-1,j+1)...
                    + (kalk_matrix_deci(i,j) - kalk_sat);
                kalk_matrix_deci(i,j) = kalk_sat;
            else
                kalk_matrix_deci(i,j+1) = kalk_matrix_deci(i-1,j+1);
            end
        end
    end
    
    for j= 70
        if kalk_matrix_deci(i,j) > 0
            kalk_matrix_deci(i,j+1) = kalk_matrix_deci(i,j) ...
                - kalk_matrix_deci(i-1,j);
        end
    end
end




for j=3:69 %Dræning af boxen såfremt forrige er ved field capacity
    if kalk_matrix_deci(i,j-1) == kalk_fc 
        kalk_matrix_deci(i,j) = kalk_matrix_deci(i-1,j) - kalk_Ks;
        if kalk_matrix_deci(i,j) < kalk_fc
            kalk_matrix_deci(i,j) = kalk_fc;
        end
        if kalk_matrix_deci(i,2) > kalk_fc
            kalk_matrix_deci(i,j) = kalk_matrix_deci(i-1,j);
        end
    end
end

for i=2:length(regn)
    for j = 70
        if kalk_matrix_deci(i,j) == 0
            kalk_matrix_deci(i,j) = kalk_matrix_deci(i,j-1);
        else
            kalk_matrix_deci(i,j) = kalk_matrix_deci(i-1,j) + kalk_matrix_deci(i,j+1); 
        end
       
    end
end

%% LIMESTONE MODELLING CONIFEROUS 

kalk_matrix_coni = [kalk_start_condition; K_coni zeros(length(K_coni),70)];

for a = 2:length(regn)
    kalk_matrix_coni(2,2) = kalk_matrix_coni(1,2) - kalk_Ks;
    for b=2
        if kalk_matrix_coni(a,b-1) > 0
            kalk_matrix_coni(a+1,b) = kalk_matrix_coni(a,b-1) + kalk_matrix_coni(a+1,b);
        end
        
    end
end
for a = 2:length(regn)
    for b=2
        
        if kalk_matrix_coni(a,b) > kalk_fc && kalk_matrix_coni(a,b) < kalk_sat
            kalk_matrix_coni(a+1,b) = kalk_matrix_coni(a,b) - kalk_Ks + kalk_matrix_coni(a,b-1);
            
        elseif kalk_matrix_coni(a,b) >= kalk_sat
            kalk_matrix_coni(a,b) = kalk_sat;
            kalk_matrix_coni(a+1,b) = kalk_matrix_coni(a,b) - kalk_Ks + kalk_matrix_coni(a,b-1);
        end
        
        if kalk_matrix_coni(a,b) < kalk_fc
            kalk_matrix_coni(a,b) = kalk_fc;
        end
        if kalk_matrix_coni(a,b) == kalk_fc
            kalk_matrix_coni(a+1,b) = kalk_fc + kalk_matrix_coni(a,b-1);
        end
        
    end
end
% From 3rd and forward
for i=2:length(regn)
    if ( (kalk_matrix_coni(i-1,1) + kalk_matrix_coni(i-1,2) ) <= kalk_sat )
        for j = 3:69
            kalk_matrix_coni(i,j) = kalk_matrix_coni(i-1,j);
        end
    else 
        rest = kalk_matrix_coni(i-1,2) + kalk_matrix_coni(i-1,1) - kalk_sat;
        for j = 3:70
            if (kalk_matrix_coni(i-1,j) < kalk_sat)
                kalk_matrix_coni(i,j) = kalk_matrix_coni(i-1,j) + rest;
                spaceindex = j;
                break
            end
        end
        for j = 3:spaceindex-1
            kalk_matrix_coni(i,j) = kalk_matrix_coni(i-1,j);
        end
        for j = spaceindex:69
            if (kalk_matrix_coni(i,j) > kalk_sat)
                kalk_matrix_coni(i,j+1) = kalk_matrix_coni(i-1,j+1)...
                    + (kalk_matrix_coni(i,j) - kalk_sat);
                kalk_matrix_coni(i,j) = kalk_sat;
            else
                kalk_matrix_coni(i,j+1) = kalk_matrix_coni(i-1,j+1);
            end
        end
    end
    
    for j= 70
        if kalk_matrix_coni(i,j) > 0
            kalk_matrix_coni(i,j+1) = kalk_matrix_coni(i,j) ...
                - kalk_matrix_coni(i-1,j);
        end
    end
end




for j=3:69 
    if kalk_matrix_coni(i,j-1) == kalk_fc 
        kalk_matrix_coni(i,j) = kalk_matrix_coni(i-1,j) - kalk_Ks;
        if kalk_matrix_coni(i,j) < kalk_fc
            kalk_matrix_coni(i,j) = kalk_fc;
        end
        if kalk_matrix_coni(i,2) > kalk_fc
            kalk_matrix_coni(i,j) = kalk_matrix_coni(i-1,j);
        end
    end
end

for i=2:length(regn)
    for j = 70
        if kalk_matrix_coni(i,j) == 0
            kalk_matrix_coni(i,j) = kalk_matrix_coni(i,j-1);
        else
            kalk_matrix_coni(i,j) = kalk_matrix_coni(i-1,j) + kalk_matrix_coni(i,j+1); 
        end
       
    end
end

%% NITRATE BALANCE START 
% IMPORT OF NITRATE
opts = spreadsheetImportOptions("NumVariables", 2);

% Specify sheet and range
opts.Sheet = "Ark1";
opts.DataRange = "A2:B33";

% Specify column names and types
opts.VariableNames = ["Dage", "KoncentrationerMiddelmgL"];
opts.VariableTypes = ["double", "double"];

% Import the data
Nitratkoncentrationer = readtable("Nitratkoncentrationer.xlsx", opts, "UseExcel", false);
days_nitrate = table2array(Nitratkoncentrationer(:,1));
C_nitrate = table2array(Nitratkoncentrationer(:,2));
clear opts

% Making the data to time basis instead of days basis
C_nitrate_time = zeros(24792,1);

for i = 1:length(C_nitrate_time)
    C_nitrate_time = [
        repmat(C_nitrate(1),720,1)
        repmat(C_nitrate(2),720,1)
        repmat(C_nitrate(3),768,1)
        repmat(C_nitrate(4),720,1)
        repmat(C_nitrate(5),792,1)
        repmat(C_nitrate(6),696,1)
        repmat(C_nitrate(7),648,1)
        repmat(C_nitrate(8),744,1)
        repmat(C_nitrate(9),744,1)
        repmat(C_nitrate(10),2952,1)
        repmat(C_nitrate(11),816,1)
        repmat(C_nitrate(12),696,1)
        repmat(C_nitrate(13),672,1)
        repmat(C_nitrate(14),672,1)
        repmat(C_nitrate(15),792,1)
        repmat(C_nitrate(16),672,1)
        repmat(C_nitrate(17),984,1)
        repmat(C_nitrate(18),576,1)
        repmat(C_nitrate(19),624,1)
        repmat(C_nitrate(20),792,1)
        repmat(C_nitrate(21),696,1)
        repmat(C_nitrate(22),744,1)
        repmat(C_nitrate(23),792,1)
        repmat(C_nitrate(24),816,1)
        repmat(C_nitrate(25),720,1)
        repmat(C_nitrate(26),768,1)
        repmat(C_nitrate(27),600,1)
        repmat(C_nitrate(28),648,1)
        repmat(C_nitrate(29),960,1)
        repmat(C_nitrate(30),528,1)
        repmat(C_nitrate(31),719,1)
        repmat(C_nitrate(32),1,1)
        ];
end


C_nitrate_rest = C_nitrate(32,1).*ones((length(regn)+1)-length(C_nitrate_time),1);
C_nitrate_total = [C_nitrate_time; C_nitrate_rest]; % [mg/L]

% Unit conversion: mg/L to mg/mm
% Dimensions of the box: 
% Surface area = 1000mm x 1000mm
% Height of box = 100mm
C_nitrate_unit = C_nitrate_total.*(10^-6); % [mg/mm3]
A_boks = 1000*1000; % [mm2]
CA_nitrate = C_nitrate_unit.*A_boks; % [mg/mm] 
%% NITRATE BALANCE DECIDUOS 
K_deci_n = [0; K_deci]; 

nitrate_rain_deci = K_deci_n.*CA_nitrate; % [mg]

nitrate_rain_deci_conc = zeros(length(CA_nitrate),1);
for i = 1:length(nitrate_rain_deci)
    if nitrate_rain_deci(i) > 0
        nitrate_rain_deci_conc(i) = CA_nitrate(i);
    end
    if nitrate_rain_deci_conc(1,1) == 0 
        nitrate_rain_deci_conc(1,1) = nitrate_rain_deci_conc(2,1);
    end
end

% FRACTURES: WATER CONTENT 
nitrate_frac_water_deci = [K_deci_n zeros(length(CA_nitrate),70)];

for i = 2:length(nitrate_frac_water_deci)
    for j = 2:70
        if kalk_matrix_deci(i-1,j) < kalk_matrix_deci(i,j)
           nitrate_frac_water_deci(i,j) = kalk_matrix_deci(i,j)-kalk_matrix_deci(i-1,j); % vand
        end
    end
end


nitrate_Ks_ind_deci = [K_deci_n zeros(length(CA_nitrate),70)];
nitrate_Ks_ud_deci = [K_deci_n zeros(length(CA_nitrate),70)];

nitrate_conc_deci = [nitrate_rain_deci_conc CA_nitrate(1).*ones(length(CA_nitrate),70)];
 
%WATER BALANCE

for i = 2:length(CA_nitrate)
    
    for j = 3:70
        if kalk_matrix_deci(i-1,j-1) > kalk_fc
            nitrate_Ks_ind_deci(i,j) = kalk_Ks;
            spaceindex = j;
            break
        end
    end
    for j = spaceindex+1:70
        nitrate_Ks_ind_deci(i+1,j) = kalk_Ks; 
    end
    
    for j = 3:70
        if nitrate_Ks_ind_deci(i,j) == kalk_Ks
            nitrate_Ks_ud_deci(i,j) = kalk_Ks;
        elseif kalk_matrix_deci(i,j) < kalk_matrix_deci(i-1,j)
            nitrate_Ks_ud_deci(i,j) = kalk_Ks;
        else
            nitrate_Ks_ud_deci(i,j) = 0;
        end
    end
    
    for j=2
        if kalk_matrix_deci(i-1,j) == kalk_fc && kalk_matrix_deci(i,1) == 0
            nitrate_Ks_ud_deci(i,j) = 0;
        else
            nitrate_Ks_ud_deci(i,j) = kalk_Ks;
        end
    end
end

 nitrate_Ks_ind_mass_deci = zeros(length(CA_nitrate),71);
 nitrate_Ks_ud_mass_deci = zeros(length(CA_nitrate),71);
 nitrate_frac_mass_deci = zeros(length(CA_nitrate),71);
 nitrate_mass_deci = zeros(length(CA_nitrate),71);

for i = 2:length(CA_nitrate)   
    for j = 2
        nitrate_Ks_ud_mass_deci(i,j) = nitrate_Ks_ud_deci(i,j).*nitrate_conc_deci(i-1,j);
    end
    for j = 2
        nitrate_frac_mass_deci(i,j) = nitrate_frac_water_deci(i,j).*nitrate_conc_deci(i-1,1);
    end
    for j = 2
        nitrate_mass_deci(i,j) = nitrate_conc_deci(i-1,j).*kalk_matrix_deci(i-1,j) ...
            - nitrate_Ks_ud_mass_deci(i,j) + nitrate_frac_mass_deci(i,j);
    end
    for j = 2
      nitrate_conc_deci(i,j) = nitrate_mass_deci(i,j)./kalk_matrix_deci(i,j);
    end  
    
    
    for j = 3:70
        nitrate_Ks_ind_mass_deci(i,j) = nitrate_Ks_ind_deci(i,j).*nitrate_conc_deci(i-1,j-1);
    end
    for j = 3:70
        nitrate_Ks_ud_mass_deci(i,j) = nitrate_Ks_ud_deci(i,j).*nitrate_conc_deci(i-1,j);
    end
    for j = 3:70
        nitrate_frac_mass_deci(i,j) = nitrate_frac_water_deci(i,j).*nitrate_conc_deci(i-1,1);
    end
    for j = 3:69
        nitrate_mass_deci(i,j) = nitrate_conc_deci(i-1,j).*kalk_matrix_deci(i-1,j) ...
            + nitrate_Ks_ind_mass_deci(i,j) - nitrate_Ks_ud_mass_deci(i,j) + nitrate_frac_mass_deci(i,j);
    end
     for j = 70
        nitrate_mass_deci(i,j) = nitrate_conc_deci(i-1,j).*(kalk_matrix_deci(i-1,j) - kalk_matrix_deci(i-1,j+1)) ...
            + nitrate_Ks_ind_mass_deci(i,j) - nitrate_Ks_ud_mass_deci(i,j) + nitrate_frac_mass_deci(i,j);
    end   
    for j = 3:70
              nitrate_conc_deci(i,j) = nitrate_mass_deci(i,j)./kalk_matrix_deci(i,j);
    end    
end

%% NITRATE BALANCE CONIFEROUS 
K_coni_n = [0; K_coni];
nitrate_rain_coni = K_coni_n.*CA_nitrate; % [mg]
nitrate_rain_coni_conc = zeros(length(CA_nitrate),1);

for i = 1:length(nitrate_rain_deci)
    if nitrate_rain_coni(i) > 0
        nitrate_rain_coni_conc(i) = CA_nitrate(i);
    end
    if nitrate_rain_coni_conc(1,1) == 0 
        nitrate_rain_coni_conc(1,1) = nitrate_rain_coni_conc(2,1);
    end
end

% FRACTURES: WATER CONTENT 
nitrate_frac_water_coni = [K_deci_n zeros(length(CA_nitrate),70)];

for i = 2:length(nitrate_frac_water_coni)
    for j = 2:70
        if kalk_matrix_coni(i-1,j) < kalk_matrix_coni(i,j)
           nitrate_frac_water_coni(i,j) = kalk_matrix_coni(i,j)-kalk_matrix_coni(i-1,j); % vand
        end
    end
end


nitrate_Ks_ind_coni = [K_coni_n zeros(length(CA_nitrate),70)];
nitrate_Ks_ud_coni = [K_coni_n zeros(length(CA_nitrate),70)];

nitrate_conc_coni = [nitrate_rain_coni_conc CA_nitrate(1).*ones(length(CA_nitrate),70)];
 
%WATER BALANCE

for i = 2:length(CA_nitrate)
    
    for j = 3:70
        if kalk_matrix_coni(i-1,j-1) > kalk_fc
            nitrate_Ks_ind_coni(i,j) = kalk_Ks;
            spaceindex = j;
            break
        end
    end
    for j = spaceindex+1:70
        nitrate_Ks_ind_coni(i+1,j) = kalk_Ks; 
    end
    
    for j = 3:70
        if nitrate_Ks_ind_coni(i,j) == kalk_Ks
            nitrate_Ks_ud_coni(i,j) = kalk_Ks;
        elseif kalk_matrix_coni(i,j) < kalk_matrix_coni(i-1,j)
            nitrate_Ks_ud_coni(i,j) = kalk_Ks;
        else
            nitrate_Ks_ud_coni(i,j) = 0;
        end
    end
    
    for j=2
        if kalk_matrix_coni(i-1,j) == kalk_fc && kalk_matrix_coni(i,1) == 0
            nitrate_Ks_ud_coni(i,j) = 0;
        else
            nitrate_Ks_ud_coni(i,j) = kalk_Ks;
        end
    end
end

 nitrate_Ks_ind_mass_coni = zeros(length(CA_nitrate),71);
 nitrate_Ks_ud_mass_coni = zeros(length(CA_nitrate),71);
 nitrate_frac_mass_coni = zeros(length(CA_nitrate),71);
 nitrate_mass_coni = zeros(length(CA_nitrate),71);

for i = 2:length(CA_nitrate)   
    for j = 2
        nitrate_Ks_ud_mass_coni(i,j) = nitrate_Ks_ud_coni(i,j).*nitrate_conc_coni(i-1,j);
    end
    for j = 2
        nitrate_frac_mass_coni(i,j) = nitrate_frac_water_coni(i,j).*nitrate_conc_coni(i-1,1);
    end
    for j = 2
        nitrate_mass_coni(i,j) = nitrate_conc_coni(i-1,j).*kalk_matrix_coni(i-1,j) ...
            - nitrate_Ks_ud_mass_coni(i,j) + nitrate_frac_mass_coni(i,j);
    end
    for j = 2
      nitrate_conc_coni(i,j) = nitrate_mass_coni(i,j)./kalk_matrix_coni(i,j);
    end  
    
    
    for j = 3:70
        nitrate_Ks_ind_mass_coni(i,j) = nitrate_Ks_ind_coni(i,j).*nitrate_conc_coni(i-1,j-1);
    end
    for j = 3:70
        nitrate_Ks_ud_mass_coni(i,j) = nitrate_Ks_ud_coni(i,j).*nitrate_conc_coni(i-1,j);
    end
    for j = 3:70
        nitrate_frac_mass_coni(i,j) = nitrate_frac_water_coni(i,j).*nitrate_conc_coni(i-1,1);
    end
    for j = 3:69
        nitrate_mass_coni(i,j) = nitrate_conc_coni(i-1,j).*kalk_matrix_coni(i-1,j) ...
            + nitrate_Ks_ind_mass_coni(i,j) - nitrate_Ks_ud_mass_coni(i,j) + nitrate_frac_mass_coni(i,j);
    end
     for j = 70
        nitrate_mass_coni(i,j) = nitrate_conc_coni(i-1,j).*(kalk_matrix_coni(i-1,j) - kalk_matrix_coni(i-1,j+1)) ...
            + nitrate_Ks_ind_mass_coni(i,j) - nitrate_Ks_ud_mass_coni(i,j) + nitrate_frac_mass_coni(i,j);
    end   
    for j = 3:70
              nitrate_conc_coni(i,j) = nitrate_mass_coni(i,j)./kalk_matrix_coni(i,j);
    end    
end

%% AVERAGE VALUES
nitrate_conc_deci_year = length(nitrate_conc_deci);

for i = 1:length(nitrate_conc_deci) 
    for j = 1:71
   if mod(i,8928) == 0
      nitrate_conc_deci_year(i,j) = sum(nitrate_conc_deci(i-8927:i,j)); 
   end
   end
end
nitrate_conc_deci_year = (nitrate_conc_deci_year./8928); 
nitrate_conc_deci_year = reshape(nitrate_conc_deci_year, 8928, []); 
nitrate_conc_deci_year = nonzeros(nitrate_conc_deci_year); 


 nitrate_conc_deci_year_sortet = [nitrate_conc_deci_year(22:22+20*1-1) ...  
     nitrate_conc_deci_year(22+20*13:22+20*14-1)...
     nitrate_conc_deci_year(22+20*33:22+20*34-1)...
     nitrate_conc_deci_year(22+20*68:22+20*69-1)]; 
 
 
 nitrate_conc_coni_year = length(nitrate_conc_coni);

for i = 1:length(nitrate_conc_coni)
    for j = 1:71
   if mod(i,8928) == 0
      nitrate_conc_coni_year(i,j) = sum(nitrate_conc_coni(i-8927:i,j)); 
   end
   end
end
nitrate_conc_coni_year = (nitrate_conc_coni_year./8928);
nitrate_conc_coni_year = reshape(nitrate_conc_coni_year, 8928, []);
nitrate_conc_coni_year = nonzeros(nitrate_conc_coni_year);

 nitrate_conc_coni_year_sortet = [nitrate_conc_coni_year(22:22+20*1-1) ...  
     nitrate_conc_coni_year(22+20*13:22+20*14-1)...
     nitrate_conc_coni_year(22+20*33:22+20*34-1)...
     nitrate_conc_coni_year(22+20*68:22+20*69-1)];
 
 
 % AVERAGE AF INFILTRATION PAA AARSBASIS
 K_deci_year = zeros(length(K_deci),1);
 for i = 1:length(K_deci)
   if mod(i,8928) == 0
      K_deci_year(i) = sum(K_deci(i-8927:i)); 
   end
 end
K_deci_year = nonzeros(K_deci_year);

K_coni_year = zeros(length(K_coni),1); 
 for i = 1:length(K_coni)
   if mod(i,8928) == 0
      K_coni_year(i) = sum(K_coni(i-8927:i)); 
   end
 end
K_coni_year = nonzeros(K_coni_year);

regn_year = zeros(length(regn),1);
 for i = 1:length(regn)
   if mod(i,8928) == 0
      regn_year(i) = sum(regn(i-8927:i)); 
   end
 end
regn_year = nonzeros(regn_year);

Epot_B_year = zeros(length(E_pot_B),1);
 for i = 1:length(E_pot_B)
   if mod(i,8928) == 0
      Epot_B_year(i) = sum(E_pot_B(i-8927:i)); 
   end
 end
Epot_B_year = nonzeros(Epot_B_year);

Epot_year = zeros(length(E_pot),1);
 for i = 1:length(E_pot)
   if mod(i,8928) == 0
      Epot_year(i) = sum(E_pot(i-8927:i)); 
   end
 end
Epot_year = nonzeros(Epot_year);

itc_B_year = zeros(length(itc_box_B),1);
 for i = 1:length(itc_B)
   if mod(i,8928) == 0
      itc_B_year(i) = sum(itc_box_B(i-8927:i)); 
   end
 end
itc_B_year = nonzeros(itc_B_year);
itc_B_year = [0; 0; itc_B_year];

TF_B_year = zeros(length(TF_B),1);
 for i = 1:length(TF_B)
   if mod(i,8928) == 0
      TF_B_year(i) = sum(TF_B(i-8927:i)); 
   end
 end
TF_B_year = nonzeros(TF_B_year);

%% NTRATE LEACHING KG N/YEAR*HA

leaching_coni = nitrate_conc_coni_year_sortet.*K_coni_year.*10*(14.0067/62.0049)*0.001;
leaching_deci = nitrate_conc_deci_year_sortet.*K_deci_year.*10*(14.0067/62.0049)*0.001;
