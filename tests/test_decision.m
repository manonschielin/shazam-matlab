% Test de decider : requêtes positives (dans la base) et négatives (Roses, absent)
clear, close all

load('resultats/index_3_morceaux.mat')
requetes = {'audio/Pyramids.mp3', 60;  'audio/Creep.mp3', 30;  'audio/Dracula.mp3', 45; ...   % positives
            'audio/Roses.mp3', 30;     'audio/Roses.mp3', 90;  'audio/Roses.mp3', 150};       % négatives

for r = 1:size(requetes, 1)
    [x, Fe] = pretraitement(requetes{r, 1});
    debut = requetes{r, 2};
    extrait = x(debut*Fe + 1 : (debut+10)*Fe);
    [cles_q, m1_q] = extraction(extrait, Fe);

    scores = rechercher(cles_q, m1_q, index);
    [id, nom] = decider(scores, index);

    fprintf('%-19s à %3d s : meilleur score = %4d  ->  réponse = %s\n', ...
        requetes{r, 1}, debut, max(scores), nom);
end