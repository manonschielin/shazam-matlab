% TEST_MICRO Vérifie que MATLAB enregistre bien depuis le micro : 5 s à 44,1 kHz,
%   niveau du signal, forme d'onde et spectrogramme.
clear, close all

Fe_rec = 44100;                                 % fréquence d'enregistrement
duree = 5;

infos = audiodevinfo;                           % les micros vus par MATLAB
disp('Micros disponibles :')
disp({infos.input.Name}')

rec = audiorecorder(Fe_rec, 16, 1);             % 16 bits, 1 voie, micro par défaut
disp('Enregistrement : parle ou tape dans tes mains pendant 5 s...')
recordblocking(rec, duree);
disp('Fini.')
y = getaudiodata(rec);

crete = max(abs(y))                             % entre 0 et 1 ; proche de 1 = saturation
niveau_dBFS = 10*log10(mean(y.^2) + 1e-20)      % puissance moyenne, 0 dB = plein niveau

audiowrite('audio/enregistrements/test_micro.wav', y, Fe_rec);

% Même chaîne que pour les morceaux
[x, Fe] = pretraitement('audio/enregistrements/test_micro.wav');
[S_dB, f, t] = spectrogramme(x, Fe);

figure
subplot(2, 1, 1)
plot((0:length(y)-1) / Fe_rec, y), grid on
xlabel('temps (s)'), ylabel('amplitude'), title('Signal enregistré')
subplot(2, 1, 2)
imagesc(t, f, S_dB), axis xy, colorbar
xlabel('temps (s)'), ylabel('fréquence (Hz)'), title('Spectrogramme (après prétraitement)')