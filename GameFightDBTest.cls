@IsTest(SeeAllData = false)
private class GameFightDBTest {


    @testSetup
    static void setup() {
        // prepare data for generate random ... methods

    }

    /*
     * test battle in auto-fight mode
     */
    static testMethod void testAutoFight() {
        List<Block__c> blocks = new List<Block__c>();
        List<Hit__c> hits = new List<Hit__c>();
        List<Body_part__c> body_parts = new List<Body_part__c>();

        for (Integer i = 0; i < 5; i++) {
            Body_part__c bodyPart = new Body_part__c(Name = 'bodyPart'+i);
            insert bodyPart;
            body_parts.add(bodyPart);
            blocks.add(new Block__c(Body_part__c = bodyPart.Id));
            hits.add(new Hit__c(Body_part__c = bodyPart.Id));
        }
        insert blocks;
        insert hits;

        GameFightUnit__c gameUnit1 = new GameFightUnit__c(name='TestUnit1', HealthPoint__c = 100,
                DamageMin__c = 1, DamageMax__c = 2);
        GameFightUnit__c gameUnit2 = new GameFightUnit__c(name='TestUnit2', HealthPoint__c = 100,
                DamageMin__c = 1, DamageMax__c = 2);

        GameFightDB game = new GameFightDB();
        game.setBlocks(blocks);
        game.setHits(hits);


//        System.Test.startTest();
        GameFightUnit__c winner;
        for(Integer i = 0; i<20;i++){
            winner = game.fight(gameUnit1, gameUnit2);
        }
//        System.Test.stopTest();

        System.assertNotEquals(null, winner, 'return null!');
        System.assertEquals(true, winner==gameUnit1||winner==gameUnit2, 'wrong return unit!');

        System.assertEquals(true, game.getRoundNumber()>0);
        System.assertEquals(true, game.getGameLog().size()>0);




    }

    /*
     * test exceptions in auto-fight mode
     */
    static testMethod void testAutoFightExceptions() {
        GameFightUnit__c gameUnit1 = new GameFightUnit__c(name='TestUnit1', HealthPoint__c = 100,
                DamageMin__c = 1, DamageMax__c = 2);
        GameFightUnit__c gameUnit2 = new GameFightUnit__c(name='TestUnit2', HealthPoint__c = 100,
                DamageMin__c = 1, DamageMax__c = 2);
        List<Block__c> blocks = new List<Block__c>();
        List<Hit__c> hits = new List<Hit__c>();
//        System.debug('hits_size'+hits.size());
        GameFightDB game2 = new GameFightDB();
        game2.setHits(hits);
        game2.setBlocks(blocks);
        String message = '';
        GameFightUnit__c winner2;
        Integer i=0;
        while (i<20){
            i++;
            try{
                winner2 = game2.fight(gameUnit1, gameUnit2);
            } catch(GameFightException e){
                message = e.getMessage();
            }
        }

        if(message.contains('hits')){
            System.assertEquals('There is no hits in DB.', message, 'wrong exception message');
        } else if (message.contains('blocks')){
            System.assertEquals('There is no blocks in DB.', message, 'wrong exception message');
        } else {
            System.assertNotEquals('', message, 'message must contains error description!');
        }

        System.assertEquals(null, winner2, 'return object instead of null');
    }


    /*
     * test units turn defining
     */
    static testMethod void testDefineUnitTurn() {
        GameFightUnit__c gameUnit1 = new GameFightUnit__c();
        GameFightUnit__c gameUnit2 = new GameFightUnit__c();
        GameFightDB game = new GameFightDB();
        GameFightUnit__c result;
        Integer i=0;
        while (i<100) {
            i++;
            result = game.defineUnitTurn(gameUnit1, gameUnit2);
        }
        System.assertEquals(true, result==gameUnit1||result==gameUnit2, 'wrong return unit!');

    }
}