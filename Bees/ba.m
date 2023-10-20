clc;
clear;
close all;
rng(1)
%% Problem Definition

nSensors=32;             % Number of Decision Variables

rSensors = 10;           % radius of each sensor layout

xArea = 100;             % Length and width of world

Area = xArea *xArea;     %Area of the world

CostFunction=@(x) ObjectiveFunc(x,rSensors,Area);        % Cost Function
%% Bees Algorithm Parameters

MaxIt=100;          % Maximum Number of Iterations

nScoutBee=10;                           % Number of Scout Bees

nSelectedSite=round(0.5*nScoutBee);     % Number of Selected Sites

nEliteSite=round(0.4*nSelectedSite);    % Number of Selected Elite Sites

nSelectedSiteBee=round(0.5*nScoutBee);  % Number of Recruited Bees for Selected Sites

nEliteSiteBee=2*nSelectedSiteBee;       % Number of Recruited Bees for Elite Sites

r=0.1*(xArea);	% Neighborhood Radius

rdamp=0.99;             % Neighborhood Radius Damp Rate

%% Initialization

% Empty Bee Structure
empty_bee.Position=[];
empty_bee.Coverage=[];

% Initialize Bees Array
bee=repmat(empty_bee,nScoutBee,1);

% Create New Solutions
for i=1:nScoutBee
    bee(i).Position=unifrnd(1,xArea,[1 ,nSensors*2]);
    bee(i).Coverage=CostFunction(bee(i).Position);
end

% Sort
[~, SortOrder]=sort([bee.Coverage], 'descend');
bee=bee(SortOrder);

% Update Best Solution Ever Found
BestSol=bee(1);

% Array to Hold Best Coverage Values
BestCoverage=zeros(MaxIt,1);
t=cputime;
%% Bees Algorithm Main Loop

for it=1:MaxIt
    
    % Elite Sites
    for i=1:nEliteSite
        
        bestnewbee.Coverage=-inf;
        
        for j=1:nEliteSiteBee
            newbee.Position=UniformBeeDance(bee(i).Position,r);
            newbee.Coverage=CostFunction(newbee.Position);
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
    disp(['Iteration ' num2str(it) ': Best Coverage = ' num2str(BestCoverage(it))]);
    
    % Damp Neighborhood Radius
    r=r*rdamp;
    
end

cpuTime = cputime-t;
%% Results
disp(['Cpu Time for ' num2str(MaxIt) ' is : ' num2str(cpuTime)]);
cpuTime = (cpuTime/MaxIt) * anchorPoint;
disp(['Cpu Time until ' num2str(anchorPoint) ' is : ' num2str(cpuTime)]);
figure;
plot (BestCoverage, 'LineWidth', 2);
xlabel ('Iteration');
ylabel ('Best Coverage');

