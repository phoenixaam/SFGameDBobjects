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
        isShowMessage = false;
    }

    public void initGameUnits() {
        isShowSystemUnit = true;
        isShowUserUnit = true;
        isShowUserChosenUnit = false;
        isShowResult = false;
        // don't change the order of methods!
        checkUnitsActivity();
        systemUnit = getRandomUnitFromDB();
        activeUnits = getActiveUnitFromDB();
        userUnit = new GameFightUnit__c(name = '', HealthPoint__c = 0, DamageMin__c = 0, DamageMax__c = 0);
        newUserUnit = new GameFightUnit__c(name = '', HealthPoint__c = 0, DamageMin__c = 0, DamageMax__c = 0);
        userChoice = '';
        gamelog.clear();
        winner = null;
    }

    // get list of active Units from DB
    private List<GameFightUnit__c> getActiveUnitFromDB() {
        return [
                select Name, HealthPoint__c, DamageMin__c, DamageMax__c
                from GameFightUnit__c
                where IsActive__c = true
        ];
        //todo: проверка на пустой лист
    }

    public PageReference chooseUnit() {
        assignUserChoise();
        return null;
    }

    public PageReference fightButton() {
        fight();
        isShowResult = true;
        return null;
    }

    // retrieve random unit from DB to fight with user
    private GameFightUnit__c getRandomUnitFromDB() {
        List<GameFightUnit__c> dbUnits = getActiveUnitFromDB();
        Integer size = dbUnits.size();
        Integer index = 0;
        if (size > 0) {
            index = (Math.floor(Math.random() * size)).intValue();
            return dbUnits.get(index);
        }
        // if we don't have any let's generate some
        GameFightUnit__c nonameUnit = new GameFightUnit__c(name = 'Noname', HealthPoint__c = 100, DamageMin__c = 10, DamageMax__c = 20);

        return nonameUnit;
    }

    // check inactive units and make them active if inactivity period is finished
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
    }

    // deactivate dead units except temporary user 'Noname'
    private void deactivate(final GameFightUnit__c looser) {
        if (looser.name != 'Noname') {
            //return health points
            List<GameFightUnit__c> loosersUnits = [
                    select DeactivationTime__c, IsActive__c
                    from GameFightUnit__c
                    where Name = :looser.name and IsActive__c = true
            ];
            if (loosersUnits.size() == 1) {
                GameFightUnit__c loosersUnit = loosersUnits.get(0);
                loosersUnit.IsActive__c = false;
                loosersUnit.DeactivationTime__c = DateTime.now();
                update loosersUnit;
            } else {
                throw new UpdateLooserException('Error update looser - not found');
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
            options.add(new SelectOption(unit.Name, unitString));
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
        if (String.isNotBlank(userChoice) && !'-- Select One --'.equals(userChoice) && !'-- Not Required --'.equals(userChoice)){
            userUnit = [
                    select Name, HealthPoint__c, DamageMin__c, DamageMax__c
                    from GameFightUnit__c
                    where Name = :userChoice
            ];
            //todo: it needs to remake with search by unitId  and get unit from list activeUnits but DB
//            getUnitFromList(activeUnits, unitId);
            isShowUserChosenUnit = true;
            isShowMessage = false;
        }  else{
            userUnit = new GameFightUnit__c(name = '', HealthPoint__c = 0, DamageMin__c = 0, DamageMax__c = 0);
            isShowUserChosenUnit = false;
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
            if (newUserUnit.Name != '' && newUserUnit.HealthPoint__c != 0 && newUserUnit.DamageMin__c != 0 && newUserUnit.DamageMax__c != 0) {
                //todo: understanding the leak of system resources here it has to be changed
                //todo: check unit by unitId
                upsert newUserUnit;
                isShowUserChosenUnit = true;
                userUnit = newUserUnit;
            } else {
                // return to choose process without changes
                errorMessage = 'Please fill the all user properties.';
                isShowMessage = true;

                return null;
            }
        }
        return null;
    }


    //todo: add HitRange and HitBlock
    //
}