public with sharing class FC_ZuoraSubscriptionGenerateInvoiceCtrl {

    private final Zuora__Subscription__c SUBSCRIPTION_RECORD;

    public FC_ZuoraSubscriptionGenerateInvoiceCtrl(ApexPages.StandardController standardController) {
        this.SUBSCRIPTION_RECORD = (Zuora__Subscription__c) standardController.getRecord();
    }

    public PageReference generateInvoice() {

        FC_ZuoraClient.UpdateSubscriptionRequest updateSubscriptionRequest = FC_ZuoraUtil.buildGenerateInvoiceForSubscriptionRequest(this.SUBSCRIPTION_RECORD.Zuora__NextChargeDate__c);
        FC_ZuoraClient zuoraClient = new FC_ZuoraClient();
        FC_ZuoraClient.UpdateSubscriptionResponse updateSubscriptionResponse = zuoraClient.updateSubscription(updateSubscriptionRequest, this.SUBSCRIPTION_RECORD.Zuora__SubscriptionNumber__c);

        Map<Boolean, ApexPages.Message> invoiceGeneratedToResponseMessageMap = new Map<Boolean, ApexPages.Message>{
                true => new ApexPages.Message(ApexPages.Severity.CONFIRM,
                        String.format('Invoice with ID {0} has been generated for subscription {1}.',
                                new String[]{
                                        updateSubscriptionResponse.invoiceId, this.SUBSCRIPTION_RECORD.Zuora__SubscriptionNumber__c
                                })),
                false => new ApexPages.Message(ApexPages.Severity.INFO,
                        String.format('No invoice was generated for subscription {0}.',
                                new String[]{
                                        this.SUBSCRIPTION_RECORD.Zuora__SubscriptionNumber__c
                                }))
        };
        if (updateSubscriptionResponse.success) {
            ApexPages.addMessage(invoiceGeneratedToResponseMessageMap.get(String.isNotBlank(updateSubscriptionResponse.invoiceId)));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    'An error occurred while generating the invoice for the subscription.'));
            renderZuoraErrors(updateSubscriptionResponse.reasons);
        }
        return null;

    }

    private void renderZuoraErrors(FC_ZuoraClient.ZuoraError[] errors) {
        if (errors != null) {
            for (FC_ZuoraClient.ZuoraError error : errors) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                        String.format('{0} - {1}', new String[]{
                                String.valueOf(error.code), error.message
                        })));
            }
        }
    }

}