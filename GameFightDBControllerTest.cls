@IsTest
private class GameFightDBControllerTest {

    @testSetup static void methodName() {
        // create units
        GameFightUnit__c gameUnit1 = new GameFightUnit__c(name = 'TestUnit1', HealthPoint__c = 100, Stamina__c = 100, DamageMin__c = 1, DamageMax__c = 2);
        GameFightUnit__c gameUnit2 = new GameFightUnit__c(name = 'TestUnit2', HealthPoint__c = 100, Stamina__c = 100, DamageMin__c = 1, DamageMax__c = 2);
        GameFightUnit__c gameUnit3 = new GameFightUnit__c(name = 'TestUnit3', HealthPoint__c = 100, Stamina__c = 100, DamageMin__c = 1, DamageMax__c = 2);
        GameFightUnit__c gameUnit4 = new GameFightUnit__c(name = 'TestUnit4', HealthPoint__c = 100, Stamina__c = 100, DamageMin__c = 1, DamageMax__c = 2,
                DeactivationTime__c = DateTime.now().addDays(-2));
        List<GameFightUnit__c> activeTestUnits = new List<GameFightUnit__c>();
        activeTestUnits.add(gameUnit1);
        activeTestUnits.add(gameUnit2);
        activeTestUnits.add(gameUnit3);
        activeTestUnits.add(gameUnit4);
        insert activeTestUnits;
        //create bodyParts
        Body_part__c bp1 = new Body_part__c(Name = 'bp1');
        Body_part__c bp2 = new Body_part__c(Name = 'bp2');
        Body_part__c bp3 = new Body_part__c(Name = 'bp3');
        List<Body_part__c> bps = new List<Body_part__c>();
        bps.add(bp1);
        bps.add(bp2);
        bps.add(bp3);
        insert bps;
        //create hits
        Hit__c hit1 = new Hit__c(Body_part__c = bp1.Id);
        Hit__c hit2 = new Hit__c(Body_part__c = bp2.Id);
        Hit__c hit3 = new Hit__c(Body_part__c = bp3.Id);
        List<Hit__c> testHits = new List<Hit__c>();
        testHits.add(hit1);
        testHits.add(hit2);
        testHits.add(hit3);
        insert testHits;
        //create blocks
        Block__c block1 = new Block__c(Body_part__c = bp1.Id);
        Block__c block2 = new Block__c(Body_part__c = bp2.Id);
        Block__c block3 = new Block__c(Body_part__c = bp3.Id);
        List<Block__c> testBlocks = new List<Block__c>();
        testBlocks.add(block1);
        testBlocks.add(block2);
        testBlocks.add(block3);
        insert testBlocks;
    }

