globals [tab colors feature] ;; Liste des types de dechets
;; Liste de memoire; proba calculée pour prise/depot; type de l'objet rencontré / porté
turtles-own [memory pprise pdepot fo current-color]

;; Initialization
to setup
  clear-all
  set tab range n ;; number of types
  set colors map [x -> x * 10 + 6] tab
  setup-patches
  setup-turtles
  reset-ticks
end

;; Initialize patches
to setup-patches
  let x 0
  let y 0
  let col 0
  foreach tab [ [cat] ->
    let k 0
    while [ k < nDech ][
      if k = nDech [ stop ]
      set x random-xcor
      set y random-ycor
      ask patch x y [ set col pcolor]
      if col = 0 [
        ask patch x y [ set pcolor item cat colors ]
        set k k + 1
      ]
    ]
  ]
end

;; Initialize turtles
to setup-turtles
  create-turtles A [
    set color white ;; white is when the turtle does not hold anything
    setxy random-xcor random-ycor
    set size 3
    set memory range T ;; List of objects encoutered
  ]
end

;; Turtle procedure (run global)
;; chaque tortue cherche un objet, trouve une pile, puis le pose
to go
  ask turtles [
    search-for-chip
    find-new-pile
    put-down-chip
  ]
  compute_feature
  tick
end

;; If the turtle does not hold anything and find an object take it, else move randomly
to search-for-chip
    ifelse pcolor != black and color = white
  [
    set current-color pcolor
    compute_pprise ;; calcul la proba de prise
    ifelse random-float 1 < pprise [
      set color pcolor
      set pcolor black
    ][
      wiggle
      search-for-chip
    ]
  ]
  [ wiggle
    search-for-chip ]
end

;; turtle procedure -- look for objects
to find-new-pile
  if pcolor = black
  [ wiggle
    find-new-pile ]
end

;; turtle procedure -- finds empty spot & drops chip
to put-down-chip
  ifelse pcolor = black
  [
    set current-color color
    compute_pdepot ;; calul la proba de depot
    ifelse random-float 1 < pdepot
    [set pcolor color
      set color white]
    [wiggle
    put-down-chip
    ]
  ]
  [ wiggle
    put-down-chip ]
end

;; Move the turtle
to wiggle
  ifelse Levy
  [
  ;; Deplacement oiseau
    rt random 60
    let N1 random-normal 0 1
    let N2 random-normal 0 1
    let cau (N1 / N2)
    fd cau
  ][
  ;; Deplacement normal
    ;pen-down
    rt random 60
    lt random 60
    fd i
  ]

  ;; Met a jour la memoire
  set memory fput pcolor memory
  set memory but-last memory
end

;; Calcul la proba de prise d'objet
to compute_pprise
  compute_fo
  let tot 0
  set tot ( KP / ( KP + fo ) ) ^ 2
  set pprise tot
end

;; Calcul la proba de depot
to compute_pdepot
  compute_fo
  let tot 0
  set tot ( fo / ( KD + fo ) ) ^ 2
  set pdepot tot
end

;; Calcul f(o)
to compute_fo
  let no 0
  let col 0
  ifelse Vision[
    ;; Vision : f0 = nb de la couleur étudiée sur les T cases devant l'agent
    let sight range T
    foreach sight [ [dist] ->
      ;; ahead of agent
      ask patch-ahead (dist + 1) [set col pcolor]
      if col = current-color [set no no + 1]
      ;; left of agent
      ask patch-left-and-ahead 30 (dist + 1) [set col pcolor]
      if col = current-color [set no no + 1]
      ;; right of agent
      ask patch-right-and-ahead 30 (dist + 1) [set col pcolor]
      if col = current-color [set no no + 1]
    ]
    set fo (no / (T * 3))
  ][
    ;; Memoire : f0 = nb de la couleur étudiée sur les T dernières cases rencontrées de l'agent
    foreach memory [ [x] ->
      if x = current-color
      [set no no + 1]
    ]
    set fo (no / T)
  ]

  ;; apply the error of decision
  let r random 2
  let er random-float err
  let s 0
  ifelse r = 0 [
    set s 1
  ][
    set s -1
  ]
  set fo (fo + (er * s))
end

