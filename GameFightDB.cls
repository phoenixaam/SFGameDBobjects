/**
 * The battle between two units.
 * We simulate random battles and define the winner unit.
 */
public with sharing class GameFightDB {

    private List<String> gameLog;
    private List<Hit__c> hits;
    private List<Block__c> blocks;
    private Integer roundNumber;

    public List<String> getGameLog() {
        return gameLog;
    }

    public Integer getRoundNumber() {
        return roundNumber;
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
     * @return looser unit
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

    /*
    * defines which unit win in particular step
    * throws exception if one of units is null
    * @param: unit1
    * @param: unit2
    * @param: hit - can be null
    * @param: block - can be null
     */
    public GameFightUnit__c oneStepFight(GameFightUnit__c unit1, GameFightUnit__c unit2, Hit__c hit, Block__c block) {
        if (unit1 == null || unit2 == null) {
            throw new GameFightException('Wrong parameter in oneStepFight(): Unit in fight can not be null');
        }
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
        Decimal leftHp = unit2.HealthPoint__c;
        if (damage > 0) {
            leftHp = leftHp - damage;
            if (unit2.Stamina__c > 0) {
                unit2.Stamina__c = unit2.Stamina__c - 1;
            }
        }
        if (leftHp > 0) {
            gameLog.add(unit2.Name + ' left ' + leftHp + ' health points, stamina left ' + unit2.Stamina__c + '%.');
            unit2.HealthPoint__c = leftHp;
        } else {
            gameLog.add(unit2.Name + ' is dead.');
            unit2.HealthPoint__c = 0;
        }
        roundNumber++;
        return unit2;
    }

    /*
     * defines random damage accordingly to the unit properties
     * @param: unit
     * @return: damage
     */
    private Integer randomKick(GameFightUnit__c unit) {
        Double damageDouble = (Math.floor((Math.random() * (unit.DamageMax__c - unit.DamageMin__c + 1) +
                unit.DamageMin__c) * unit.Stamina__c / 100));
        Integer damage = damageDouble.intValue();
        return damage;
    }

    /*
     * randomize players turn
     * @param: unit1
     * @param: unit2
     * @return: unit
     */
    public GameFightUnit__c defineUnitTurn(GameFightUnit__c unit1, GameFightUnit__c unit2) {
        if (Math.random() < 0.5) {
            return(unit1);
        } else {
            return(unit2);
        }
    }

    /*
     * get random block
     * throws exception if list of available blocks is empty
     */
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

    /*
     * get random hit
     * throws exception if list of available hits is empty
     */
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