public with sharing class FC_ChargeMonthlyRevShareProcessorBatch implements Database.Batchable<sObject> {

    public String importProcessId;

    public FC_ChargeMonthlyRevShareProcessorBatch(String importProcessId) {
        this.importProcessId = importProcessId;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
                select Id, Charge_Number__c, Date__c, Monthly_Revenue__c, Rate_Plan_Charge__c,
                        Rate_Plan_Charge__r.Seg3_Record__c,
                        Rate_Plan_Charge__r.Seg3_Record__r.Geography_Type__c,
                        Rate_Plan_Charge__r.Seg3_Record__r.Product_Geography__c,
                        Rate_Plan_Charge__r.Seg3_Record__r.Product_Geography__r.Geography__c,
                        Rate_Plan_Charge__r.Seg3_Record__r.Product_Geography__r.Geography__r.Name,
                        Rate_Plan_Charge__r.Seg3_Record__r.Product_Geography__r.Geography__r.Seg2__c,
                        Rate_Plan_Charge__r.Seg3_Record__r.Product_Geography__r.ProductGeographyType__c,
                        Rate_Plan_Charge__r.Seg3_Record__r.Product_Geography__r.ProductGeographyType__r.GeographyType__c,
                        Rate_Plan_Charge__r.Seg3_Record__r.Product_Geography__r.ProductGeographyType__r.GeographyType__r.Name
                from FC_Charge_Monthly_Revenue__c
                where Import_Process_ID__c = :this.importProcessId
        ]);
    }

    public void execute(Database.BatchableContext context, List<FC_Charge_Monthly_Revenue__c> scope) {
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

        FC_Charge_Monthly_Revenue_Share__c[] recordsToInsert = new List<FC_Charge_Monthly_Revenue_Share__c>();
        if (scope != null && !scope.isEmpty()) {
            for (FC_Charge_Monthly_Revenue__c record : scope) {
                Decimal mrr = record.Monthly_Revenue__c != null ? record.Monthly_Revenue__c : 0;
                if (record.Rate_Plan_Charge__c != null &&
                        record.Rate_Plan_Charge__r.Seg3_Record__c != null &&
                        record.Rate_Plan_Charge__r.Seg3_Record__r.Product_Geography__c != null &&
                        record.Rate_Plan_Charge__r.Seg3_Record__r.Product_Geography__r.ProductGeographyType__c != null &&
                        record.Rate_Plan_Charge__r.Seg3_Record__r.Product_Geography__r.ProductGeographyType__r.GeographyType__c != null) {
                    if (record.Rate_Plan_Charge__r.Seg3_Record__r.Product_Geography__r.ProductGeographyType__r.GeographyType__r.Name == 'State' &&
                            stateToSegment2AssignmentsMap.containsKey(record.Rate_Plan_Charge__r.Seg3_Record__r.Product_Geography__r.Geography__r.Name) &&
                            stateToSegment2TotalPercentAllocationMap.containsKey(record.Rate_Plan_Charge__r.Seg3_Record__r.Product_Geography__r.Geography__r.Name) &&
                            stateToSegment2TotalPercentAllocationMap.get(record.Rate_Plan_Charge__r.Seg3_Record__r.Product_Geography__r.Geography__r.Name) != 0) {
                        for (FC_Segment_2_Assignment__c segment2AssignmentRecord : stateToSegment2AssignmentsMap.get(record.Rate_Plan_Charge__r.Seg3_Record__r.Product_Geography__r.Geography__r.Name)) {
                            Decimal allocationPercentage = segment2AssignmentRecord.Allocation_Percentage__c /
                                    stateToSegment2TotalPercentAllocationMap.get(record.Rate_Plan_Charge__r.Seg3_Record__r.Product_Geography__r.Geography__r.Name);
                            recordsToInsert.add(new FC_Charge_Monthly_Revenue_Share__c(
                                    Allocated_Amount__c = mrr * allocationPercentage,
                                    Allocated_Geography__c = segment2ToGeographyMap.get(segment2AssignmentRecord.Name),
                                    Allocation_Percentage__c = allocationPercentage * 100,
                                    Charge_Monthly_Revenue__c = record.Id,
                                    RD_Assignment__c = segment2AssignmentRecord.Sales_Region_Assignment_ID__c,
                                    Segment_2__c = segment2AssignmentRecord.Name
                            ));
                        }
                    } else if (record.Rate_Plan_Charge__r.Seg3_Record__r.Product_Geography__r.ProductGeographyType__r.GeographyType__r.Name == 'Country') {
                        for (FC_Segment_2_Assignment__c segment2AssignmentRecord : segment2AssignmentMap.values()) {
                            Decimal allocationPercentage = segment2AssignmentRecord.Allocation_Percentage__c / Decimal.valueOf(100);
                            recordsToInsert.add(new FC_Charge_Monthly_Revenue_Share__c(
                                    Allocated_Amount__c = mrr * allocationPercentage,
                                    Allocated_Geography__c = segment2ToGeographyMap.get(segment2AssignmentRecord.Name),
                                    Allocation_Percentage__c = allocationPercentage * 100,
                                    Charge_Monthly_Revenue__c = record.Id,
                                    RD_Assignment__c = segment2AssignmentRecord.Sales_Region_Assignment_ID__c,
                                    Segment_2__c = segment2AssignmentRecord.Name
                            ));
                        }
                    } else {
                        FC_Segment_2_Assignment__c segment2AssignmentRecord =
                                segment2AssignmentMap.get(record.Rate_Plan_Charge__r.Seg3_Record__r.Product_Geography__r.Geography__r.Seg2__c);
                        if (segment2AssignmentRecord != null) {
                            recordsToInsert.add(new FC_Charge_Monthly_Revenue_Share__c(
                                    Allocated_Amount__c = mrr,
                                    Allocated_Geography__c = segment2ToGeographyMap.get(segment2AssignmentRecord.Name),
                                    Allocation_Percentage__c = 100,
                                    Charge_Monthly_Revenue__c = record.Id,
                                    RD_Assignment__c = segment2AssignmentRecord != null ?
                                            segment2AssignmentRecord.Sales_Region_Assignment_ID__c : null,
                                    Segment_2__c = record.Rate_Plan_Charge__r.Seg3_Record__r.Product_Geography__r.Geography__r.Seg2__c
                            ));
                        }
                    }
                }
            }
        }

        if (!recordsToInsert.isEmpty()) {
            insert recordsToInsert;
        }
    }

    public void finish(Database.BatchableContext context) {
        FC_Charge_Monthly_Revenue_Settings__c config = FC_Charge_Monthly_Revenue_Settings__c.getOrgDefaults();
        config.Active_Import_Process_ID__c = this.importProcessId;
        upsert config;
        Database.executeBatch(new FC_ChargeMonthlyRevenueCleanerBatchable());
    }
}