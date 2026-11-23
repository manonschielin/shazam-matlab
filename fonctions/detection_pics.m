function [k, m] = detection_pics(S_dB, dk, dm, marge)
% DETECTION_PICS Maxima locaux du spectrogramme (carte de constellation).
%   [k, m] = detection_pics(S_dB) utilise dk = 5 canaux, dm = 3 trames
%   et une marge de 10 dB au-dessus de la médiane de chaque canal.
%   k : indices de fréquence (lignes), m : indices de trame (colonnes).

if nargin < 2 || isempty(dk), dk = 5; end
if nargin < 3 || isempty(dm), dm = 3; end
if nargin < 4, marge = 10; end

% 1. Maximum local : le point est le plus fort de son voisinage
voisinage = ones(2*dk + 1, 2*dm + 1);                 % rectangle canaux x trames
S_max = ordfilt2(S_dB, numel(voisinage), voisinage, 'symmetric');   % max du voisinage
est_max = (S_dB == S_max);

% 2. Seuil local : le point dépasse le fond de son canal d'au moins "marge" dB
seuil = median(S_dB, 2) + marge;                      % un seuil par canal (colonne 513 x 1)
assez_fort = (S_dB > seuil);                          % comparé ligne par ligne

[k, m] = find(est_max & assez_fort);                  % les deux conditions à la fois
end