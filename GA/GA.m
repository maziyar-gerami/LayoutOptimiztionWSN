clc;
clear;
close all;
%% Problem Definition

nSensors=32;             % Number of Decision Variables

rSensors = 10;           % radius of each sensor layout

xArea = 100;             % Length and width of world

Area = xArea *xArea;     % Area of the world

CostFunction=@(x) ObjectiveFunc(x,rSensors,Area);        % Cost Function


%% GA Parameters

MaxIt=100;      % Maximum Number of Iterations

nPop=50;        % Population Size

pc=0.8;                 % Crossover Percentage
nc=2*round(pc*nPop/2);  % Number of Offsprings (Parnets)

pm=0.2;                 % Mutation Percentage
nm=round(pm*nPop);      % Number of Mutants

mu=0.02;         % Mutation Rate

%% Initialization

empty_individual.Position=[];
empty_individual.Coverage=[];

pop=repmat(empty_individual,nPop,1);

for i=1:nPop
    
    pop(i).Position=unifrnd(1,xArea,[1 ,nSensors*2]);
    pop(i).Coverage=CostFunction(pop(i).Position);
    
end

% Sort Population
[~, SortOrder]=sort([pop.Coverage], 'descend');
pop=pop(SortOrder);

% Best Solution Ever Found
BestSol=pop(1);

% Array to Hold Best Coverages
BestCoverage=zeros(MaxIt,1);

t=cputime;

%% Main Loop

for it=1:MaxIt
    
    
    P=[pop.Coverage]/sum([pop.Coverage]);
    
    % Crossover
    popc=repmat(empty_individual,nc/2,2);
    for k=1:nc/2
        
        %  Select Parents Indices
        i1=RouletteWheelSelection(P);
        i2=RouletteWheelSelection(P);

        % Select Parents
        p1=pop(i1);
        p2=pop(i2);
        
        % Apply Crossover
        flag = true;
            
        [popc(k,1).Position, popc(k,2).Position]=Crossover(p1.Position,p2.Position);
            
        % Evaluate Offsprings
        popc(k,1).Coverage = CostFunction(popc(k,1).Position);
        
        popc(k,2).Coverage = CostFunction(popc(k,2).Position);
        
        
    end
    popc=popc(:);
    
    % Mutation
    popm=repmat(empty_individual,nm,1);
    for k=1:1
        
        % Select Parent
        i=randi([1 nPop]);
        p=pop(i);
        
        % Apply Mutation    
    
        popm(k).Position=Mutate(p.Position,mu, xArea);
        
        % Evaluate Mutant
        popm(k).Coverage=CostFunction(popm(k).Position);
        
    end
    
    % Create Merged Population
    pop=[pop
         popc
         popm];
    
    % Sort Population
    [~, SortOrder]=sort([pop.Coverage], 'descend');
    pop=pop(SortOrder);
    
    
    % Truncation
    pop=pop(1:nPop);

    % Set an anchor point
    if (pop(1).Coverage > BestSol.Coverage)
        anchorPoint = it; 
    end
    
    % Store Best Solution Ever Found
    BestSol=pop(1);
    
    
    
    % Store Best Coverage Ever Found
    BestCoverage(it)=BestSol.Coverage;
    
    % Show Iteration Information
    disp(['Iteration ' num2str(it) ': Best Coverage = ' num2str(BestCoverage(it))]);
    
    
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
