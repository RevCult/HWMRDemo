global without sharing class FC_SubscriptionProductChargeHandler extends fcf.TriggerAdapter {

    global static final String TRIGGER_RUN_STATUS_ID = 'FC_SubscriptionProductChargeHandler';

    // Before and after phases
    private static Map<ID, Zuora__Subscription__c> subscriptionLookupMap = new Map<ID, Zuora__Subscription__c>();

    // Before phase
    private Map<ID, FC_Metroclient_Product_Geography_Seg3__c> productGeographySeg3LookupMap = new Map<ID, FC_Metroclient_Product_Geography_Seg3__c>();
    private Map<Id, Set<MetrostudySalesRegionAssignment__c>> salesRegionIdToSalesRegionAssignmentsMap =
            new Map<Id, Set<MetrostudySalesRegionAssignment__c>>();
    private Map<String, FC_Segment_2_Assignment__c> fcSegment2AssignmentLookupMap = FC_Segment_2_Assignment__c.getAll();

    // After phase
    private Set<String> ratePlanChargeZuoraIdsToLookup = new Set<String>();
    private Set<String> fcLookupKeysToLookup = new Set<String>();
    private Set<String> chargeNumbersToLookup = new Set<String>();
    private Set<ID> billingAccountIdsToUpdate = new Set<ID>();
    private Set<ID> subscriptionIdsToUpdate = new Set<ID>();


    global override void bulkBefore() {
        if (Trigger.isInsert || Trigger.isUpdate) {

            Set<ID> seg3RecordIdsToLookup = new Set<ID>();
            for (SObject so : Trigger.new) {
                Zuora__SubscriptionProductCharge__c chargeRecord = (Zuora__SubscriptionProductCharge__c) so;
                if (String.isNotBlank(chargeRecord.Seg3RecordID__c)) {
                    try {
                        seg3RecordIdsToLookup.add(Id.valueOf(chargeRecord.Seg3RecordID__c));
                    } catch (Exception e) {
                        // Do nothing.
                    }
                }
            }
            productGeographySeg3LookupMap.putAll(FC_FcMetroclientProductGeoSeg3Cache.findByIds(seg3RecordIdsToLookup));

            Set<Id> salesRegionIdsToLookup = new Set<Id>();
            for (FC_Metroclient_Product_Geography_Seg3__c seg3Record : productGeographySeg3LookupMap.values()) {
                if (seg3Record.Product_Geography__r.Geography__r.SalesRegion__c != null) {
                    salesRegionIdsToLookup.add(seg3Record.Product_Geography__r.Geography__r.SalesRegion__c);
                }
            }
            salesRegionIdToSalesRegionAssignmentsMap.putAll(FC_MetrostudySalesRegionAssignmentCache.findBySalesRegionIds(salesRegionIdsToLookup));

            Set<ID> subscriptionIdsToLookup = new Set<ID>();
            for (SObject so : Trigger.new) {
                Zuora__SubscriptionProductCharge__c subscriptionProductChargeRecord = (Zuora__SubscriptionProductCharge__c) so;
                if (subscriptionProductChargeRecord.Zuora__Subscription__c != null) {
                    subscriptionIdsToLookup.add(subscriptionProductChargeRecord.Zuora__Subscription__c);
                }
            }
            subscriptionLookupMap.putAll(FC_SubscriptionCache.findByIds(subscriptionIdsToLookup));
        }
    }

    global override void beforeInsert(SObject so) {
        Zuora__SubscriptionProductCharge__c newCharge = (Zuora__SubscriptionProductCharge__c) so;
        populateFields(newCharge);
    }

    global override void beforeUpdate(SObject oldSo, SObject so) {
        Zuora__SubscriptionProductCharge__c newCharge = (Zuora__SubscriptionProductCharge__c) so;
        newCharge.FC_Most_Recent_Service_Start_Date__c = null;
        populateFields(newCharge);
    }

    global override void finallyBefore() {

        if (Trigger.isInsert || Trigger.isUpdate) {

            Map<String, zqu__ProductRatePlanCharge__c> productRatePlanChargeMap = FC_ProductRatePlanChargeCache.findByFcLookupKeys(fcLookupKeysToLookup);
            for (SObject so : Trigger.new) {
                Zuora__SubscriptionProductCharge__c newCharge = (Zuora__SubscriptionProductCharge__c) so;
                if (String.isNotBlank(newCharge.FC_Lookup_Key__c) && productRatePlanChargeMap.containsKey(newCharge.FC_Lookup_Key__c)) {
                    newCharge.Product_Rate_Plan_Charge__c = productRatePlanChargeMap.get(newCharge.FC_Lookup_Key__c).Id;
                }
            }

        }

        if (Trigger.isUpdate) {
            for (AggregateResult ar : [
                    select fziiss__Rate_Plan_Charge__c,
                            max(fziiss__ServiceStartDate__c) latestServiceStartDate
                    from fziiss__Invoice_Item__c
                    where fziiss__Rate_Plan_Charge__c in :Trigger.new
                    group by fziiss__Rate_Plan_Charge__c
            ]) {
                Zuora__SubscriptionProductCharge__c subscriptionProductChargeRecord =
                        (Zuora__SubscriptionProductCharge__c) Trigger.newMap.get((Id) ar.get('fziiss__Rate_Plan_Charge__c'));
                if (subscriptionProductChargeRecord != null) {
                    subscriptionProductChargeRecord.FC_Most_Recent_Service_Start_Date__c =
                            (Date) ar.get('latestServiceStartDate');
                }
            }
        }

    }


    global override void bulkAfter() {

        Set<ID> subscriptionIdsToLookup = new Set<ID>();
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
            for (SObject so : Trigger.new) {
                Zuora__SubscriptionProductCharge__c subscriptionProductChargeRecord = (Zuora__SubscriptionProductCharge__c) so;
                if (subscriptionProductChargeRecord.Zuora__Subscription__c != null) {
                    subscriptionIdsToLookup.add(subscriptionProductChargeRecord.Zuora__Subscription__c);
                }
            }
        }
        if (Trigger.isUpdate || Trigger.isDelete) {
            for (SObject so : Trigger.old) {
                Zuora__SubscriptionProductCharge__c subscriptionProductChargeRecord = (Zuora__SubscriptionProductCharge__c) so;
                if (subscriptionProductChargeRecord.Zuora__Subscription__c != null) {
                    subscriptionIdsToLookup.add(subscriptionProductChargeRecord.Zuora__Subscription__c);
                }
            }
        }
        subscriptionLookupMap.putAll(FC_SubscriptionCache.findByIds(subscriptionIdsToLookup));

    }

    global override void afterInsert(SObject so) {
        Zuora__SubscriptionProductCharge__c newCharge = (Zuora__SubscriptionProductCharge__c) so;

        if (String.isNotBlank(newCharge.Zuora__External_Id__c)) {
            ratePlanChargeZuoraIdsToLookup.add(newCharge.Zuora__External_Id__c);
            chargeNumbersToLookup.add(newCharge.Zuora__ChargeNumber__c);
        }

        markSubscriptionAndBillingAccountForUpdate(newCharge);
    }

    global override void afterUpdate(SObject oldSo, SObject so) {
        Zuora__SubscriptionProductCharge__c newCharge = (Zuora__SubscriptionProductCharge__c) so;
        Zuora__SubscriptionProductCharge__c oldCharge = (Zuora__SubscriptionProductCharge__c) oldSo;

        if (String.isNotBlank(newCharge.Zuora__External_Id__c)) {
            ratePlanChargeZuoraIdsToLookup.add(newCharge.Zuora__External_Id__c);
            chargeNumbersToLookup.add(newCharge.Zuora__ChargeNumber__c);
        }

        markSubscriptionAndBillingAccountForUpdate(newCharge);
        markSubscriptionAndBillingAccountForUpdate(oldCharge);
    }

    global override void afterDelete(SObject oldSo) {
        Zuora__SubscriptionProductCharge__c oldCharge = (Zuora__SubscriptionProductCharge__c) oldSo;

        markSubscriptionAndBillingAccountForUpdate(oldCharge);
    }

    global override void afterUndelete(SObject so) {
        Zuora__SubscriptionProductCharge__c newCharge = (Zuora__SubscriptionProductCharge__c) so;

        markSubscriptionAndBillingAccountForUpdate(newCharge);
    }

    global override void finallyAfter() {

        // Prevent after phase from recursively executing
        if (!fcf.TriggerRunStatus.isRunnable(new fcf.TriggerRunStatusItem(TRIGGER_RUN_STATUS_ID))) {
            return;
        }
        fcf.TriggerRunStatus.block(new fcf.TriggerRunStatusItem(TRIGGER_RUN_STATUS_ID));

        if (Trigger.isInsert || Trigger.isUpdate) {

            if (!chargeNumbersToLookup.isEmpty()) {
                List<MetroclientAccountProductGeography__c> metroclientAccountProductGeographiesToUpdate = new List<MetroclientAccountProductGeography__c>();
                for (MetroclientAccountProductGeography__c record : [
                        select Id
                        from MetroclientAccountProductGeography__c
                        where ChargeNumber__c in :chargeNumbersToLookup
                ]) {
                    metroclientAccountProductGeographiesToUpdate.add(new MetroclientAccountProductGeography__c(Id = record.Id));
                }
                if (!metroclientAccountProductGeographiesToUpdate.isEmpty()) {
                    update metroclientAccountProductGeographiesToUpdate;
                }
                chargeNumbersToLookup.clear();
            }

        }

        if (!billingAccountIdsToUpdate.isEmpty()) {
            Zuora__CustomerAccount__c[] billingAccountsToUpdate = new List<Zuora__CustomerAccount__c>();
            for (ID billingAccountIdToUpdate : billingAccountIdsToUpdate) {
                billingAccountsToUpdate.add(new Zuora__CustomerAccount__c(Id = billingAccountIdToUpdate));
            }
            update billingAccountsToUpdate;
            billingAccountIdsToUpdate.clear();
        }

        if (!subscriptionIdsToUpdate.isEmpty()) {
            Zuora__Subscription__c[] subscriptionsToUpdate = new List<Zuora__Subscription__c>();
            for (Id subscriptionIdToUpdate : subscriptionIdsToUpdate) {
                subscriptionsToUpdate.add(new Zuora__Subscription__c(Id = subscriptionIdToUpdate));
            }
            update subscriptionsToUpdate;
            subscriptionIdsToUpdate.clear();
        }

    }

    private void markSubscriptionAndBillingAccountForUpdate(Zuora__SubscriptionProductCharge__c charge) {
        if (charge.Zuora__Subscription__c != null && subscriptionLookupMap.containsKey(charge.Zuora__Subscription__c)) {
            if (subscriptionLookupMap.get(charge.Zuora__Subscription__c).Zuora__CustomerAccount__c != null) {
                billingAccountIdsToUpdate.add(subscriptionLookupMap.get(charge.Zuora__Subscription__c).Zuora__CustomerAccount__c);
            }
            subscriptionIdsToUpdate.add(charge.Zuora__Subscription__c);
        }
    }

    private void populateFields(Zuora__SubscriptionProductCharge__c chargeRecord) {

        // Populate FC Lookup Key
        String fcLookupKey = String.join(new String[]{
                chargeRecord.Zuora__ProductSKU__c,
                chargeRecord.Zuora__RatePlanName__c, chargeRecord.Name
        }, '^');
        chargeRecord.FC_Lookup_Key__c = fcLookupKey;
        fcLookupKeysToLookup.add(fcLookupKey);

        // Populate Segment2 Market Name
        String segment2 = chargeRecord.Segment2__c == null ? '' : chargeRecord.Segment2__c;
        if (segment2.trim().length() == 1) {
            segment2 = '0' + segment2;
        }

        FC_Segment_2_Assignment__c assignment = fcSegment2AssignmentLookupMap.get(segment2);
        chargeRecord.Segment2_Market_Name__c = '';
        if (assignment != null) {
            chargeRecord.Segment2_Market_Name__c = assignment.Market_Name__c;
        }

        // Populate Seg3 Record
        chargeRecord.Seg3_Record__c = null;
        try {
            if (String.isNotBlank(chargeRecord.Seg3RecordID__c) &&
                    productGeographySeg3LookupMap.containsKey(Id.valueOf(chargeRecord.Seg3RecordID__c))) {
                chargeRecord.Seg3_Record__c = Id.valueOf(chargeRecord.Seg3RecordID__c);
            }
        } catch (Exception e) {
            // Do nothing.
        }

        // Populate RD Assignment
        try {
            chargeRecord.FC_RD_Assignment__c = null;
            FC_Metroclient_Product_Geography_Seg3__c seg3Record = productGeographySeg3LookupMap.get(Id.valueOf(chargeRecord.Seg3RecordID__c));
            if (seg3Record != null) {
                Set<MetrostudySalesRegionAssignment__c> possibleSalesRegionAssignments =
                        salesRegionIdToSalesRegionAssignmentsMap.get(seg3Record.Product_Geography__r.Geography__r.SalesRegion__c);
                if (possibleSalesRegionAssignments != null) {
                    for (MetrostudySalesRegionAssignment__c salesRegionAssignmentRecord : possibleSalesRegionAssignments) {
                        if (salesRegionAssignmentRecord.Role__c == 'RD') {
                            chargeRecord.FC_RD_Assignment__c = salesRegionAssignmentRecord.Id;
                            break;
                        }
                    }
                }
            }
        } catch (Exception e) {
            // Do nothing.
        }

        // Populate Eligible to Cancel Start and End Dates
        chargeRecord.FC_Eligible_to_Cancel_Start_Date__c = null;
        chargeRecord.FC_Eligible_to_Cancel_End_Date__c = null;
        Zuora__Subscription__c subscriptionRecord = subscriptionLookupMap.get(chargeRecord.Zuora__Subscription__c);
        if (subscriptionRecord != null && subscriptionRecord.Zuora__TermSettingType__c == 'EVERGREEN' &&
                subscriptionRecord.Zuora__SubscriptionStartDate__c != null &&
                subscriptionRecord.Zuora__NextChargeDate__c != null &&
                subscriptionRecord.Zuora__TermStartDate__c != null) {
            Date todaysDate = Date.today();
            Date endOfFirstYear = subscriptionRecord.Zuora__SubscriptionStartDate__c.addYears(1).addDays(-1);
            Boolean isFirstYear = todaysDate >= subscriptionRecord.Zuora__SubscriptionStartDate__c &&
                    todaysDate <= endOfFirstYear;

            // Assume charge is in the first year
            chargeRecord.FC_Eligible_to_Cancel_Start_Date__c = endOfFirstYear.addDays(-90);
            chargeRecord.FC_Eligible_to_Cancel_End_Date__c = endOfFirstYear.addDays(-30);

            // Calculate dates if not in first year
            if (!isFirstYear) {

                // Assume billing period is not monthly
                chargeRecord.FC_Eligible_to_Cancel_Start_Date__c = subscriptionRecord.Zuora__NextChargeDate__c.addDays(-90);
                chargeRecord.FC_Eligible_to_Cancel_End_Date__c = subscriptionRecord.Zuora__NextChargeDate__c.addDays(-30);

                // Calculate dates if billing period is monthly
                if (chargeRecord.Zuora__BillingPeriod__c == 'Month') {

                    // Calculate quarter
                    Date quarterStartDate = Date.newInstance(todaysDate.year() - 1, subscriptionRecord.Zuora__TermStartDate__c.month(), subscriptionRecord.Zuora__TermStartDate__c.day());


                    /* If the quarter ends on the last day of the month, assume that each quarter will end on the last
                     * day of the month. This is to prevent an infinite loop from occurring when todays date's month
                     * has more days than the quarter end date's month.
                     */
                    Boolean useLastDayOfMonthForQuarterEnd = false;
                    Date quarterEndDate = Date.newInstance(todaysDate.year() - 1, subscriptionRecord.Zuora__TermStartDate__c.month(), subscriptionRecord.Zuora__TermStartDate__c.day()).addMonths(3).addDays(-1);
                    Integer quarterEndDay = quarterEndDate.day();
                    if (quarterEndDay == Date.daysInMonth(quarterEndDate.year(), quarterEndDate.month())) {
                        useLastDayOfMonthForQuarterEnd = true;
                    }
                    while (todaysDate < quarterStartDate || quarterEndDate < todaysDate) {
                        quarterStartDate = quarterStartDate.addMonths(3);
                        quarterEndDate = quarterEndDate.addMonths(3);
                        if (useLastDayOfMonthForQuarterEnd) {
                            quarterEndDate = getLastDateForMonth(quarterEndDate.year(), quarterEndDate.month());
                        }
                    }
                    chargeRecord.FC_Eligible_to_Cancel_Start_Date__c = quarterEndDate.addDays(-90);
                    chargeRecord.FC_Eligible_to_Cancel_End_Date__c = quarterEndDate.addDays(-30);
                }

            }
        }
    }

    private Date getLastDateForMonth(Integer year, Integer month) {
        return Date.newInstance(year, month, Date.daysInMonth(year, month));
    }

}