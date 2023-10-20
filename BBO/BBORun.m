clc;
clear;
close all;
%% Problem Definition

nSensors=32;             % Number of Decision Variables

target = 32;

rSensors = 10;           % radius of each sensor layout

xArea = 100;             % Length and width of world

nIT = 10;

%% Main

for i=1: nIT
    
    [BestCoverage(i) ,BestEnergyConsumption(i)] = bbo (nSensors,target,rSensors,xArea);
         
end

result = [BestCoverage;BestEnergyConsumption];

xlswrite('Result.xlsx', result);


