function [vetorteste]=eft(time)
	lengthTime = length(time) - 1;    
    freqRet = zeros([1 lengthTime]);            
    j = 1;    
    K = 2^(1/12);
%     freq = 27.5*2^((j - 9)/12); 
	freq = 27.5*2^(-2/3); 
    vetorteste = ones([1 128]);
    while freq < lengthTime / 2
        soma = 0;        
        for n=0:lengthTime,            
            %soma = soma + termo;            
            %-----------Sem Euller            
            termo = (time(n + 1)) * exp((-1i*(freq)*(n)*(2)*pi)/lengthTime);            
            %-----------Euller    
            %termo = ((-1*(k - 1)*(n - 1)*2*pi)/lengthTime);
            %sinTermo = 1i * sin(termo);
            %cosTermo = cos(termo);
            %termo = (time(n)*(cosTermo + sinTermo));                                          
            soma = round(soma*1000)/1000 + round(termo*1000)/1000;
        end                
        freqRet(round(freq)) = soma; 
        vetorteste(j) = soma;
        j = j + 1;
        freq = freq * K;
    end     
end

