function [cles, m1, triplets] = empreintes(k, m, F, dm_min, dm_max, dk_max, dfc)
% EMPREINTES Clés par paires de pics (ancre, cible) dans une zone cible.
%   [cles, m1, triplets] = empreintes(k, m) utilise F = 10 cibles par ancre,
%   une zone de 1 à 24 trames après l'ancre et de +/- 60 canaux, et dfc = 2.
%   cles : une clé entière par paire ; m1 : instant (trame) de l'ancre ;
%   triplets : [Qf(k1), Qf(k2), dm] pour chaque paire.

if nargin < 3 || isempty(F),      F = 10;      end
if nargin < 4 || isempty(dm_min), dm_min = 1;  end
if nargin < 5 || isempty(dm_max), dm_max = 24; end
if nargin < 6 || isempty(dk_max), dk_max = 60; end
if nargin < 7 || isempty(dfc),    dfc = 2;     end

[m, ordre] = sort(m);                                 % pics dans l'ordre du temps
k = k(ordre);

nb = numel(k);
triplets = zeros(nb*F, 3);                            % place réservée pour toutes les paires
m1 = zeros(nb*F, 1);
n = 0;                                                % nombre de paires trouvées

for i = 1:nb                                          % chaque pic est une ancre
    dm = m - m(i);                                    % écarts de temps avec tous les pics
    dk = abs(k - k(i));                               % écarts de fréquence
    cibles = find(dm >= dm_min & dm <= dm_max & dk <= dk_max);   % pics de la zone cible
    cibles = cibles(1:min(F, numel(cibles)));         % les F premiers dans le temps

    for j = cibles'
        n = n + 1;
        triplets(n, :) = [floor((k(i)-1)/dfc), floor((k(j)-1)/dfc), m(j) - m(i)];
        m1(n) = m(i);
    end
end

triplets = triplets(1:n, :);                          % on enlève la place non utilisée
m1 = m1(1:n);

% Un seul nombre entier par triplet (pour l'index inversé plus tard)
cles = (triplets(:,1)*1024 + triplets(:,2)) * (dm_max + 1) + triplets(:,3);
end