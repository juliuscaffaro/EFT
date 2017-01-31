function [X]=fft2(time,N, s)	
    X = zeros(0);            
    if N == 1
        X(1) = time(1);
    else
        Xodds = fft2(time(1:2:N),N/2, 2*s);        
        Xeven = fft2(time(2:2:N),N/2,2*s);        
        for k=1:N/2,
            constExp = exp((-2*pi*1i*k)/N) * Xodds(k);
            X(k) = Xeven(k) +  constExp;
            X(k + (N/2)) = Xeven(k) -  constExp;;            
        end        
    end
end