;; Calcul le nombre de dechet voisins de même type pour chaque case
to compute_feature
  let k 0
  let j 0
  let col 0
  let tot 0
  set feature 0
  while [k <  max-pxcor][
    set j 0
    while [j < max-pycor][
      ask patch k j [set col pcolor]
      if col != 0 [
        ask patch (k + 1) j [
          if pcolor = col[
            set feature (feature + 1)
          ]
        ]
        ask patch (k - 1) j [
          if pcolor = col[
            set feature (feature + 1)
          ]
        ]
        ask patch (k + 1) (j + 1) [
          if pcolor = col[
            set feature (feature + 1)
          ]
        ]
        ask patch (k - 1) (j - 1) [
          if pcolor = col[
            set feature (feature + 1)
          ]
        ]
        ask patch (k + 1) (j - 1) [
          if pcolor = col[
            set feature (feature + 1)
          ]
        ]
        ask patch (k - 1) (j + 1) [
          if pcolor = col[
            set feature (feature + 1)
          ]
        ]
        ask patch k (j + 1) [
          if pcolor = col[
            set feature (feature + 1)
          ]
        ]
        ask patch k (j - 1) [
          if pcolor = col[
            set feature (feature + 1)
          ]
        ]
      ]
      set j (j + 1)
    ]
    set k (k + 1)
  ]
  set feature (feature / (nDech * n))
end
@#$#@#$#@
GRAPHICS-WINDOW
229
35
664
471
-1
-1
7.0
1
7
1
1
1
0
1
1
1
0
60
0
60
1
1
1
ticks
120.0

BUTTON
15
24
88
57
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
112
25
175
58
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
25
78
197
111
n
n
1
20
3.0
1
1
NIL
HORIZONTAL

SLIDER
25
157
197
190
T
T
1
30
10.0
1
1
NIL
HORIZONTAL

SLIDER
25
198
197
231
i
i
0
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
24
241
196
274
kp
kp
0.1
1
0.1
0.1
1
NIL
HORIZONTAL

SLIDER
25
287
197
320
kd
kd
0.1
1
0.3
0.1
1
NIL
HORIZONTAL

SLIDER
25
116
197
149
nDech
nDech
1
500
169.0
1
1
NIL
HORIZONTAL

SLIDER
25
330
197
363
A
A
1
300
50.0
1
1
NIL
HORIZONTAL

SLIDER
25
374
197
407
err
err
0
0.4
0.0
0.01
1
NIL
HORIZONTAL

PLOT
737
35
1100
289
Indice de rangement
time
nb
0.0
10.0
0.0
6.0
true
false
"" ""
PENS
"default" 1.0 0 -14439633 true "" "plot feature"

SWITCH
736
304
839
337
Levy
Levy
1
1
-1000

SWITCH
736
348
839
381
Vision
Vision
1
1
-1000

@#$#@#$#@
## BUT DU MODELE

Ce système multi-agent constitué d'un ensemble d'agents réactifs évoluant sur une grille 2D a pour but de simuler un tri-collectif à partir des comportements locaux des agents.

## COMMENT CA MARCHE

Initialement, la grille comporte plusieurs déchets de plusieurs types (un type est symbolisé par une couleur sur la grille). Le but du système est que les actions locales des agents résultent en un tri selectif global. Pour cela, chaque agent bouge aléatoirement sur la grille. Quand il rencontre un déchet, il a une probabilité de le récuperer en fonction du type. L'agent continue ensuite à se déplacer et à chaque pas de temps a une probabilité de poser le déchet qu'il transporte avec une autre probabilité Ces probabilités dépendent soit de la mémoire de l'agent, soit de son champs de vision :

p<sub>prise</sub> = (k<sub>p</sub> / (k<sub>p</sub> + f(o)))<sup>2</sup>

p<sub>depot</sub> = (f(o) / (k<sub>d</sub> + f(o)))<sup>2</sup>

f(o) correspond à la fraction des déchets de type o rencontrés dans la mémoire de l'agent ou bien sur son champs de vision.


## COMMENT L'UTILISER

Voici les différents paramètres utilisés par le modèle :

* n : nombre de types de déchets différents
* nDech : nombre de déchets générés sur la grille pour chaque type
* T : taille de la mémoire ou du champs de vision des agents
* i : distance du déplacement des agent à chaque pas de temps
* kp : paramètre influençant la probabilité de prise des agents
* kd : paramètre influençant la probabilité de dépôt des agents
* A : nombre d'agents générés
* err : Correspond à l'erreur dans les décisions de l'agent. A chaque décision, f(o) est multiplié par un nombre entre -err et err


