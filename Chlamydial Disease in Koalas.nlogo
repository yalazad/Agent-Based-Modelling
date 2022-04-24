globals [
  age-list                 ;; list of ages of dead agents
  adult-age                ;; tracks the age of adulthood
  seasons-list             ;; a list containing the seasons
  seasons-list-idx         ;; an index for the seasons-list
  season_cnt               ;; a counter to trigger a change of season after 91 days
  num-recovered            ;; the total number of koalas recovered after receiving treatment in hospital
  tot-num-dead             ;; the total number of koalas that have died in the wild and in hospital
  num-dead-in-hosp         ;; the number of koalas that have died in hospital only
  tot-hospitalised         ;; the total number of koalas that have been hospitalised from start of run
  pop-cnt                  ;; a counter to keep a track of the population
  hospitalised-cnt         ;; a counter to keep track of the current number of koalas in hospital
  mating-energy-threshold  ;; the energy threshold required from each parent to produce offspring
]

breed [ k_males k_male ]
breed [ k_females k_female ]

patches-own [ regrowth-rate ]

k_females-own [
  energy                 ;; the amount of energy the agent has
  partner                ;; a variable to temporarily store a mating-partner
  carrying?              ;; a boolean to indicate if a female is carrying after mating
  carry-time             ;; tracks the time of carrying an infant. Includes gestation-period of 1 month plus time in pouch of 6 months => 215 days
  age                    ;; variable to keep track of age
  lifespan               ;; gets randomly assigned at birth - age up to which an agent lives
  num-of-exes            ;; tracks mating partners an agent had in its life
  num-of-children        ;; tracks how many children an agent has
  adult?                 ;; boolean to indicate if this agent is an adult
  infected?              ;; boolean to inidicate if this agent is infected
  inf-severity           ;; infection severity: 1 - aymptomatic, 2 - mild symptoms, 3 - medium symptoms, 4 - severe symptoms
  parent                 ;; used to inherit features from parent in reproduction
  treatment-time         ;; amount of days/ticks the agent has been receiving treatment in hospital
  hospitalised?          ;; boolean to indicate if this agent is currently in hospital
]

k_males-own [
  energy                ;; the amount of energy the agent has
  partner               ;; a variable to temporarily store a mating-partner
  age                   ;; variable to keep track of age
  lifespan              ;; gets randomly assigned at birth - age up to which an agent lives
  num-of-exes           ;; tracks mating partners an agent had in its life
  num-of-children       ;; tracks how many children an agent has
  adult?                ;; boolean to indicate if this agent is an adult
  infected?             ;; boolean to inidicate if this agent is infected
  inf-severity          ;; infection severity: 1 - aymptomatic, 2 - mild symptoms, 3 - medium symptoms, 4 - severe symptoms
  parent                ;; used to inherit features from parent in reproduction
  treatment-time        ;; amount of days/ticks the agent has been receiving treatment in hospital
  hospitalised?         ;; boolean to indicate if this agent is currently in hospital
]


