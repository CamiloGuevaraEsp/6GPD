%% Protein concentration script
% By Camilo Guevara
%2022/10/27 

%Assume it is doing triplicates in a 96 well plate

clear all
%Plate map


rows = ["A","B","C","D","E", "F", "G","H"]; 
columns = ["01","02","03","04","05","06","07","08","09","10","11","12"]; 
counter = 1;

for i = 1: length(rows)
   for j = 1: length(columns)
       %el i times j es el problema
       plate(counter,1) = strcat(rows(i),columns(j));
       counter = counter + 1; 
   end
end

%Write down which wells have samples and standards
sample_wells = ["A01","A02","A03","A04","A05","A06","A07", "A08","A09"];
standards_wells = ["B01","B02", "B03", "B04","B05","B06","B07","B08","B09","B10","B11","B12", "C01","C02", "C03", "C04", "C05","C06","C07","C08","C09","C10","C11","C12"];
filename = "20221020_BCA_1.xls";
%Write how many samples are you using
samples_num = 3; 
%Write your diution factor
dilution_factor = 4; 
%Name your samples in the order you loaded into the wells 
sample_name = ["100 heads A","100 heads B","100 heads C"];
worked_wells = [sample_wells standards_wells]'; 
T = readtable(filename);

%map into indices 
index = ismember(plate,worked_wells); 
measured = T.Absorbance_540_A_(index); 
%Uncomment for triplicate
well_end_point = 3:3:length(measured);
%Uncomment for duplicate
%well_end_point = 2:2:length(measured);
for i =  1:length(well_end_point)
   %Uncomment for triplicate
   averages(i) = mean(measured(well_end_point(i)-2:well_end_point(i))) 
   %Uncomment for duplicate
   averages(i) = mean(measured(well_end_point(i)-1:well_end_point(i)));
end

samples = averages(1:samples_num);
std = averages(samples_num + 1: end);

%Substract OD540 of Blank 2(0 Standard, #8) from all BSA Standards

stds = std - std(8);  

%For samples, substract OD540 of Blank 1 (0 standard #7) from that of
%protein samples

samples = samples - std(7);

%Plot the standard curve 

std_conc = [2000,1000,500,250,125,25,0,0]; 
scatter(std_conc, stds) 

p = polyfit(std_conc,stds,1);
f = polyval(p,std_conc);
plot(std_conc,stds,'o',std_conc,f,'-');
slope = (p(1));
intercept = p(2); 

concentrations = dilution_factor .* ((samples - intercept)/slope)

for i = 1:length(samples)
   fprintf ('Protein concentration for %s is %e ug/mL\n ', sample_name(i), concentrations(i));
end