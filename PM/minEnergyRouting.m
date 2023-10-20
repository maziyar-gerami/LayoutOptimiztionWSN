function [ EnergyConsumption ] = minEnergyRouting( inputNode, nodes )


    % Numbdr of nodes, including sink
    nNodes = (length (nodes.Position))/2;
    
    nodesPosition = ones(3, nNodes);
    
    x = linspace (1,nNodes, nNodes);
    
    y= x+1;

    nodesPosition(1,:) = nodes.Position(x);
    nodesPosition(2,:) = nodes.Position(y);
    
    
    nodesPosition(3,inputNode) = 0;
    
    EnergyConsumption = 0;
    
    minEnergy(inputNode, nodesPosition);
    
    function minEnergy(currentNode, nodes)
        
        Ea=1;
        
        for i=1:nNodes
            
            if nodes(3,i) >0

               nextNode = i;

               Ea(i) = computeEnergy (currentNode , nextNode, nodes);
               
            else
                
                Ea(i) = inf;
               
            end

        end

        [EnergyConsumptionTemp, index] = min (Ea);

        EnergyConsumption = EnergyConsumption + EnergyConsumptionTemp;

        nodes(3,index) = 0;
        
        if nnz(nodes(3,:))>1
        
            minEnergy (index, nodes);
            
        else
            
            a=1;

        end
        
    end

end

