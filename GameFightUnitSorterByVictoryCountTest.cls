@IsTest
private class GameFightUnitSorterByVictoryCountTest {
    static testMethod void testBehavior() {
        // Add the opportunity wrapper objects to a list.
        GameFightUnitSorterByVictoryCount[] unitList = new List<GameFightUnitSorterByVictoryCount>();
        Date closeDate = Date.today().addDays(10);
        unitList.add(new GameFightUnitSorterByVictoryCount(new GameFightUnit__c(
                Name = 'Unit1', HealthPoint__c = 100, VictoryCount__c = 1)));
        unitList.add(new GameFightUnitSorterByVictoryCount(new GameFightUnit__c(
                Name = 'Unit2', HealthPoint__c = 100, VictoryCount__c = 2)));
        unitList.add(new GameFightUnitSorterByVictoryCount(new GameFightUnit__c(
                Name = 'Unit3', HealthPoint__c = 100, VictoryCount__c = 0)));

        // Sort the wrapper objects using the implementation of the
        // compareTo method.
        unitList.sort();

        // Verify the sort order
        System.assertEquals('Unit2', unitList[0].getUnit().Name);
        System.assertEquals('Unit1', unitList[1].getUnit().Name);
        System.assertEquals('Unit3', unitList[2].getUnit().Name);

        // Write the sorted list contents to the debug log.
        System.debug(unitList);
    }
}