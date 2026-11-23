% CAMPAGNE_TELEPHONE Série d'enregistrements au micro, la musique étant jouée
%   par un téléphone à une distance donnée. 4 morceaux connus x 2 positions
%   (1:00 et 2:00) = 8 essais, les mêmes à chaque distance.
clear, close all

distance_cm = 700;                              % à changer : 100 puis 700
duree = 10;
s_thr = 26;                                     % seuil adapté pour 10 s
positions_s = [60 120];                         % où lancer le morceau sur le téléphone

load('resultats/index_demo.mat')
nb = numel(index.titres);
connus = nb-3 : nb;                             % les 4 morceaux connus sont à la fin de l'index
noms_courts = {'pyramids', 'creep', 'dracula', 'roses'};

[J, P] = meshgrid(1:4, 1:numel(positions_s));   % tous les couples (morceau, position)
n = numel(J);
morceau = strings(n, 1);
position_s = zeros(n, 1);
score_vrai = zeros(n, 1);
meilleur_autre = zeros(n, 1);
trouve = false(n, 1);
position_trouvee_s = NaN(n, 1);

rec = audiorecorder(44100, 16, 1);
for r = 1:n
    j = J(r);
    i = connus(j);
    morceau(r) = string(index.titres{i});
    position_s(r) = positions_s(P(r));
    fprintf('\n%d / %d : lance « %s » à %d:%02d sur le téléphone, puis appuie sur Entrée.', ...
            r, n, morceau(r), floor(position_s(r)/60), mod(position_s(r), 60))
    input('');
    recordblocking(rec, duree);
    y = getaudiodata(rec);
    fichier = sprintf('audio/enregistrements/tel_%s_d%03dcm_t%03d.wav', ...
                      noms_courts{j}, distance_cm, position_s(r));
    audiowrite(fichier, y, 44100);

    [x, Fe] = pretraitement(fichier);
    [cles, m1] = extraction(x, Fe);
    [scores, decalages] = rechercher(cles, m1, index);
    id = decider(scores, index, s_thr);

    score_vrai(r) = scores(i);
    autres = scores;
    autres(i) = [];
    meilleur_autre(r) = max(autres);
    trouve(r) = (id == i);
    if trouve(r)
        position_trouvee_s(r) = decalages(i) * 512 / Fe;    % où on est dans le morceau
    end
    fprintf('   score %d, meilleur autre %d, crête %.2f -> %s\n', ...
            score_vrai(r), meilleur_autre(r), max(abs(y)), string(trouve(r)))
end

T = table(morceau, position_s, score_vrai, meilleur_autre, trouve, position_trouvee_s)
TBD_pourcent = 100 * mean(trouve)
score_median = median(score_vrai)
save(sprintf('resultats/telephone_d%03dcm.mat', distance_cm), 'T', 'distance_cm')