function y=Mutate(x,mu,xArea)

    
    
    nVar=numel(x);
    
    nmu=ceil(mu*nVar);
    
    
    j = randi(length(x),nmu);
    
    y=x;
    y(j)= unifrnd(1,xArea,1);
        

   
end