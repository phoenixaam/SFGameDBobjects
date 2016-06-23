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
        Decimal leftHp = unit1.HealthPoint__c - randomKick(unit2);
        if (leftHp > 0) {
            gameLog.add(unit1.Name + ' left ' + leftHp + ' health points.');
            unit1.HealthPoint__c = leftHp;
        } else {
            gameLog.add(unit1.Name + ' is dead.');
            unit1.HealthPoint__c = 0;
        }
    }

    private Integer randomKick(GameFightUnit__c unit) {
        Double damageDouble = (Math.floor(Math.random() * (unit.DamageMax__c - unit.DamageMin__c + 1) + unit.DamageMax__c));
        Integer damage = damageDouble.intValue();
        gameLog.add(unit.Name + ' kicks with ' + damage + ' damages.');
        return damage;
    }

}