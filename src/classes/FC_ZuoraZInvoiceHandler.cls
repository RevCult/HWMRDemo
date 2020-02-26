global without sharing class FC_ZuoraZInvoiceHandler extends fcf.TriggerAdapter {

    private static final String TRIGGER_RUN_STATUS_ID = 'FC_ZuoraZInvoiceHandler';

    global override void finallyBefore() {

        // Initialize aggregate fields
        for (SObject so : Trigger.new) {
            Zuora__ZInvoice__c invoiceRecord = (Zuora__ZInvoice__c) so;
            invoiceRecord.FC_Most_Recent_Payment_Processed_On__c = null;
        }

        // Summarize invoice payment records
        if (Trigger.isUpdate) {

            for (AggregateResult ar : [
                    select Zuora__Invoice__c, max(Zuora__Payment__r.Zuora__Effective_Date__c) mostRecentProcessedPaymentDate
                    from Zuora__PaymentInvoice__c
                    where Zuora__Payment__r.Zuora__Status__c = 'Processed'
                    and Zuora__Payment__r.Zuora__Effective_Date__c != null
                    and Zuora__Invoice__c in :Trigger.newMap.keySet()
                    group by Zuora__Invoice__c
            ]) {
                Zuora__ZInvoice__c invoiceRecord =
                        (Zuora__ZInvoice__c) Trigger.newMap.get((Id) ar.get('Zuora__Invoice__c'));
                invoiceRecord.FC_Most_Recent_Payment_Processed_On__c = (Date) ar.get('mostRecentProcessedPaymentDate');
            }

        }

    }

}