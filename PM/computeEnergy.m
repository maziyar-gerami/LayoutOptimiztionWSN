function et = computeEnergy(currentNode,nextNode, nodes)


    % L = 20 log(d) + 20 log(f) + 36.6 : this is the radoi theory
    % where L is power in db, d is distance in mile and f is frequency in MHZ
    % we can convert L to Power in watt using:
    % P(W) = 10^(dBm/ 10) / 1000
    %f is: 2.4Ghz or 2400 Mhz
    
    
    
    nNodes = length (nodes);

    f = 2400;

    Distance = pdist2([nodes(1,currentNode), nodes(2,currentNode)], [nodes(1,nextNode), nodes(2,nextNode)]);

    L = 20*log(Distance/1600) + 20*log(f) +36.6;
    et = 10^(L/10)/1000;
        
end

