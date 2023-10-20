clc;
clear;
close all;
%% Problem Definition

nSensors=50;             % Number of Decision Variables

target = 32;

rSensors = 10;           % radius of each sensor layout

xArea = 100;             % Length and width of world

Area = xArea *xArea;     %Area of the world

CostFunction=@(x) ObjectiveFunc(x,rSensors,Area);        % Cost Function
%% IHS Algorithm Parameters

NI=100;                             % Maximum Number of Iterations

HMS =50;                           	% Harmoney Memory Size

HMCRMax =1;                        % Max Harmoney Memory Considering Rate

HMCRMin = 0.7;                      % Min Harmoney Memory Considering Rate

PARMin = 0.1;                       % Min Rate of Choosing a Neighboring Value

PARMax = 0.5;                        % Max Rate of Choosing a Neighboring Value

BWMax = 1;                          % Max Bandwith

BWMin = 0;                          % Min Bandwith

%% Bee Parameters

MaxIt=100;          % Maximum Number of Iterations

nScoutBee=10;                           % Number of Scout Bees

nSelectedSite=round(0.5*nScoutBee);     % Number of Selected Sites

nEliteSite=round(0.4*nSelectedSite);    % Number of Selected Elite Sites

nSelectedSiteBee=round(0.5*nScoutBee);  % Number of Recruited Bees for Selected Sites

nEliteSiteBee=2*nSelectedSiteBee;       % Number of Recruited Bees for Elite Sites

r=0.1*(xArea);	% Neighborhood Radius

rdamp=0.99;             % Neighborhood Radius Damp Rate

%% Initialization

% Empty Harmoney Structure
empty_Harmoney.Position=[];
empty_Harmoney.Coverage=[];
empty_Harmoney.Energy = [];
empty_Harmoney.Quality = [];

% Initialize Harmonies Array
harmonies=repmat(empty_Harmoney,HMS,1);

% Create New Solutions
for i=1:HMS
    
    harmonies(i).Position=unifrnd(1,xArea,[1 ,nSensors*2]);
    
    harmonies(i).Coverage=CostFunction(harmonies(i).Position);
    
    harmonies(i).Energy = minEnergyRouting (target, harmonies(i));
       
    
end

[ value , index ] = Topsis (harmonies);


% Sort
harmonies=harmonies(index);

for i=1:HMS
    
    harmonies(i).Quality = value(i);
       
end

% Update Best Solution Ever Found
BestSol=harmonies(1);

n = nSensors*2;

% Array to Hold Best Coverage Values
BestCoverage=zeros(NI,1);
BestEnergyConsumption = zeros(NI,1);
t=cputime;
%% IHS Algorithm Main Loop

for i=1:NI
    
   HMCR = HMCRMin + (HMCRMax - HMCRMin) * i/NI;
   PAR = PARMin + (PARMax - PARMin) * i/NI;
   BW = BWMin + (BWMax - BWMin) * i/NI;
   
   newSol =repmat(empty_Harmoney,1,1);
   
   for j=1:n
   
       if rand< HMCR

            newSol.Position(j) = harmonies(1).Position(j);
            
            if rand <PAR
               
                feasible = false;
                
                while ~feasible
                    
                    temp = newSol.Position(j) + unifrnd(-1,1)*BW;
                 
                    if Feasible(temp, xArea)
                     
                        newSol.Position(j) = temp;
                    
                        feasible = true;
                    end
                    
                    
                end
                
                 
                
            end
            
       else
           
           newSol.Position(j) = unifrnd(1,xArea);
           
           

        end
       
       
    end
   
    newSol.Coverage=CostFunction(newSol.Position);
    newSol.Energy = minEnergyRouting (target, newSol);
    
    [ value , index ] = Topsis (harmonies);

    
    % Sort
    harmonies=harmonies(index);
    
    for j=1:HMS
    
        harmonies(j).Quality = value(j);
       
    end
        
    
    harmonies(end) = newSol;
    
    % sort again
    
    [ value , index ] = Topsis (harmonies);


    % Sort
    harmonies=harmonies(index);
    
    Quality = Topsis (harmonies);

    for j=1:HMS
    
        harmonies(j).Quality = value(j);
       
    end
    
    % Sort
    [~, SortOrder]=sort([harmonies.Quality], 'descend');
    
    % Update Best Solution Ever Found
    BestSol=harmonies(1);
    
    % Store Best Coverage Ever Found
    BestCoverage(i)=BestSol.Coverage;
    BestEnergyConsumption(i) =BestSol.Energy;
    
    disp(['Iteration ' num2str(i) ': Best Coverage = ' num2str(BestCoverage(i)) ' and Best Energy Consumption = ' num2str(BestEnergyConsumption(i))]);
    
