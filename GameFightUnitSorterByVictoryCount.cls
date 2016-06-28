/*
 * sorter for GameFightUnit__c objects by rank
 */
public with sharing class GameFightUnitSorterByVictoryCount implements Comparable {
    private GameFightUnit__c unit;

    public GameFightUnit__c getUnit(){
        return unit;
    }

    public GameFightUnitSorterByVictoryCount(GameFightUnit__c unit) {
        this.unit = unit;
    }

    public Integer compareTo(Object compareObject) {
        // Cast argument to GameFightUnitSorter
        GameFightUnitSorterByVictoryCount compareToUnitSorter = (GameFightUnitSorterByVictoryCount) compareObject;
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (unit.VictoryCount__c < compareToUnitSorter.unit.VictoryCount__c) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (unit.VictoryCount__c > compareToUnitSorter.unit.VictoryCount__c) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        return returnValue;
    }

}