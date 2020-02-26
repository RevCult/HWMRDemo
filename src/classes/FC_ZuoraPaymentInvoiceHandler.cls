global without sharing class FC_ZuoraPaymentInvoiceHandler extends fcf.TriggerAdapter {

    private static final String TRIGGER_RUN_STATUS_ID = 'FC_ZuoraPaymentInvoiceHandler';

    // After phase
    private Set<Id> invoiceIdsToUpdate = new Set<Id>();

    global override void afterInsert(SObject so) {
        Zuora__PaymentInvoice__c newPaymentInvoice = (Zuora__PaymentInvoice__c) so;
        prepareInvoiceForUpdate(newPaymentInvoice);
    }

    global override void afterUpdate(SObject oldSo, SObject so) {
        Zuora__PaymentInvoice__c newPaymentInvoice = (Zuora__PaymentInvoice__c) so;
        prepareInvoiceForUpdate(newPaymentInvoice);
    }

    global override void afterDelete(SObject oldSo) {
        Zuora__PaymentInvoice__c oldPaymentInvoice = (Zuora__PaymentInvoice__c) oldSo;
        prepareInvoiceForUpdate(oldPaymentInvoice);
    }

    global override void afterUndelete(SObject so) {
        Zuora__PaymentInvoice__c newPaymentInvoice = (Zuora__PaymentInvoice__c) so;
        prepareInvoiceForUpdate(newPaymentInvoice);
    }

    global override void finallyAfter() {

        // Prevent after phase from recursively executing
        if (!fcf.TriggerRunStatus.isRunnable(new fcf.TriggerRunStatusItem(TRIGGER_RUN_STATUS_ID))) {
            return;
        }
        fcf.TriggerRunStatus.block(new fcf.TriggerRunStatusItem(TRIGGER_RUN_STATUS_ID));

        if (!invoiceIdsToUpdate.isEmpty()) {
            Zuora__ZInvoice__c[] invoicesToUpdate = new List<Zuora__ZInvoice__c>();
            for (Id invoiceIdToUpdate : invoiceIdsToUpdate) {
                invoicesToUpdate.add(new Zuora__ZInvoice__c(Id = invoiceIdToUpdate));
            }
            update invoicesToUpdate;
            invoicesToUpdate.clear();
        }

    }

    private void prepareInvoiceForUpdate(Zuora__PaymentInvoice__c paymentInvoiceRecord) {
        if (paymentInvoiceRecord.Zuora__Invoice__c != null) {
            invoiceIdsToUpdate.add(paymentInvoiceRecord.Zuora__Invoice__c);
        }
    }

}