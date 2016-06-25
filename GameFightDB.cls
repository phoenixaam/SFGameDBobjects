/**
 * Created by phoenix on 18.06.2016.
 */
/**
 * The battle between two units.
 * We simulate random battles and define the winner unit.
 */
public with sharing class GameFightDB {

    private List<String> gameLog;
    private FightType fType;
    private List<Hit__c> hits;
    private List<Block__c> blocks;
    private Integer roundNumber;

    public List<String> getGameLog() {
        return gameLog;
    }

    public Integer getRoundNumber() {
        return roundNumber;
    }

    public void setFightType(FightType fType) {
        this.fType = fType;
    }

    public void setHits(List<Hit__c> hits) {
        this.hits = hits;
    }
    public void setBlocks(List<Block__c> blocks) {
        this.blocks = blocks;
    }

    public GameFightDB() {
        gameLog = new List<String>();
        roundNumber = 1;
    }

    /**
     * Defines which unit will win in the battle.
     * @param unit1
     * @param unit2
     * @return winner unit
     */
    public GameFightUnit__c fight(GameFightUnit__c unit1, GameFightUnit__c unit2) {

        while (unit1.HealthPoint__c > 0 && unit2.HealthPoint__c > 0) {
            GameFightUnit__c activeUnit = defineUnitTurn(unit1, unit2);
            if (activeUnit == unit1) {
                unit2 = oneStepFight(unit1, unit2, null, null);
            } else {
                unit1 = oneStepFight(unit2, unit1, null, null);
            }
        }
        if (unit1.HealthPoint__c > 0) {
            return unit2;
        } else {
            return unit1;
        }

    }

    public GameFightUnit__c oneStepFight(GameFightUnit__c unit1, GameFightUnit__c unit2, Hit__c hit, Block__c block) {
        if (hit == null) {
            hit = generateRandomHit();
        }
        if (block == null) {
            block = generateRandomBlock();
        }
        Integer damage = 0;
        if (block.Body_part__c == hit.Body_part__c) {
            gameLog.add(unit1.Name + ' kicks with 0 damages through the block ' + block.Body_part__r.Name);
        } else {
            damage = randomKick(unit1);
            gameLog.add(unit1.Name + ' kicks with ' + damage + ' damages.');
        }
        Decimal leftHp = unit2.HealthPoint__c - damage;
        if (leftHp > 0) {
            gameLog.add(unit2.Name + ' left ' + leftHp + ' health points.');
            unit2.HealthPoint__c = leftHp;
        } else {
            gameLog.add(unit2.Name + ' is dead.');
            unit2.HealthPoint__c = 0;
        }
        roundNumber++;
        return unit2;
    }

    // define random damage accordingly to the unit properties
    private Integer randomKick(GameFightUnit__c unit) {
        Double damageDouble = (Math.floor(Math.random() * (unit.DamageMax__c - unit.DamageMin__c + 1) + unit.DamageMin__c));
        Integer damage = damageDouble.intValue();
        return damage;
    }

    // randomizing players turn
    public GameFightUnit__c defineUnitTurn(GameFightUnit__c unit1, GameFightUnit__c unit2) {
        if (Math.random() < 0.5) {
            return(unit1);
        } else {
            return(unit2);
        }
    }

    // generate random block
    private Block__c generateRandomBlock() {
        Integer size = blocks.size();
        Integer index = 0;
        if (size > 0) {
            index = (Math.floor(Math.random() * size)).intValue();
            return blocks.get(index);
        } else {
            throw new GameFightException('There is no blocks in DB.');
        }
    }

    // generate random hit
    private Hit__c generateRandomHit() {
        Integer size = hits.size();
        Integer index = 0;
        if (size > 0) {
            index = (Math.floor(Math.random() * size)).intValue();
            return hits.get(index);
        } else {
            throw new GameFightException('There is no hits in DB.');
        }
    }
}