    /*
     * test saveNewUnit() method
     */
    static testMethod void testNewUnitSave() {
        PageReference pageRef = Page.GameFightDB;
        Test.setCurrentPage(pageRef);

        GameFightDBController controller = new GameFightDBController();

        String userChoice = '';

        GameFightUnit__c newRightUserUnit = new GameFightUnit__c(Name = 'testunit', HealthPoint__c = 10, Stamina__c = 100, DamageMin__c = 1, DamageMax__c = 5);
        GameFightUnit__c newWrongNameUserUnit = new GameFightUnit__c(Name = '', HealthPoint__c = 10, Stamina__c = 100, DamageMin__c = 0, DamageMax__c = 5);
        GameFightUnit__c newWrongHealthUserUnit = new GameFightUnit__c(Name = 'testunit', HealthPoint__c = 0, Stamina__c = 100, DamageMin__c = 0, DamageMax__c = 5);
        GameFightUnit__c newWrongDamageUserUnit = new GameFightUnit__c(Name = 'testunit', HealthPoint__c = 10, Stamina__c = 100, DamageMin__c = 10, DamageMax__c = 5);

        controller.newUserUnit = newRightUserUnit;
        controller.saveNewUnit();
        System.assertEquals(newRightUserUnit, controller.userUnit, 'newUserUnit was not saved.');

        List<GameFightUnit__c> testsaves = [
                SELECT Name
                FROM GameFightUnit__c
                WHERE Id = :controller.userUnit.Id
        ];

        System.assertEquals('testunit', testsaves.get(0).Name, 'Name does not equal.');

        controller.newUserUnit = newWrongNameUserUnit;
        controller.saveNewUnit();
        System.assertEquals('Please fill the all user properties.', controller.errorMessage, 'No message.');
        controller.newUserUnit = newWrongHealthUserUnit;
        controller.saveNewUnit();
        System.assertEquals('Please fill the all user properties.', controller.errorMessage, 'No message.');
        controller.newUserUnit = newWrongDamageUserUnit;
        controller.saveNewUnit();
        System.assertEquals('Please fill the all user properties.', controller.errorMessage, 'No message.');
    }
    /*
     * test creation select list of units
     */
    static testMethod void testUnitSelectListCreation() {
        GameFightDBController controller = new GameFightDBController();
        controller.activeUnits = new List<GameFightUnit__c>();
        List<SelectOption> options;
        //Test no record list
        options = controller.getUserUnitSelectList();
        System.assertEquals(1, options.size(), 'empty list of Units creation');
        controller.activeUnits = [
                select Id, Name, HealthPoint__c, Stamina__c, DamageMin__c, DamageMax__c, IsActive__c, DeactivationTime__c
                from GameFightUnit__c
                where IsActive__c = true
        ];
        //Test many records list
        options = controller.getUserUnitSelectList();
        System.assertEquals(5, options.size(), 'many records list of Units creation');
    }

    /*
     * test creation select list of hits
     */
    static testMethod void testHitSelectListCreation() {
        GameFightDBController controller = new GameFightDBController();
        controller.hits = new List<Hit__c>();
        List<SelectOption> options;
        //Test no record list
        options = controller.getUserHitSelectList();
        System.assertEquals(1, options.size(), 'empty list of Hits creation');
        controller.hits = [
                SELECT Id, Body_part__r.Id, Body_part__r.Name
                FROM Hit__c
        ];
        //Test many records list
        options = controller.getUserHitSelectList();
        System.assertEquals(4, options.size(), 'many records list of Hits creation');
    }

    /*
     * test creation select list of blocks
     */
    static testMethod void testBlockSelectListCreation() {
        GameFightDBController controller = new GameFightDBController();
        controller.blocks = new List<Block__c>();
        List<SelectOption> options;
        //Test no record list
        options = controller.getUserBlockSelectList();
        System.assertEquals(1, options.size(), 'empty list of Blocks creation');
        controller.blocks = [
                SELECT Id, Body_part__r.Id, Body_part__r.Name
                FROM Block__c
        ];
        //Test many records list
        options = controller.getUserBlockSelectList();
        System.assertEquals(4, options.size(), 'many records list of Blocks creation');
    }

    /*
     * test initGameUnits() method
     */
    static testMethod void testInitGameUnits() {
        GameFightDBController controller = new GameFightDBController();
        controller.initGameUnits();
        System.assertEquals(4, controller.activeUnits.size(), 'get list of active units');
        System.assertEquals(3, controller.hits.size(), 'get list of hits');
        System.assertEquals(3, controller.blocks.size(), 'get list of blocks');
        System.assertEquals(true, controller.systemUnit.Name.startsWith('TestUnit'), 'get systemUnit from list of active units');
        System.assertEquals('', controller.userUnit.Name, 'assign userUnit');
        System.assertEquals(true, controller.game != null, 'assign game');
        System.assertEquals(0, controller.gameLog.size(), 'get empty list of logs');
    }

    /*
     * test chooseUnit() method
     */
    static testMethod void testChooseUnit() {
        GameFightDBController controller = new GameFightDBController();
        GameFightUnit__c newRightUserUnit = new GameFightUnit__c(Name = 'testunit', HealthPoint__c = 10, Stamina__c = 100, DamageMin__c = 0, DamageMax__c = 5);
        insert newRightUserUnit;
        controller.activeUnits = new List<GameFightUnit__c>();
        controller.activeUnits.add(newRightUserUnit);
        String choice = newRightUserUnit.Id;
        controller.userChoice = choice;
        controller.chooseUnit();
        System.assertEquals(newRightUserUnit, controller.userUnit, 'assign userUnit');
    }

