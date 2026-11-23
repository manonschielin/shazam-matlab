function [S_dB, f, t] = spectrogramme(x, Fe, N)
% SPECTROGRAMME Spectrogramme en dB par TFD à court terme (fenêtre de Hann).
%   [S_dB, f, t] = spectrogramme(x, Fe) utilise N = 1024.
%   S_dB : une ligne par fréquence, une colonne par trame.
%   f : fréquences des lignes (Hz), t : instants des colonnes (s).

if nargin < 3
    N = 1024;
end
H = N/2;                                              % avance entre deux trames

[X, f, t] = spectrogram(x, hann(N), N-H, N, Fe);     % TFD de chaque trame

epsilon = 1e-10;                                      % évite log10(0) = -Inf
S_dB = 10*log10(abs(X).^2 + epsilon);                 % on ne garde que le module
end