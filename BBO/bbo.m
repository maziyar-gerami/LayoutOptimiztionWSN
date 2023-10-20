function [BestCoverageR,BestEnergyConsumptionR] = proposed (nSensors,target,rSensors,xArea)
%% Problem Definition

Area = xArea *xArea;     %Area of the world

CostFunction=@(x) ObjectiveFunc(x,rSensors,Area);        % Cost Function

%% BBO Parameters

MaxIt=100;          % Maximum Number of Iterations

nPop=50;            % Number of Habitats (Population Size)

KeepRate=0.4;                   % Keep Rate
nKeep=round(KeepRate*nPop);     % Number of Kept Habitats

nNew=nPop-nKeep;                % Number of New Habitats

% Migration Rates
mu=linspace(1,0,nPop);          % Emmigration Rates
lambda=1-mu;                    % Immigration Rates

alpha=0.1;

pMutation=0.2;

sigma=0.2*(1-xArea);
%% Initialization

% Empty Habitat
habitat.Position=[];
habitat.Coverage=[];

% Create Habitats Array
pop=repmat(habitat,nPop,1);

% Initialize Habitats
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
%% BBO Main Loop

for it=1:MaxIt
    
    newpop=pop;
    for i=1:nPop
        for k=1:nSensors*2
            % Migration
            if rand<=lambda(i)
                % Emmigration Probabilities
                EP=mu;
                EP(i)=0;
                EP=EP/sum(EP);
                
                % Select Source Habitat
                j=RouletteWheelSelection(EP);
                
                % Migration
                newpop(i).Position(k)=pop(i).Position(k) ...
                    +alpha*(pop(j).Position(k)-pop(i).Position(k));
                
            end
            
            % Mutation
            if rand<=pMutation
                newpop(i).Position(k)=newpop(i).Position(k)+sigma*randn;
            end
        end
        
        % Evaluation
        newpop(i).Coverage=CostFunction(newpop(i).Position);
    end
    
    % Sort New Population
    [~, SortOrder]=sort([newpop.Coverage], 'descend');
    newpop=newpop(SortOrder);
    
    % Select Next Iteration Population
    pop=[pop(1:nKeep)
         newpop(1:nNew)];
     
    % Sort Population
    [~, SortOrder]=sort([pop.Coverage], 'descend');
    pop=pop(SortOrder);
    
    if (pop(1).Coverage > BestSol.Coverage)
        anchorPoint = it; 
    end
    
    % Update Best Solution Ever Found
    BestSol=pop(1);
    
    % Store Best Coverage Ever Found
    BestCoverage(it)=BestSol.Coverage;
    
    % Show Iteration Information
    disp(['Iteration ' num2str(it) ': Best Coverage = ' num2str(BestCoverage(it))]);
    
end

cpuTime = cputime-t;
%% Results

BestCoverageR = BestSol.Coverage;
BestEnergyConsumptionR = BestSol.Energy;


disp(['Cpu Time for ' num2str(MaxIt) ' is : ' num2str(cpuTime)]);
cpuTime = (cpuTime/MaxIt) * anchorPoint;
disp(['Cpu Time until ' num2str(anchorPoint) ' is : ' num2str(cpuTime)]);
figure;
plot (BestCoverage, 'LineWidth', 2);
xlabel ('Iteration');
ylabel ('Best Coverage');