end

%% Bee Initialization

% Empty Bee Structure
empty_bee.Position=[];
empty_bee.Coverage=[];
empty_bee.Energy=[];

% Initialize Bees Array
bee=repmat(empty_bee,nScoutBee,1);

% Create New Solutions
for i=1:nScoutBee
    bee(i).Position=harmonies(i).Position;
    bee(i).Coverage=CostFunction(bee(i).Position);
    bee(i).Energy = minEnergyRouting (target, bee(i));
end

% Sort
[~, SortOrder]=sort([bee.Coverage], 'descend');
bee=bee(SortOrder);

% Update Best Solution Ever Found
BestSol=bee(1);

% Array to Hold Best Coverage Values
BestCoverage=zeros(MaxIt,1);
t=cputime;

%% Bee Algorithm

for it=1:MaxIt
    
    % Elite Sites
    for i=1:nEliteSite
        
        bestnewbee.Coverage=-inf;
        
        for j=1:nEliteSiteBee
            newbee.Position=UniformBeeDance(bee(i).Position,r);
            newbee.Coverage=CostFunction(newbee.Position);
            newbee.Energy = minEnergyRouting (target, newbee);
            if newbee.Coverage>bestnewbee.Coverage
                bestnewbee=newbee;
            end
        end

        if bestnewbee.Coverage>bee(i).Coverage
            bee(i)=bestnewbee;
        end
        
    end
    
    % Selected Non-Elite Sites
    for i=nEliteSite+1:nSelectedSite
        
        bestnewbee.Coverage=-inf;
        
        for j=1:nSelectedSiteBee
            newbee.Position=UniformBeeDance(bee(i).Position,r);
            newbee.Coverage=CostFunction(newbee.Position);
            newbee.Energy = minEnergyRouting (target, newbee);
            if newbee.Coverage>bestnewbee.Coverage
                bestnewbee=newbee;
            end
        end

        if bestnewbee.Coverage>bee(i).Coverage
            bee(i)=bestnewbee;
        end
        
    end
    
    % Non-Selected Sites
    for i=nSelectedSite+1:nScoutBee
        bee(i).Position=unifrnd(1,xArea,[1 ,nSensors*2]);
        bee(i).Coverage=CostFunction(bee(i).Position);
        bee(i).Energy = minEnergyRouting (target, bee(i));
    end
    
    % Sort
    [~, SortOrder]=sort([bee.Coverage], 'descend');
    bee=bee(SortOrder);
    
    if (bee(1).Coverage > BestSol.Coverage)
        anchorPoint = it; 
    end
    
    % Update Best Solution Ever Found
    BestSol=bee(1);
    
    % Store Best Coverage Ever Found
    BestCoverage(it)=BestSol.Coverage;
    
    % Display Iteration Information
    disp(['Iteration ' num2str(it) ': Best Coverage = ' num2str(BestCoverage(it)) 'and Best Energy Consumption = ' num2str(BestSol.Energy)]);
    
    % Damp Neighborhood Radius
    r=r*rdamp;
    
end


%% Results

x = linspace (1,nSensors*2-1, nSensors);
    
y= x+1;

figure

for i=1: nSensors;
    
    circle(BestSol.Position(x(i)),BestSol.Position(y(i)),rSensors);
    
    hold on
    
end


figure;
plot (BestCoverage, 'LineWidth', 2);

xlabel ('Iteration');
ylabel ('Best Coverage');

figure;
plot (BestEnergyConsumption, 'LineWidth', 2);

xlabel ('Iteration');
ylabel ('Best Energy Consumption');
