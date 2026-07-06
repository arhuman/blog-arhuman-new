+++
title = "Réaliser le rêve d'une IA"
type = "post"
date = '2026-05-30T02:00:07+01:00'
categories = ["Article"]
tags = ["AI","Mnemos"]
+++

On ne va pas parler ici d'altruisme, je n'ai aucune intention d'offrir à mon modèle un datacenter ou l'accès à toutes les connaissances humaines (ça d'autres s'en chargent déjà).

Quand je dis "réaliser", je le pense au sens littéral: comment implémenter la fonction de rêver pour un modèle ?

Mais pour comprendre pourquoi et comment je suis arrivé à cette hypothèse de conception, il faut revenir en arrière.

## La mémoire n’est pas du stockage

Tout part d'un travail sur la mémoire à long terme des agents que j'essaie d'implémenter via l'outil Open Source Mnemos[^1].

Le stockage des informations se fait via un bundle OKF[^2] local qui représente les connaissances.

Et comme la mémoire ne se limite pas au stockage, Mnemos offre aussi la possibilité d'enrichir/chercher/rappeler ces connaissances à travers un serveur MCP et un outil ligne de commande.

L'ensemble fonctionne (facilité par l'usage d'un skill) mais rapidement on se heurte à un problème : l'ajout de connaissance dégrade l'efficacité de la mémoire.

Une base de connaissances qui ne fait qu’accumuler devient une archive.
Comment transformer des informations dispersées en connaissances utiles ?

Une vraie mémoire doit structure sa connaissance, la "consolider".

## OKF et le problème de la consolidation

Le format OKF permet déjà de structurer les connaissances :

- Une structure minimaliste exploitable (frontmatter)
- La gestion de la sémantique (tags, liens)
- Le regroupement d'informations (index, références)
- Un format lisible par les humains et les agents (extension du Markdown)

Mais si l’ajout, la suppression et la recherche sont automatisables, la réorganisation, le nettoyage des informations obsolètes et la déduplication, bref la consolidation, restent manuels.

Or, si j'ai conçu Mnemos, c'est précisément pour automatiser la gestion de la connaissance :

* Je n'aime pas écrire les choses deux fois.
* Je n'aime pas noter le statut de tous les projets que je gère à la main.
* J'aime que mon outil gère automatiquement mes connaissances et le souvenir de ce que j'ai fait.

Mais comment automatiser une opération aussi sensible que la consolidation ?

## La pièce manquante : une fonction d’évaluation

La difficulté de la consolidation n’est pas d’abord technique. Fusionner deux notes, créer un lien, supprimer une information obsolète ou extraire une règle générale sont des opérations relativement simples à implémenter.

Le vrai problème est ailleurs : comment savoir si une transformation améliore la mémoire ou la dégrade ?

Fusionner deux idées proches est utile si ce sont des doublons, mais destructeur si ce sont deux nuances importantes.

Invalider une connaissance est nécessaire si elle est réellement obsolète, mais préjudiciable si elle reste vraie dans certains contextes.

Créer une association entre deux concepts est puissant si le lien est réel, mais toxique si ce n’est qu’une hallucination structurée.

Autrement dit, une mémoire qui consolide sans fonction d’évaluation ne devient pas plus intelligente. Elle se dilue.

Et c’est là que mon problème initial revient par la fenêtre.

Si Mnemos me propose des consolidations, je dois les relire, les juger, les accepter, les corriger ou les refuser. Je viens donc de me rajouter du travail alors que je cherchais précisément à m’en enlever.

Ma mémoire automatique risque alors de devenir un partenaire énergivore : utile, mais incapable d’évoluer sans validation humaine permanente.

Il manque donc une pièce centrale : une fonction d’évaluation capable d’estimer, même imparfaitement mais **automatiquement**, si une transformation de connaissance mérite d’être appliquée, proposée, différée ou rejetée.


## De la validation explicite au feedback comportemental

La paresse étant la première vertu du programmeur[^3], je me suis demandé comment déléguer cette évaluation.
Ou plutôt : peut-on valider sans solliciter l'utilisateur ?

