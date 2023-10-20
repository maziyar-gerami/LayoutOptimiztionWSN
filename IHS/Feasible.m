function feasible = Feasible(sol, xArea)

    if (sol < xArea) && (sol>=0)
        
        feasible = true;
        
    else
        
        feasible = false;
        
    end

end

