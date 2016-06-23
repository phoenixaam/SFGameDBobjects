public class GameFightDBController {
    public GameFightDB game { get; set; }
    public GameFightUnit__c systemUnit { get; set; }
    public GameFightUnit__c userUnit { get; set; }
    public GameFightUnit__c newUserUnit { get; set; }
    public GameFightUnit__c winner { get; set; }
    public List<GameFightUnit__c> activeUnits { get; set; }
    public Boolean isShowResult { get; set; }
    public Boolean isShowUserUnit { get; set; }
    public Boolean isShowSystemUnit { get; set; }
    public Boolean isShowUserChosenUnit { get; set; }
    public Boolean isNewUserSaveDisabled { get; set; }
    public Boolean isShowGameStart { get; set; }
    public Boolean isShowMessage { get; set; }
    public List<String> gameLog { get; set; }
    public String userChoice { get; set; }
    public String errorMessage { get; set; }


    public GameFightDBController() {
        userChoice = '';
        errorMessage = '';
        gamelog = new List<String>();
        isShowResult = false;
        isShowUserUnit = false;
        isShowSystemUnit = false;
        isShowUserChosenUnit = false;
        isNewUserSaveDisabled = true;
        isShowMessage = false;
        isShowGameStart = false;
    }

    public void initGameUnits() {
        isShowSystemUnit = true;
        isShowUserUnit = true;
        isShowUserChosenUnit = false;
        isNewUserSaveDisabled = true;
        isShowResult = false;
        isShowGameStart = false;
        isShowMessage = false;
        // don't change the order of methods!
        checkUnitsActivity();
        activeUnits = getActiveUnitsFromDB();
        systemUnit = getRandomActiveUnit();
        userUnit = new GameFightUnit__c(name = '', HealthPoint__c = 0, DamageMin__c = 0, DamageMax__c = 0);
        newUserUnit = new GameFightUnit__c(name = '', HealthPoint__c = 0, DamageMin__c = 0, DamageMax__c = 0);
        userChoice = '';
        gamelog.clear();
        winner = null;
    }

    // get list of active Units from DB
    private List<GameFightUnit__c> getActiveUnitsFromDB() {
        return [
                select Id, Name, HealthPoint__c, DamageMin__c, DamageMax__c, IsActive__c, DeactivationTime__c
                from GameFightUnit__c
                where IsActive__c = true
        ];
    }

    public PageReference chooseUnit() {
        assignUserChoise();
        return null;
    }

    public PageReference fightButton() {
        fight();
        isShowResult = true;
        isShowUserUnit = false;
        isShowGameStart = false;
        return null;
    }

    // retrieve random unit from DB to fight with user
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

    // check inactive units and make them active if inactivity period is expired
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

    private void fight() {
        game = new GameFightDB();
        winner = game.fight(systemUnit, userUnit);
        GameFightUnit__c looser;
        if (winner == systemUnit) {
            looser = userUnit;
        } else {
            looser = systemUnit;
        }
        deactivate(looser);
        gameLog = game.getGameLog();
        saveGameResult(winner, looser, gameLog);
    }

    // deactivate dead units except temporary user 'Noname'
    private void deactivate(final GameFightUnit__c looser) {
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
                throw new UpdateLooserException('Error update looser - not found');
            } else {
                throw new UpdateLooserException('Error update looser - save not unique');
            }
        }
    }

    // To generate the units picklist based on the active units in DB except chosen system unit
    public List<SelectOption> getUserUnitSelectList() {
        List<SelectOption> options = new List<SelectOption>();

        List<GameFightUnit__c> userUnits = new List<GameFightUnit__c>();
        for (GameFightUnit__c unit: activeUnits) {
            if (unit != systemUnit) {
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

    // assign chosen user unit to userUnit if selection is proper
    private void assignUserChoise() {
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

    // save user created unit
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
                if(!saveResult.isSuccess()){
                    for(Database.Error error:saveResult.getErrors()){
                         errorMessage = errorMessage+error.message;
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
    // check if user fill all the unit's fields correctly
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

    // to adoid saving by pressing 'Enter'
//    public PageReference save() {
//        return null;
//    }

    // save fight results to the DB
    private void saveGameResult(GameFightUnit__c winner, GameFightUnit__c looser, List<String> gameLog){
        String gameLogString = '';
        for(String s: gameLog){
            gameLogString = gameLogString + s + '\n';
        }
        Fight__c fight = new Fight__c(Winner__c = winner.Id, Looser__c = looser.Id, Game_Log__c = gameLogString);
        insert fight;
    }


    //todo: add HitRange and HitBlock
    //
}