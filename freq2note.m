function [MIDI,note]=freq2note(freq)% Umsetzung Frequenzwert in MIDI-Wert und Notename%% Frequenzen werden in der temperierten Stimmung abgerundetMIDI=round(69+12*log2(freq/440));oktave=8-floor((131-MIDI)/12);note_in_oktave=MIDI-12*(oktave+2);switch note_in_oktave	case 0, name='c';	case 1, name='c#';	case 2, name='d';	case 3, name='d#';	case 4, name='e';	case 5, name='f';	case 6, name='f#';	case 7, name='g';	case 8, name='g#';	case 9, name='a';	case 10, name='a#';	case 11, name='b';endnote=[name,' ',num2str(oktave)];