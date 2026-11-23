% PASSAGE_ECHELLE Taille de l'index et temps de recherche selon le nombre de morceaux.
%   Base de 1 000 morceaux : les 104 de la base + 896 autres de fma_small.
%   Les clés de chaque morceau sont extraites une seule fois (enregistrées dans
%   resultats/cles_1000.mat), puis les index de N morceaux sont assemblés.
clear, close all

rng(13)
Ns = [13 26 52 104 250 500 1000];
duree_q = 5;
s_thr = 21;

base = readtable('resultats/liste_base.csv', 'TextType', 'string', 'Delimiter', ',');
neg = readtable('resultats/liste_negatives.csv', 'TextType', 'string', 'Delimiter', ',');

% --- Les 1 000 morceaux : la base (dans un ordre aléatoire) puis 896 autres
if isfile('resultats/cles_1000.mat')
    load('resultats/cles_1000.mat')
else
    T = readtable('../fma/fma_small_genres.csv', 'TextType', 'string', 'Delimiter', ',');
    T.chemin = "../fma/" + T.chemin;
    exclus = [98565 98567 98569 99134 108925 133297];        % fichiers trop courts connus
    autres = T(~ismember(T.id, [base.id; neg.id; exclus']), :);
    autres = autres(randperm(height(autres), max(Ns) - height(base)), :);
    chemins = [base.chemin(randperm(height(base))); autres.chemin];

    cles_m = cell(numel(chemins), 1);
    m1_m = cell(numel(chemins), 1);
    tic
    for i = 1:numel(chemins)
        try
            [x, Fe] = pretraitement(chemins(i));
            [c, m1] = extraction(x, Fe);
            cles_m{i} = uint32(c);                  % entiers sur 4 octets : fichier plus petit
            m1_m{i} = uint32(m1);
        catch
            fprintf('illisible : %s\n', chemins(i))  % morceau gardé, mais sans clé
            cles_m{i} = zeros(0, 1, 'uint32');
            m1_m{i} = zeros(0, 1, 'uint32');
        end
        if mod(i, 100) == 0, fprintf('%d / %d  (%.0f s)\n', i, numel(chemins), toc); end
    end
    temps_extraction_par_morceau = toc / numel(chemins)
    save('resultats/cles_1000.mat', 'chemins', 'cles_m', 'm1_m', 'temps_extraction_par_morceau')
end

% --- Les requêtes (les mêmes pour toutes les tailles de base)
% positives : 2 extraits de 5 s de chacun des 13 premiers morceaux (présents dans tous les index)
% négatives : 1 extrait de 26 morceaux de la liste des négatives (absents de tous les index)
req_fichiers = [repelem(chemins(1:13), 2); neg.chemin(1:26)];
req_vrai = [repelem((1:13)', 2); zeros(26, 1)];
Q = numel(req_fichiers);
req_cles = cell(Q, 1);
req_m1 = cell(Q, 1);
for r = 1:Q
    [x, Fe] = pretraitement(req_fichiers(r));
    L = duree_q * Fe;
    debut = floor(rand * (length(x) - L));
    [req_cles{r}, req_m1{r}] = extraction(x(debut + 1 : debut + L), Fe);
end

% --- Pour chaque taille de base
nb = numel(Ns);
nb_entrees = zeros(nb, 1);
taille_Mo = zeros(nb, 1);
temps_assemblage_s = zeros(nb, 1);
temps_requete_ms = zeros(nb, 1);
TBD = zeros(nb, 1);
TFD = zeros(nb, 1);
median_pos = zeros(nb, 1);
max_neg = zeros(nb, 1);
pos = req_vrai > 0;

for n = 1:nb
    tic
    index = assembler_index(cles_m(1:Ns(n)), m1_m(1:Ns(n)), cellstr(chemins(1:Ns(n))));
    temps_assemblage_s(n) = toc;
    nb_entrees(n) = numel(index.id);
    infos = whos('index');
    taille_Mo(n) = infos.bytes / 1e6;

    score_max = zeros(Q, 1);
    id_max = zeros(Q, 1);
    tic
    for r = 1:Q
        scores = rechercher(req_cles{r}, req_m1{r}, index);
        [score_max(r), id_max(r)] = max(scores);
    end
    temps_requete_ms(n) = 1000 * toc / Q;

    TBD(n) = 100 * mean(id_max(pos) == req_vrai(pos) & score_max(pos) >= s_thr);
    TFD(n) = 100 * mean(score_max(~pos) >= s_thr);
    median_pos(n) = median(score_max(pos));
    max_neg(n) = max(score_max(~pos));
    fprintf('N = %4d : %.1f ms par requete\n', Ns(n), temps_requete_ms(n))
end

N = Ns';
resultats = table(N, nb_entrees, taille_Mo, temps_assemblage_s, temps_requete_ms, ...
                  TBD, TFD, median_pos, max_neg)
save('resultats/passage_echelle.mat', 'resultats')

% --- Figure : taille et temps en fonction de N (échelles logarithmiques)
figure
subplot(1, 2, 1)
loglog(N, taille_Mo, 'o-', 'LineWidth', 1.5), grid on
xlabel('nombre de morceaux N'), ylabel('taille de l''index (Mo)')
title('Taille de l''index')
subplot(1, 2, 2)
loglog(N, temps_requete_ms, 'o-', 'LineWidth', 1.5), grid on
xlabel('nombre de morceaux N'), ylabel('temps par requête (ms)')
title('Temps de recherche')
saveas(gcf, 'resultats/passage_echelle.png')

% =========================================================================
function index = assembler_index(cles_m, m1_m, noms)
% Même assemblage que construire_index, à partir de clés déjà extraites.
toutes_cles = double(vertcat(cles_m{:}));
tous_instants = double(vertcat(m1_m{:}));            % double : sinon les soustractions saturent
tous_id = repelem((1:numel(cles_m))', cellfun(@numel, cles_m));
[toutes_cles, ordre] = sort(toutes_cles);
index.id = tous_id(ordre);
index.instant = tous_instants(ordre);
[index.cles, index.debut] = unique(toutes_cles, 'first');
index.nombre = diff([index.debut; numel(toutes_cles) + 1]);
index.noms = noms;
end