    /*
     * test pushing the AutoFight button
     */
    static testMethod void testAutoFightButton() {
        GameFightDBController controller = new GameFightDBController();
        controller.initGameUnits();
        GameFightUnit__c newRightUserUnit = new GameFightUnit__c(Name = 'testunit', HealthPoint__c = 10, Stamina__c = 100, DamageMin__c = 0, DamageMax__c = 5);
        insert newRightUserUnit;
        controller.userUnit = newRightUserUnit;
        controller.autoFightButton();
        System.assertNotEquals(null, controller.winner, 'winner is null');
        // check if results saved properly
        List<Fight__c> fightsList = [
                SELECT Winner__c, Looser__c, Game_Log__c
                FROM Fight__c
        ];
        System.assertEquals(fightsList.get(0).Winner__c, controller.winner.Id, 'winner is not saved');
        GameFightUnit__c looser;
        if (controller.winner == controller.userUnit) {
            looser = controller.systemUnit;
        } else if (controller.winner == controller.systemUnit) {
            looser = controller.userUnit;
        } else
                System.assertEquals(fightsList.get(0).Looser__c, looser.Id, 'looser is not saved');
        String gameLog = fightsList.get(0).Game_Log__c;
        System.assertEquals(true, gameLog.length() > 0, 'log is not saved');
    }

    /*
     * test step by step fight logic
     */
    static testMethod void testStepByStepButton() {
        GameFightDBController controller = new GameFightDBController();
        controller.initGameUnits();
        GameFightUnit__c newRightUserUnit = new GameFightUnit__c(Name = 'testunit', HealthPoint__c = 100, Stamina__c = 100, DamageMin__c = 1, DamageMax__c = 5);
        insert newRightUserUnit;
        controller.userUnit = newRightUserUnit;
        controller.activeUnit = newRightUserUnit;
        controller.activeUnits.add(newRightUserUnit);
        controller.stepByStepFightButton();
        controller.userBlock = [
                SELECT Id, Body_part__r.Id, Body_part__r.Name
                FROM Block__c
        ].get(0);
        controller.userHit = [
                SELECT Id, Body_part__r.Id, Body_part__r.Name
                FROM Hit__c
        ].get(0);
        Integer logSize = controller.gameLog.size();
        Integer rNumber = controller.roundNumber;
        controller.chooseHit();
        //this round won't be finished
        System.assertEquals(null, controller.winner, 'winner has not to be chosen');
        System.assertEquals(true, logSize < controller.gameLog.size(), 'log is not saved');
        System.assertEquals(true, rNumber < controller.roundNumber, 'roundNumber is not saved');

        //todo: test controller fields after Step
        GameFightUnit__c newRightUserUnit1 = new GameFightUnit__c(Name = 'testunit', HealthPoint__c = 1, Stamina__c = 100, DamageMin__c = 10, DamageMax__c = 50);
        GameFightUnit__c newRightUserUnit2 = new GameFightUnit__c(Name = 'testunit', HealthPoint__c = 1, Stamina__c = 100, DamageMin__c = 10, DamageMax__c = 50);
        insert newRightUserUnit1;
        insert newRightUserUnit2;
        controller.userUnit = newRightUserUnit1;
        controller.systemUnit = newRightUserUnit2;
        controller.activeUnit = newRightUserUnit1;
        controller.activeUnits.add(newRightUserUnit1);
        controller.activeUnits.add(newRightUserUnit2);
        // assign different parts to hit and block
        controller.userHit = controller.hits.get(0);
        controller.userBlock = controller.blocks.get(1);
        controller.chooseBlock();
        //this round have to be finished
//        System.assertNotEquals(null, controller.winner, 'winner has to be chosen');
        System.assertEquals(true, controller.isShowResult, 'isShowResult has to be true');
        System.assertEquals(true, logSize < controller.gameLog.size(), 'log is not saved');
        System.assertEquals(true, rNumber < controller.roundNumber, 'roundNumber is not saved');
    }

    //todo: test controller fields after battle
}