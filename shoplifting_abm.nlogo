__includes [ "terrain.nls" "CRAVED_method.nls"]
extensions [ csv matrix rnd ] ;; ex 7.1


globals
[
  colour_background
  colour_aisles
  colour_shelves
  colour_entrance
  colour_exit
  colour_outside
  colour_intersection
  colour_walking_regularcustomer
  interval_creation_RC ;; new regular customers will be created every x ticks
  decide_browsetobuy_threshold
  colour_standing_regularcustomer
  time_creation_SC
  colour_walking_SC
  colour_standing_SC
  decide_browsetosteal_threshold ;; probability threshold
  time_creation_RG ;; time when turtle is created
  N_RG ;; number of guardians to create
  colour_walking_RG ;; colour of guardians in walking mode
  colour_standing_RG ;; colour of guardians in standing mode
  has_been_detected ;; number of guardians that detect the shoplifting incident
  has_noticed_detection ;; number of times the offender noticed they were seen 0 concealing an item
  ;prob_guardians ;; ex 13.11
  ;prob_shoplifters
]

patches-own
[
  category
  CRAVED
  CRAVED_score
]

turtles-own
[
  init_time ;; time when turtle is created
  role ;; role of the turtle (customer, guardian)
  Shoplifter ;; criminal property of the turtle (Y N)
  state ;; state of the turtle regarding its movement (walking, standing)
  leaving ;; state of the turtle - turns to "Y" when the turtle has to leave the supermarket
  _candidates ;; patch-set of all neighbouring patches where the turtle can go
  number_of_products ;; number of products in the turtle's shopping basket
  pause_timer_max
  pause_timer
  number_of_products_max
  floorplan  ;; ex 7.2
  Ntimes_visited ;; ex 8.1 Number of times the agent visited the neighbouring patches
  x_candidates ;; X coordinates of the neighbouring patches
  y_candidates ;; Y coordinates of the neighbouring patches
  number_of_stolen_products_max ;; ex 11.5 number of products the shoplifter plans to steal
  number_of_stolen_products ;; number of products the shoplifter has taken
]

to setup

  ca
  reset-ticks

  create_supermarket

  add_products

  set colour_walking_regularcustomer grey

  set interval_creation_RC 10

  set decide_browsetobuy_threshold 10

  set colour_standing_regularcustomer violet

;; ex 11.1
  set time_creation_SC 500
  set colour_walking_SC green
  set colour_standing_SC red

;; ex 11.4
  set decide_browsetosteal_threshold 25

;; ex 12.1
  set time_creation_RG 0
  set N_RG 4
  set colour_walking_RG blue
  set colour_standing_RG blue

  set has_been_detected 0
  set has_noticed_detection 0

;; ex 13.11
  ;set prob_guardians
  ;set prob_shoplifters
  set has_been_detected 0
  set has_noticed_detection 0

end



to go

  ;;ex15
  let the_shoplifter one-of turtles with [ shoplifter = "Y"]
  if (ticks > time_creation_SC and the_shoplifter = nobody)
    [stop]
  if (ticks > time_creation_SC and [leaving] of the_shoplifter = "Y")
    [stop]


  ;;ex 3.5
  if ( ticks mod interval_creation_RC = 0 )
  [
    make-turtles ( "RC" ) ( 2 )
  ]

  if ( ticks = time_creation_SC )
  [
    make-turtles ( "SC" ) ( 1 )
  ]

   if ( ticks = time_creation_RG )
  [
    make-turtles ( "RG" ) ( 1 )
  ]


  ;; If a turtle is on an aisle and their state is “walking”, then make them move one patch forward.
  ask turtles
  [if state = "walking"
    [ifelse ( category =  "aisles" )
      [ifelse leaving = "N"
        [ ifelse ( shoplifter = "N")
          [ decide_browsetobuy
            if state != "browsingtobuy" [ fd 1 ]  ;; ex 5.5
          ]
          [ if ( shoplifter = "Y")
            [ decide_browsetosteal
              if state != "browsingtosteal" [ fd 1 ]
            ]
          ]
        ]
        [
          fd 1
        ]
      ]
      [

;; If they are on an intersection patch: create a list of patches where they can move to
      if ( category = "intersection" )
        [
;; ex 8.2 Write the x and y coordinates of the agent’s neighbouring patches inito x_candidates and y_candidtates
          set _candidates ( patches with [ distance myself = 1 and category =  "aisles" ] )
          set x_candidates [] ;; ex 8.2
          set y_candidates [] ;; ex 8.2

;; ex 8.2 control the order of the elements using the sort command
          foreach sort _candidates
          [x ->
             set x_candidates lput [ pxcor ] of x x_candidates
             set y_candidates lput [ pycor ] of x y_candidates
          ]

          set Ntimes_visited []
          let index 0
          repeat (length x_candidates)
          [
            set Ntimes_visited lput matrix:get floorplan ( item index y_candidates )  ( item index x_candidates ) Ntimes_visited
            set index ( index + 1 )
          ]


;; ex 9.1
          let w []
          set w generate-weights ( Ntimes_visited )

 ;; ex 10.1
          let list_index n-values length x_candidates [ i -> i ]

 ;; ex 10.2
          let pairs (map list list_index w)
          let weighted_patch_no first rnd:weighted-one-of-list pairs [ [p] -> last p ]
          face patch (item weighted_patch_no x_candidates) (item weighted_patch_no y_candidates)

      fd 1
      ]

  if ( category = "entrance" )
    [set heading towards one-of neighbors4 with [ category =  "aisles" ]
      fd 1]

  if ( category = "exit" )
    [ ifelse ( leaving = "N")
      [
        face one-of patches with [ distance myself = 1 and category =  "aisles" ]
        fd 1
      ]
      [
        face patch 19 24
        fd 1
      ]
    ]
      ]

   if ( category = "outside" )
      [
        die
      ]
   ]
  ]
 ask turtles with [ state = "browsingtobuy" ]
  [set pause_timer ( pause_timer - 1 )
    if ( pause_timer = 1 )
     [ set pause_timer pause_timer_max
       set state "walking"
       ifelse role = "customer"
        [
         set number_of_products number_of_products + 1
         set color colour_walking_regularcustomer
          if ( number_of_products = number_of_products_max )
          [
            set leaving "Y"
          ]
        ]
        [
          set color colour_walking_RG
        ]
         ;; ex 6.2
     ]
  ]

  ;; ex. 116
 ask turtles with [ state = "browsingtosteal" ]
  [set pause_timer ( pause_timer - 1 )
    if ( pause_timer = 1 )
     [ set pause_timer pause_timer_max
       set number_of_stolen_products number_of_stolen_products + 1
       ;; ex 13.12
       detection
       set state "walking"
       set color colour_walking_SC
       if ( number_of_stolen_products = number_of_stolen_products_max )
          [ set leaving "Y" ]

     ]
  ]




  ;; ex 7.3
  ask turtles
  [
    matrix:set floorplan pycor pxcor (( matrix:get floorplan pycor pxcor ) + 1 )
  ]


  tick

