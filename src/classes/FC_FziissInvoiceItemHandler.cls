global without sharing class FC_FziissInvoiceItemHandler extends fcf.TriggerAdapter {

    global static final String TRIGGER_RUN_STATUS_ID = 'FC_FziissInvoiceItemHandler';

    // Before phase
    private Map<ID, Zuora__SubscriptionProductCharge__c> subscriptionProductChargeLookupMap =
            new Map<ID, Zuora__SubscriptionProductCharge__c>();
    private Map<ID, FC_Metroclient_Product_Geography_Seg3__c> seg3RecordLookupMap = new Map<ID, FC_Metroclient_Product_Geography_Seg3__c>();

    // After phase
    private Map<ID, Zuora__SubscriptionProductCharge__c> subscriptionProductChargesToUpdate =
            new Map<ID, Zuora__SubscriptionProductCharge__c>();

    global override void bulkBefore() {
        if (Trigger.isInsert || Trigger.isUpdate) {

            Set<ID> subscriptionProductChargeIds = new Set<ID>();
            Set<ID> seg3RecordIds = new Set<ID>();
            for (SObject so : Trigger.new) {
                fziiss__Invoice_Item__c invoiceItemRecord = (fziiss__Invoice_Item__c) so;
                if (invoiceItemRecord.fziiss__Rate_Plan_Charge__c != null) {
                    subscriptionProductChargeIds.add(invoiceItemRecord.fziiss__Rate_Plan_Charge__c);
                }

                if (invoiceItemRecord.Seg3_Record__c != null) {
                    seg3RecordIds.add(invoiceItemRecord.Seg3_Record__c);
                }
                if (String.isNotBlank(invoiceItemRecord.Seg3RecordID__c)) {
                    try {
                        seg3RecordIds.add(Id.valueOf(invoiceItemRecord.Seg3RecordID__c));
                    } catch (Exception e) {
                        // Do nothing.
                    }
                }
            }
            subscriptionProductChargeLookupMap.putAll(FC_SubscriptionProductChargeCache.findByIds(subscriptionProductChargeIds));
            seg3RecordLookupMap.putAll(FC_FcMetroclientProductGeoSeg3Cache.findByIds(seg3RecordIds));

        }
    }

    global override void beforeInsert(SObject so) {
        fziiss__Invoice_Item__c newInvoiceItem = (fziiss__Invoice_Item__c) so;
        populateSegment2MarketName(newInvoiceItem);
        populateFields(null, newInvoiceItem);
    }

    global override void beforeUpdate(SObject oldSo, SObject so) {
        fziiss__Invoice_Item__c oldInvoiceItem = (fziiss__Invoice_Item__c) oldSo;
        fziiss__Invoice_Item__c newInvoiceItem = (fziiss__Invoice_Item__c) so;
        populateSegment2MarketName(newInvoiceItem);
        populateFields(oldInvoiceItem, newInvoiceItem);
    }

    global override void afterInsert(SObject so) {
        fziiss__Invoice_Item__c newInvoiceItem = (fziiss__Invoice_Item__c) so;
        prepareSubscriptionProductChargeForUpdate(newInvoiceItem);
    }

    global override void afterUpdate(SObject oldSo, SObject so) {
        fziiss__Invoice_Item__c newInvoiceItem = (fziiss__Invoice_Item__c) so;
        prepareSubscriptionProductChargeForUpdate(newInvoiceItem);
    }

    global override void afterDelete(SObject so) {
        fziiss__Invoice_Item__c oldInvoiceItem = (fziiss__Invoice_Item__c) so;
        prepareSubscriptionProductChargeForUpdate(oldInvoiceItem);
    }

    global override void afterUndelete(SObject so) {
        fziiss__Invoice_Item__c newInvoiceItem = (fziiss__Invoice_Item__c) so;
        prepareSubscriptionProductChargeForUpdate(newInvoiceItem);
    }

    global override void finallyAfter() {

        // Prevent after phase from recursively executing
        if (!fcf.TriggerRunStatus.isRunnable(new fcf.TriggerRunStatusItem(TRIGGER_RUN_STATUS_ID))) {
            return;
        }
        fcf.TriggerRunStatus.block(new fcf.TriggerRunStatusItem(TRIGGER_RUN_STATUS_ID));

        if (!subscriptionProductChargesToUpdate.isEmpty()) {
            update subscriptionProductChargesToUpdate.values();
            subscriptionProductChargesToUpdate.clear();
        }

    }

    private void populateSegment2MarketName(fziiss__Invoice_Item__c invoiceItemRecord) {
        invoiceItemRecord.Segment2_Market_Name__c = null;
        if (String.isNotBlank(invoiceItemRecord.Segment2__c)) {
            FC_Segment_2_Assignment__c fcSegment2Assignment = FC_Segment_2_Assignment__c.getInstance(invoiceItemRecord.Segment2__c);
            if (fcSegment2Assignment != null) {
                invoiceItemRecord.Segment2_Market_Name__c = fcSegment2Assignment.Market_Name__c;
            }
        }
    }

    private void populateFields(fziiss__Invoice_Item__c oldInvoiceItemRecord,
            fziiss__Invoice_Item__c newInvoiceItemRecord) {
        Zuora__SubscriptionProductCharge__c subscriptionProductChargeRecord = null;

        if (newInvoiceItemRecord.fziiss__Rate_Plan_Charge__c != null) {
            subscriptionProductChargeRecord = subscriptionProductChargeLookupMap.get(newInvoiceItemRecord.fziiss__Rate_Plan_Charge__c);
            if (subscriptionProductChargeRecord != null) {
                if (oldInvoiceItemRecord == null || String.isBlank(oldInvoiceItemRecord.Billing_Frequency__c)) {
                    newInvoiceItemRecord.Billing_Frequency__c = subscriptionProductChargeRecord.Zuora__BillingPeriod__c;
                }
                if (oldInvoiceItemRecord == null || oldInvoiceItemRecord.List_Price__c == null) {
                    newInvoiceItemRecord.List_Price__c = subscriptionProductChargeRecord.List_Price_Per_Period__c;
                }
                if ((oldInvoiceItemRecord == null ||
                        oldInvoiceItemRecord.Opportunity__c != subscriptionProductChargeRecord.Zuora__Subscription__r.Opportunity__c) &&
                        subscriptionProductChargeRecord.Zuora__Subscription__c != null &&
                        subscriptionProductChargeRecord.Zuora__Subscription__r.Opportunity__c != null) {
                    newInvoiceItemRecord.Opportunity__c = subscriptionProductChargeRecord.Zuora__Subscription__r.Opportunity__c;
                }
            }
        }

        if (newInvoiceItemRecord.Seg3_Record__c == null && ((subscriptionProductChargeRecord != null && subscriptionProductChargeRecord.Seg3_Record__c != null) ||
                String.isNotBlank(newInvoiceItemRecord.Seg3RecordID__c))) {
            try {
                if (String.isNotBlank(newInvoiceItemRecord.Seg3RecordID__c) &&
                        seg3RecordLookupMap.containsKey(Id.valueOf(newInvoiceItemRecord.Seg3RecordID__c))) {
                    newInvoiceItemRecord.Seg3_Record__c = Id.valueOf(newInvoiceItemRecord.Seg3RecordID__c);
                }
            } catch (Exception e) {
                // Do nothing.
            }
            if (newInvoiceItemRecord.Seg3_Record__c == null && subscriptionProductChargeRecord != null &&
                    subscriptionProductChargeRecord.Seg3_Record__c != null) {
                newInvoiceItemRecord.Seg3RecordID__c = subscriptionProductChargeRecord.Seg3_Record__c;
                newInvoiceItemRecord.Seg3_Record__c = subscriptionProductChargeRecord.Seg3_Record__c;
            }
        }

    }

    private void prepareSubscriptionProductChargeForUpdate(fziiss__Invoice_Item__c invoiceItemRecord) {
        if (invoiceItemRecord.fziiss__Rate_Plan_Charge__c != null) {
            subscriptionProductChargesToUpdate.put(invoiceItemRecord.fziiss__Rate_Plan_Charge__c,
                    new Zuora__SubscriptionProductCharge__c(Id = invoiceItemRecord.fziiss__Rate_Plan_Charge__c));
        }
    }

}