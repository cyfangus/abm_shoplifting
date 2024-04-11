# An Agent-based model on shoplifting scenarios

This repo stores the codes of an agent-based model simulating shoplifting in gorcery stores. With the application of Netlogo, it simulates shoplifting scenarios with the probability of detection manipulated... more updates to come.

First, it creates a terrain for the supermarket. There is one entrance, one exit, 3 x 7 aisles (grid style), and shelves oneach sides of the aisles. The coordinates and corresponding properties of each grid is stored in "supermarketTerrain.csv"

<img width="242" alt="Screenshot 2024-04-11 at 23 44 27" src="https://github.com/cyfangus/abm_shoplifting/assets/123187295/b3162bdd-7ada-4477-bc5d-f1d34974d4c5">

Then, it adds products to the shelves with randomly assigned CRAVED scores of each product. CRAVED framework was proposed by Clarke & Webb (1999). It hypothesizes the more concealable, removable, available, vulnerable, enjoyable and disposable a product, the more likely it is that they are stolen. For simplicity, we consider that all the products on a given shelves patch are the same and therefore we only need a single six-dimensional CRAVED vector per patch. You will find the CRAVED vectors in "supermarketCRAVED.csv"

After that, we introduce agents into the terrain. One regular customer is created every 10 ticks and 'walk' into the supermarket. They would walk in random direction and browse products on the shelves, similuating daily situations in supermarket. And then a shoplifter is generated at time=500. And security guards are introduced.

By adjusting the probability the security guards being able to detect a shoplifting, and the probability that the shoplifter detecting a security guards nearby, the simulation allows us to answer the question: how does the number of shoplifters caught in the act of shoplifting vary when guardians are better trained to detect shoplifting acts?

<img width="733" alt="Screenshot 2024-04-12 at 00 15 02" src="https://github.com/cyfangus/abm_shoplifting/assets/123187295/5c023f2a-2258-41af-8ab3-78940bb20dd1">

