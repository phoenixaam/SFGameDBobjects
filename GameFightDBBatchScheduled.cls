global class GameFightDBBatchScheduled implements Schedulable {
    global void execute(SchedulableContext sc) {
        GameFightDBBatch b = new GameFightDBBatch();
        database.executebatch(b, 10);

    }
}