public class GameFightDBController {
    public static final Integer DEFAULT_INACTIVITY_PERIOD = 24;

    public GameFightDB game { get; set; }
    public GameFightUnit__c systemUnit { get; set; }
    public GameFightUnit__c userUnit { get; set; }
    public GameFightUnit__c newUserUnit { get; set; }
    public GameFightUnit__c winner { get; set; }
    public GameFightUnit__c activeUnit { get; set; }
    public List<GameFightUnit__c> activeUnits { get; set; }
    public List<Hit__c> hits { get; set; }
    public List<Block__c> blocks { get; set; }
    public Hit__c userHit { get; set; }
    public Block__c userBlock { get; set; }
    public Boolean isShowResult { get; set; }
    public Boolean isShowUserUnit { get; set; }
    public Boolean isShowSystemUnit { get; set; }
    public Boolean isShowUserChosenUnit { get; set; }
    public Boolean isNewUserSaveDisabled { get; set; }
    public Boolean isShowGameStart { get; set; }
    public Boolean isShowMessage { get; set; }
    public Boolean isShowChooseBlockPanel { get; set; }
    public Boolean isShowChooseHitPanel { get; set; }
    public Boolean isGetSystemUnitDisabled { get; set; }
    public Boolean isInputPeriodDisabled { get; set; }
    public Boolean isSetInputPeriodDisabled { get; set; }
    public Boolean isSetPeriod { get; set; }
    public List<String> gameLog { get; set; }
    public String userChoice { get; set; }
    public String userHitChoice { get; set; }
    public String userBlockChoice { get; set; }
    public String errorMessage { get; set; }
    public Integer roundNumber { get; set; }
    public Integer inactivityPeriod { get; set; }

    /**
    * when game started (page has shown)
    * only "Game parameters" block is shown
    * and one button "Get random system unit" is available
     */
    public GameFightDBController() {
        errorMessage = '';
        gamelog = new List<String>();
        isShowResult = false;
        isShowUserUnit = false;
        isShowSystemUnit = false;
        isShowUserChosenUnit = false;
        isShowMessage = false;
        isShowGameStart = false;
        isShowChooseBlockPanel = false;
        isShowChooseHitPanel = false;
        isInputPeriodDisabled = true;
        isSetInputPeriodDisabled = false;
        isSetPeriod = false;
        inactivityPeriod = DEFAULT_INACTIVITY_PERIOD;
    }
     /**
     *   prepare data for game:
     *
     *   retrieve list of unit from DB
     *   choose one of them as systemUnit
     *   show "SystemUnit" panel with unit's properties
     *   show "UserUnit" panel for choose userUnit from list of DB units,
     *   or input new unit
      */
    public void initGameUnits() {
        isShowSystemUnit = true;
        isShowUserUnit = true;
        isShowUserChosenUnit = false;
        isShowChooseBlockPanel = false;
        isShowChooseHitPanel = false;
        isShowResult = false;
        isShowGameStart = false;
        isShowMessage = false;
        isInputPeriodDisabled = true;
        isNewUserSaveDisabled = true;
        // don't change the order of methods!
        checkUnitsActivity();
        activeUnits = getActiveUnitsFromDB();
        hits = getHitsFromDB();
        blocks = getBlocksFromDB();
        systemUnit = getRandomActiveUnit();
        userUnit = new GameFightUnit__c(name = '', HealthPoint__c = 0, DamageMin__c = 0, DamageMax__c = 0);
        newUserUnit = new GameFightUnit__c(name = '', HealthPoint__c = 0, DamageMin__c = 0, DamageMax__c = 0);
        userChoice = '';
        userHitChoice = '';
        userBlockChoice = '';
        gamelog.clear();
        winner = null;
        activeUnit = null;
        userHit = null;
        userBlock = null;
        game = new GameFightDB();
        game.setHits(hits);
        game.setBlocks(blocks);
        roundNumber = 1;
    }

//    public PageReference checkPeriod() {
//        //todo: check if integer? if bigger than 0
//
//        isGetSystemUnitDisabled = false;
//
//        return null;
//    }


//    public PageReference setPeriod() {
//        inactivityPeriod = DEFAULT_INACTIVITY_PERIOD;
//        isInputPeriodDisabled = false;
//        isGetSystemUnitDisabled = true;
//        if (isSetPeriod) {
//           isSetPeriod = false;
//        } else{
//            isSetPeriod = true;
//        }
//        return null;
//    }

