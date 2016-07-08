/*
 * Test for Batch update Stamina__c and IsActive
 */
@IsTest
private class GameFightDBBatchTest {

    @testSetup
    static void setup() {
        // prepare data
        List<GameFightUnit__c> units = new List<GameFightUnit__c>();
        for (Integer i = 0; i < 100; i++) {
            GameFightUnit__c unit1 = new GameFightUnit__c(Name = 'Unit1', HealthPoint__c = 100, DamageMax__c = 10,
                    VictoryCount__c = 0, IsActive__c = false, DeactivationTime__c = DateTime.now().addDays(-2), Stamina__c = 0);
            GameFightUnit__c unit2 = new GameFightUnit__c(Name = 'Unit1', HealthPoint__c = 100, DamageMax__c = 10,
                    VictoryCount__c = 0, IsActive__c = true, DeactivationTime__c = DateTime.now().addDays(-2), Stamina__c = 0);
            units.add(unit1);
            units.add(unit2);
        }
        insert units;
    }

    @isTest
    static void testBehavior() {

        Test.startTest();

        GameFightDBBatch batch = new GameFightDBBatch();
        Database.executebatch(batch);

        Test.stopTest();

        // Now that the batch has executed after Test.stopTest(),
        // check if records were updated.
        List<GameFightUnit__c> units = [
                SELECT Id, Stamina__c
                FROM GameFightUnit__c
                WHERE IsActive__c = true
        ];

        System.assertEquals(200, units.size());
        System.assertEquals(100, units.get(0).Stamina__c);
    }
}