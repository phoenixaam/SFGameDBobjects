/*
 * test trigger on GameFightUnit__c
 */

@isTest
public with sharing class GameFightCalcRankTest {
    @testSetup
    static void setup() {
        // prepare data
        GameFightUnit__c unit1 = new GameFightUnit__c(Name = 'Unit1', HealthPoint__c = 100, DamageMax__c = 10, VictoryCount__c = 0);
        GameFightUnit__c unit2 = new GameFightUnit__c(Name = 'Unit2', HealthPoint__c = 100, DamageMax__c = 10, VictoryCount__c = 0);
        GameFightUnit__c unit3 = new GameFightUnit__c(Name = 'Unit3', HealthPoint__c = 100, DamageMax__c = 10, VictoryCount__c = 0);
        List<GameFightUnit__c> units = new List<GameFightUnit__c>();
        units.add(unit1);
        units.add(unit2);
        units.add(unit3);
        insert units;
        Fight__c fight1 = new Fight__c(Winner__c = unit1.Id, Looser__c = unit2.Id);
        Fight__c fight2 = new Fight__c(Winner__c = unit1.Id, Looser__c = unit3.Id);
        Fight__c fight3 = new Fight__c(Winner__c = unit2.Id, Looser__c = unit3.Id);
        Fight__c fight4 = new Fight__c(Winner__c = unit3.Id, Looser__c = unit1.Id);
        Fight__c fight5 = new Fight__c(Winner__c = unit3.Id, Looser__c = unit1.Id);
        Fight__c fight6 = new Fight__c(Winner__c = unit3.Id, Looser__c = unit2.Id);
        Fight__c fight7 = new Fight__c(Winner__c = unit3.Id, Looser__c = unit2.Id);
        List<Fight__c> fights = new List<Fight__c>();
        fights.add(fight1);
        fights.add(fight2);
        fights.add(fight3);
        fights.add(fight4);
        fights.add(fight5);
        fights.add(fight6);
        fights.add(fight7);
        insert fights;
    }


    static testMethod void testBehavior() {

        // test one record saving
        List<GameFightUnit__c> units = [
                SELECT Id, Name, VictoryCount__c
                FROM GameFightUnit__c
                WHERE Name IN ('Unit1', 'Unit2', 'Unit3')
                ORDER BY Id
        ];
        GameFightUnit__c unit1 = units.get(0);
        GameFightUnit__c unit2 = units.get(1);
        GameFightUnit__c unit3 = units.get(2);
        unit1.VictoryCount__c = 1;
        update unit1;
        update unit2;
        List<GameFightUnit__c> unitsAfterTest = [
                SELECT Id, Name, Rank__c, VictoryCount__c
                FROM GameFightUnit__c
                WHERE Id IN (:unit1.Id, :unit2.Id)
                ORDER BY Id
        ];
        GameFightUnit__c unit1AfterTest = unitsAfterTest.get(0);
        GameFightUnit__c unit2AfterTest = unitsAfterTest.get(1);
        System.assertEquals(1, unitsAfterTest.get(0).Rank__c, 'wrong rank1');
        System.assertEquals(2, unitsAfterTest.get(1).Rank__c, 'wrong rank2');

        // test many records saving
        List<GameFightUnit__c> unitsForTest = new List<GameFightUnit__c>();
        unit1.VictoryCount__c = 2;
        unit2.VictoryCount__c = 1;
        unit3.VictoryCount__c = 4;
        unitsForTest.add(unit1);
        unitsForTest.add(unit2);
        unitsForTest.add(unit3);
        update unitsForTest;

        unitsAfterTest = [
                SELECT Id, Name, Rank__c, VictoryCount__c, Percent_of_success__c
                FROM GameFightUnit__c
                WHERE Id IN (:unit1.Id, :unit2.Id, :unit3.Id)
                ORDER BY Id
        ];

        System.assertEquals(2, unitsAfterTest.get(0).Rank__c, 'wrong rank1');
        System.assertEquals(3, unitsAfterTest.get(1).Rank__c, 'wrong rank2');
        System.assertEquals(1, unitsAfterTest.get(2).Rank__c, 'wrong rank3');

        // check getting data from Fights and calculate percent
        System.assertEquals(50, unitsAfterTest.get(0).Percent_of_success__c, 'wrong percent_of_success1');
        System.assertEquals(25, unitsAfterTest.get(1).Percent_of_success__c, 'wrong percent_of_success2');
        System.assertEquals(66.67, ((Decimal) Math.roundToLong(unitsAfterTest.get(2).Percent_of_success__c * 100)) / 100, 'wrong percent_of_success3');

    }
}