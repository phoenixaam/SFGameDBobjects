/**
 * Created by phoenix on 18.06.2016.
 */
/**
 * The battle between two units.
 * We simulate random battles and define the winner unit.
 */
public with sharing class GameFightDB {

    public List<String> gameLog;

    public List<String> getGameLog() {
        return gameLog;
    }

    public GameFightDB() {
        gameLog = new List<String>();
    }

    /**
     * Defines which unit will win in the battle.
     * @param unit1
     * @param unit2
     * @return winner unit
     */
    public GameFightUnit__c fight(GameFightUnit__c unit1, GameFightUnit__c unit2) {

        while (unit1.HealthPoint__c > 0 && unit2.HealthPoint__c > 0) {
            if (Math.random() < 0.5) {    // randomizing players turn
                round(unit1, unit2);
            } else {
                round(unit2, unit1);
            }
        }
        if (unit1.HealthPoint__c > 0) {
            return unit1;
        } else {
            return unit2;
        }

    }

    private void round(GameFightUnit__c unit1, GameFightUnit__c unit2) {
//        Decimal leftHp = unit1.HealthPoint__c - randomKick(unit2);
        Block__c block = generateRandomBlock();
        system.debug(block.Body_part__r.Name);
        Hit__c hit = generateRandomHit();
        system.debug(hit.Body_part__r.Name);
        Decimal leftHp = unit1.HealthPoint__c - randomKickWithHitAndBlock(unit2, block, hit);
        if (leftHp > 0) {
            gameLog.add(unit1.Name + ' left ' + leftHp + ' health points.');
            unit1.HealthPoint__c = leftHp;
        } else {
            gameLog.add(unit1.Name + ' is dead.');
            unit1.HealthPoint__c = 0;
        }
    }

    private Integer randomKick(GameFightUnit__c unit) {
        Double damageDouble = (Math.floor(Math.random() * (unit.DamageMax__c - unit.DamageMin__c + 1) + unit.DamageMin__c));
        Integer damage = damageDouble.intValue();
        gameLog.add(unit.Name + ' kicks with ' + damage + ' damages.');
        return damage;
    }

    private Integer randomKickWithHitAndBlock(GameFightUnit__c unit, Block__c block, Hit__c hit) {
        Double damageDouble = (Math.floor(Math.random() * (unit.DamageMax__c - unit.DamageMin__c + 1) + unit.DamageMin__c));
        Integer damage = damageDouble.intValue();
        if (block.Body_part__c == hit.Body_part__c) {
            damage = 0;
            gameLog.add(unit.Name + ' kicks with ' + damage + ' damages through the block '+block.Body_part__r.Name);
        } else {
            gameLog.add(unit.Name + ' kicks with ' + damage + ' damages.');
        }
        return damage;
    }

    // generate random block
    private Block__c generateRandomBlock() {
        List<Block__c> blocks = [
                SELECT Id, Body_part__r.Id, Body_part__r.Name
                FROM Block__c
        ];
        Integer size = blocks.size();
        Integer index = 0;
        if (size > 0) {
            index = (Math.floor(Math.random() * size)).intValue();
            return blocks.get(index);
        }
        return new Block__c(Body_part__c = 'Noname' + String.valueOf(Math.random() * 1000));
    }

    // generate random hit
    private Hit__c generateRandomHit() {
        List<Hit__c> hits = [
                SELECT Id, Body_part__r.Id, Body_part__r.Name
                FROM Hit__c
        ];
        Integer size = hits.size();
        Integer index = 0;
        if (size > 0) {
            index = (Math.floor(Math.random() * size)).intValue();
            return hits.get(index);
        }
        return new Hit__c(Body_part__c = 'Noname' + String.valueOf(Math.random() * 1000));
    }
    //todo: put retrieving data from DB (blocks && hits) to constructor and lists to vars
}