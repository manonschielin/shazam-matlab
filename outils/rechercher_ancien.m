function [scores, decalages] = rechercher(cles_q, m1_q, index)
% RECHERCHER Score de chaque morceau de l'index pour un extrait.
%   [scores, decalages] = rechercher(cles_q, m1_q, index)
%   cles_q, m1_q : clés et instants d'ancre de l'extrait (sortie de extraction)
%   scores(s)    : nombre de clés alignées sur le meilleur couple de décalages (δ, δ+1)
%   decalages(s) : décalage (en trames) de ce pic

nb_morceaux = numel(index.noms);
[trouve, pos] = ismember(cles_q, index.cles);         % où est chaque clé dans la liste des clés

ids = [];                                             % morceau de chaque correspondance
deltas = [];                                          % décalage de chaque correspondance
for i = find(trouve)'
    lignes = index.debut(pos(i)) : index.debut(pos(i)) + index.nombre(pos(i)) - 1;   % tout le bloc
    ids = [ids; index.id(lignes)];
    deltas = [deltas; index.instant(lignes) - m1_q(i)];
end

scores = zeros(nb_morceaux, 1);
decalages = zeros(nb_morceaux, 1);
for s = 1:nb_morceaux
    d = deltas(ids == s);                             % décalages trouvés pour le morceau s
    if ~isempty(d)
        h = accumarray(d - min(d) + 1, 1);            % histogramme : h(i) = nombre de clés au décalage min(d)+i-1
        h2 = h + [h(2:end); 0];                       % chaque case + sa voisine de droite
        [scores(s), p] = max(h2);                     % la paire de cases la plus haute
        decalages(s) = p + min(d) - 1;                % décalage de la première case de la paire
    end
end
end

