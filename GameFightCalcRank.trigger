/*
 * defines rank of the unit and updates it
 */
trigger GameFightCalcRank on GameFightUnit__c (before update, before insert) {

    if (Trigger.isInsert) {
        //It's unnecessary to check VictoryCount__c when the unit is saving at the very first time,
        // because the saving method fired, when battle has not started yet.

    }

    Map<Id, GameFightUnit__c> unitsOld = Trigger.oldMap;
    Map<Id, GameFightUnit__c> unitsNew = Trigger.newMap;
    System.debug('trigger fired on' + Trigger.new);
    if (Trigger.isUpdate) {
        Integer changedVictoryCountUnits = 0;
        for (GameFightUnit__c unit: Trigger.new) {
            if (unitsOld.get(unit.Id).VictoryCount__c != unitsNew.get(unit.Id).VictoryCount__c) {
                changedVictoryCountUnits++;
            }
        }
        System.debug('changedVictoryCountUnits=' + changedVictoryCountUnits);
        if (changedVictoryCountUnits > 0) {
            List<GameFightUnit__c> otherUnits = [
                    SELECT Id, VictoryCount__c, Rank__c
                    FROM GameFightUnit__c
                    WHERE Id NOT IN :Trigger.new
            ];
            List<GameFightUnit__c> newUnits = Trigger.new;
            List<GameFightUnit__c> allUnits = new List<GameFightUnit__c>();
            allUnits.addAll(newUnits);
            allUnits.addAll(otherUnits);
            // create List of sorter wrappers
            List<GameFightUnitSorterByVictoryCount> allUnitsSorter = new List<GameFightUnitSorterByVictoryCount>();
            System.debug('allUnits.size=' + allUnits.size());
            for (GameFightUnit__c unit: allUnits) {
                allUnitsSorter.add(new GameFightUnitSorterByVictoryCount(unit));
            }
            allUnitsSorter.sort();

            List<Fight__c> fights = [
                    SELECT Winner__c, Looser__c
                    FROM Fight__c
            ];
            Map<Id, Integer> fightsByUnit = new Map<Id, Integer>();
            for (Fight__c fight: fights) {
                if (fightsByUnit.containsKey(fight.Winner__c)) {
                    fightsByUnit.put(fight.Winner__c, fightsByUnit.get(fight.Winner__c) + 1);
                } else {
                    fightsByUnit.put(fight.Winner__c, 1);
                }
                if (fightsByUnit.containsKey(fight.Looser__c)) {
                    fightsByUnit.put(fight.Looser__c, fightsByUnit.get(fight.Looser__c) + 1);
                } else {
                    fightsByUnit.put(fight.Looser__c, 1);
                }
            }
            List<GameFightUnit__c> unitsToUpdate = new List<GameFightUnit__c>();
            Integer newRank = 0;
            System.debug('allUnitsSorter.size=' + allUnitsSorter.size());
            for (GameFightUnitSorterByVictoryCount sorter: allUnitsSorter) {
                newRank++;
                GameFightUnit__c unit = sorter.getUnit();
                unit.Rank__c = newRank;
                Integer allFightsByUnit = 1;
                if (fightsByUnit.containsKey(unit.Id)) {
                    allFightsByUnit = fightsByUnit.get(unit.Id);
                }
                System.debug('unit.VictoryCount__c=' + unit.VictoryCount__c);
                System.debug('allFightsByUnit=' + allFightsByUnit);

                unit.Percent_of_success__c = (unit.VictoryCount__c / allFightsByUnit) * 100;
                System.debug('unit.Percent_of_success__c=' + unit.Percent_of_success__c);
                if (unitsNew.containsKey(unit.Id)) {
                    //skip
                } else {
                    unitsToUpdate.add(unit);
                }
            }

            update unitsToUpdate;

        }
        //nothing to do

    }

}