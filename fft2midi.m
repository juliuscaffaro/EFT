function result = fft2midi(filename, sampleFrame)
if (nargin<2)
    sampleFrame = 11025; %  Bloco de frames, analisando sempre 0,25 segundos
end


[sample,Fs,bits] = wavread(strcat(filename, '.wav'));
sampleLength = length(sample);
lengthTime = sampleLength / Fs;
pointer = 1;
midiTable = zeros(3, (mean(sampleLength / sampleFrame)));
N = 1;
ampNotaAnterior = 0;
noteAnterior = 0;
ampNotaAttack = 0;

while pointer + sampleFrame - 1 <= sampleLength
    x = sample(pointer:pointer + sampleFrame - 1);   
    xFreq = fft(x);    
    xFreq = xFreq(1:length(xFreq)/2);    
    ampMaior = 0;
    note = 0;
%     
     for i=1:length(xFreq)        
%         if abs(xFreq(i)) > ampMaior
%             note = i;
%             ampMaior = abs(xFreq(i));  
%         en
        XHarm = abs(xFreq(i));
        for j=2:4
            if (j*i<length(xFreq))
                XHarm = XHarm+abs(xFreq(j))/j;
            end
        end
        if XHarm > ampMaior
            note = i;
            ampMaior = XHarm;  
        end
    end
    
    note = freq2note((note * Fs) / sampleFrame);
    ampNotaAtual = mean(abs(x));    
    
    
    %   Note off, jah tratando o final da musica
	if (((pointer + sampleFrame) * lengthTime) / sampleLength) <= lengthTime
        noteOff = (((pointer + sampleFrame) * lengthTime) / length(sample));
	else
        noteOff = lengthTime;
    end
    
        
% Se nao for uma pausa
    if ampNotaAtual >= ampNotaAttack  / 4 
%     Se a amplitude da nota que eu to capturando agora eh maior que a que
%     eu capturei antes, eu vou considerar que a nota eh diferente
        if noteAnterior ~= note && (ampNotaAtual >= ampNotaAnterior - 0.005) 
            ampNotaAttack = ampNotaAtual;
            %     Nota    
            midiTable(N, 1) = note;                
            %   aqui, utilizaremos a media da amplitude e modificaremos para a escala 0:127, como temos valores -32768 - 32767 
            %   para representar a amplitude, e o zero equivale ao 64, estamos fazendo esta conversao          
            midiTable(N, 2) = 64 - floor(ampNotaAtual / 512);      
            %   Note on
            midiTable(N, 3) = (((pointer) * lengthTime) / length(sample));
    %         Note off
            midiTable(N,4) = noteOff;
            N = N + 1;    
            noteAnterior = note;
        else %interpreto que eh a mesma nota        
            midiTable(N - 1, 4) = noteOff;        
        end          
    end

    ampNotaAnterior = ampNotaAtual;
    pointer = pointer + sampleFrame;
end

% initialize matrix:
% number of notes
M = zeros(N - 1,6);

M(:,1) = 1;         % all in track 1
M(:,2) = 1;         % all in channel 1
M(:,3) = midiTable(:,1);      % note numbers: one ocatave starting at middle C (60)
M(:,4) = midiTable(:,2);  % lets have volume ramp up 80->120
M(:,5) = midiTable(:,3);  % note on:  notes start every .5 seconds
M(:,6) = midiTable(:,4);   % note off: each note has duration .5 seconds

midi_new = matrix2midi(M);
writemidi(midi_new, strcat(filename, 'fft.mid'));

result = strcat('criado o midi do ', filename);
end    