;; setup the population of male and female koalas
to setup
  clear-all

  set-default-shape k_males "molecule water" ;; 'molecule water' looks like a koala's head with two ears so use this shape
  set-default-shape k_females "molecule water"

  set adult-age int (0.25 * mean-lifespan) ;; Agents with age more than 25% of mean-lifespan are considered adult

  set seasons-list ["Spring" "Summer" "Autumn" "Winter"]

  ;; Create male agents and initialise them
  create-k_males (initial-population-size / 2 ) [
    setxy random-xcor random-ycor
    set color grey
    set energy 100

    ;; initialise turtle variables
    set age int median (list 1 (random-normal (mean-lifespan / 2) (mean-lifespan / 6) ) 18) ;; randomly generated age must not exceed the normal range in wild 1-18
    set lifespan int median (list mean-lifespan (random-normal (mean-lifespan) (mean-lifespan / 6) ) 18) ;; randomly generated lifespan must not exceed the normal range in wild mean-lifespan to 18
    set partner nobody
    set num-of-exes 0
    set num-of-children 0
    set infected? false
    set inf-severity 0
    set treatment-time 0
    set hospitalised? false
    ;; adult koalas are larger
    ifelse age < adult-age [
      set size 1.5
      set adult? false
    ] [ set size 2.5
        set adult? true]
  ]

  ;; Create female agents and initialise them
  create-k_females initial-population-size - count k_males [
    setxy random-xcor random-ycor
    set color grey
    set energy 80 ;; females have slightly less energy than males as they are smaller
    set partner nobody
    set carrying? false

    ;; initialise rest of turtle variables
    set carry-time 0
    set age int median (list 1 (random-normal (mean-lifespan / 2) (mean-lifespan / 6) ) 18) ;; randomly normally distributed age must not exceed the range in wild: 1-18
    set lifespan int median (list mean-lifespan (random-normal (mean-lifespan) (mean-lifespan / 6) ) 18) ;; randomly normally distributed lifespan must not exceed the normal range in wild: mean-lifespan to 18
    set num-of-exes 0
    set num-of-children 0
    set infected? false
    set inf-severity 0
    set treatment-time 0
    set hospitalised? false
    ;; adult koalas are larger
    ifelse age < adult-age [
      set size 1.5
      set adult? false
    ] [ set size 2 ;; females are slightly smaller than males
        set adult? true]
  ]

  setup-k_females
  setup-k_males

  set age-list []
  set season_cnt 0
  set seasons-list-idx random 4 ;; randomly set a season initially
  set mating-energy-threshold 50 ;; a significant amount of energy is required for mating
  set num-recovered 0
  set tot-num-dead 0
  set num-dead-in-hosp 0
  set pop-cnt initial-population-size
  set hospitalised-cnt 0
  set tot-hospitalised 0

  ask patches [
    set pcolor one-of [ green brown ]
    ifelse pcolor = green
    [ set regrowth-rate eucalyptus-growth-rate ]
    [ set regrowth-rate random eucalyptus-growth-rate ] ;; initialise eucalyptus regrowth clocks randomly for brown patches
  ]
  display-labels
  reset-ticks
end

to setup-k_females
   ask k_females [
    ifelse (random initial-population-size + 1) < initial-population-size * initial-infected-pct / 100  ;; a percentage of the population is infected based on slider initial-infected
    [set infected? true
      set color red
      set inf-severity random 4 + 1 ;; set the infection severity as a random number between 1 and 4
    ]
    [set infected? false
      set color grey ]
  ]
end

to setup-k_males
   ask k_males [
    ifelse (random initial-population-size + 1) < initial-population-size * initial-infected-pct / 100 ; a percentage of the population is infected based on slider initial-infected
    [set infected? true
      set color red
      set inf-severity random 4 + 1 ;; set the infection severity as a random number between 1 and 4
    ]
    [set infected? false
      set color grey ]
  ]
end

to go
  if not any? turtles [ stop ]

  ask turtles [ check-if-dead ]

  ask k_males [
    if not hospitalised? [ move ]
    ifelse [age] of self > adult-age [
      set adult? true
      set size 2.5
    ][
      set adult? false
      set size 1.5
    ]
    eat-eucalyptus
    expend_energy
    check-status ;; check status of infected agents
  ]

  ask k_males with [adult?] [ if energy > mating-energy-threshold [mate] ]

  ask k_females [
    if not hospitalised? [ move ]
    ifelse [age] of self > adult-age [
      set adult? true
      set size 2

    ][
      set adult? false
      set size 1.5
    ]
    eat-eucalyptus
    expend_energy
    check-status
  ]

  ask k_females with [adult?] [ if energy > mating-energy-threshold [reproduce] ]

  ask patches [ grow-eucalyptus ]

  tick
  check-season ;; check if we need to change season
  display-labels
end

to check-season
  ;; change the season every 91 days
  let change_season? false ;; boolean to know whether or not to change the season

  if season_cnt = 91 ;; we are setting 91 days per season
  [  ;set change-season boolean to true, reset season counter to zero
    set season_cnt 0 ;; reset counter
    set change_season? true

    if change_season?
    [
      ifelse seasons-list-idx = length seasons-list - 1 ;; we are at the end of the list, set the index to beginning of list
      [set seasons-list-idx 0]
      [set seasons-list-idx seasons-list-idx + 1] ;; otherwise increment index to next season
    ]
  ]
  set season_cnt season_cnt + 1
end

to expend_energy

  ifelse (infected? = true)[
    ifelse (hospitalised? = true) ;; the koala is in hospital receiving treatment
    [set energy energy - 1] ;; if infected and receiving treatment in hospital, expend less energy than an infected koala in the wild
    [set energy energy - inf-severity] ;; otherwise not receiving treatment, the higher the severity the more energy that is lost
  ][set energy energy - 0.5] ;; else not infected expend a small amount of energy

end

