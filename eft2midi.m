function result = eft2midi(filename, sampleFrameSize)
if (nargin<2)
    sampleFrameSize = 11025; %  Bloco de frames, analisando sempre 0,25 segundos    
end

% deltaSF = 0;
deltaSF = sampleFrameSize / 2;
[sample,Fs] = wavread(strcat(filename, '.wav'));
sampleLength = length(sample);
lengthTime = sampleLength / Fs;
pointer = 1;
midiTable = zeros(3, (mean(sampleLength / sampleFrameSize)));
N = 1;
ampNotaAnterior = 0;
noteAnterior = 0;
ampNotaAttack = 0;

% toc deste cara = 0.22 segundos
tic
% ------------------------janelamento para atenuar o inicio da janela
% windowFunction = zeros([1 sampleFrameSize]);
% for i=1:sampleFrameSize
%     windowFunction(i) = log((i/sampleFrameSize) + 1);
% end
% ------------------------janelamento de hanning
tab = [0,0,0,0,0,0,0,0,0];
windowFunction = hanning(11025 * 2);

while pointer + sampleFrameSize <= sampleLength
    ((pointer) * lengthTime) / length(sample)
    inicioSF = pointer - deltaSF;
    if inicioSF <= 0        
        inicioSF = 1;
    end

	if pointer == 1        
        finalSF = sampleFrameSize;
    else
        finalSF = pointer + sampleFrameSize + deltaSF - 1;    
        if finalSF > sampleLength
            finalSF = sampleLength;
        end
	end
    x = sample(inicioSF:finalSF);
    
	if length(windowFunction) ~= length(x)
        windowFunction = hanning(length(x));
	end
    
%     if pointer ~= 1  
        x = x .* windowFunction';
%     end
    xFreq = abs(eft(x));   
% 	note = find(xFreq == max(xFreq), 1);
%  	ampMaior = xFreq(note);      
    vetHarm = length(xFreq);
    
% %     Media ponderada entre harmonicas-------------------------------------
%       for i=1:length(xFreq)        
%           XHarm = abs(xFreq(i));
%           if ((i + 12)<length(xFreq))
%               XHarm = XHarm+abs(xFreq((i + 12)))/2;
%           end
%           if ((i + 19)<length(xFreq))
%               XHarm = XHarm+abs(xFreq((i + 19)))/3;
%           end
%           if ((i + 24)<length(xFreq))
%               XHarm = XHarm+abs(xFreq((i + 24)))/4;
%           end        
%   
%           vetHarm(i) = XHarm;
%       end
%     Media ponderada entre harmonicas-------------------------------------
%     Media -------------------------------------    

     for i=1:length(xFreq)        
         XHarm = abs(xFreq(i));
         contador = 1;
         if ((i + 12)<length(xFreq))
             contador = contador + 1;
             XHarm = XHarm+abs(xFreq((i + 12)));
         end
         if ((i + 19)<length(xFreq))
             contador = contador + 1;
             XHarm = XHarm+abs(xFreq((i + 19)));
         end
         if ((i + 24)<length(xFreq))
             contador = contador + 1;
             XHarm = XHarm+abs(xFreq((i + 24)));
         end
         if ((i + 28)<length(xFreq))
             contador = contador + 1;
             XHarm = XHarm+abs(xFreq((i + 28)));
         end
         vetHarm(i) = XHarm / contador;
     end    
%     Media -------------------------------------    
    note = freq2note((midi2Freq(find(vetHarm == max(vetHarm), 1)) * Fs) / sampleFrameSize);      
    ampNotaAtual = mean(abs(x));
% TESTE(comentar as duas linhas acima)---------------------------------------------------------------    
%     teste = xFreq;
%     teste(note) = 0;    
%     note2 = find(teste == max(teste), 1);
%     amp2 = teste(note2);
%     teste(note2) = 0;
%     note3 = find(teste == max(teste), 1);
%     amp3 = teste(note3);
%     teste(note3) = 0;
%     note4 = find(teste == max(teste), 1);
%     amp4 = teste(note4);
%     
%     note = (midi2freq(note) * Fs) / (sampleFrameSize + deltaSF);
%     note = freq2note(note);
%     
%     note2 = (midi2freq(note2) * Fs) / (sampleFrameSize + deltaSF);
%     note2 = freq2note(note2);
%     
%     note3 = (midi2freq(note3) * Fs) / (sampleFrameSize + deltaSF);
%     note3 = freq2note(note3);
%     
%     note4 = (midi2freq(note4) * Fs) / (sampleFrameSize + deltaSF);
%     note4 = freq2note(note4);
%     tab = [tab; [(((pointer) * lengthTime) / length(sample)), note, ampMaior, note2, amp2, note3, amp3, note4, amp4]];    
%     note = freq2note((midi2Freq(note) * Fs) / sampleFrameSize);      
%     ampNotaAtual = mean(abs(x));
% TESTE---------------------------------------------------------------    
    
    
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
filenameRet = strcat(filename, 'eftcommedia');
writemidi(midi_new, strcat(filenameRet, '.mid'));
result = strcat('criado o midi do ', filenameRet);
towav(filenameRet);
end    