Il apparaît que oui, au moins partiellement, en observant l'usage :
* L'utilisateur corrige le résultat d'une consolidation => confiance baisse ou contenu modifié
* L'utilisateur réutilise un résultat d'une association => lien renforcé
* L'utilisateur contredit explicitement une fusion => invalidation 
* ...


Pour chaque proposition de consolidation la fonction d'évaluation peut être :
* Exposition à l’utilisateur
* Observation du comportement
* Ajustement de la "certitude" mémoire

L'utilisateur ne valide pas explicitement, c'est son comportement qui le fait plus ou moins.
Vous vous en doutez : le comportement ne donne pas une vérité absolue.
Il donne un signal de pertinence, de friction, de valeur ou d’usage.

## L’intuition du rêve : l’émotion comme signal d’apprentissage

C’est en cherchant à comprendre comment le cerveau valide ses propres consolidations sans nous solliciter constamment que j’ai eu cette intuition :  

Le rêve pourrait bien être cette boucle offline où le cerveau génère des associations, recombine des souvenirs et simule des scénarios inédits, en utilisant nos réactions émotionnelles comme baromètre d’évaluation.  

Cette hypothèse rejoint d’ailleurs les travaux récents en neurosciences sur le sommeil paradoxal. Ceux-ci montrent que le rêve joue un rôle clé dans la consolidation de la mémoire et la réorganisation des réseaux neuronaux, notamment via des mécanismes de relecture et de simulation[^4]. Cependant, ils expliquent encore peu *comment* le cerveau évalue la pertinence des nouvelles associations formées. Mon intuition, à prendre comme une analogie de conception plus que comme une affirmation neuroscientifique, est que la charge émotionnelle du rêve pourrait jouer un rôle proche d’un signal d’évaluation.

Et, du point de vue de l’implémentation, cette analogie n’est pas seulement poétique. Elle suggère trois contraintes très concrètes :

* la consolidation doit se faire au repos, pendant les temps morts ;
* elle doit utiliser des mécanismes différents de ceux mobilisés en usage normal, avec moins de contraintes immédiates ;
* elle ne doit pas générer de retour direct à l’utilisateur, ni surtout exiger une action de sa part.

*Autrement dit pour un agent, rêver ne consiste pas à halluciner davantage. Cela consiste à produire des hypothèses de mémoire pendant les temps morts, sans déranger l’utilisateur, puis à ne garder que celles que l’usage confirme.*

## Comment Mnemos pourrait rêver

Pour Mnemos, “rêver” signifierait donc une chose très concrète : consolider la mémoire hors interaction directe, en générant des transformations de connaissance, puis en les évaluant avant de les appliquer.

Cette boucle peut se décomposer en cinq étapes :

1. Sélectionner des connaissances candidates.

Mnemos sélectionne d'abord certaines connaissances : anciennes, peu utilisées, redondantes, contradictoires, trop isolées, ou au contraire souvent rappelées ensemble.

2. Générer des transformations.

* fusionner deux notes proches
* créer un lien entre deux concepts
* invalider une connaissance devenue obsolète
* renforcer une association souvent réutilisée
* extraire une règle générale à partir de plusieurs cas
* séparer deux idées artificiellement collées

Mais aucune de ces transformations n'est appliquée directement.

3. Évaluer chaque transformation selon plusieurs signaux.

Chaque transformation doit passer par une fonction d'évaluation.

