public class FC_ChargeRevenueShareProcessorSchedule implements Schedulable {

    public void execute(SchedulableContext context) {
        FC_ChargeRevenueShareProcessorBatchable batchable = new FC_ChargeRevenueShareProcessorBatchable(false);
        Database.executeBatch(batchable);
    }

}