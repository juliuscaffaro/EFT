function result = ffteft2midi(filename, sampleFrameSize)
if (nargin<2)
    sampleFrameSize = 11025; %  Bloco de frames, analisando sempre 0,25 segundos
end


[sample,Fs,bits] = wavread(strcat(filename, '.wav'));
sampleLength = length(sample);
lengthTime = sampleLength / Fs;
pointer = 1;
midiTable = zeros(3, (mean(sampleLength / sampleFrameSize)));
N = 1;
ampNotaAnterior = 0;
noteAnterior = 0;
ampNotaAttack = 0;

tic
while pointer + sampleFrameSize - 1 <= sampleLength
    x = sample(pointer:pointer + sampleFrameSize - 1);   
%----------------------------------------- Aplicando FFT e buscando maiores amplitudes-----------------------------------------    
    xFreq = fft(x);
%     xFreq = fft2(x,sampleFrameSize, 1);
    xFreq = xFreq(1:length(xFreq)/2);
    ampMaior = 0;
    note = 0;
    
    for i=1:length(xFreq)        
        if abs(xFreq(i)) > ampMaior
            note = i;
            ampMaior = abs(xFreq(i));  
        end
    end
    note = freq2note((note * Fs) / sampleFrameSize);
%----------------------------------------- Procurando os candidatos-----------------------------------------    
    notas = [ (note - 24) (note - 19) (note - 12) (note - 7) (note - 1) note (note + 1) (note + 12) (note + 19) (note + 24)];
    candidates = zeros(length(notas),2);
    for i=1:length(notas)
        freqSearch = (27.5*2^((notas(i) - 9)/12)) * sampleFrameSize/Fs;
        candidates(i,:) = [notas(i) freqSearch];
    end
        
    note = candidates(eftNote(x, candidates));
    ampNotaAtual = mean(abs(x));    

%----------------------------------------- Transcrevendo para o MIDI-----------------------------------------        
    
    %   Note off, jah tratando o final da musica
	if (((pointer + sampleFrameSize) * lengthTime) / sampleLength) <= lengthTime
        noteOff = (((pointer + sampleFrameSize) * lengthTime) / length(sample));
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
    pointer = pointer + sampleFrameSize;
end
toc
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
writemidi(midi_new, strcat(filename, 'hibrid.mid'));

result = strcat('criado o midi do ', filename);
end    