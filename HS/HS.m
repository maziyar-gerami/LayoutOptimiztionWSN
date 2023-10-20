clc;
clear;
close all;
%% Problem Definition

nSensors=32;             % Number of Decision Variables

rSensors = 10;           % radius of each sensor layout

xArea = 100;             % Length and width of world

Area = xArea *xArea;     %Area of the world

CostFunction=@(x) ObjectiveFunc(x,rSensors,Area);        % Cost Function
%% HS Algorithm Parameters

NI=500;                             % Maximum Number of Iterations

HMS =50;                           	% Harmoney Memory Size

HMCR =0.8;                          % Harmoney Memory Considering Rate

PAR = 0.3;                          % Rate of Choosing a Neighboring Value

BW = 0.6;                           % Max Bandwith

r=0.1*(xArea);                      % Neighborhood Radius

rdamp=0.99;                         % Neighborhood Radius Damp Rate

%% Initialization

% Empty Harmoney Structure
empty_Harmoney.Position=[];
empty_Harmoney.Coverage=[];

% Initialize Harmonies Array
harmonies=repmat(empty_Harmoney,HMS,1);

% Create New Solutions
for i=1:HMS
    
    harmonies(i).Position=unifrnd(1,xArea,[1 ,nSensors*2]);
    
    harmonies(i).Coverage=CostFunction(harmonies(i).Position);
end

% Sort
[~, SortOrder]=sort([harmonies.Coverage], 'descend');
harmonies=harmonies(SortOrder);

% Update Best Solution Ever Found
BestSol=harmonies(1);

n = nSensors*2;

% Array to Hold Best Coverage Values
BestCoverage=zeros(NI,1);
t=cputime;
%% IHS Algorithm Main Loop

for i=1:NI
    
   
   newSol =repmat(empty_Harmoney,1,1);
   
   for j=1:n
   
       if rand< HMCR

            newSol.Position(j) = harmonies(randi(HMS)).Position(j);
            
            if rand <PAR
               
                
                newSol.Position(j) = newSol.Position(j) + unifrnd(-1,1)*BW;
                
            end
            
       else
           
           newSol.Position(j) = unifrnd(1,xArea);

        end
       
       
    end
   
    newSol.Coverage=CostFunction(newSol.Position);
    
    harmonies(end) = newSol;
   
    % Sort
    [~, SortOrder]=sort([harmonies.Coverage], 'descend');
    harmonies=harmonies(SortOrder);
    
    % Update Best Solution Ever Found
    BestSol=harmonies(1);
    
    % Store Best Coverage Ever Found
    BestCoverage(i)=BestSol.Coverage;
    
    disp(['Iteration ' num2str(i) ': Best Coverage = ' num2str(BestCoverage(i))]);
    
end

cpuTime =cputime-t;
%% Results
disp(['Cpu Time for ' num2str(NI) ' is : ' num2str(cpuTime)]);

figure;
plot (BestCoverage, 'LineWidth', 2);
xlabel ('Iteration');
ylabel ('Best Coverage');

