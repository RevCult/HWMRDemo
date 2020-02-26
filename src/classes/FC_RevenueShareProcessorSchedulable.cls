public class FC_RevenueShareProcessorSchedulable implements Schedulable {

    public void execute(SchedulableContext context) {
        FC_RevenueShareProcessorBatchable batchable = new FC_RevenueShareProcessorBatchable(false);
        Database.executeBatch(batchable);
    }

}