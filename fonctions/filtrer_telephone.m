function [y, b, a] = filtrer_telephone(x, Fe, f_bas, f_haut)
% FILTRER_TELEPHONE Filtre passe-bande simulant un téléphone ou un petit haut-parleur.
%   [y, b, a] = filtrer_telephone(x, Fe) : Butterworth d'ordre 4, bande 300-3400 Hz.
%   b, a : coefficients du filtre (pour tracer sa réponse en fréquence).

if nargin < 3, f_bas = 300; end
if nargin < 4, f_haut = 3400; end

[b, a] = butter(4, [f_bas f_haut] / (Fe/2), 'bandpass');   % fréquences normalisées par Fe/2
y = filter(b, a, x);                                        % filtrage causal, comme un vrai appareil
end