end

 ;; ex 3.4 CREATE THE AGENTS
to make-turtles [ turtle_category how_many ]

  set-default-shape turtles "person" ;; Set the default shape of the turtles to “person”

  create-turtles how_many
  [ set init_time ticks ;; how long each turtle has been in the supermarket
    set leaving "N" ;; it will change to ‘Y’ when a customer decides to leave the supermarket
    set state "walking" ;; it will change when a customer decides to stop and browse products
    set pause_timer_max (random 6) + 5  ;; set pause timer max between 5 and 10

    ifelse ( turtle_category = "RC" )
  [
   set role "customer"
   set shoplifter "N"
   set color colour_walking_regularcustomer
   set number_of_products 0
   set number_of_products_max ( random 4 + 3 ) ;; ex 6.1 set number of prodcut max between 3 and 6
  ]

  [
   if ( turtle_category = "SC" )
      [
      set role "customer"
      set shoplifter "Y"
      set color colour_walking_SC
      set shape "person soldier"
      set number_of_stolen_products_max (random 2 ) + 4
      set number_of_stolen_products 0
      ]
 ;; ex 12.3
   if ( turtle_category = "RG" )
      [
      set role "guardian"
      set shoplifter "N"
      set color colour_walking_RG
      set shape "person police"
      ]
   ]




    set floorplan matrix:make-constant max-pycor max-pxcor 0 ;; ex 7.2
    setxy 1 23
    set heading 180
    fd 1
  ]

end

;; BEHAVIOUR OF CUSTIMERS (Browsing to buy procedures)

to decide_browsetobuy  ;; ex 5.3

  if random 101 <= decide_browsetobuy_threshold
  [ browsetobuy ]

end

to browsetobuy  ;; ex 5.4

  set state "browsingtobuy"
  set color colour_standing_regularcustomer
  set pause_timer pause_timer_max

end

to decide_browsetosteal  ;; ex 11.4

  if random 101 <= decide_browsetosteal_threshold
  [ browsetosteal ]

end

to browsetosteal  ;; ex 11.4

  set state "browsingtosteal"
  set color colour_standing_SC
  set pause_timer pause_timer_max

end


to-report generate-weights [ n_visits ]

  report map [ i -> ((1 + sum n_visits) - i )/(1 + sum n_visits) ] ( n_visits )

end

to-report whats_in_between [turtle_1 turtle_2]

