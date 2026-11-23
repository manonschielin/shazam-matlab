% MAIN Démonstration du système de reconnaissance musicale.
%   Écoute le micro pendant 10 s, reconnaît le morceau dans l'index de démo
%   (104 morceaux FMA + 4 morceaux connus), puis affiche :
%   - le spectrogramme de ce qui a été entendu, avec la constellation de pics ;
%   - les scores de tous les morceaux, avec le seuil de décision ;
%   - l'histogramme des décalages du meilleur morceau (le pic = l'alignement).
%   Tape Entrée pour écouter, q puis Entrée pour quitter.
clear, close all
init_projet

duree = 10;                                     % durée d'écoute (s)
s_thr = 26;                                     % seuil adapté pour 10 s
load('resultats/index_demo.mat')
rec = audiorecorder(44100, 16, 1);
fichier = 'audio/enregistrements/demo.wav';

while true
    reponse = input('\nEntrée pour écouter 10 s, q puis Entrée pour quitter : ', 's');
    if strcmpi(reponse, 'q'), break, end
    disp('J''écoute...')
    recordblocking(rec, duree);
    y = getaudiodata(rec);
    audiowrite(fichier, y, 44100);

    % Reconnaissance : la même chaîne que partout ailleurs
    tic
    [x, Fe] = pretraitement(fichier);
    [cles, m1] = extraction(x, Fe);
    [scores, decalages] = rechercher(cles, m1, index);
    id = decider(scores, index, s_thr);
    temps_calcul = toc;

    [~, meilleur] = max(scores);                % meilleur morceau, même sous le seuil
    if id == 0
        titre = sprintf('Morceau inconnu (meilleur score %d, seuil %d)', scores(meilleur), s_thr);
    else
        pos = decalages(id) * 512 / Fe;         % 1 trame = 512 échantillons = 64 ms
        titre = sprintf('%s   (score %d, à %d:%02d dans le morceau)', ...
                        index.titres{id}, scores(id), floor(pos/60), floor(mod(pos, 60)));
    end
    fprintf('%s   [calcul : %.2f s]\n', titre, temps_calcul)

    % 1) Spectrogramme et constellation (mêmes étapes que dans extraction)
    [S_dB, f, t] = spectrogramme(x, Fe);
    [k, m] = detection_pics(S_dB);
    [k, m] = selection_pics(S_dB, k, m, f, t);

    figure(1), clf
    sgtitle(titre, 'FontWeight', 'bold')
    subplot(2, 2, [1 2])
    imagesc(t, f, S_dB), axis xy, colorbar, hold on
    plot(t(m), f(k), 'wo', 'MarkerSize', 4, 'LineWidth', 1)
    xlabel('temps (s)'), ylabel('fréquence (Hz)')
    title(sprintf('Ce que le micro a entendu : %d pics, %d clés', numel(k), numel(cles)))

    % 2) Scores de tous les morceaux
    subplot(2, 2, 3)
    bar(scores, 'FaceColor', [0.6 0.6 0.6], 'EdgeColor', 'none'), hold on
    bar(meilleur, scores(meilleur), 'FaceColor', [0.85 0.2 0.2], 'EdgeColor', 'none')
    yline(s_thr, 'b--', 'seuil', 'LineWidth', 1.5)
    xlim([0 numel(scores) + 1])
    xlabel('numéro du morceau'), ylabel('score')
    title('Score de chaque morceau de la base')

    % 3) Histogramme des décalages du meilleur morceau
    [trouve, pos_cle] = ismember(cles, index.cles);
    d = [];
    for q = find(trouve)'
        lignes = index.debut(pos_cle(q)) : index.debut(pos_cle(q)) + index.nombre(pos_cle(q)) - 1;
        lignes = lignes(index.id(lignes) == meilleur);           % seulement ce morceau
        d = [d; index.instant(lignes) - m1(q)];
    end
    subplot(2, 2, 4)
    histogram(d * 512 / Fe, 'BinWidth', 512 / Fe, 'FaceColor', [0.85 0.2 0.2])
    if id > 0, xlim(pos + [-20 20]), end   % zoom autour du décalage trouvé
    xlabel('décalage (s)'), ylabel('nombre de clés')
    title(sprintf('Décalages des clés communes avec le n° %d', meilleur))
end