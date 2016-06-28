/*
 * batch for update isActive field on GameFightUnit objects
 */
global class GameFightDBBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Name, IsActive__c, DeactivationTime__c FROM GameFightUnit__c ]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<GameFightUnit__c> updateUnitList = new List<GameFightUnit__c>();
        for(GameFightUnit__c unit: (List<GameFightUnit__c>)scope){
            if (unit.DeactivationTime__c < DateTime.now().addDays(-1)) {
                unit.IsActive__c = true;
                updateUnitList.add(unit);
            }
        }
        update updateUnitList;
        system.debug(updateUnitList);
    }

    global void finish(Database.BatchableContext BC){
//        system.debug(BC);
    }
}