public class FC_MapgUltimateParentAccountSyncSchedule implements Schedulable {

    public void execute(SchedulableContext context) {
        FC_MapgUltimateParentAccountSyncBatch batchable = new FC_MapgUltimateParentAccountSyncBatch();
        Database.executeBatch(batchable);
    }

}