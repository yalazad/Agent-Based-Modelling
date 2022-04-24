# Agent-Based-Modelling - Chlamydial Disease in Koalas
![image](https://user-images.githubusercontent.com/11303258/164977845-918f395a-3395-4433-98a9-4d6df09989b9.png)

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
