@IsTest
private class GameFightDBControllerTest {

    @testSetup static void methodName() {
        // create units
        GameFightUnit__c gameUnit1 = new GameFightUnit__c(name = 'TestUnit1', HealthPoint__c = 100, DamageMin__c = 1, DamageMax__c = 2);
        GameFightUnit__c gameUnit2 = new GameFightUnit__c(name = 'TestUnit2', HealthPoint__c = 100, DamageMin__c = 1, DamageMax__c = 2);
        GameFightUnit__c gameUnit3 = new GameFightUnit__c(name = 'TestUnit3', HealthPoint__c = 100, DamageMin__c = 1, DamageMax__c = 2);
        List<GameFightUnit__c> activeTestUnits = new List<GameFightUnit__c>();
        activeTestUnits.add(gameUnit1);
        activeTestUnits.add(gameUnit2);
        activeTestUnits.add(gameUnit3);
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

        GameFightUnit__c newRightUserUnit = new GameFightUnit__c(Name = 'testunit', HealthPoint__c = 10, DamageMin__c = 0, DamageMax__c = 5);
        GameFightUnit__c newWrongNameUserUnit = new GameFightUnit__c(Name = '', HealthPoint__c = 10, DamageMin__c = 0, DamageMax__c = 5);
        GameFightUnit__c newWrongHealthUserUnit = new GameFightUnit__c(Name = 'testunit', HealthPoint__c = 0, DamageMin__c = 0, DamageMax__c = 5);
        GameFightUnit__c newWrongDamageUserUnit = new GameFightUnit__c(Name = 'testunit', HealthPoint__c = 10, DamageMin__c = 10, DamageMax__c = 5);

        controller.newUserUnit = newRightUserUnit;
        controller.saveNewUnit();
//        System.assertEquals(newRightUserUnit, controller.userUnit, 'newUserUnit was not saved.');

        //todo: test insert & test update
//        List<GameFightUnit__c> testsaves = [
//                SELECT Name
//                FROM GameFightUnit__c
//                WHERE Id = :controller.userUnit.Id
//        ];
//
//        System.assertEquals('testunit', testsaves.get(0).Name, 'Name does not equal.');

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
                select Id, Name, HealthPoint__c, DamageMin__c, DamageMax__c, IsActive__c, DeactivationTime__c
                from GameFightUnit__c
                where IsActive__c = true
        ];
        //Test many records list
        options = controller.getUserUnitSelectList();
        System.assertEquals(4, options.size(), 'many records list of Units creation');
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
        System.assertEquals(3, controller.activeUnits.size(), 'get list of active units');
        System.assertEquals(3, controller.hits.size(), 'get list of hits');
        System.assertEquals(3, controller.blocks.size(), 'get list of blocks');
        System.assertEquals(true, controller.systemUnit.Name.startsWith('TestUnit'), 'get systemUnit from list of active units');
        System.assertEquals('', controller.userUnit.Name, 'assign userUnit');
        System.assertEquals(true, controller.game != null, 'assign game');
        System.assertEquals(0, controller.gameLog.size(), 'get empty list of logs');


        //todo: test controller fields after battle

    }

    static testMethod void testAutoFightButton() {
        GameFightDBController controller = new GameFightDBController();
        controller.initGameUnits();
        GameFightUnit__c newRightUserUnit = new GameFightUnit__c(Name = 'testunit', HealthPoint__c = 10, DamageMin__c = 0, DamageMax__c = 5);
        insert newRightUserUnit;
        controller.userUnit = newRightUserUnit;
        controller.autoFightButton();
    }
}