    /*
     * get list of active Units from DB
      */
    private List<GameFightUnit__c> getActiveUnitsFromDB() {
        return [
                select Id, Name, HealthPoint__c, DamageMin__c, DamageMax__c, IsActive__c, DeactivationTime__c
                from GameFightUnit__c
                where IsActive__c = true
        ];
    }
    /*
     * get list of Hits from DB
      */
    private List<Hit__c> getHitsFromDB() {
        return [
                SELECT Id, Body_part__r.Id, Body_part__r.Name
                FROM Hit__c
        ];
    }

    /*
     * get list of Blocks from DB
      */
    private List<Block__c> getBlocksFromDB() {
        return [
                SELECT Id, Body_part__r.Id, Body_part__r.Name
                FROM Block__c
        ];
    }

    /*
    * handle chosen unit from selectList "userUnitSelectList"
     */
    public PageReference chooseUnit() {
        assignUserUnitChoise();
        return null;
    }

    /*
    * handle chosen hit from selectList "userHitSelectList"
     */
    public PageReference chooseHit() {
        assignUserHitChoise();
        fight(FightType.STEP_BY_STEP);
        return null;
    }

    /*
    * handle chosen block from selectList "userBlockSelectList"
     */
    public PageReference chooseBlock() {
        assignUserBlockChoise();
        fight(FightType.STEP_BY_STEP);
        return null;
    }

    /*
    * handle "Auto Fight" button
    * call fight method, show results and finish the game
     */
    public PageReference autoFightButton() {
        fight(FightType.AUTO);
        isShowResult = true;
        isShowUserUnit = false;
        isShowGameStart = false;
        return null;
    }

    /*
    *  handle "Step by step Fight" button
    *  call method to define whos turn and show "StepByStep" panel
     */
    public PageReference stepByStepFightButton() {
        defineUnitTurn();
        isShowUserUnit = false;
        isShowGameStart = false;
        return null;
    }

    /*
    * defines which unit will turn
    * and show assosiated with it panel ("user_turn" or "computer_turn")
    * for user to choose hit or block
     */
    private void defineUnitTurn() {
        activeUnit = game.defineUnitTurn(systemUnit, userUnit);
        if (activeUnit == systemUnit) {
            isShowChooseBlockPanel = true;
            isShowChooseHitPanel = false;
        } else if (activeUnit == userUnit) {
            isShowChooseBlockPanel = false;
            isShowChooseHitPanel = true;
        }
        isShowUserUnit = false;
        isShowGameStart = false;
    }

    /*
     * defines result of the game step (STEP_BY_STEP) or result of the all battle (AUTO)
     * calls  game.fight(), game.oneStepFight(), game.getGameLog(), game.getRoundNumber()
     * shows result(logs)
     * calls deactivate the looser and save the result of the game
     * @param: FightType
     *
     * throws exception if get wrong param
     * throws exception if game.fight() or game.oneStepFight() return a wrong unit object
     */
    private void fight(FightType type) {
        GameFightUnit__c looser;
        if (type == FightType.AUTO) {
            looser = game.fight(systemUnit, userUnit);
        } else if (type == FightType.STEP_BY_STEP) {
            if (userUnit == activeUnit) {
                looser = game.oneStepFight(userUnit, systemUnit, userHit, null);
            } else if (systemUnit == activeUnit) {
                looser = game.oneStepFight(systemUnit, userUnit, null, userBlock);
            } else {
                throw new GameFightException('Unknown Unit.');
            }
            if (looser.HealthPoint__c > 0) {
                //next round
                defineUnitTurn();
                gameLog = game.getGameLog();
                roundNumber = game.getRoundNumber();
                userHitChoice = '';
                userBlockChoice = '';
                return; //if not finished
            } else {
                // go to finish
                isShowChooseHitPanel = false;
                isShowChooseBlockPanel = false;
                isShowResult = true;
            }
        } else {
            throw new GameFightException('Unknown Figth Type.');
        }
        if (looser == userUnit) {
            winner = systemUnit;
        } else if (looser == systemUnit) {
            winner = userUnit;
        } else {
            throw new GameFightException('Unknown Unit.');
        }
        deactivate(looser);
        gameLog = game.getGameLog();
        saveGameResult(winner, looser, gameLog);
    }

    /*
     * get random unit from activeUnits list to fight with user
     */
    private GameFightUnit__c getRandomActiveUnit() {
        Integer size = activeUnits.size();
        Integer index = 0;
        if (size > 0) {
            index = (Math.floor(Math.random() * size)).intValue();
            return activeUnits.get(index);
        }
        // if we don't have any let's generate some
        GameFightUnit__c nonameUnit = new GameFightUnit__c(name = 'Noname', HealthPoint__c = 100, DamageMin__c = 10, DamageMax__c = 20);

        return nonameUnit;
    }