;; ex 13.3
  let region []
  let number_patches 99999
  let number_turtles 99999
  let result []

  if ( [ xcor ] of turtle_1 = [ xcor ] of turtle_2 )
   [if ( [ xcor ] of turtle_1 = 1 ) or ( [ xcor ] of turtle_1 = 4 ) or ( [ xcor ] of turtle_1 = 7 ) or ( [ xcor ] of turtle_1 = 10 ) or ( [ xcor ] of turtle_1 = 13 ) or ( [ xcor ] of turtle_1 = 16 ) or ( [ xcor ] of turtle_1 = 19)
      [ifelse [ycor] of turtle_1 <= [ycor] of turtle_2
        [set region patches with [pxcor = [xcor] of turtle_1 and pycor > [ycor] of turtle_1 and pycor < [ycor] of turtle_2]]
        [set region patches with [pxcor = [xcor] of turtle_1 and pycor > [ycor] of turtle_2 and pycor < [ycor] of turtle_1]]
      ]
  ]

  if ( [ ycor ] of turtle_1 = [ ycor ] of turtle_2 )
   [if ( [ ycor ] of turtle_1 = 1 ) or ( [ ycor ] of turtle_1 = 12 ) or ( [ ycor ] of turtle_1 = 23 )
      [ifelse [xcor] of turtle_1 <= [xcor] of turtle_2
        [set region patches with [pycor = [ycor] of turtle_1 and pxcor > [xcor] of turtle_1 and pxcor < [xcor] of turtle_2]]
        [set region patches with [pycor = [ycor] of turtle_1 and pxcor > [xcor] of turtle_2 and pxcor < [xcor] of turtle_1]]
      ]
  ]

  if region != []
  [
    set number_patches count region
    set number_turtles count turtles-on region
  ]

  set result (list (number_patches) (number_turtles) )
  report result

end


;; ex 13.7
to-report probability_detection [in_between prob]

  let probability  ( prob ^ ( 1 + item 0 in_between + item 1 in_between) )
  report probability

end


;; ex 13.10
to-report binomial_dist [prob]
;; this reporter is used to randomly select 1 or 0 with 'prob' representing Pr(1)
  let list_index [0 1]
  let prob_list list (1 - prob) prob
  let pairs (map list list_index prob_list)
  report first rnd:weighted-one-of-list pairs [ [p] -> last p ]

end

;; ex 13.12
to detection

let in_between []
let the_shoplifter one-of turtles with [ Shoplifter = "Y" ]
ask turtles with [ role = "guardian" ]
  [
    let the_guard self
    if the_shoplifter != nobody
    [
     set in_between (whats_in_between the_guard the_shoplifter)
     if binomial_dist (probability_detection(in_between) (prob_guardians)) = 1
        [
          set has_been_detected has_been_detected + 1
          if binomial_dist (probability_detection(in_between) (prob_shoplifters)) = 1
          [
            set has_noticed_detection has_noticed_detection + 1
           ]
         ]
    ]
  ]

  if has_been_detected > 0 and has_noticed_detection = 0
   [
     ask the_shoplifter [die]
   ]
  if has_been_detected > 0 and has_noticed_detection > 0
   [
     ask the_shoplifter
      [
       set number_of_stolen_products 0
       set leaving "Y"
      ]
    ]


end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
528
329
-1
-1
10.0
1
9
1
1
1
0
1
1
1
0
30
0
30
1
1
1
ticks
30.0

BUTTON
130
14
196
47
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
133
56
196
89
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
1

PLOT
4
102
204
252
number of agents
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

SLIDER
541
13
713
46
prob_guardians
prob_guardians
0.1
0.9
0.9
0.2
1
NIL
HORIZONTAL

SLIDER
541
57
713
90
prob_shoplifters
prob_shoplifters
0.1
0.9
0.9
0.2
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

person police
false
0
Polygon -1 true false 124 91 150 165 178 91
Polygon -13345367 true false 134 91 149 106 134 181 149 196 164 181 149 106 164 91
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -13345367 true false 120 90 105 90 60 195 90 210 116 158 120 195 180 195 184 158 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Polygon -13345367 true false 150 26 110 41 97 29 137 -1 158 6 185 0 201 6 196 23 204 34 180 33
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Rectangle -16777216 true false 109 183 124 227
Rectangle -16777216 true false 176 183 195 205
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Polygon -1184463 true false 172 112 191 112 185 133 179 133
Polygon -1184463 true false 175 6 194 6 189 21 180 21
Line -1184463 false 149 24 197 24
Rectangle -16777216 true false 101 177 122 187
Rectangle -16777216 true false 179 164 183 186

person soldier
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -10899396 true false 105 90 60 195 90 210 135 105
Polygon -10899396 true false 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Polygon -10899396 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -6459832 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -6459832 true false 120 193 180 201
Polygon -6459832 true false 122 4 107 16 102 39 105 53 148 34 192 27 189 17 172 2 145 0
Polygon -16777216 true false 183 90 240 15 247 22 193 90
Rectangle -6459832 true false 114 187 128 208
Rectangle -6459832 true false 177 187 191 208

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
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="ShopliftingExperiment" repetitions="250" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>has_been_detected</metric>
    <metric>has_noticed_detection</metric>
    <enumeratedValueSet variable="prob_shoplifters">
      <value value="0.1"/>
      <value value="0.3"/>
      <value value="0.5"/>
      <value value="0.7"/>
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="prob_guardians">
      <value value="0.1"/>
      <value value="0.3"/>
      <value value="0.5"/>
      <value value="0.7"/>
      <value value="0.9"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
