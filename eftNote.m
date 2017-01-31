function ret=eftNote(time, cand)
	lengthTime = length(time) - 1;
    ampMaior = 0;
    for i=1:length(cand)
        soma = 0;    
        freq = cand(i,2);
        for n=0:lengthTime,                        
            termo = (time(n + 1)) * exp((-1i*(freq)*(n)*(2)*pi)/lengthTime);                        
            soma = round(soma*1000)/1000 + round(termo*1000)/1000;
        end          
        vetTeste(i) = soma;
        if abs(soma) > ampMaior
            ret = i;  
            ampMaior = abs(soma);
        end
    end       
end

