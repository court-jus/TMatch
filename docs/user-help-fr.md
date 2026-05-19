# Triple Match

Le jeu est inspiré de [Triple Town](http://www.tripletown.com/) du studio [Spryfox](http://www.spryfox.com/), vous ne serez donc pas perdu si vous y avez déjà joué.

On ne peut pas gagner, on peut juste essayer de faire le meilleur score possible.

Il y a deux façon de perdre :

- Noyer tous les personnages
- Remplir la zone de jeu jusqu'à ce qu'il n'y ait plus d'eau du tout

A chaque tour, vous devez placer un élément sur une cellule vide. Lorsque vous posez 3 éléments identiques côte à côte, ils se combinent en 1 nouvel élément. C'est grâce à ce mécanisme que vous pouvez empêcher la zone de jeu de se remplir.

A chaque tour, le jeu vous présente un nouvel élément dans la zone "En cours" à gauche. Cliquez dans l'espace de jeu sur la cellule où vous voulez placer cet élément.

La zone "Réserve" sous la zone "En cours" vous permet de conserver un élément que vous ne voulez pas utiliser immédiatement. Cliquez sur la "Réserve" pour y stocker l'élément courant (et récupérer l'élément stocké).

Vous disposez d'autant de réserves différentes qu'il y a de personnages sur le jeu. Cliquez simplement sur un personnage pour afficher sa réserve "personnelle". Pour vous aider, chaque personnage affiche dans une bulle l'élément qu'il "réserve" actuellement.

# Combinaisons

Vous pouvez combiner 3 blocs ou plus en un bloc plus "important". Voici l'ordre de combinaison :

![Combinaisons](../assets/images/BlocksExplanation.png)

# Insectes agaçants

Parfois, vous devez placer des "Insectes". Ils se déplacent librement sur le plateau et vous empêchent de positionner d'autres éléments. Pour les tuer, il suffit de les enfermer dans une zone ne contenant plus aucune cellule libre. Ils se changent alors en diamant vert. Les diamants peuvent se combiner comme les blocs :

![Combinaisons d'insectes](../assets/images/BugsExplanation.png)

# Éléments spéciaux

<img src="../assets/images/matcher.png" width="32" align="left" style="margin-right:8px;"> "L'étoile" est un joker. Elle peut se combiner avec n'importe quel bloc ou n'importe quel diamant. Si deux combinaisons (ou plus) sont possibles, la "plus petite" sera choisie.

<img src="../assets/images/eraser.png" width="32" align="left" style="margin-right:8px;"> La "clé" est une gomme. Elle peut enlever n'importe quel élément.

<img src="../assets/images/Enemy Bug.png" width="32" align="left" style="margin-right:8px;"> Ce bloc est juste là pour vous bloquer. Tout ce que vous pouvez faire, c'est l'enlever grâce à la clé.

# Petits personnsages

Au départ il n'y a que la reine. Un nouveau personnage apparaît à chaque fois que vous réalisez une combinaison de niveau 5 ou plus (planche de bois).

Les personnages se déplacent sur les cellules "hors d'eau". Contrairement aux insectes, ils peuvent se déplacer en diagonale.

Pour chaque personnage sur la zone de jeu, il y a une réserve. Donc plus vous avez de personnages, plus vous pouvez stocker d'éléments pour un usage futur.

Les personnages se noient s'ils se retrouvent sur une cellule d'eau avec aucune possibilité de fuite (attention lorsque vous combinez 3 éléments et qu'un personnage est sur l'un de ces éléments ou lorsque vous supprimez un élément avec la clé).

# Grille de score

| Quand l'élément<br>... est ... | Placé | Combiné | Résultat de<br>combinaison | Détruit |
|---|---|---|---|---|
| <img src="../assets/images/type_1.png" width="24"> 1 | 5 | 10 | | -5 |
| <img src="../assets/images/type_2.png" width="24"> 2 | 10 | 20 | 30 | -30 |
| <img src="../assets/images/type_3.png" width="24"> 3 | 50 | 50 | 70 | -75 |
| <img src="../assets/images/type_4.png" width="24"> 4 | 200 | 100 | 150 | -200 |
| <img src="../assets/images/type_5.png" width="24"> 5 | | 150 | 500 | -1000 |
| <img src="../assets/images/type_6.png" width="24"> 6 | | 1000 | 2500 | -5000 |
| <img src="../assets/images/type_7.png" width="24"> 7 | | | 10000 | -20000 |
| <img src="../assets/images/Door Tall Closed.png" width="24"> -1 | 500 | | | 2000 |
| <img src="../assets/images/Enemy Bug.png" width="24"> -2 | 10 | 100 | | 10 |
| <img src="../assets/images/eraser.png" width="24"> -3 | 100 | | | |
| <img src="../assets/images/matcher.png" width="24"> -4 | 250 | | | |
| <img src="../assets/images/Green Diamond.png" width="24"> -5 | | 500 | 750 | 500 |
| <img src="../assets/images/Blue Diamond.png" width="24"> -6 | | 2500 | 1500 | 1000 |
| <img src="../assets/images/Orange Diamond.png" width="24"> -7 | | | 1500 | 25000 |


# Credits

- Code : [Ghislain "court-jus" Lévêque](http://about.me/courtjus/)
- Inspiration : [Triple Town](http://www.tripletown.com/) from [Spryfox](http://www.spryfox.com/) (I guess it was inspired by older stuff, so I thank them too)
- Graphics : [PlanetCute](https://lostgarden.com/2007/05/12/dancs-miraculously-flexible-game-prototyping-tiles/) from [Lost Garden](http://www.lostgarden.com/)
