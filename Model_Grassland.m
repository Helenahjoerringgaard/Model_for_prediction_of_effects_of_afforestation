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
KorrigeretEpot = readtable("Korrigeret_E_pot_Grass.xlsx", opts, "UseExcel", false);
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

%% INTERCEPTION for Grass
opts = spreadsheetImportOptions("NumVariables", 31);

% Specify sheet and range
opts.Sheet = "Grass";
opts.DataRange = "A1:AE12";

% Specify column names and types
opts.VariableNames = ["VarName1", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9", "VarName10", "VarName11", "VarName12", "VarName13", "VarName14", "VarName15", "VarName16", "VarName17", "VarName18", "VarName19", "VarName20", "VarName21", "VarName22", "VarName23", "VarName24", "VarName25", "VarName26", "VarName27", "VarName28", "VarName29", "VarName30", "VarName31"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Import the data
LAIS6 = readtable("LAI.xlsx", opts, "UseExcel", false);

clear opts

% Matrix
max_itc_Grass = table2array(LAIS6(:,:));
% Interception Winter wheat

% Days to hours
max_itc_hr_Grass = repelem(max_itc_Grass,1,24);

% Max interception for 20 years
itc_matrix_Grass = repmat(max_itc_hr_Grass,20,1);

% Matrix til kollone
itc_Grass = 0;
for i = 1:240
    itc_Grass = [itc_Grass itc_matrix_Grass(i,:)];
end

itc_Grass = itc_Grass';

% INTERCEPTION MODEL
itc_box_Grass = zeros(length(itc_Grass),1);

for i=2:length(itc_box_Grass)
    if regn(i)>=itc_Grass(i)
        itc_box_Grass(i)=itc_Grass(i)-E_pot(i);
        if E_pot(i)>itc_Grass(i)
            itc_box_Grass(i)=0;
        end
    end
    if regn(i)<itc_Grass(i) && itc_Grass(i)>E_pot(i)
        itc_box_Grass(i)= itc_box_Grass(i-1)+regn(i)-E_pot(i);
        if itc_box_Grass(i)<0
            itc_box_Grass(i)=0;
        end
        if  itc_box_Grass(i-1)+regn(i)>itc_Grass(i)
            itc_box_Grass(i)=itc_Grass(i)-E_pot(i);
        end
    elseif regn(i)<itc_Grass(i) && itc_Grass(i)<=E_pot(i)
        itc_box_Grass(i)=0;
    end
end

% Throughfall
TF_Grass = zeros(length(regn),1);

for i=2:length(regn)
    if regn(i)+itc_box_Grass(i-1)>itc_Grass(i)
        TF_Grass(i)=regn(i)+itc_box_Grass(i-1)-itc_Grass(i);
        if regn(i)+itc_box_Grass(i-1)<itc_Grass(i)
            TF_Grass(i)=0;
        end
    end
end

% NY E_pot
E_pot_Grass = zeros(length(E_pot),1);

for i=2:length(E_pot)
    if regn(i)+itc_box_Grass(i-1)>itc_Grass(i)
        E_pot_Grass(i)=E_pot(i)-itc_Grass(i);
        if E_pot(i) < itc_Grass(i)
            E_pot_Grass(i) = 0;
        end
    elseif regn(i)+itc_box_Grass(i-1)<=itc_Grass(i)
        E_pot_Grass(i)=E_pot(i)-regn(i)-itc_box_Grass(i-1);
        if E_pot(i)-regn(i)-itc_box_Grass(i-1)<0
            E_pot_Grass(i)=0;
        end
    end
end

%% VANDDEFICIT
field_capacity = 134.4/2; 
wilting_point = 44.9/2; 
Vdeficit_max = field_capacity - wilting_point;

E_a_deci = zeros(length(regn),1);
V_deci = [V_start_condition; zeros(length(regn)-1,1)];
K_deci = [K_start_condition; zeros(length(regn)-1,1)];

I_deci = zeros(length(regn),1);

for i = 2:length(TF_Grass)
    I_deci(i) = TF_Grass(i);
    
    if V_deci(i-1) < 0.5*Vdeficit_max && I_deci(i) >= E_pot_Grass(i)
        E_a_deci(i) = E_pot_Grass(i); 
        if V_deci(i-1) < (I_deci(i) - E_a_deci(i))
            V_deci(i) = 0;                           
        elseif V_deci(i-1) > (I_deci(i) - E_a_deci(i))
            V_deci(i) = V_deci(i-1) - (I_deci(i) - E_a_deci(i));
        end
        
    elseif V_deci(i-1) < 0.5*Vdeficit_max && I_deci(i) <= E_pot_Grass(i)
        E_a_deci(i) = E_pot_Grass(i);                          
        V_deci(i) = V_deci(i-1) + abs(I_deci(i) - E_a_deci(i));
        
    elseif  V_deci(i-1) >= 0.5*Vdeficit_max && I_deci(i) <= E_pot_Grass(i)
        E_a_deci(i) =-(I_deci(i) - E_pot_Grass(i)).*2.*(1-V_deci(i-1)./Vdeficit_max) + I_deci(i);
        V_deci(i) = V_deci(i-1) + abs(I_deci(i) - E_a_deci(i));
        
    elseif  V_deci(i-1) >= 0.5*Vdeficit_max && I_deci(i) >= E_pot_Grass(i)
        E_a_deci(i) = E_pot_Grass(i);
        V_deci(i) = V_deci(i-1) - (I_deci(i) - E_a_deci(i)); 
    end
    if V_deci(i) > Vdeficit_max
        V_deci(i) = Vdeficit_max; 
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

%% LIMESTONE MODELLING

kalk_fc = 418.3/10;
kalk_total_porosity = 475.5/10;
spraekker = 0.03;
kalk_sat = kalk_total_porosity-3; 
kalk_Ks = 0.01233; %[mm/time]

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



for j=3:69 
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

% INPUT MATRICE
C_nitrate_rest = C_nitrate(32,1).*ones((length(regn)+1)-length(C_nitrate_time),1);
C_nitrate_total = [C_nitrate_time; C_nitrate_rest]; % [mg/L]

% Unit conversion: mg/L to mg/mm
% Dimensions of the box: 
% Surface area = 1000mm x 1000mm
% Height of box = 100mm
C_nitrate_unit = C_nitrate_total.*(10^-6); % [mg/mm3]
A_boks = 1000*1000; % [mm2]
CA_nitrate = C_nitrate_unit.*A_boks; % [mg/mm]
%% NITRATE BALANCE 

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
nitrategrass = nitrate_conc_deci_year_sortet;
 
  Grass_recharge_year = zeros(length(K_deci),1);
 for i = 1:length(K_deci)
   if mod(i,8928) == 0
      Grass_recharge_year(i) = sum(K_deci(i-8927:i)); 
   end
 end
Grass_recharge_year = nonzeros(Grass_recharge_year);

leaching_grass = nitrate_conc_deci_year_sortet.*Grass_recharge_year.*10*(14.0067/62.0049)*0.001;

K_deci_year = Grass_recharge_year;
regn_year = zeros(length(regn),1);
 for i = 1:length(regn)
   if mod(i,8928) == 0
      regn_year(i) = sum(regn(i-8927:i)); 
   end
 end
regn_year = nonzeros(regn_year);