L'évaluation d'une consolidation repose sur un faisceau d'indices : l'usage (l'utilisateur réutilise-t-il ce lien ?), la friction (le corrige-t-il ?), la cohérence sémantique, l'âge de l'information, et les éventuelles contradictions. Chaque indice est un signal faible. Aucun ne dit la vérité absolue, mais leur combinaison donne un niveau de confiance.

Concrètement, un lien réutilisé plusieurs fois et jamais contredit verra sa confiance augmenter. Un lien ignoré ou corrigé la verra baisser. La mémoire devient ainsi un système d'hypothèses vivantes, pas une vérité figée.

4. Appliquer, proposer, différer ou rejeter.

À partir de là, Mnemos ne décide pas brutalement. Il pondère.

Une transformation très bien sourcée, cohérente, réutilisée plusieurs fois et jamais contredite peut être appliquée automatiquement.

Une transformation plausible mais incertaine peut être proposée à l'utilisateur.

Une transformation faible peut être différée.

Une transformation contredite ou créatrice de friction peut être invalidée.

5. Observer l'usage futur pour ajuster la confiance.

Les interactions futures de l'utilisateur avec les transformations sont automatiquement évaluées.
(Pour les étapes 3 et 4)

Le modèle est simple; sa difficulté n’est pas conceptuelle, mais dans le réglage.
Une mémoire trop prudente ne consolide rien. Une mémoire trop agressive se raconte des histoires.

Le rêve utile se situe probablement entre les deux : assez libre pour générer des associations nouvelles, assez conservateur pour ne pas transformer une archive en hallucination organisée.

Mais ouvrir la porte aux hypothèses, c'est aussi ouvrir la porte aux dérives.

## Risques, et garde-fous

Car le premier risque avec un agent est de le voir se raconter des histoires, et la consolidation est une usine à idées/connaissances qui peut vite produire, si on n'y prend pas garde :
- fausses associations
- surinterprétation du comportement
- consolidation prématurée
- biais renforcés
- confusion entre préférence stable et humeur passagère

Pour contrer cette dérive, le garde-fou principal réside dans la nature même du format OKF : le rêve ne doit jamais écraser l'histoire. En pratique, chaque consolidation génère une révision ou un embranchement plutôt qu'une modification destructrice. Tant qu'une transformation n'a pas atteint un score de confiance absolu par l'usage, l'ancienne version reste disponible en arrière-plan. C'est une approche "Copy-on-Write" appliquée à la connaissance : on s'autorise à imaginer, mais on s'interdit d'effacer sans certitude.

Ensuite, la fonction d'évaluation doit agir comme un censeur sévère. Au-delà d'un réglage de température très bas lors de la phase de génération, l'astuce consiste à introduire une asymétrie volontaire : il doit être dix fois plus difficile pour une hypothèse d'être validée automatiquement que d'être rétrogradée au moindre signal de friction de l'utilisateur. En cas de doute sémantique, Mnemos doit préférer le statu quo d'une archive rigide à la fluidité d'une hallucination cohérente.

## Conclusion

Vous l’aurez compris, ce "rêve d’IA" n’en est encore qu’à ses prémices.

Mais l’intuition me semble suffisamment féconde pour mériter d’être explorée. Une mémoire utile ne se contente pas de conserver : elle réorganise, oublie, relie et consolide.

La prochaine étape sera une première implémentation mesurable.

Il serait dommage que le rêve d’une IA ne reste qu'une abstraction poétique, quand il pourrait devenir une capacité concrète : transformer, pendant les temps morts, une archive de souvenirs en mémoire vivante.


[^1]: [Mnemos](https://github.com/arhuman/mnemos) 
[^2]: [OKF](https://github.com/GoogleCloudPlatform/knowledge-catalog/tree/main/okf) Open Knowledge Format : Extension de Markdown qui permet de représenter les connaissances.
[^3]: ["We will encourage you to develop the three great virtues of a programmer: laziness, impatience, and hubris." -- Larry Wall, ProgrammingPerl](https://threevirtues.dev/)
[^4]: Lendner, J. D., Niethard, N., Mander, B. A., van Schalkwijk, F. J., Schuh-Hofer, S., Schmidt, H., Knight, R. T., Born, J., Walker, M. P., Lin, J. J., & Helfrich, R. F. (2023). Human REM sleep recalibrates neural activity in support of memory formation. Science Advances
Zhang, J., Pena, A., Delano, N., Sattari, N., Shuster, A. E., Baker, F. C., Simon, K., & Mednick, S. C. (2024). Evidence of an active role of dreaming in emotional memory processing shows that we dream to forget. Scientific Reports
Rawson, G., & Jackson, M. L. (2024). Sleep and Emotional Memory: A Review of Current Findings and Application to a Clinical Population. Current Sleep Medicine Reports
Rasch, B., & Born, J. (2013). About sleep’s role in memory. Physiological Reviews

