  /*
   * Test for  GameFightDBBatch and GameFightDBBatchScheduled
   */
@IsTest
private class GameFightDBBatchScheduledTest {
    // CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    @testSetup
    static void setup() {
        // prepare data
        GameFightUnit__c unit1 = new GameFightUnit__c(Name = 'Unit1', HealthPoint__c = 100, DamageMax__c = 10,
                VictoryCount__c = 0, IsActive__c = false, DeactivationTime__c = DateTime.now().addDays(-2), Stamina__c = 0);
        insert unit1;
    }

    @isTest
    static void testBehavior() {
        Test.startTest();

        // Schedule the test job
        String jobId = System.schedule('GameFightDBBatchScheduled',
                CRON_EXP,
                new GameFightDBBatchScheduled());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [
                SELECT Id, CronExpression, TimesTriggered,
                        NextFireTime
                FROM CronTrigger
                WHERE id = :jobId
        ];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP,
                ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2022-03-15 00:00:00',
                String.valueOf(ct.NextFireTime));

        Test.stopTest();

        // Now that the scheduled job has executed after Test.stopTest(),
        // check if records were updated.
        List<GameFightUnit__c> units = [
                SELECT Id
                FROM GameFightUnit__c
                WHERE IsActive__c = true
        ];
        System.assertEquals(1, units.size());
        System.assertEquals(100, units.get(0).Stamina__c);
    }
}