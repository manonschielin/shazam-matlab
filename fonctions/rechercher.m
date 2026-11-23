function [scores, decalages] = rechercher(cles_q, m1_q, index)
% RECHERCHER Score de chaque morceau de l'index pour un extrait.
%   [scores, decalages] = rechercher(cles_q, m1_q, index)
%   cles_q, m1_q : clés et instants d'ancre de l'extrait (sortie de extraction)
%   scores(s)    : nombre de clés alignées sur le meilleur couple de décalages (δ, δ+1)
%   decalages(s) : décalage (en trames) de ce pic
%   Version sans boucle : un seul histogramme 2D (morceau x décalage).

nb_morceaux = numel(index.noms);
scores = zeros(nb_morceaux, 1);
decalages = zeros(nb_morceaux, 1);

[trouve, pos] = ismember(cles_q, index.cles);         % où est chaque clé dans la liste des clés
if ~any(trouve), return, end
p = pos(trouve);
debut = index.debut(p);                               % le bloc de chaque clé trouvée
nombre = index.nombre(p);
m1 = m1_q(trouve);

% Toutes les lignes de tous les blocs, sans boucle
premier = cumsum([0; nombre(1:end-1)]);               % place du début de chaque bloc dans la liste
rang = (1:sum(nombre))' - repelem(premier, nombre);   % 1, 2, ..., nombre dans chaque bloc
lignes = repelem(debut, nombre) + rang - 1;

ids = index.id(lignes);                               % morceau de chaque correspondance
deltas = index.instant(lignes) - repelem(m1, nombre); % décalage de chaque correspondance

% Histogramme 2D : H(s, i) = nombre de clés du morceau s au décalage d0 + i - 1
d0 = min(deltas);
largeur = max(deltas) - d0 + 2;                       % + 1 colonne vide pour la case voisine
H = accumarray([ids, deltas - d0 + 1], 1, [nb_morceaux, largeur], [], [], true);  % matrice creuse
H2 = H(:, 1:end-1) + H(:, 2:end);                     % chaque case + sa voisine de droite
[s, c] = max(H2, [], 2);                              % la paire de cases la plus haute, par morceau
scores = full(s);
decalages = c + d0 - 1;
decalages(scores == 0) = 0;
end