Le modèle utilise plusieurs types de fonctionnement, modifiable par les interrupteurs suivant :

* Levy : Quand actionné, les agents se déplacent en utilisant un vol de Lévy. Sinon, les agents se déplacent d'une distance i à chaque pas de temps.
* Vision : Quand acionné, f(o) correspond à la fraction des déchets de type o sur les cases du champs de vision de l'agent. Le champs de vision correspond aux T cases devant l'agent, aux T cases à 30 degrés à droite devant l'agent et aux T cases à 30 degrés à gauche devant l'agent.
Si il n'est pas actionné, f(o) correspond à la fraction des déchets de type o rencontrés dans la mémoire de taille T de l'agent 

De plus, un 'indice de rangement' est tracé le long des simulations. Celui-ci correspond au nombre de déchets voisins de même type moyen pour tous les déchets de l'environnement. Pour cela, le nombre de déchets de même type sur les 8 cases autour de chaque déchet est calculé. Plus cet indice est grand, plus on peut dire que le tri collectif est de qualité.


## RESULTATS

Avec les paramètres de base (sans erreur, sans vol de Levy et avec la mémoire), le modèle marche plutôt bien. Avec 10 types de déchets différents et 100 déchets par type, le système tend assez vite vers un état relativement stable où on observe bien les différents tas de déchets séparés selon leurs types. L'indice de rangement stagne alors aux alentours de 4.2. En augmentant l'erreur, des tas en fonction des types de déchet sont toujours visibles mais de plus en plus hétérogènes. A partir d'une erreur proche de 0.12, le tri ne fonctionne plus et l'indice de rangement est proche de 0.
Le système semble marcher quelque soit le nombre de types de déchets, de déchets et d'agents. Le système convergera juste plus lentement si ces paramètres augmentent.
Avec une mémoire assez petite, T=3 par exemple, on verra l'apparition de plusieurs tas d'une même couleur, ce qui est logique. En attendant, les tas fusionnent, mais ceux ci sont moins stable qu'avec une mémoire plus grande. En effet, la décision des agents est moins robuste avec une une memoire aussi basse et le hasard a un impact plus important sur les prises de décision.
Avec un i > 1, le tri n'est pas efficace et on ne voit pas l'apparition de tas homogènes. Les agents font des sauts trop grand dans l'espace et leurs mémoires ne devient plus pertientes pour les prises de décision.
Si on augmente kp suffisament, jusqu'à environ 0.6, les tas proches homogènes vont commencer à se mélanger
Augmenter kd semble provoquer des tas moins stables, mais avec un changement peu visible.



En utilisant le vol de Levy (avec les paramètres de base), on constate des appartitions de petits ensemble de déchets de même type, mais seulement ponctuels. L'indice de rangement ne dépasse que très rarement 1. Cette technique de déplacement ne semble pas fonctionner pour cette tâche de tri selectif. Cela semble assez logique : avec ce type de déplacement, les agents réalisent souvent des grands saut dans l'espace. Cependant, leurs mémoires correspondent aux déchets vu précedemment, avant le saut, et celles-ci ne sont plus pertinentes pour la prise de décision dans cette nouvelle zone.

En utilisant le champs de vision au lieu de la mémoire avec un déplacement normal et les paramètres de base, le système marche bien. L'amplitude du champs de vision ne doit pas être trop grande. Avec T = 3, le système converge assez vite vers des tas homogènes et un indice de rangement proche de 4.

C'est la combinaison du vol de Levy et du champs de vision qui donne les meilleurs résultats. Avec T = 2, le système met plus de temps à converger et les tas se forment petit à petit, mais les tas sont beaucoup plus compacts : l'indice de rangement oscille aux alentours de 5.5, signe d'un rangement de qualité. Si l'agent prend ses décisions en fonction de son champs de vision, les sauts provoqués par le vol de Levy ne sont plus un problème. De plus, on peut penser que ce type de déplacement empeche mieux les agents de prendre des déchets d'un tas déjà trié et de les poser plus loin. Le meilleurs indice de rangement devrait en partir venir de la.

## AUTEURS

Alexis Pister et Raphael Teitgen


@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
