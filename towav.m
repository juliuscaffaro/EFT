    function towav(entry)
    midi = readmidi(strcat(entry, '.mid'));
    [y,Fs] = midi2audio(midi, 44100, 'fm');
    wavwrite(y, Fs, strcat(entry, '.wav'));
end