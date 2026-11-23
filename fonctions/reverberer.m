function [y, h] = reverberer(x, Fe, T60, DRR_dB)
% REVERBERER Simule la réverbération d'une salle de temps de réverbération T60 (s).
%   [y, h] = reverberer(x, Fe, T60) : réponse impulsionnelle = bruit blanc à
%   décroissance exponentielle (60 dB en T60 secondes), sans son direct (pire cas).
%   [y, h] = reverberer(x, Fe, T60, DRR_dB) ajoute un son direct, avec un rapport
%   d'énergie direct / réverbéré de DRR_dB (0 dB : à 1-2 m d'un haut-parleur).

L = round(T60 * Fe);
t = (0:L-1)' / Fe;
a = 3 * log(10) / T60;                                % décroissance de 60 dB en T60
h = randn(L, 1) .* exp(-a * t);
h = h / norm(h);                                      % réverbération d'énergie 1

if nargin >= 4
    h(1) = h(1) + sqrt(10^(DRR_dB / 10));             % son direct : énergie = 10^(DRR/10)
    h = h / norm(h);                                  % énergie totale 1
end
y = fftfilt(h, x);                                    % convolution rapide (par FFT)
end