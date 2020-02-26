public class FC_ContactUpdaterSchedulable implements Schedulable {
    public void execute (SchedulableContext sc) {
        Database.executeBatch(new FC_ContactUpdaterBatchable());
    }
}