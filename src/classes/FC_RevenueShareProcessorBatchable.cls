public without sharing class FC_RevenueShareProcessorBatchable implements Database.Batchable<sObject>,
        Database.Stateful {

    public DateTime lastRunOn;
    public DateTime startTime;

    public Boolean processObsoletes;

    public FC_RevenueShareProcessorBatchable(Boolean processObsoletes) {
        this.processObsoletes = processObsoletes;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        FC_Revenue_Share_Settings__c config = FC_Revenue_Share_Settings__c.getOrgDefaults();
        DateTime currentTime = DateTime.now();
        this.startTime = currentTime;
        this.lastRunOn = config.Last_Run_On__c;
        String soqlTemplate = 'select Id, FC_Cancellation_Revenue_Formula__c, FC_Effective_Date__c, ' +
                'FC_End_Date__c, FC_Geography__c, FC_Geography_Type__c, FC_New_Revenue_Formula__c, ' +
                'FC_Price_Increase_Decrease_Formula__c, FC_Product_Geography_Seg3__c, FC_Purchase_Type__c, ' +
                'FC_RD_Assignment__c, FC_Renewal_Revenue_Formula__c, FC_Seg2__c, OpportunityId, Opportunity.LastModifiedDate, ' +
                'Opportunity.FC_Most_Recent_OLI_Last_Modified_Date__c, TotalPrice ' +
                'from OpportunityLineItem where {0} and (not Opportunity.RecordType.DeveloperName in (\'\'Marketing_Group\'\', \'\'Media\'\')) ' +
                'and Opportunity.FC_Bypass_Revenue_Share_Calculation__c = false';

        String criteria = 'Opportunity.CreatedDate <= :currentTime';
        if (config.Last_Run_On__c != null) {
            criteria = '(Opportunity.CreatedDate > :lastRunOn and Opportunity.CreatedDate <= :currentTime)';
        }
        if (processObsoletes) {
            criteria = 'OpportunityId in (select Opportunity__c from FC_Revenue_Share__c where Obsolete__c = true)';
        }

        return Database.getQueryLocator(String.format(soqlTemplate, new String[]{
                criteria
        }));
    }

    public void execute(Database.BatchableContext context, List<OpportunityLineItem> scope) {
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

        FC_Revenue_Share__c[] recordsToInsert = new List<FC_Revenue_Share__c>();
        if (scope != null && !scope.isEmpty()) {
            for (OpportunityLineItem opportunityLineItemRecord : scope) {
                Decimal cancellationRevenue = opportunityLineItemRecord.FC_Cancellation_Revenue_Formula__c != null ? opportunityLineItemRecord.FC_Cancellation_Revenue_Formula__c : 0;
                Decimal deltaRevenue = opportunityLineItemRecord.FC_Price_Increase_Decrease_Formula__c != null ? opportunityLineItemRecord.FC_Price_Increase_Decrease_Formula__c : 0;
                Decimal newRevenue = opportunityLineItemRecord.FC_New_Revenue_Formula__c != null ? opportunityLineItemRecord.FC_New_Revenue_Formula__c : 0;
                Decimal renewalRevenue = opportunityLineItemRecord.FC_Renewal_Revenue_Formula__c != null ? opportunityLineItemRecord.FC_Renewal_Revenue_Formula__c : 0;
                Decimal totalRevenue = opportunityLineItemRecord.TotalPrice != null ? opportunityLineItemRecord.TotalPrice : 0;
                if (opportunityLineItemRecord.FC_Geography_Type__c == 'State' &&
                        stateToSegment2AssignmentsMap.containsKey(opportunityLineItemRecord.FC_Geography__c) &&
                        stateToSegment2TotalPercentAllocationMap.containsKey(opportunityLineItemRecord.FC_Geography__c) &&
                        stateToSegment2TotalPercentAllocationMap.get(opportunityLineItemRecord.FC_Geography__c) != 0) {
                    for (FC_Segment_2_Assignment__c segment2AssignmentRecord : stateToSegment2AssignmentsMap.get(opportunityLineItemRecord.FC_Geography__c)) {
                        Decimal allocationPercentage = segment2AssignmentRecord.Allocation_Percentage__c /
                                stateToSegment2TotalPercentAllocationMap.get(opportunityLineItemRecord.FC_Geography__c);
                        recordsToInsert.add(new FC_Revenue_Share__c(
                                Allocated_Cancellation_Revenue__c = cancellationRevenue * allocationPercentage,
                                Allocated_Delta_Revenue__c = deltaRevenue * allocationPercentage,
                                Allocated_Geography__c = segment2ToGeographyMap.get(segment2AssignmentRecord.Name),
                                Allocated_New_Revenue__c = newRevenue * allocationPercentage,
                                Allocated_Renewal_Revenue__c = renewalRevenue * allocationPercentage,
                                Allocated_Total_Revenue__c = totalRevenue * allocationPercentage,
                                Allocation_Percentage__c = allocationPercentage * 100,
                                End_Date__c = opportunityLineItemRecord.FC_End_Date__c,
                                Opportunity__c = opportunityLineItemRecord.OpportunityId,
                                Opportunity_Last_Modified_Date__c = opportunityLineItemRecord.Opportunity.LastModifiedDate,
                                Opportunity_Line_Item_ID__c = opportunityLineItemRecord.Id,
                                Processed_By_Batchable_On__c = this.startTime,
                                Purchase_Type__c = opportunityLineItemRecord.FC_Purchase_Type__c,
                                RD_Assignment__c = segment2AssignmentRecord.Sales_Region_Assignment_ID__c,
                                Recent_Opp_Line_Item_Last_Modified_Date__c = opportunityLineItemRecord.Opportunity.FC_Most_Recent_OLI_Last_Modified_Date__c,
                                Seg3_Record__c = opportunityLineItemRecord.FC_Product_Geography_Seg3__c,
                                Segment_2__c = segment2AssignmentRecord.Name,
                                Start_Date__c = opportunityLineItemRecord.FC_Effective_Date__c));
                    }
                } else if (opportunityLineItemRecord.FC_Geography_Type__c == 'Country') {
                    for (FC_Segment_2_Assignment__c segment2AssignmentRecord : segment2AssignmentMap.values()) {
                        Decimal allocationPercentage = segment2AssignmentRecord.Allocation_Percentage__c / Decimal.valueOf(100);
                        recordsToInsert.add(new FC_Revenue_Share__c(
                                Allocated_Cancellation_Revenue__c = cancellationRevenue * allocationPercentage,
                                Allocated_Delta_Revenue__c = deltaRevenue * allocationPercentage,
                                Allocated_Geography__c = segment2ToGeographyMap.get(segment2AssignmentRecord.Name),
                                Allocated_New_Revenue__c = newRevenue * allocationPercentage,
                                Allocated_Renewal_Revenue__c = renewalRevenue * allocationPercentage,
                                Allocated_Total_Revenue__c = totalRevenue * allocationPercentage,
                                Allocation_Percentage__c = allocationPercentage * 100,
                                End_Date__c = opportunityLineItemRecord.FC_End_Date__c,
                                Opportunity__c = opportunityLineItemRecord.OpportunityId,
                                Opportunity_Last_Modified_Date__c = opportunityLineItemRecord.Opportunity.LastModifiedDate,
                                Opportunity_Line_Item_ID__c = opportunityLineItemRecord.Id,
                                Processed_By_Batchable_On__c = this.startTime,
                                Purchase_Type__c = opportunityLineItemRecord.FC_Purchase_Type__c,
                                RD_Assignment__c = segment2AssignmentRecord.Sales_Region_Assignment_ID__c,
                                Recent_Opp_Line_Item_Last_Modified_Date__c = opportunityLineItemRecord.Opportunity.FC_Most_Recent_OLI_Last_Modified_Date__c,
                                Seg3_Record__c = opportunityLineItemRecord.FC_Product_Geography_Seg3__c,
                                Segment_2__c = segment2AssignmentRecord.Name,
                                Start_Date__c = opportunityLineItemRecord.FC_Effective_Date__c));
                    }
                } else {
                    recordsToInsert.add(new FC_Revenue_Share__c(
                            Allocated_Cancellation_Revenue__c = cancellationRevenue,
                            Allocated_Delta_Revenue__c = deltaRevenue,
                            Allocated_Geography__c = segment2ToGeographyMap.get(opportunityLineItemRecord.FC_Seg2__c),
                            Allocated_New_Revenue__c = newRevenue,
                            Allocated_Renewal_Revenue__c = renewalRevenue,
                            Allocated_Total_Revenue__c = totalRevenue,
                            Allocation_Percentage__c = 100,
                            End_Date__c = opportunityLineItemRecord.FC_End_Date__c,
                            Opportunity__c = opportunityLineItemRecord.OpportunityId,
                            Opportunity_Last_Modified_Date__c = opportunityLineItemRecord.Opportunity.LastModifiedDate,
                            Opportunity_Line_Item_ID__c = opportunityLineItemRecord.Id,
                            Processed_By_Batchable_On__c = this.startTime,
                            Purchase_Type__c = opportunityLineItemRecord.FC_Purchase_Type__c,
                            RD_Assignment__c = opportunityLineItemRecord.FC_RD_Assignment__c,
                            Recent_Opp_Line_Item_Last_Modified_Date__c = opportunityLineItemRecord.Opportunity.FC_Most_Recent_OLI_Last_Modified_Date__c,
                            Seg3_Record__c = opportunityLineItemRecord.FC_Product_Geography_Seg3__c,
                            Segment_2__c = opportunityLineItemRecord.FC_Seg2__c,
                            Start_Date__c = opportunityLineItemRecord.FC_Effective_Date__c));
                }
            }
        }

        if (!recordsToInsert.isEmpty()) {
            insert recordsToInsert;
        }
    }

    public void finish(Database.BatchableContext context) {
        FC_Revenue_Share_Settings__c config = FC_Revenue_Share_Settings__c.getOrgDefaults();
        config.Last_Run_On__c = this.startTime;
        upsert config;
        if (!processObsoletes) {
            FC_RevenueShareProcessorBatchable processorBatchable = new FC_RevenueShareProcessorBatchable(true);
            Database.executeBatch(processorBatchable);
        } else {
            FC_RevenueShareCleanerBatchable cleanerBatchable = new FC_RevenueShareCleanerBatchable(this.startTime);
            Database.executeBatch(cleanerBatchable);
        }
    }

}