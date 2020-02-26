@RestResource(urlMapping='/ChargeMonthlyRevenueShareProcessor')
global without sharing class FC_ChargeMonthlyRevShareProcessorCtrl {

    @HttpPost
    global static void runProcess(String importProcessId) {
        FC_ChargeMonthlyRevShareProcessorBatch batchable = new FC_ChargeMonthlyRevShareProcessorBatch(importProcessId);
        Database.executeBatch(batchable);
    }

}