    /*
     * check inactive units and make them active if inactivity period is expired
     */
    private void checkUnitsActivity() {
        List<GameFightUnit__c> dbUnits = [
                select IsActive__c, DeactivationTime__c
                from GameFightUnit__c
                where IsActive__c = false
        ];
        List<GameFightUnit__c> unitsToUpdate = new List<GameFightUnit__c>();
        for (GameFightUnit__c unit: dbUnits) {
            if (unit.DeactivationTime__c < DateTime.now().addDays(-1)) {
                unit.IsActive__c = true;
                unitsToUpdate.add(unit);
            }
        }
        if (!unitsToUpdate.isEmpty()) {
            update unitsToUpdate;
        }
    }

    /*
     * deactivate dead units except temporary unit 'Noname'
     *
     * throws exception when unit "looser" not found in DB
     * @param: unit
     */
    private void deactivate(final GameFightUnit__c looser) {
        if(looser!=null){
            if (looser.name != 'Noname') {
                //we don't want to save current unit with no health points
                // then we get it from DB
                String looserId = looser.Id;
                List<GameFightUnit__c> loosersUnits = [
                        select DeactivationTime__c, IsActive__c
                        from GameFightUnit__c
                        where Id = :looser.Id
                ];
                if (loosersUnits.size() == 1) {
                    GameFightUnit__c loosersUnit = loosersUnits.get(0);
                    loosersUnit.IsActive__c = false;
                    loosersUnit.DeactivationTime__c = DateTime.now();
                    update loosersUnit;
                } else if (loosersUnits.isEmpty()) {
                    throw new GameFightException('Error update looser - not found');
                } else {
                    throw new GameFightException('Error update looser - save not unique');
                }
            }
        } else{
            throw new GameFightException('Error deactivating looser - nothing to unique');
        }

    }


    /*
     * save to DB user created unit
     * show "ErrorPanel" if input does not correct
     */
    public PageReference saveNewUnit() {
        isShowMessage = false;
        if (String.isNotBlank(userChoice) && !'-- Select One --'.equals(userChoice) && !'-- Not Required --'.equals(userChoice)) {
            errorMessage = 'Unit has already chosen in list.';
            isShowMessage = true;
            return null;
        } else {
            if (String.isNotBlank(newUserUnit.Name) && newUserUnit.HealthPoint__c != 0 && newUserUnit.DamageMin__c != 0
                    && newUserUnit.DamageMax__c != 0 && newUserUnit.DamageMin__c <= newUserUnit.DamageMax__c) {

                // upsert newUserUnit;
                // understanding the leak of system resources here, upsert was changed
                Database.SaveResult saveResult;
                if (FieldsChecker.hasSObjectField(newUserUnit, 'Id')) {
                    saveResult = Database.update(newUserUnit);
                } else {
                    saveResult = Database.insert(newUserUnit);
                }
                if (!saveResult.isSuccess()) {
                    for (Database.Error error:saveResult.getErrors()) {
                        errorMessage = errorMessage + error.message;
                    }
                }

                isShowUserChosenUnit = true;
                isShowGameStart = true;
                isShowUserUnit = false;
                userUnit = newUserUnit;
                newUserUnit = new GameFightUnit__c(name = '', HealthPoint__c = 0, DamageMin__c = 0, DamageMax__c = 0);
            } else {
                // return to choose process without changes
                errorMessage = 'Please fill the all user properties.';
                isShowMessage = true;
                isShowUserChosenUnit = false;
                isShowGameStart = false;
                return null;
            }
        }
        return null;
    }
    /*
     * check if user fill all the unit's fields correctly
     * show "ErrorPanel" if input does not correct
     */
    public PageReference checkNewUnit() {
        if (String.isBlank(newUserUnit.Name) || newUserUnit.HealthPoint__c == 0 || newUserUnit.DamageMin__c == 0
                || newUserUnit.DamageMax__c == 0) {
            isNewUserSaveDisabled = true;
        } else if (newUserUnit.DamageMin__c > newUserUnit.DamageMax__c) {
            isNewUserSaveDisabled = true;
            errorMessage = 'DamageMin can`t be bigger then DamageMax';
            isShowMessage = true;
        } else {
            isNewUserSaveDisabled = false;
            isShowMessage = false;
        }
        return null;
    }

