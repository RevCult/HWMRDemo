@RestResource(urlMapping='/renewal_opportunities')
global with sharing class FC_RenewalOpportunityService {

    @HttpPost
    global static CreateRenewalOpportunityResponse createRenewalOpportunities(RenewalOpportunityInfo[] renewalOpportunityInfos) {

        CreateRenewalOpportunityResponse response = new CreateRenewalOpportunityResponse();

        Savepoint sp = Database.setSavepoint();

        try {
            FC_Renewal_Opportunity_Service_Settings__c config = FC_Renewal_Opportunity_Service_Settings__c.getInstance();

            String[] purchaseTypesToExclude = new List<String>();
            String[] saleTypesToExclude = new List<String>();
            String[] msProductsToExclude = new List<String>();


            // Build opportunity SOQL
            String[] filters = new List<String>();
            Map<Id, RenewalOpportunityInfo> originalOpportunityIdsToRenewalOpportunityInfoMap =
                    new Map<Id, RenewalOpportunityInfo>();

            Map<Id, Boolean> originalOpportunityIdToAnnualizeMap = new Map<Id, Boolean>();

            for (RenewalOpportunityInfo info : renewalOpportunityInfos) {
                if (info.originalOpportunityId != null) {
                    originalOpportunityIdsToRenewalOpportunityInfoMap.put(info.originalOpportunityId, info);
                    originalOpportunityIdToAnnualizeMap.put(info.originalOpportunityId, info.annualize == true);
                }
            }
            if (originalOpportunityIdsToRenewalOpportunityInfoMap.isEmpty()) {
                throw new FC_Exception('No renewalOpportunityInfos specified.');
            }
            Set<Id> originalOpportunityIdsToQuery = originalOpportunityIdsToRenewalOpportunityInfoMap.keySet();
            filters.add('Id in :originalOpportunityIdsToQuery');
            if (String.isNotBlank(config.Purchase_Types_To_Exclude__c)) {
                purchaseTypesToExclude.addAll(config.Purchase_Types_To_Exclude__c.split(';'));
                filters.add('Purchase_Type__c not in :purchaseTypesToExclude');
            }
            if (String.isNotBlank(config.Sale_Types_To_Exclude__c)) {
                saleTypesToExclude.addAll(config.Sale_Types_To_Exclude__c.split(';'));
                filters.add('One_time_Sale_Type__c not in :saleTypesToExclude');
            }
            if (String.isNotBlank(config.MS_Products_To_Exclude__c)) {
                msProductsToExclude.addAll(config.MS_Products_To_Exclude__c.split(';'));
                String[] formattedMsProductsToExclude = new List<String>();
                for (String msProductToExclude : msProductsToExclude) {
                    formattedMsProductsToExclude.add(String.format('\'\'{0}\'\'', new String[]{
                            msProductToExclude
                    }));
                }
                filters.add(String.format('MS_Products__c excludes ({0})', new String[]{
                        String.join(formattedMsProductsToExclude, ', ')
                }));
            }
            String opportunitySoqlTemplate = 'select Id, AccountId, Account.Name, Channel_Type__c, ContractId, ' +
                    'Contract.FC_Subscription__c, Contract.FC_Subscription__r.Zuora__TermEndDate__c, ' +
                    'Contract.FC_Subscription__r.Zuora__TermSettingType__c, ' +
                    'Contract.FC_Subscription__r.Zuora__TermStartDate__c, Division__c, Membership_Term__c, ' +
                    'MS_Products__c, MS_Segments__c, ' +
                    'One_time_Sale_Type__c, OwnerId, Owner.FirstName, Owner.LastName, Purchase_Type__c, RecordTypeId, ' +
                    'RecordType.DeveloperName, Region__c, ' +
                    '(select Id, IsPrimary, OpportunityId, ContactId, Role from OpportunityContactRoles) OpportunityContactRoles ' +
                    'from Opportunity ' +
                    'where {0}';
            String opportunitySoql = String.format(opportunitySoqlTemplate, new String[]{
                    String.join(filters, ' and ')
            });

            // Query original opportunities
            Id[] originalOpportunityIds = new List<Id>();
            Opportunity[] opportunitiesToInsert = new List<Opportunity>();
            List<List<OpportunityContactRole>> opportunityContactRolesToInsertList = new List<List<OpportunityContactRole>>();
            for (Opportunity originalOpportunityRecord : Database.query(opportunitySoql)) {
                RenewalOpportunityInfo info =
                        originalOpportunityIdsToRenewalOpportunityInfoMap.get(originalOpportunityRecord.Id);

                // Build renewal opportunity
                Map<String, String> recordTypeToChannelMap = new Map<String, String>{
                        'Media' => 'BPM',
                        'Network_Opportunity' => 'BPM',
                        'Metrostudy_Opportunity_REE' => originalOpportunityRecord.Channel_Type__c
                };
                String renewalOpportunityChannel = 'Direct';
                if (recordTypeToChannelMap.containsKey(originalOpportunityRecord.RecordType.DeveloperName)) {
                    renewalOpportunityChannel = recordTypeToChannelMap.get(originalOpportunityRecord.RecordType.DeveloperName);
                }
                originalOpportunityIds.add(originalOpportunityRecord.Id);
                opportunitiesToInsert.add(new Opportunity(
                        AccountId = originalOpportunityRecord.AccountId,
                        Cancellation_Status__c = 'Green - Renew/Upsell',
                        Channel_Type__c = renewalOpportunityChannel,
                        CloseDate = info.renewalDate,
                        ContractId = originalOpportunityRecord.ContractId,
                        Description = info.renewalOpportunityDescription,
                        Division__c = originalOpportunityRecord.Division__c,
                        FC_Renew__c = true,
                        FC_Term_Type__c = originalOpportunityRecord.Contract.FC_Subscription__r.Zuora__TermSettingType__c,
                        FC_Term_Start_Date__c = info.renewalDate,
                        Membership_Term__c = originalOpportunityRecord.Membership_Term__c,
                        MS_Products__c = originalOpportunityRecord.MS_Products__c,
                        MS_Segments__c = originalOpportunityRecord.MS_Segments__c,
                        Name = String.format('{0} {1} : {2} {3}', new String[]{
                                String.valueOf(info.renewalDate.year()),
                                originalOpportunityRecord.Account.Name,
                                originalOpportunityRecord.MS_Products__c,
                                String.format('{0}{1}', new String[]{
                                        originalOpportunityRecord.Owner.FirstName.left(1), originalOpportunityRecord.Owner.LastName.left(1)
                                })
                        }).left(120),
                        One_time_Sale_Type__c = originalOpportunityRecord.One_time_Sale_Type__c,
                        OwnerId = originalOpportunityRecord.OwnerId,
                        Probability = originalOpportunityRecord.Contract.FC_Subscription__r.Zuora__TermSettingType__c == 'EVERGREEN' ? 90 : 10,
                        Purchase_Type__c = originalOpportunityRecord.Purchase_Type__c,
                        Region__c = originalOpportunityRecord.Region__c,
                        Renewal__c = true,
                        RecordTypeId = originalOpportunityRecord.RecordTypeId,
                        Skip_Validation__c = true,
                        StageName = 'Proposal Submitted',
                        Type = 'Renewal'
                ));
                opportunityContactRolesToInsertList.add(originalOpportunityRecord.OpportunityContactRoles);
            }

            // Insert renewal opportunities
            CreateRenewalOpportunityResult[] results = new List<CreateRenewalOpportunityResult>();
            Map<Id, Boolean> renewalOpportunityIdToAnnualizeMap = new Map<Id, Boolean>();

            if (!opportunitiesToInsert.isEmpty()) {
                insert opportunitiesToInsert;

                // Insert contact roles for renewal opportunities and prepare value for annualization
                OpportunityContactRole[] opportunityContactRolesToInsert = new List<OpportunityContactRole>();
                Map<Id, Id> opportunityIdToContractIdMap = new Map<Id, Id>();
                for (Integer i = 0; i < opportunitiesToInsert.size(); i++) {
                    opportunityIdToContractIdMap.put(opportunitiesToInsert[i].Id, opportunitiesToInsert[i].ContractId);
                    results.add(new CreateRenewalOpportunityResult(originalOpportunityIds[i], opportunitiesToInsert[i].Id));
                    for (OpportunityContactRole originalOpportunityContactRole : opportunityContactRolesToInsertList[i]) {
                        opportunityContactRolesToInsert.add(
                                new OpportunityContactRole(OpportunityId = opportunitiesToInsert[i].Id,
                                        ContactId = originalOpportunityContactRole.ContactId,
                                        Role = originalOpportunityContactRole.Role,
                                        IsPrimary = originalOpportunityContactRole.IsPrimary));
                    }
                    renewalOpportunityIdToAnnualizeMap.put(opportunitiesToInsert[i].Id, originalOpportunityIdToAnnualizeMap.get(originalOpportunityIds[i]));
                }
                if (!opportunityContactRolesToInsert.isEmpty()) {
                    insert opportunityContactRolesToInsert;
                }
                if (!opportunityIdToContractIdMap.isEmpty()) {

                    // Associate opportunities with contracts
                    FC_OpportunityContractUtil.associateOpportunitiesWithContracts(opportunityIdToContractIdMap);

                    if (!renewalOpportunityIdToAnnualizeMap.isEmpty()) {
                        updateOpportunities(renewalOpportunityIdToAnnualizeMap);
                    }

//                    RenewalOpportunityAsyncInfo asyncInfo = new RenewalOpportunityAsyncInfo(opportunityIdToContractIdMap, renewalOpportunityIdToAnnualizeMap);
//                    FC_LinkOpportunitiesToContractsQueueable linkOpportunitiesToContractsQueueable = new FC_LinkOpportunitiesToContractsQueueable(asyncInfo);
//                    if (!Test.isRunningTest()) {
//                        System.enqueueJob(linkOpportunitiesToContractsQueueable);
//                    }

                }
            }

            response.results = results;
            response.success = true;
        } catch (Exception e) {
            response.success = false;
            response.exceptionType = e.getTypeName();
            response.message = e.getMessage();
            response.stackTrace = e.getStackTraceString();
            Database.rollback(sp);
        }
        return response;
    }

//    public class RenewalOpportunityAsyncInfo {
//
//        public Map<Id, Id> opportunityIdToContractIdMap;
//        public Map<Id, Boolean> opportunityIdToAnnualizeMap;
//
//        public RenewalOpportunityAsyncInfo(Map<Id, Id> opportunityIdToContractIdMap, Map<Id, Boolean> opportunityIdToAnnualizeMap) {
//            this.opportunityIdToContractIdMap = opportunityIdToContractIdMap;
//            this.opportunityIdToAnnualizeMap = opportunityIdToAnnualizeMap;
//        }
//
//    }

    @future
    public static void updateOpportunities(Map<Id, Boolean> opportunityIdToAnnualizeMap) {
        OpportunityLineItem[] opportunityLineItemsToUpdate = new List<OpportunityLineItem>();
        for (OpportunityLineItem opportunityLineItemRecord : [
                select Id, OpportunityId
                from OpportunityLineItem
                where OpportunityId in :opportunityIdToAnnualizeMap.keySet()
        ]) {
            opportunityLineItemsToUpdate.add(new OpportunityLineItem(Id = opportunityLineItemRecord.Id,
                    FC_Do_Not_Annualize__c = opportunityIdToAnnualizeMap.get(opportunityLineItemRecord.OpportunityId) != true,
                    FC_Purchase_Type__c = 'Renewal'));
        }
        if (!opportunityLineItemsToUpdate.isEmpty()) {
            update opportunityLineItemsToUpdate;
        }

        // Get opportunity amounts from line item totals
        Map<Id, Decimal> opportunityIdToAmountMap = new Map<Id, Decimal>();
        for (AggregateResult row : [
                select OpportunityId, sum(TotalPrice) OpportunityTotal
                from OpportunityLineItem
                where OpportunityId in :opportunityIdToAnnualizeMap.keySet()
                group by OpportunityId
        ]) {
            opportunityIdToAmountMap.put((Id) row.get('OpportunityId'), (Decimal) row.get('OpportunityTotal'));
        }

        // Update opportunity name with amount
        Map<Id, String> opportunityIdToNameMap = new Map<Id, String>();
        for (Opportunity opportunityRecord : [
                select Id, AccountId, Account.Name, CloseDate,
                        MS_Products__c, OwnerId, Owner.FirstName, Owner.LastName
                from Opportunity
                where Id in :opportunityIdToAnnualizeMap.keySet()
        ]) {
            if (opportunityIdToAmountMap.containsKey(opportunityRecord.Id)) {
                opportunityIdToNameMap.put(opportunityRecord.Id, String.format('{0} {1} :{2}${3} {4}', new String[]{
                        String.valueOf(opportunityRecord.CloseDate.year()),
                        opportunityRecord.Account.Name,
                        String.isNotBlank(opportunityRecord.MS_Products__c) ? ' ' + opportunityRecord.MS_Products__c + ' ' : ' ',
                        opportunityIdToAmountMap.get(opportunityRecord.Id).setScale(2).format(),
                        String.format('{0}{1}', new String[]{
                                opportunityRecord.Owner.FirstName.left(1), opportunityRecord.Owner.LastName.left(1)
                        })
                }).left(120));
            }
        }

        Opportunity[] opportunitiesToUpdate = new List<Opportunity>();
        for (Id opportunityId : opportunityIdToNameMap.keySet()) {
            opportunitiesToUpdate.add(new Opportunity(Id = opportunityId,
                    Name = opportunityIdToNameMap.get(opportunityId), Skip_Validation__c = true));
        }
        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }

    }

    global class RenewalOpportunityInfo {

        global Id originalOpportunityId;
        global Date renewalDate;
        global String renewalOpportunityDescription;
        global Boolean annualize;

    }

    global class CreateRenewalOpportunityResponse {

        global Boolean success;
        global CreateRenewalOpportunityResult[] results;
        global String exceptionType;
        global String message;
        global String stackTrace;

    }

    global class CreateRenewalOpportunityResult {

        global Id originalOpportunityId;
        global Id renewalOpportunityId;

        global CreateRenewalOpportunityResult(Id originalOpportunityId, Id renewalOpportunityId) {
            this.originalOpportunityId = originalOpportunityId;
            this.renewalOpportunityId = renewalOpportunityId;
        }

    }

}