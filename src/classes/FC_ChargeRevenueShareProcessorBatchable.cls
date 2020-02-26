public without sharing class FC_ChargeRevenueShareProcessorBatchable implements Database.Batchable<sObject>,
        Database.Stateful {

    public DateTime lastRunOn;
    public DateTime startTime;

    public Boolean processObsoletes;

    public FC_ChargeRevenueShareProcessorBatchable(Boolean processObsoletes) {
        this.processObsoletes = processObsoletes;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        FC_Charge_Revenue_Share_Settings__c config = FC_Charge_Revenue_Share_Settings__c.getOrgDefaults();
        DateTime currentTime = DateTime.now();
        this.startTime = currentTime;
        this.lastRunOn = config.Last_Run_On__c;
        String soqlTemplate = 'select Id, ARR__c, LastModifiedDate, Seg3_Record__c, ' +
                'Seg3_Record__r.Geography_Type__c, Seg3_Record__r.Product_Geography__c, ' +
                'Seg3_Record__r.Product_Geography__r.Geography__c, ' +
                'Seg3_Record__r.Product_Geography__r.Geography__r.Name, ' +
                'Seg3_Record__r.Product_Geography__r.Geography__r.Seg2__c, ' +
                'Seg3_Record__r.Product_Geography__r.ProductGeographyType__r.GeographyType__r.Name ' +
                'from Zuora__SubscriptionProductCharge__c where {0}';
        String criteria = 'CreatedDate <= :currentTime';
        if (config.Last_Run_On__c != null) {
            criteria = '(CreatedDate > :lastRunOn and CreatedDate <= :currentTime)';
        }
        if (processObsoletes) {
            criteria = 'Id in (select Subscription_Product_Charge__c from FC_Charge_Revenue_Share__c where Obsolete__c = true)';
        }

        return Database.getQueryLocator(String.format(soqlTemplate, new String[]{
                criteria
        }));
    }

    public void execute(Database.BatchableContext context, List<Zuora__SubscriptionProductCharge__c> scope) {
        Map<String, FC_Segment_2_Assignment__c> segment2AssignmentMap = FC_Segment_2_Assignment__c.getAll();

        Map<String, Id> segment2ToGeographyMap = new Map<String, Id>();
        for (MetroclientGeography__c geographyRecord : [
                select Id, Seg2__c
                from MetroclientGeography__c
                where Seg2__c != null
                and Seg2__c != '' and GeographyType__r.Name = 'Market' and (not Geography_FIPS__c like '%c%')
        ]) {
            if (String.isNotBlank(geographyRecord.Seg2__c)) {
                segment2ToGeographyMap.put(geographyRecord.Seg2__c, geographyRecord.Id);
            }
        }

        Map<String, Set<FC_Segment_2_Assignment__c>> stateToSegment2AssignmentsMap = new Map<String, Set<FC_Segment_2_Assignment__c>>();
        Map<String, Decimal> stateToSegment2TotalPercentAllocationMap = new Map<String, Decimal>();
        for (FC_Segment_2_Assignment__c segment2AssignmentRecord : segment2AssignmentMap.values()) {
            if (String.isNotBlank(segment2AssignmentRecord.State__c)) {

                Set<FC_Segment_2_Assignment__c> stateSegment2Assignments = stateToSegment2AssignmentsMap.get(segment2AssignmentRecord.State__c);
                if (stateSegment2Assignments == null) {
                    stateSegment2Assignments = new Set<FC_Segment_2_Assignment__c>();
                    stateToSegment2AssignmentsMap.put(segment2AssignmentRecord.State__c, stateSegment2Assignments);
                }
                stateSegment2Assignments.add(segment2AssignmentRecord);

                Decimal stateTotalPercentAllocation = stateToSegment2TotalPercentAllocationMap.get(segment2AssignmentRecord.State__c);
                if (stateTotalPercentAllocation == null) {
                    stateTotalPercentAllocation = 0;
                }
                stateToSegment2TotalPercentAllocationMap.put(segment2AssignmentRecord.State__c,
                        stateTotalPercentAllocation + segment2AssignmentRecord.Allocation_Percentage__c);

            }
        }

        FC_Charge_Revenue_Share__c[] recordsToInsert = new List<FC_Charge_Revenue_Share__c>();
        if (scope != null && !scope.isEmpty()) {
            for (Zuora__SubscriptionProductCharge__c chargeRecord : scope) {
                Decimal arr = chargeRecord.ARR__c != null ? chargeRecord.ARR__c : 0;
                if (chargeRecord.Seg3_Record__r.Product_Geography__r.ProductGeographyType__r.GeographyType__r.Name == 'State' &&
                        stateToSegment2AssignmentsMap.containsKey(chargeRecord.Seg3_Record__r.Product_Geography__r.Geography__r.Name) &&
                        stateToSegment2TotalPercentAllocationMap.containsKey(chargeRecord.Seg3_Record__r.Product_Geography__r.Geography__r.Name) &&
                        stateToSegment2TotalPercentAllocationMap.get(chargeRecord.Seg3_Record__r.Product_Geography__r.Geography__r.Name) != 0) {
                    for (FC_Segment_2_Assignment__c segment2AssignmentRecord : stateToSegment2AssignmentsMap.get(chargeRecord.Seg3_Record__r.Product_Geography__r.Geography__r.Name)) {
                        Decimal allocationPercentage = segment2AssignmentRecord.Allocation_Percentage__c /
                                stateToSegment2TotalPercentAllocationMap.get(chargeRecord.Seg3_Record__r.Product_Geography__r.Geography__r.Name);
                        recordsToInsert.add(new FC_Charge_Revenue_Share__c(
                                Allocated_ARR__c = arr * allocationPercentage,
                                Allocated_Geography__c = segment2ToGeographyMap.get(segment2AssignmentRecord.Name),
                                Allocation_Percentage__c = allocationPercentage * 100,
                                Charge_Last_Modified_Date__c = chargeRecord.LastModifiedDate,
                                Processed_By_Batchable_On__c = this.startTime,
                                RD_Assignment__c = segment2AssignmentRecord.Sales_Region_Assignment_ID__c,
                                Segment_2__c = segment2AssignmentRecord.Name,
                                Subscription_Product_Charge__c = chargeRecord.Id));
                    }
                } else if (chargeRecord.Seg3_Record__r.Product_Geography__r.ProductGeographyType__r.GeographyType__r.Name == 'Country') {
                    for (FC_Segment_2_Assignment__c segment2AssignmentRecord : segment2AssignmentMap.values()) {
                        Decimal allocationPercentage = segment2AssignmentRecord.Allocation_Percentage__c / Decimal.valueOf(100);
                        recordsToInsert.add(new FC_Charge_Revenue_Share__c(
                                Allocated_ARR__c = arr * allocationPercentage,
                                Allocated_Geography__c = segment2ToGeographyMap.get(segment2AssignmentRecord.Name),
                                Allocation_Percentage__c = allocationPercentage * 100,
                                Charge_Last_Modified_Date__c = chargeRecord.LastModifiedDate,
                                Processed_By_Batchable_On__c = this.startTime,
                                RD_Assignment__c = segment2AssignmentRecord.Sales_Region_Assignment_ID__c,
                                Segment_2__c = segment2AssignmentRecord.Name,
                                Subscription_Product_Charge__c = chargeRecord.Id));
                    }
                } else {
                    FC_Segment_2_Assignment__c segment2AssignmentRecord =
                            segment2AssignmentMap.get(chargeRecord.Seg3_Record__r.Product_Geography__r.Geography__r.Seg2__c);
                    recordsToInsert.add(new FC_Charge_Revenue_Share__c(
                            Allocated_ARR__c = arr,
                            Allocated_Geography__c = segment2ToGeographyMap.get(chargeRecord.Seg3_Record__r.Product_Geography__r.Geography__r.Seg2__c),
                            Allocation_Percentage__c = 100,
                            Charge_Last_Modified_Date__c = chargeRecord.LastModifiedDate,
                            Processed_By_Batchable_On__c = this.startTime,
                            RD_Assignment__c = segment2AssignmentRecord != null ?
                                    segment2AssignmentRecord.Sales_Region_Assignment_ID__c : null,
                            Segment_2__c = chargeRecord.Seg3_Record__r.Product_Geography__r.Geography__r.Seg2__c,
                            Subscription_Product_Charge__c = chargeRecord.Id));
                }
            }
        }
        if (!recordsToInsert.isEmpty()) {
            insert recordsToInsert;
        }
    }

    public void finish(Database.BatchableContext context) {
        if (!processObsoletes) {
            FC_Charge_Revenue_Share_Settings__c config = FC_Charge_Revenue_Share_Settings__c.getOrgDefaults();
            config.Last_Run_On__c = this.startTime;
            upsert config;
            FC_ChargeRevenueShareProcessorBatchable processorBatchable = new FC_ChargeRevenueShareProcessorBatchable(true);
            Database.executeBatch(processorBatchable);
        } else {
            FC_ChargeRevenueShareCleanerBatchable cleanerBatchable = new FC_ChargeRevenueShareCleanerBatchable(this.startTime);
            Database.executeBatch(cleanerBatchable);
        }
    }

}