    /*
     * save fight results to the DB
     */
    private void saveGameResult(GameFightUnit__c winner, GameFightUnit__c looser, List<String> gameLog) {
        String gameLogString = '';
        for (String s: gameLog) {
            gameLogString = gameLogString + s + '\n';
        }
        Fight__c fight = new Fight__c(Winner__c = winner.Id, Looser__c = looser.Id, Game_Log__c = gameLogString);
        insert fight;
    }

    /*
     * Generate the units picklist based on the active units in DB except chosen system unit
     */
    public List<SelectOption> getUserUnitSelectList() {
        List<SelectOption> options = new List<SelectOption>();

        List<GameFightUnit__c> userUnits = new List<GameFightUnit__c>();
        for (GameFightUnit__c unit: activeUnits) {
            if (unit != systemUnit) {       //except chosen system unit
                userUnits.add(unit);
            }
        }
        // Sort the units based on their names
        userUnits.sort();

        // Generate the Select Options based on the final sorted list
        for (GameFightUnit__c unit : userUnits) {
            String unitString = unit.Name + ':   HealthPoints = ' + unit.HealthPoint__c + ', DamageMin = ' + unit.DamageMin__c + ', DamageMax = ' + unit.DamageMax__c ;
            options.add(new SelectOption(unit.Id, unitString));
        }

        // If no units are found, just say not required in the dropdown.
        if (options.size() > 0) {
            options.add(0, new SelectOption('', '-- Select One --'));
        } else {
            options.add(new SelectOption('', '-- Not Required --'));
        }
        return options;
    }

    /*
     * Generate the Hits picklist
     */
    public List<SelectOption> getUserHitSelectList() {
        List<SelectOption> options = new List<SelectOption>();
        for (Hit__c hit: hits) {
            options.add(new SelectOption(hit.Id, hit.Body_part__r.Name));
        }
        if (options.size() > 0) {
            options.add(0, new SelectOption('', '-- Select Hit --'));
        } else {
            options.add(new SelectOption('', '-- Not Required --'));
        }
        return options;
    }

    /*
     *Generate the Blocks picklist
     */
    public List<SelectOption> getUserBlockSelectList() {
        List<SelectOption> options = new List<SelectOption>();
        for (Block__c block: blocks) {
            options.add(new SelectOption(block.Id, block.Body_part__r.Name));
        }
        if (options.size() > 0) {
            options.add(0, new SelectOption('', '-- Select Block --'));
        } else {
            options.add(new SelectOption('', '-- Not Required --'));
        }
        return options;
    }

    /*
     * assign chosen user unit to userUnit if selection is proper
     */
    private void assignUserUnitChoise() {
        if (String.isNotBlank(userChoice) && !'-- Select One --'.equals(userChoice) && !'-- Not Required --'.equals(userChoice)) {
            // search by unitId  and get unit from list activeUnits
            for (GameFightUnit__c unit: activeUnits) {
                if (unit.Id.equals(userChoice)) {
                    userUnit = unit;
                }
            }
            isShowUserChosenUnit = true;
            isShowMessage = false;
            isShowGameStart = true;
            isShowUserUnit = false;
        } else {
            userUnit = new GameFightUnit__c(name = '', HealthPoint__c = 0, DamageMin__c = 0, DamageMax__c = 0);
            isShowUserChosenUnit = false;
            errorMessage = 'Please select or input user unit.';
            isShowMessage = true;
            isShowGameStart = false;
        }
    }

    /*
     * assign chosen user hit to userHit if selection is proper
     */
    private void assignUserHitChoise() {
        if (String.isNotBlank(userHitChoice) && !'-- Select Hit --'.equals(userHitChoice) && !'-- Not Required --'.equals(userHitChoice)) {
            // search by HitId  and get Hit from list hits
            for (Hit__c hit: hits) {
                if (hit.Id.equals(userHitChoice)) {
                    userHit = hit;
                }
            }
            isShowMessage = false;
        } else {
            errorMessage = 'Please select user hit.';
            isShowMessage = true;
        }
    }

    /*
     * assign chosen user block to userBlock if selection is proper
     */
    private void assignUserBlockChoise() {
        if (String.isNotBlank(userBlockChoice) && !'-- Select Block --'.equals(userBlockChoice) && !'-- Not Required --'.equals(userBlockChoice)) {
            // search by HitId  and get Hit from list hits
            for (Block__c block: blocks) {
                if (block.Id.equals(userBlockChoice)) {
                    userBlock = block;
                }
            }
            isShowMessage = false;
        } else {
            errorMessage = 'Please select user block.';
            isShowMessage = true;
        }
    }
}
