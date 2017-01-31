sampleFrame = 8192;
[sample,Fs,bits] = wavread('orgao.wav');
x = sample(1:sampleFrame);
pointer = sampleFrame;
while pointer <= length(sample)
%---------------------------------Do Matlab

    nfft = 8192;
    Xmat = fft(x,nfft);
    Xmat = Xmat(1:nfft/2);
    mx = abs(Xmat);
    %funcao de vetor, eh o input do plot(o y do eixo
    f = (0:nfft/2 - 1)*Fs/nfft; 
    figure(1);
    plot(f,mx);

%---------------------------Meu DFT

%{
XMeuDft = dft(x);
nfft = length(XMeuDft);
f = (0:nfft/2 - 1)*Fs/nfft;
figure(2);
plot(f, abs(XMeuDft(1:length(XMeuDft)/2)));
%}


%---------------------------MEU DFT exponencial


    XMeuFreq = dftfreq(x);
    figure(3);
    plot(abs(XMeuFreq));
    pointer = pointer + sampleFrame;
end
%nfft = length(XMeuFreq);
%f = (0:nfft/2 - 1)*Fs/nfft;
%figure(3);
%plot(f, abs(XMeuFreq(1:length(XMeuFreq)/2)));


%figure(2);
%plot(f,abs(Xmeu(1:nfft)), 'color', 'r');
%figure(3);
%plot(f,abs(XinvMat(1:2500)), 'color', 'g');hold on;
%plot(f,abs(XinvMeu(1:2500)), 'color', 'r');
%figure(4);
%plot(f,abs(Xmat(1:2500)), 'color', 'g');hold on;
%plot(f,abs(Xmeu(1:2500)), 'color', 'r');