;; procedure to move randomly
to move ;; turtle procedure

  if (infected? = true and random-float 1 < (annual-treated-pct / 100 ) / 365) ;; calculate daily hospital admission rate
    ;; a percentage of sick koalas are taken to the wildlife hospital to be treated
    [ hospitalise ]


  if not hospitalised? [
    let normal-step-size 1
    let step-size 0

    ifelse infected? = true and inf-severity != 1 ;; asymptomatic koalas movement is not impacted
    [
      ;; infected agents move less. The higher the severity of the disease the less the agent moves
      (ifelse inf-severity = 2 [
        set step-size normal-step-size * 0.7] ;; mild symptoms -> 70% of normal movemnt
        inf-severity = 3 [
          set step-size normal-step-size * 0.5] ;; medium symptoms -> 50% of normal movemnt
        inf-severity = 4 [
          set step-size normal-step-size * 0.3] ;; severe symptoms -> 30% of normal movemnt
      )
    ];; else all other koalas move normally
    [set step-size normal-step-size]

    rt random 50
    lt random 50
    ;; In spring and summer agents move more in order to find a mate
    ifelse item seasons-list-idx seasons-list = "Spring" or item seasons-list-idx seasons-list = "Summer"
    [ fd step-size * 3] ;; during mating season agents move 3 times more
    [ fd step-size ]
  ]
end

to hospitalise
  set pcolor white
  set hospitalised? true
  set tot-hospitalised tot-hospitalised + 1
  if treatment-time != 0 [set treatment-time 0]
  set hospitalised-cnt hospitalised-cnt + 1
end

to check-status
  if (infected? = true or color = blue) [;if infected or recovered

    ;; if receiving treatment and treatment-time greater than 60 days then recover
    if (hospitalised? = true) [
      set treatment-time treatment-time + 1

      if (treatment-time > 60 and infected? = true) [ ;; after treatment of 2 months, the koala is recovered barring small percentage who don't recover
        ifelse random-float 1 < 1 - antibiotic-effectiveness / 100 [;; a proportion of koalas being treated in hospital will die
          set tot-num-dead tot-num-dead + 1
          set pop-cnt pop-cnt - 1
          set treatment-time 0
          set hospitalised-cnt hospitalised-cnt - 1
          set pcolor green
          set num-dead-in-hosp num-dead-in-hosp + 1
          set age-list lput [age] of self age-list
          die
        ]
        [set infected? false
          set color blue ;; blue for recovered
          set num-recovered num-recovered + 1 ;; increment the recovered counter
        ]
      ]

      ;; can the koala be released from hospital?
      if treatment-time > 90 ;; after 2 months treatment there is an observation time of up to 4 weeks before koalas are released back into wild so release after 90 days
      [
        set hospitalised? false
        set pcolor green
        set treatment-time 0
        set hospitalised-cnt hospitalised-cnt - 1
        set color grey
        set treatment-time 0
        set inf-severity 0
        move ;; leave the hospital
      ]
    ]
  ]
end

to check-if-dead ;; turtle procedure
  ;; if an agent's energy is negative then it dies
  if energy < 0 [
    set age-list lput [age] of self age-list
    set tot-num-dead tot-num-dead + 1
    set pop-cnt pop-cnt - 1
    if pcolor != green [set pcolor green]
    die ]
  ;; if an agent is older than the assigned lifespan it dies
  ifelse age > lifespan [
    set age-list lput [age] of self age-list

    if pcolor != green [set pcolor green]
    die
    set tot-num-dead tot-num-dead + 1 ;; increment num-dead counter
  ][
    set age age + 0.003 ;; represents 1 day/1 tick = 1/365
  ]
end

;; procedure to find an adult partner
to mate ;; a male procedure
  ;; find eligible adult females in close proximity to mate with
  ;; if there are no other males around then choose one of these females
  ;; that have the required mating energy
  if count k_females in-radius 1 with [not carrying? and adult?] = 1
      and count other k_males with [adult?] in-radius 1 = 0  [
    set partner one-of k_females with [adult?] in-radius 1 with [not carrying?] with [energy > 50]
  ]

  if partner = nobody [ stop ]

  ;; if female infected and male is not then male becomes infected
  if infected? = false and [infected?] of partner = true [
       ask self [
        set color red
        set infected? true
        set inf-severity random 4 + 1
        ]
  ]

  ;; agents lose mating-energy-threshold amount when mating
  set energy energy - mating-energy-threshold
  ;; successful mating leads to conception 100% of the time in the model
  ifelse random-float 1 < mating-chance / 100 [
    ask partner [
      set partner myself
      set carrying? true

      set energy energy - mating-energy-threshold
      set num-of-exes num-of-exes + 1


      ;; if male infected then female becomes infected too
      if [infected?] of myself = true and infected? = false [
        set infected? true
        set inf-severity random 4 + 1
        ]

      ifelse infected? [set color orange][set color yellow] ;display carrying female koalas as yellow if not infected and orange if infected (red + yellow = orange)
    ]
    ;; reset partner to nobody, so that this male agent can mate with other females immediately
    set partner nobody
    set num-of-exes num-of-exes + 1
  ][ ;; mating unsuccessful
    set partner nobody
  ] end


