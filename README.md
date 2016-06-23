# SFGameDBobjects
The battle between two units.
Every unit has own life (healthPoint) and strength (damageMin, damageMax).
We should simulate random battles and define the winner.
GameUnits should be saved in DB.
It should be a VFpage with game, where we can choose the unit, create the unit, start the game and see the results of battle.
When unit is defeated, it should be inactive for some period (24 hours). 
User and computer mustn't be able to choose disabled unit for fight.
While fighting, user should be able to choose where to hit and where to place block.
If the user's kick matches with opponent's block - damage will not be applied and vise versa.
