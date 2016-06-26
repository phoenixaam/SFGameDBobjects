@IsTest
private class FieldsCheckerTest {
    static testMethod void testBehavior() {
        GameFightUnit__c unit = new GameFightUnit__c(Name = 'Test');
        System.assertEquals(true, FieldsChecker.hasSObjectField(unit, 'Test'), 'can not find existing field');
        System.assertEquals(false, FieldsChecker.hasSObjectField(unit, 'Id'), 'can find not existing field');
    }


}