to reproduce ;; a female procedure
  if carrying? [
    ;; When carrying period is over, the joey leaves the mother's pouch, the mother can start afresh and can have a new partner
    ;; reset variables associated with carrying
    ifelse carry-time = 215 [ ;; if time has come for the joey to leave the mother's pouch
      set carry-time 0
      set carrying? false
      ifelse infected? [set color red][set color grey] ;; no longer carrying so set back normal colours

      ;; determine the sex of the offspring randomly if less than 50 then male otherwise female
      ifelse random 100 < 50 [
          hatch-k_males 1 [
            set pop-cnt pop-cnt + 1
            set size 1.5
            set partner nobody
            set heading random 360
            set age 0
            set adult? False
            set lifespan int median (list mean-lifespan (random-normal (mean-lifespan) (mean-lifespan / 6) ) 18)
            set hospitalised? false
            set num-of-exes 0
            set num-of-children 0
            set parent myself
            set color [color] of parent
            if color = red [
              set inf-severity random 4 + 1
              set infected? true
            ]
          ]
      ][ ;; else corresponds to the chance of having a female child
          hatch-k_females 1 [
            set pop-cnt pop-cnt + 1
            set size 1.5
            set partner nobody
            set carrying? false
            set heading random 360
            set carry-time 0
            set age 0
            set adult? False
            set lifespan int median (list mean-lifespan (random-normal (mean-lifespan) (mean-lifespan / 6) ) 18)
            set hospitalised? false
            set num-of-exes 0
            set num-of-children 0
            set parent myself
            set color [color] of parent ;; if mother is infected then so is joey
            if color = red [
              set inf-severity random 4 + 1
              set infected? true
            ]
          ]
        ]

      if partner != nobody [
        ;; if the male partner still alive, update his number of children
        ask partner [set num-of-children num-of-children + 1]
      ]
      set num-of-children num-of-children + 1 ;; update my number of children
      set partner nobody ;; this female agent can go find herself another male
    ][ ;; else case for the reproduce procedure
      set carry-time carry-time + 1  ;; update the carry-time
    ]
  ]
end


to grow-eucalyptus ;; patch procedure
  ;; regrowth-rate on brown patches: if you reach 0, grow eucalyptus
  if pcolor = brown [
    ifelse regrowth-rate <= 0
      [ set pcolor green
        set regrowth-rate eucalyptus-growth-rate ]
      [ set regrowth-rate regrowth-rate - 1 ]
  ]
end


to eat-eucalyptus ;; koala procedure
  if pcolor = green or pcolor = white ;; those in hospital (pcolor white) are being fed but not moving so account for this
  [ if pcolor = green
    [set pcolor brown]
    set energy energy + eucalyptus-energy
  ]
end


to-report season-name ;; used for season monitor
  report item seasons-list-idx seasons-list
end


