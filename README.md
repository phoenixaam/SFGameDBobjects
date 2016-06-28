# SFGameDBobjects
The battle between two units.
<p> Tasks:</p>
<li>Every unit has own life (healthPoint) and strength (damageMin, damageMax).</li>
<li>We should simulate random battles and define the winner.</li>
<li>GameUnits should be saved in DB.</li>
<li>It should be a VFpage with game, where we can choose the unit, create the unit, start the game and see the results of battle.</li>
<li>When unit is defeated, it should be inactive for some period (24 hours). 
User and computer mustn't be able to choose disabled unit for fight.</li>
<li>While fighting, user should be able to choose where to hit and where to place block.
If the user's kick matches with opponent's block - damage will not be applied and vise versa.</li>


<p> Changes:</p>
<li> GameFightDB.cls created with the same logic as in SalesForceGame </li>
<li> GameFightDB.page with GameFightDBController.cls created</li>
<li> added methods: </li>
<li> to get list of active Units from DB</li>
<li> to retrieve random unit from DB to fight with user</li>
<li> to check inactive units and make them active if inactivity period is expired</li>
<li> to fight</li>
<li> to deactivate dead unit </li>
<li> to generate the units picklist based on the active units in DB except chosen system unit</li>
<li> to assign chosen user unit to userUnit if selection is proper</li>
<li> to check if user fill all the unit's fields correctly</li>
<li> to save user created unit</li>
<li> to save fight results to the DB</li>
<li> added sObject: </li>
<li> Game_Fight__c - The Game (can store the game parameters such as time of inactivity dead user) </li>
<li> GameFightUnit__c - Unit</li>
<li> Fight__c - Results of the battles (winner, looser, game log)</li>
<li> Block__c - block</li>
<li> Hit__c - hit </li>
<li> Body_part__c - list body parts for blocking and hitting</li>

<p> Implemented AutoFight functionality as well as StepByStep Fight</p>
<p> Added Tests for all classes</p>
<p> Added trigger for updating Unit's fields Rank__c and Percent_of_success__c depend on VictoryCount__c and the total number of fights by Unit</p>
<p> Added Butch for update fiels IsActive every 12 hours</p>
