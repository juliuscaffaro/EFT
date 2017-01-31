function [freqRet]=dft(time)
	lengthTime = length(time) - 1;    
    freqRet = zeros(0);
    soma = 0;    
    %tabFreq = [];
    for k=0:lengthTime - 1, 
        for n=0:lengthTime - 1,       
            %soma = soma + termo;            
            %-----------Sem Euller            
            termo = (time(n + 1)) * exp((-1i*(k)*(n)*(2)*pi)/lengthTime);
            %-----------Euller    
            %termo = ((-1*(k - 1)*(n - 1)*2*pi)/lengthTime);
            %sinTermo = 1i * sin(termo);
            %cosTermo = cos(termo);
            %termo = (time(n)*(cosTermo + sinTermo));                        
            soma = round(soma*1000)/1000 + round(termo*1000)/1000;
        end
%        if soma ~= 0
%           disp(sprintf('termo = %d freq = %f', k, abs(soma)));			
%        end             
        freqRet(k + 1) = soma;                    
        soma = 0;
    end
end