to display-labels ;; add labels for the two switches: show-energy? and show-inf-severity?
  ask turtles [ set label "" ]
  if show-energy? [
    ask k_males [
      set label round energy
      set label-color blue
    ]
    ask k_females [
      set label round energy
      set label-color blue
    ]
    set show-inf-severity? false
  ]

   if show-inf-severity? [
    ask k_males [
      set label round inf-severity
      set label-color blue
    ]
    ask k_females [
      set label round inf-severity
      set label-color blue
    ]
    set show-energy? false
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
204
10
706
513
-1
-1
14.97
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
18
12
101
45
NIL
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
111
12
189
45
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

SLIDER
18
63
190
96
eucalyptus-growth-rate
eucalyptus-growth-rate
0
100
15.0
1
1
NIL
HORIZONTAL

SLIDER
18
105
190
138
eucalyptus-energy
eucalyptus-energy
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
19
148
190
181
initial-population-size
initial-population-size
0
500
151.0
1
1
NIL
HORIZONTAL

SLIDER
19
191
191
224
mean-lifespan
mean-lifespan
0
25
13.0
1
1
NIL
HORIZONTAL

SLIDER
20
235
192
268
initial-infected-pct
initial-infected-pct
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
20
279
193
312
antibiotic-effectiveness
antibiotic-effectiveness
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
20
321
193
354
annual-treated-pct
annual-treated-pct
0
100
10.0
1
1
NIL
HORIZONTAL

PLOT
717
11
935
194
Population Statistics
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
"infected" 1.0 0 -2674135 true "" "plot count turtles with [ color = red ]"
"susceptible" 1.0 0 -7500403 true "" "plot count turtles with [ color = grey ]"
"recovered" 1.0 0 -13345367 true "" "plot count turtles with [ color = blue ]"

MONITOR
1058
253
1150
298
Tot. no. dead
tot-num-dead
17
1
11

MONITOR
1057
202
1150
247
No. recovered
num-recovered
17
1
11

PLOT
718
212
933
392
Infected Koalas %
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
"default" 1.0 0 -2674135 true "" "plot count turtles with [ color = red ] / pop-cnt * 100"

MONITOR
1059
356
1151
401
Pop. count
pop-cnt
17
1
11

MONITOR
946
305
1042
350
Current hosp.
hospitalised-cnt
17
1
11

MONITOR
946
356
1043
401
Season
season-name
17
1
11

SWITCH
21
435
193
468
show-energy?
show-energy?
0
1
-1000

SWITCH
22
474
193
507
show-inf-severity?
show-inf-severity?
1
1
-1000

TEXTBOX
719
429
1225
513
- Red agents are infected\n- Grey agents are susceptible\n- Blue agents are recovered (while in hospital only)\n- Yellow agents are susceptible and either pregnant or carrying a joey\n- Orange agents are infected and either pregnant or carrying a joey\n- White patches indicate hospitalised agents
11
0.0
1

MONITOR
946
202
1040
247
No. infected
count turtles with [color = red]
17
1
11

SLIDER
20
362
192
395
mating-chance
mating-chance
0
100
85.0
1
1
NIL
HORIZONTAL

MONITOR
946
254
1042
299
No. died hosp.
num-dead-in-hosp
17
1
11

MONITOR
1058
304
1151
349
Tot. hosp.
tot-hospitalised
17
1
11

MONITOR
946
408
1152
453
Mating season?
season-name = \"Spring\" or season-name = \"Summer\"
17
1
11

PLOT
945
11
1150
193
Koala deaths by age
Age at death
Frequency
0.0
18.0
0.0
75.0
true
false
"set-histogram-num-bars 18\nset-plot-pen-mode 1 ; bar mode" ""
PENS
"default" 1.0 0 -2674135 true "" "histogram age-list"

@#$#@#$#@
## WHAT IS IT?

This model describes the spread of Chlamydia pecorum in the koala population of Australia. In some parts of Australia the koala population has declined by as much as 80% over the last few decades. Treatment facilities have reported that Chlamydia is the most lethal of all diseases affecting the animals and one of the main causes of death, second only to road accidents. 

Adult koalas catch Chlamydia just as humans do through sexual transmission. However young koalas in their mother's pouch can also become infected by eating pap which is a nutritious type of faeces excreted by infected mothers. The disease can have a devastating effect on the health of the animal result in blindness, urinary tract infections and infertility if left untreated.

## HOW IT WORKS

There are two types of agents: male koalas and female koalas. Male koalas are slightly larger than their female counterparts and have more energy to begin with. The agents move around randomly in the space using energy as they move and try to find a mate. A suitable mate is found if they are in close proximity to each other and have enough energy to mate. Koalas gain energy by eating eucalyptus leaves. 

During the mating season, Spring and Summer, koalas are much more active and therefore their movement increases.

After successful mating, the female becomes pregnant and is 'carrying' for around 7 months. Although the gestation period only 35 days, the mother carries the joey in its pouch for a further 6 months and is therefore very unlikely to mate. Hence the females won't mate if they are 'carrying' which has been defined in the model as a period of 215 days/ticks. The offspring hatches after this period and the female is free to mate again.

If the male or female koala is infected, the partner also becomes infected during mating.
100% of joeys are infected by their mother as they will all consume the pap that is produced by their mothers.

Carrying females are characterised as orange in the model if they are infected and yellow if they are not. Uninfected or susceptible koalas are displayed as grey in the model.
Infected koalas as red. If the koala is hospitalised the patch where the koala is turns white and stays white until the koala is released from hospital. Recovered koalas are marked as blue whilst they are in hospital but grey when they are released. This is because once released they are susceptible to catching Chlamydia again.

While in hospital the koala receives treatment in the form of antibiotics. These however can have the side effect of killing off the gut microbiota responsible for breaking down the toxic compound tannin from the eucalyptus leaves that is their main food source. This can result in the koalas losing weight and starving to death as they cannot digest food anymore.
Not all koalas taken to hospital can be saved. Sometimes the disease is at too a late stage to recover from and the koalas are euthanised.

If a koala is infected there are different levels of the disease which is represented by the severity assigned to the animal: 1 - asymptomatic, 2 - mild symptoms, 3 - medium symptoms, 4 - severe symptoms. The higher the severity the more energy exerted by the koala.
If an infected koala is being treated in hospital they expend less energy compared to an infected koala in the wild.

All koalas are assigned a random age and lifespan. If the koala exceeds their assigned lifespan then it dies. The koala also dies if its energy becomes negative.

The infection time is not recorded as in the wild it is not possible to tell how long a koala has had the infection.
    
## HOW TO USE IT

To initiate the model click the 'setup' button. The model is executed by clicking the 'go' button.

There are eight sliders:

- eucalyptus-growth-rate controls the rate at which the eucalyptus grows.
- eucalyptus-energy determines how much energy can be gained from eating eucalyptus leaves.
- initial-population-size allows the user to decide the initial koala population
- mean-lifespan allows the user to change the average lifespan of the koala. This can be used in the case where koala populations in different parts of Australia have different lifespans.
- initial-infected-pct allows the user to decide what % of the initial population is infected. 
- antibiotic-effectiveness allows the user to control how good an antibiotic is. 
- annual-treatment-pct allows the user to determine the percentage of koalas that are treated in hospital.
- mating-chance allows the user to decide what percentage of koalas are successful in mating. 

There are two switches:

- show-energy? displays the energy of the koala as it moves around the space
- show-inf-severity? displays the severity of the disease if the koala is infected

They cannot be used at the same time.

There are nine monitors:

- Mating season? indicates whether the current season is a mating season or not
- No. infected displays the number of infected koalas
- No. recovered shows the number of recovered koalas
- No. died hosp. displays the number of koalas that died while in hopital
- Tot. no. dead gives the total number of koalas that have died
- Current hosp. displays the number of koalas currently hospitalised
- Tot. hosp. gives the total number of koalas hospitalised including those released
- Season shows the current season which changes every 91 days
- Pop. count is a counter the displays the population count increasing over time/ticks 



## THINGS TO NOTICE

There are three plots:

- The plot “Population Statistics” represents the numbers of susceptible, infected, and recovered individuals in the population. 
- The plot "Infected Koalas %" displays the percentage of infected koalas in the population. We can notice increasing waves of infection in line with the increasing population in the "Population Statistics" plot.
- The histogram "Koala deaths by age" shows the age frequency for koalas that have died.

## THINGS TO TRY
The eucalyptus-growth-rate slider can be increased to simulate loss of habitat.

Changing the initial-infected-pct slider can be used to model the different chlamydia infection rates of koalas in different parts of Australia.

Studies have shown that different antibiotics produce varying results. Currently hospitals tend to use a combination of antibiotics but by increasing the antibiotic-effectiveness slider we can see what happens when we have a really effective antibiotic.

Currently only a small fraction of the koala population can be treated in hospital each year. Increasing the annual-treatment-pct shows that treating more koalas in hospital decreases the percentage of koalas infected significantly.

The mating-chance slider can be decreased to represent a certain level of infertility which is prevalent in a highly diseased koala population.

## EXTENDING THE MODEL

- Vaccination - in this model vaccination has not been taken into account as it is currently not commonplace. However, this could be easily added to the model.

- Males and females reach adult maturity at different ages. Males tend to mature at around 4 whereas females mature earlier at around the age of 2. The model currently uses a value in between for the adult maturity of both sexes but could be changed to reflect the differing maturities of males and females.

- Koalas seem to be more susceptible to having adverse reactions to Chlamydia if they also have Koala retrovirus KoRV-B. This could be added to the model and the severity would increase for koalas that have the retrovirus as well as Chlamydia.

- Although it is implicit that the chance of death increases with the severity of the disease, perhaps a specific koalas-own variable could be added.

- Infertility has not been explicitly added to the model although this can be currently simulated by decreasing the mating-chance.

- Koalas have a unique partner each time they mate. Females only mate once in a season and only produce around 6 offspring in a lifetime whereas males can mate 2 to 3 times a season and can have many more offspring. Therefore males and females have different numbers of partners and children.
The following variables which are already present in the model could be used to more accurately keep a track this:
num-of-exes
num-of-children

- Perhaps the model could be extended to not only show how Chlamydia affects the koala population but also other factors such as road accidents, bush fires, domestic dog attacks and loss of habitat which also contribute to the mortality of koalas and therefore the decreasing koala population.

- Normally male koalas are more active than female koalas especially during the mating season. The model could be updated to reflect this. Currently the model has the same increased rate of movement for both sexes during mating season.

- Female koalas live longer than their male counterparts. This could be reflected somehow in the lifespan of the creatures. Currently both sexes have the same mean-lifespan. 

- We could also add separate monitors to check how many koalas die in hospital following antibitoic treatment and how many are euthanised. Currently there is no distinction made.

## NETLOGO FEATURES

There are no special or unusual NetLogo features.

## RELATED MODELS

This model is based on the Covid model demonstrated in the ABM class and the Wolf-Sheep-Predation and Sex Ratio Equilibrium models in NetLogo.

## CREDITS AND REFERENCES

NetLogo Copyright 1998 Uri Wilensky.
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

footprint other
true
0
Polygon -7500403 true true 75 195 90 240 135 270 165 270 195 255 225 195 225 180 195 165 177 154 167 139 150 135 132 138 124 151 105 165 76 172
Polygon -7500403 true true 250 136 225 165 210 135 210 120 227 100 241 99
Polygon -7500403 true true 75 135 90 135 105 120 105 75 90 75 60 105
Polygon -7500403 true true 120 122 155 121 161 62 148 40 136 40 118 70
Polygon -7500403 true true 176 126 200 121 206 89 198 61 186 57 166 106
Polygon -7500403 true true 93 69 103 68 102 50
Polygon -7500403 true true 146 34 136 33 137 15
Polygon -7500403 true true 198 55 188 52 189 34
Polygon -7500403 true true 238 92 228 94 229 76

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

molecule water
false
0
Circle -1 true false 183 63 84
Circle -16777216 false false 183 63 84
Circle -7500403 true true 75 75 150
Circle -16777216 false false 75 75 150
Circle -1 true false 33 63 84
Circle -16777216 false false 33 63 84

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
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Experiment1" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>pop-cnt</metric>
    <metric>num-recovered</metric>
    <metric>num-dead-in-hosp</metric>
    <metric>tot-hospitalised</metric>
    <metric>tot-num-dead</metric>
    <metric>count turtles with [color = red] / pop-cnt * 100</metric>
    <enumeratedValueSet variable="eucalyptus-energy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lifespan">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="antibiotic-effectiveness">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-population-size">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mating-chance">
      <value value="87"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="annual-treated-pct">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eucalyptus-growth-rate">
      <value value="31"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-infected-pct">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-inf-severity?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment 2" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>pop-cnt</metric>
    <metric>num-recovered</metric>
    <metric>num-dead-in-hosp</metric>
    <metric>tot-hospitalised</metric>
    <metric>tot-num-dead</metric>
    <metric>count turtles with [color = red] / pop-cnt * 100</metric>
    <enumeratedValueSet variable="eucalyptus-energy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lifespan">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="antibiotic-effectiveness">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-population-size">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mating-chance">
      <value value="87"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="annual-treated-pct">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eucalyptus-growth-rate">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-infected-pct">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-inf-severity?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment3" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>pop-cnt</metric>
    <metric>num-recovered</metric>
    <metric>num-dead-in-hosp</metric>
    <metric>tot-hospitalised</metric>
    <metric>tot-num-dead</metric>
    <metric>count turtles with [color = red] / pop-cnt * 100</metric>
    <enumeratedValueSet variable="eucalyptus-energy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lifespan">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="antibiotic-effectiveness">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-population-size">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mating-chance">
      <value value="87"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="annual-treated-pct">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eucalyptus-growth-rate">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-infected-pct">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-inf-severity?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment4" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>pop-cnt</metric>
    <metric>num-recovered</metric>
    <metric>num-dead-in-hosp</metric>
    <metric>tot-hospitalised</metric>
    <metric>tot-num-dead</metric>
    <metric>count turtles with [color = red] / pop-cnt * 100</metric>
    <enumeratedValueSet variable="eucalyptus-energy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lifespan">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="antibiotic-effectiveness">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-population-size">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mating-chance">
      <value value="87"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="annual-treated-pct">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eucalyptus-growth-rate">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-infected-pct">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-inf-severity?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment5" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>pop-cnt</metric>
    <metric>num-recovered</metric>
    <metric>num-dead-in-hosp</metric>
    <metric>tot-hospitalised</metric>
    <metric>tot-num-dead</metric>
    <metric>count turtles with [color = red] / pop-cnt * 100</metric>
    <enumeratedValueSet variable="eucalyptus-energy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lifespan">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="antibiotic-effectiveness">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-population-size">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mating-chance">
      <value value="87"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="annual-treated-pct">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eucalyptus-growth-rate">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-infected-pct">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-inf-severity?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="eucalyptus-energy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lifespan">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="antibiotic-effectiveness">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-population-size">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mating-chance">
      <value value="87"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="annual-treated-pct">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eucalyptus-growth-rate">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-infected-pct">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-inf-severity?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment6" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>pop-cnt</metric>
    <metric>num-recovered</metric>
    <metric>num-dead-in-hosp</metric>
    <metric>tot-hospitalised</metric>
    <metric>tot-num-dead</metric>
    <metric>count turtles with [color = red] / pop-cnt * 100</metric>
    <enumeratedValueSet variable="eucalyptus-energy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lifespan">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="antibiotic-effectiveness">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-population-size">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mating-chance">
      <value value="87"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="annual-treated-pct">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eucalyptus-growth-rate">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-infected-pct">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-inf-severity?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment7" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>pop-cnt</metric>
    <metric>num-recovered</metric>
    <metric>num-dead-in-hosp</metric>
    <metric>tot-hospitalised</metric>
    <metric>tot-num-dead</metric>
    <metric>count turtles with [color = red] / pop-cnt * 100</metric>
    <enumeratedValueSet variable="eucalyptus-energy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lifespan">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="antibiotic-effectiveness">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-population-size">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mating-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="annual-treated-pct">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eucalyptus-growth-rate">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-infected-pct">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-inf-severity?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment9" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1825"/>
    <metric>pop-cnt</metric>
    <metric>num-recovered</metric>
    <metric>num-dead-in-hosp</metric>
    <metric>tot-hospitalised</metric>
    <metric>tot-num-dead</metric>
    <metric>count turtles with [color = red] / pop-cnt * 100</metric>
    <enumeratedValueSet variable="eucalyptus-energy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lifespan">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="antibiotic-effectiveness">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-population-size">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mating-chance">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="annual-treated-pct">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eucalyptus-growth-rate">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-infected-pct">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-inf-severity?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment10" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>pop-cnt</metric>
    <metric>num-recovered</metric>
    <metric>num-dead-in-hosp</metric>
    <metric>tot-hospitalised</metric>
    <metric>tot-num-dead</metric>
    <metric>count turtles with [color = red] / pop-cnt * 100</metric>
    <enumeratedValueSet variable="eucalyptus-energy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lifespan">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="antibiotic-effectiveness">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-population-size">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mating-chance">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="annual-treated-pct">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eucalyptus-growth-rate">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-infected-pct">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-inf-severity?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment11" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>pop-cnt</metric>
    <metric>num-recovered</metric>
    <metric>num-dead-in-hosp</metric>
    <metric>tot-hospitalised</metric>
    <metric>tot-num-dead</metric>
    <metric>count turtles with [color = red] / pop-cnt * 100</metric>
    <enumeratedValueSet variable="eucalyptus-energy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lifespan">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="antibiotic-effectiveness">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-population-size">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mating-chance">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="annual-treated-pct">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eucalyptus-growth-rate">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-infected-pct">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-inf-severity?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Experiment12" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3650"/>
    <metric>pop-cnt</metric>
    <metric>num-recovered</metric>
    <metric>num-dead-in-hosp</metric>
    <metric>tot-hospitalised</metric>
    <metric>tot-num-dead</metric>
    <metric>count turtles with [color = red] / pop-cnt * 100</metric>
    <enumeratedValueSet variable="eucalyptus-energy">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-lifespan">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="antibiotic-effectiveness">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-population-size">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mating-chance">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="annual-treated-pct">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eucalyptus-growth-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-infected-pct">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-inf-severity?">
      <value value="false"/>
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
