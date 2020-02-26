public class FC_MetroclientAccountProvisioningUtil {

    private static final MetroclientAccountProductGeography__c[] ACCOUNT_PRODUCT_GEOGRAPHIES_TO_INSERT =
            new List<MetroclientAccountProductGeography__c>();
    private static final Map<Id, MetroclientAccountProductGeography__c> ACCOUNT_PRODUCT_GEOGRAPHIES_TO_UPDATE_MAP =
            new Map<Id, MetroclientAccountProductGeography__c>();
    private static final Note[] ZUORA_CLIENT_TRANSACTION_NOTES = new List<Note>();

    public static void buildProvisioningRecords(List<Id> accountIds, Id transactionParentId) {
        FC_ZuoraClient client = new FC_ZuoraClient(transactionParentId);

        try {

            // Split account IDs into groups of 200
            List<List<Id>> listOfAccountIdLists = splitIdList(new List<Id>(accountIds), 200);

            // Query accounts from Zuora
            Map<String, Map<String, String>> zuoraAccountLookupMap = new Map<String, Map<String, String>>();
            Map<Id, Map<String, String>> zuoraAccountCrmIdLookupMap = new Map<Id, Map<String, String>>();
            for (List<Id> accountIdSublist : listOfAccountIdLists) {
                List<String> accountCriteriaList = new List<String>();
                for (Id accountId : accountIdSublist) {
                    accountCriteriaList.add(String.format('CrmId = \'\'{0}\'\'', new String[]{
                            String.escapeSingleQuotes(accountId)
                    }));
                }

                if (!accountCriteriaList.isEmpty()) {
                    FC_ZuoraClient.QueryActionRequest accountQueryRequest = new FC_ZuoraClient.QueryActionRequest();
                    FC_ZuoraClient.QueryActionRequestConf conf = new FC_ZuoraClient.QueryActionRequestConf();
                    conf.batchSize = 2000;
                    accountQueryRequest.conf = conf;
                    accountQueryRequest.queryString = String.format('select Id, CrmId from Account where {0}',
                            new String[]{
                                    String.join(accountCriteriaList, ' or ')
                            });
                    System.debug('**** ACCOUNT QUERY REQUEST: ' + accountQueryRequest);
                    FC_ZuoraClient.QueryActionResponse accountQueryResponse = client.query(accountQueryRequest);
                    System.debug('**** ACCOUNT QUERY RESPONSE: ' + accountQueryResponse);
                    for (Map<String, String> accountRecord : accountQueryResponse.records) {
                        zuoraAccountLookupMap.put(accountRecord.get('Id'), accountRecord);
                        try {
                            if (String.isNotBlank(accountRecord.get('CrmId'))) {
                                zuoraAccountCrmIdLookupMap.put(Id.valueOf(accountRecord.get('CrmId')), accountRecord);
                            }
                        } catch (Exception e) {
                            // Do nothing.
                        }
                    }
                }
            }

            // Split Zuora account IDs into groups of 200.
            List<List<String>> listOfAccountZuoraIdLists = splitStringList(new List<String>(zuoraAccountLookupMap.keySet()), 200);

            // Query subscriptions from Zuora
            Map<String, Map<String, String>> zuoraSubscriptionLookupMap = new Map<String, Map<String, String>>();
            Map<String, Map<String, String>> zuoraPreviousSubscriptionLookupMap = new Map<String, Map<String, String>>();
            Map<String, Map<String, Map<String, String>>> subscriptionZuoraIdToRatePlansLookupMap = new Map<String, Map<String, Map<String, String>>>();
            // Set<String> accountZuoraIdsToLookup = new Set<String>();
            Set<String> ratePlanZuoraIdsToLookup = new Set<String>();
            Set<String> previousSubscriptionIdsToLookup = new Set<String>();
            Set<String> subscriptionNumbersInScope = new Set<String>();
            for (List<String> accountZuoraIdSublist : listOfAccountZuoraIdLists) {
                List<String> subscriptionCriteriaList = new List<String>();
                for (String accountZuoraId : accountZuoraIdSublist) {
                    subscriptionCriteriaList.add(String.format('AccountId = \'\'{0}\'\'',
                            new String[]{
                                    String.escapeSingleQuotes(accountZuoraId)
                            }));
                }

                if (!subscriptionCriteriaList.isEmpty()) {
                    FC_ZuoraClient.QueryActionRequest subscriptionQueryRequest = new FC_ZuoraClient.QueryActionRequest();
                    FC_ZuoraClient.QueryActionRequestConf subscriptionQueryRequestConf = new FC_ZuoraClient.QueryActionRequestConf();
                    subscriptionQueryRequestConf.batchSize = 2000;
                    subscriptionQueryRequest.conf = subscriptionQueryRequestConf;
                    subscriptionQueryRequest.queryString = String.format('select Id, AccountId, CancelledDate, Name, ' +
                            'PreviousSubscriptionId, Status, SubscriptionEndDate, SubscriptionStartDate from Subscription where {0}',
                            new String[]{
                                    String.join(subscriptionCriteriaList, ' or ')
                            });
                    System.debug('**** SUBSCRIPTION QUERY REQUEST: ' + subscriptionQueryRequest);
                    FC_ZuoraClient.QueryActionResponse subscriptionQueryResponse = client.query(subscriptionQueryRequest);
                    System.debug('**** SUBSCRIPTION QUERY RESPONSE: ' + subscriptionQueryResponse);
                    for (Map<String, String> subscriptionRecord : subscriptionQueryResponse.records) {
                        zuoraSubscriptionLookupMap.put(subscriptionRecord.get('Id'), subscriptionRecord);
                        // accountZuoraIdsToLookup.add(subscriptionRecord.get('AccountId'));
                        subscriptionNumbersInScope.add(subscriptionRecord.get('Name'));
                        if (String.isNotBlank(subscriptionRecord.get('PreviousSubscriptionId'))) {
                            previousSubscriptionIdsToLookup.add(subscriptionRecord.get('PreviousSubscriptionId'));
                            zuoraPreviousSubscriptionLookupMap.put(subscriptionRecord.get('PreviousSubscriptionId'), subscriptionRecord);
                        }
                    }
                }

                // Split Zuora subscription IDs into groups of 199.
                List<List<String>> listOfSubscriptionZuoraIdLists = splitStringList(new List<String>(zuoraSubscriptionLookupMap.keySet()), 199);
                for (List<String> subscriptionZuoraIdSublist : listOfSubscriptionZuoraIdLists) {

                    List<String> ratePlanCriteriaList = new List<String>();
                    for (String subscriptionZuoraId : subscriptionZuoraIdSublist) {
                        ratePlanCriteriaList.add(String.format('SubscriptionId = \'\'{0}\'\'',
                                new String[]{
                                        String.escapeSingleQuotes(subscriptionZuoraId)
                                }));
                    }

                    // Query rate plans from Zuora
                    if (!ratePlanCriteriaList.isEmpty()) {

                        // Do not include removed rate plans in first query
                        FC_ZuoraClient.QueryActionRequest ratePlanQueryRequest = new FC_ZuoraClient.QueryActionRequest();
                        FC_ZuoraClient.QueryActionRequestConf ratePlanQueryRequestConf = new FC_ZuoraClient.QueryActionRequestConf();
                        ratePlanQueryRequestConf.batchSize = 2000;
                        ratePlanQueryRequest.conf = ratePlanQueryRequestConf;
                        ratePlanQueryRequest.queryString = String.format('select Id, SubscriptionId from RatePlan where {0}',
                                new String[]{
                                        String.join(ratePlanCriteriaList, ' or ')
                                });
                        System.debug('**** RATE PLAN QUERY 1 REQUEST: ' + ratePlanQueryRequest);
                        FC_ZuoraClient.QueryActionResponse ratePlanQueryResponse = client.query(ratePlanQueryRequest);
                        System.debug('**** RATE PLAN QUERY 1 RESPONSE: ' + ratePlanQueryResponse);
                        Boolean ratePlanQueryDone = false;
                        while (!ratePlanQueryDone) {
                            ratePlanQueryDone = ratePlanQueryResponse.done;
                            for (Map<String, String> ratePlanRecord : ratePlanQueryResponse.records) {
                                ratePlanZuoraIdsToLookup.add(ratePlanRecord.get('Id'));
                                Map<String, Map<String, String>> subscriptionRatePlansLookupMap = subscriptionZuoraIdToRatePlansLookupMap.get(ratePlanRecord.get('SubscriptionId'));
                                if (subscriptionRatePlansLookupMap == null) {
                                    subscriptionRatePlansLookupMap = new Map<String, Map<String, String>>();
                                    subscriptionZuoraIdToRatePlansLookupMap.put(ratePlanRecord.get('SubscriptionId'), subscriptionRatePlansLookupMap);
                                }
                                subscriptionRatePlansLookupMap.put(ratePlanRecord.get('Id'), ratePlanRecord);
                            }
                            if (!ratePlanQueryDone) {
                                FC_ZuoraClient.QueryMoreActionRequest ratePlanQueryMoreRequest = new FC_ZuoraClient.QueryMoreActionRequest();
                                ratePlanQueryMoreRequest.queryLocator = ratePlanQueryResponse.queryLocator;
                                ratePlanQueryResponse = client.queryMore(ratePlanQueryMoreRequest);
                            }
                        }

                        // Include removed rate plans in second query
                        ratePlanQueryRequest = new FC_ZuoraClient.QueryActionRequest();
                        ratePlanQueryRequestConf = new FC_ZuoraClient.QueryActionRequestConf();
                        ratePlanQueryRequestConf.batchSize = 2000;
                        ratePlanQueryRequest.conf = ratePlanQueryRequestConf;
                        ratePlanQueryRequest.queryString = String.format('select Id, SubscriptionId from RatePlan where {0} and AmendmentType != null',
                                new String[]{
                                        String.join(ratePlanCriteriaList, ' or ')
                                });
                        System.debug('**** RATE PLAN QUERY 2 REQUEST: ' + ratePlanQueryRequest);
                        ratePlanQueryResponse = client.query(ratePlanQueryRequest);
                        System.debug('**** RATE PLAN QUERY 2 RESPONSE: ' + ratePlanQueryResponse);
                        ratePlanQueryDone = false;
                        while (!ratePlanQueryDone) {
                            ratePlanQueryDone = ratePlanQueryResponse.done;
                            for (Map<String, String> ratePlanRecord : ratePlanQueryResponse.records) {
                                ratePlanZuoraIdsToLookup.add(ratePlanRecord.get('Id'));
                                Map<String, Map<String, String>> subscriptionRatePlansLookupMap = subscriptionZuoraIdToRatePlansLookupMap.get(ratePlanRecord.get('SubscriptionId'));
                                if (subscriptionRatePlansLookupMap == null) {
                                    subscriptionRatePlansLookupMap = new Map<String, Map<String, String>>();
                                    subscriptionZuoraIdToRatePlansLookupMap.put(ratePlanRecord.get('SubscriptionId'), subscriptionRatePlansLookupMap);
                                }
                                subscriptionRatePlansLookupMap.put(ratePlanRecord.get('Id'), ratePlanRecord);
                            }
                            if (!ratePlanQueryDone) {
                                FC_ZuoraClient.QueryMoreActionRequest ratePlanQueryMoreRequest = new FC_ZuoraClient.QueryMoreActionRequest();
                                ratePlanQueryMoreRequest.queryLocator = ratePlanQueryResponse.queryLocator;
                                ratePlanQueryResponse = client.queryMore(ratePlanQueryMoreRequest);
                            }
                        }

                    }

                }

            }


            // Split rate plan IDs into groups of 200
            List<List<String>> listOfRatePlanZuoraIdLists = splitStringList(new List<String>(ratePlanZuoraIdsToLookup), 200);

            // Query rate plan charges from Zuora
            Map<String, Map<String, String>> zuoraRatePlanChargeLookupMap = new Map<String, Map<String, String>>();
            Map<String, List<Map<String, String>>> ratePlanZuoraIdToRatePlanChargesMap = new Map<String, List<Map<String, String>>>();
            Set<Id> metroclientProductGeographyIdsInScope = new Set<Id>();
            for (List<String> ratePlanZuoraIdSublist : listOfRatePlanZuoraIdLists) {
                List<String> ratePlanChargeCriteriaList = new List<String>();
                for (String ratePlanZuoraId : ratePlanZuoraIdSublist) {
                    ratePlanChargeCriteriaList.add(String.format('RatePlanId = \'\'{0}\'\'', new String[]{
                            String.escapeSingleQuotes(ratePlanZuoraId)
                    }));
                }

                if (!ratePlanChargeCriteriaList.isEmpty()) {
                    FC_ZuoraClient.QueryActionRequest ratePlanChargeQueryRequest = new FC_ZuoraClient.QueryActionRequest();
                    FC_ZuoraClient.QueryActionRequestConf ratePlanChargeQueryRequestConf = new FC_ZuoraClient.QueryActionRequestConf();
                    ratePlanChargeQueryRequestConf.batchSize = 2000;
                    ratePlanChargeQueryRequest.conf = ratePlanChargeQueryRequestConf;
                    ratePlanChargeQueryRequest.queryString = String.format('select Id, ChargeNumber, ChargeType, ' +
                            'EffectiveEndDate, EffectiveStartDate, IsLastSegment, RatePlanId, Record_Id__c, Segment ' +
                            'from RatePlanCharge where {0}',
                            new String[]{
                                    String.join(ratePlanChargeCriteriaList, ' or ')
                            });
                    System.debug('**** RATE PLAN CHARGE QUERY REQUEST: ' + ratePlanChargeQueryRequest);
                    FC_ZuoraClient.QueryActionResponse ratePlanChargeQueryResponse = client.query(ratePlanChargeQueryRequest);
                    System.debug('**** RATE PLAN CHARGE QUERY RESPONSE: ' + ratePlanChargeQueryResponse);
                    Boolean ratePlanChargeQueryDone = false;
                    while (!ratePlanChargeQueryDone) {
                        ratePlanChargeQueryDone = ratePlanChargeQueryResponse.done;
                        for (Map<String, String> ratePlanChargeRecord : ratePlanChargeQueryResponse.records) {
                            if (toBoolean(ratePlanChargeRecord.get('IsLastSegment')) || toInteger(ratePlanChargeRecord.get('Segment')) == 1) {
                                zuoraRatePlanChargeLookupMap.put(ratePlanChargeRecord.get('Id'), ratePlanChargeRecord);
                                if (toId(ratePlanChargeRecord.get('Record_Id__c')) != null) {
                                    metroclientProductGeographyIdsInScope.add(toId(ratePlanChargeRecord.get('Record_Id__c')));
                                }
                                List<Map<String, String>> ratePlanCharges = ratePlanZuoraIdToRatePlanChargesMap.get(ratePlanChargeRecord.get('RatePlanId'));
                                if (ratePlanCharges == null) {
                                    ratePlanCharges = new List<Map<String, String>>();
                                    ratePlanZuoraIdToRatePlanChargesMap.put(ratePlanChargeRecord.get('RatePlanId'), ratePlanCharges);
                                }
                                ratePlanCharges.add(ratePlanChargeRecord);
                            }
                        }
                        if (!ratePlanChargeQueryDone) {
                            FC_ZuoraClient.QueryMoreActionRequest ratePlanChargeQueryMoreRequest = new FC_ZuoraClient.QueryMoreActionRequest();
                            ratePlanChargeQueryMoreRequest.queryLocator = ratePlanChargeQueryResponse.queryLocator;
                            ratePlanChargeQueryResponse = client.queryMore(ratePlanChargeQueryMoreRequest);
                        }
                    }
                }
            }

            // Split previous subscriptionIds into groups of 200
            List<List<String>> listOfPreviousSubscriptionZuoraIdLists = splitStringList(new List<String>(previousSubscriptionIdsToLookup), 200);

            // Query amendments from Zuora
            Map<String, Map<String, String>> zuoraAmendmentLookupMap = new Map<String, Map<String, String>>();
            Map<String, Map<String, String>> subscriptionZuoraIdToAmendmentMap = new Map<String, Map<String, String>>();
            for (List<String> previousSubscriptionZuoraIdSublist : listOfPreviousSubscriptionZuoraIdLists) {
                List<String> amendmentCriteriaList = new List<String>();
                for (String previousSubscriptionId : previousSubscriptionZuoraIdSublist) {
                    amendmentCriteriaList.add(String.format('SubscriptionId = \'\'{0}\'\'', new String[]{
                            String.escapeSingleQuotes(previousSubscriptionId)
                    }));
                }

                if (!amendmentCriteriaList.isEmpty()) {
                    FC_ZuoraClient.QueryActionRequest amendmentQueryRequest = new FC_ZuoraClient.QueryActionRequest();
                    FC_ZuoraClient.QueryActionRequestConf amendmentQueryRequestConf = new FC_ZuoraClient.QueryActionRequestConf();
                    amendmentQueryRequestConf.batchSize = 2000;
                    amendmentQueryRequest.conf = amendmentQueryRequestConf;
                    amendmentQueryRequest.queryString = String.format('select Id, EffectiveDate, SubscriptionId, Type ' +
                            'from Amendment where {0}',
                            new String[]{
                                    String.join(amendmentCriteriaList, ' or ')
                            });
                    System.debug('**** AMENDMENT QUERY REQUEST: ' + amendmentQueryRequest);
                    FC_ZuoraClient.QueryActionResponse amendmentQueryResponse = client.query(amendmentQueryRequest);
                    System.debug('**** AMENDMENT QUERY RESPONSE: ' + amendmentQueryResponse);
                    Boolean amendmentQueryDone = false;
                    while (!amendmentQueryDone) {
                        amendmentQueryDone = amendmentQueryResponse.done;
                        for (Map<String, String> amendmentRecord : amendmentQueryResponse.records) {
                            zuoraAmendmentLookupMap.put(amendmentRecord.get('Id'), amendmentRecord);
                            Map<String, String> subscriptionRecord = zuoraPreviousSubscriptionLookupMap.get(amendmentRecord.get('SubscriptionId'));
                            if (subscriptionRecord != null) {
                                subscriptionZuoraIdToAmendmentMap.put(subscriptionRecord.get('Id'), amendmentRecord);
                            }
                        }
                        if (!amendmentQueryDone) {
                            FC_ZuoraClient.QueryMoreActionRequest amendmentQueryMoreRequest = new FC_ZuoraClient.QueryMoreActionRequest();
                            amendmentQueryMoreRequest.queryLocator = amendmentQueryResponse.queryLocator;
                            amendmentQueryResponse = client.queryMore(amendmentQueryMoreRequest);
                        }
                    }
                }
            }

            // Get provisioned Metroclient Account Product Geographies
            MetroclientAccountProductGeography__c[] provisionedMetroclientAccountProductGeographies = [
                    select Id, Account__c, ChargeNumber__c, Deleted__c, EndDate__c, MetroclientProductGeography__c,
                            Override__c, StartDate__c, SubscriptionName__c
                    from MetroclientAccountProductGeography__c
                    where Deleted__c = false
                    and Account__c in :accountIds
                    // and SubscriptionName__c = :subscriptionNumbersInScope
            ];

            System.debug('**** PROVISIONED MAPG LIST: ' + provisionedMetroclientAccountProductGeographies);

            // Store provisioned Metroclient Account Product Geographies in a map
            Map<MetroclientAccountProductGeographyKey, MetroclientAccountProductGeography__c> provisionedMetroclientAccountProductGeographiesMap =
                    new Map<MetroclientAccountProductGeographyKey, MetroclientAccountProductGeography__c>();
            Map<ChargeNumberMetroclientProductGeographyKey, MetroclientAccountProductGeography__c> provisionedRatePlanChargeKeysToMetroclientAccountProductGeographiesMap =
                    new Map<ChargeNumberMetroclientProductGeographyKey, MetroclientAccountProductGeography__c>();
            for (MetroclientAccountProductGeography__c metroclientAccountProductGeographyRecord :
                    provisionedMetroclientAccountProductGeographies) {
                if (!metroclientAccountProductGeographyRecord.Override__c) {
                    provisionedMetroclientAccountProductGeographiesMap.put(new MetroclientAccountProductGeographyKey(
                            metroclientAccountProductGeographyRecord.ChargeNumber__c,
                            metroclientAccountProductGeographyRecord.MetroclientProductGeography__c,
                            metroclientAccountProductGeographyRecord.Account__c,
                            metroclientAccountProductGeographyRecord.SubscriptionName__c),
                            metroclientAccountProductGeographyRecord);
                    provisionedRatePlanChargeKeysToMetroclientAccountProductGeographiesMap.put(new ChargeNumberMetroclientProductGeographyKey(
                            metroclientAccountProductGeographyRecord.ChargeNumber__c,
                            metroclientAccountProductGeographyRecord.MetroclientProductGeography__c),
                            metroclientAccountProductGeographyRecord);
                }
            }

            System.debug('**** PROVISIONED MAPG MAP: ' + provisionedMetroclientAccountProductGeographiesMap);
            System.debug('**** PROVISIONED RPC TO PROVISIONED MAPG MAP: ' + provisionedRatePlanChargeKeysToMetroclientAccountProductGeographiesMap);

            /* The Metroclient Account Product Geographies that we are about to insert also need to be in the map to
             * prevent duplicate provisioning records from being created.
             */
            for (MetroclientAccountProductGeography__c metroclientAccountProductGeographyRecord : ACCOUNT_PRODUCT_GEOGRAPHIES_TO_INSERT) {
                provisionedMetroclientAccountProductGeographiesMap.put(new MetroclientAccountProductGeographyKey(
                        metroclientAccountProductGeographyRecord.ChargeNumber__c,
                        metroclientAccountProductGeographyRecord.MetroclientProductGeography__c,
                        metroclientAccountProductGeographyRecord.Account__c,
                        metroclientAccountProductGeographyRecord.SubscriptionName__c),
                        metroclientAccountProductGeographyRecord);
                provisionedRatePlanChargeKeysToMetroclientAccountProductGeographiesMap.put(new ChargeNumberMetroclientProductGeographyKey(
                        metroclientAccountProductGeographyRecord.ChargeNumber__c,
                        metroclientAccountProductGeographyRecord.MetroclientProductGeography__c),
                        metroclientAccountProductGeographyRecord);
            }

            Map<Id, MetroclientProductGeography__c> metroclientProductGeographyLookupMap =
                    FC_MetroclientProductGeographyCache.findByIds(metroclientProductGeographyIdsInScope);

            System.debug('**** MAPG LOOKUP MAP: ' + metroclientProductGeographyLookupMap);

            /* Track visited rate plan charges by storing a key consisting of the Rate Plan Charge Number and the
             * Rate Plan Charge Record_Id__c field values
             */
            Set<ChargeNumberMetroclientProductGeographyKey> visitedRatePlanChargeKeys =
                    new Set<ChargeNumberMetroclientProductGeographyKey>();

            // Keep track of rate plan charge earliest effective start date
            Map<String, Date> ratePlanChargeEarliestEffectiveStartDateMap = new Map<String, Date>();

            // Keep track of rate plan charge latest effective end date
            Map<String, Date> ratePlanChargeLatestEffectiveEndDateMap = new Map<String, Date>();

            // Keep track of rate plan charges where the latest effective end date was computed
            Set<String> chargeNumbersWithNoEffectiveEndDate = new Set<String>();

            // Iterate through subscription version in order specified by input parameter
            for (Map<String, String> subscriptionObject : zuoraSubscriptionLookupMap.values()) {

                if (subscriptionObject.get('Status') != 'Expired') {

                    Date startDate = null;
                    Date endDate = null;

                    // Iterate through subscription rate plans
                    Map<String, Map<String, String>> ratePlansLookupMap = subscriptionZuoraIdToRatePlansLookupMap.get(subscriptionObject.get('Id'));
                    if (ratePlansLookupMap != null) {
                        for (Map<String, String> ratePlan : ratePlansLookupMap.values()) {

                            // Iterate through subscription rate plan charges
                            List<Map<String, String>> ratePlanCharges = ratePlanZuoraIdToRatePlanChargesMap.get(ratePlan.get('Id'));
                            if (ratePlanCharges != null) {
                                for (Map<String, String> ratePlanCharge : ratePlanCharges) {

                                    System.debug('**** PROCESSING RPC: ' + ratePlanCharge);

                                    // If Record_Id__c exists in the Metroclient Product Geographies in scope...
                                    if (toId(ratePlanCharge.get('Record_Id__c')) != null &&
                                            metroclientProductGeographyLookupMap.containsKey(toId(ratePlanCharge.get('Record_Id__c')))) {

                                        MetroclientProductGeography__c metroclientProductGeographyRecord =
                                                metroclientProductGeographyLookupMap.get(toId(ratePlanCharge.get('Record_Id__c')));


                                        /* If Rate Plan Charge is not a One-Time Charge, or
                                         * if MPG.ProductGeographyType__r.Product__r.SubscriptionOnly__c is true...
                                         */
                                        if (ratePlanCharge.get('ChargeType') != 'OneTime' ||
                                                metroclientProductGeographyRecord.ProductGeographyType__r.Product__r.SubscriptionOnly__c) {

                                            // Track visited rate plan charge
                                            visitedRatePlanChargeKeys.add(
                                                    new ChargeNumberMetroclientProductGeographyKey(ratePlanCharge.get('ChargeNumber'),
                                                            toId(ratePlanCharge.get('Record_Id__c'))));

                                            // Determine start and end dates.
                                            Date ratePlanChargeEffectiveStartDate = toDate(ratePlanCharge.get('EffectiveStartDate'));
                                            System.debug('****** RATE PLAN CHARGE EFFECTIVE START DATE FOR ' + ratePlanCharge.get('ChargeNumber') + ': ' + ratePlanChargeEffectiveStartDate);
                                            Date currentEarliestRatePlanChargeEffectiveStartDate = ratePlanChargeEarliestEffectiveStartDateMap.get(ratePlanCharge.get('ChargeNumber'));
                                            System.debug('****** BEFORE - CURRENT RATE PLAN CHARGE EARLIEST EFFECTIVE START DATE FOR ' + ratePlanCharge.get('ChargeNumber') + ': ' + currentEarliestRatePlanChargeEffectiveStartDate);
                                            if (currentEarliestRatePlanChargeEffectiveStartDate == null || ratePlanChargeEffectiveStartDate < currentEarliestRatePlanChargeEffectiveStartDate) {
                                                ratePlanChargeEarliestEffectiveStartDateMap.put(ratePlanCharge.get('ChargeNumber'), ratePlanChargeEffectiveStartDate);
                                                currentEarliestRatePlanChargeEffectiveStartDate = ratePlanChargeEffectiveStartDate;
                                            }
                                            System.debug('****** AFTER - CURRENT RATE PLAN CHARGE EARLIEST EFFECTIVE START DATE FOR ' + ratePlanCharge.get('ChargeNumber') + ': ' + currentEarliestRatePlanChargeEffectiveStartDate);
                                            //startDate = toDate(ratePlanCharge.get('EffectiveStartDate'));
                                            startDate = currentEarliestRatePlanChargeEffectiveStartDate;

                                            Date ratePlanChargeEffectiveEndDate = toDate(ratePlanCharge.get('EffectiveEndDate'));
                                            System.debug('****** RATE PLAN CHARGE EFFECTIVE END DATE FOR ' + ratePlanCharge.get('ChargeNumber') + ': ' + ratePlanChargeEffectiveEndDate);
                                            Date currentLatestRatePlanChargeEffectiveEndDate = ratePlanChargeLatestEffectiveEndDateMap.get(ratePlanCharge.get('ChargeNumber'));
                                            System.debug('****** BEFORE - CURRENT RATE PLAN CHARGE LATEST EFFECTIVE END DATE FOR ' + ratePlanCharge.get('ChargeNumber') + ': ' + currentLatestRatePlanChargeEffectiveEndDate);
                                            if (ratePlanChargeEffectiveEndDate == null) {
                                                chargeNumbersWithNoEffectiveEndDate.add(ratePlanCharge.get('ChargeNumber'));
                                                currentLatestRatePlanChargeEffectiveEndDate = null;
                                            } else if (currentLatestRatePlanChargeEffectiveEndDate == null || ratePlanChargeEffectiveEndDate > currentLatestRatePlanChargeEffectiveEndDate) {
                                                ratePlanChargeLatestEffectiveEndDateMap.put(ratePlanCharge.get('ChargeNumber'), ratePlanChargeEffectiveEndDate);
                                                currentLatestRatePlanChargeEffectiveEndDate = ratePlanChargeEffectiveEndDate;
                                            }

                                            System.debug('****** AFTER - CURRENT RATE PLAN CHARGE LATEST EFFECTIVE END DATE FOR ' + ratePlanCharge.get('ChargeNumber') + ': ' + currentLatestRatePlanChargeEffectiveEndDate);

                                            if (subscriptionObject.get('Status') == 'Cancelled' &&
                                                    String.isNotBlank(subscriptionObject.get('CancelledDate'))) {
                                                endDate = toDate(subscriptionObject.get('CancelledDate'));
                                            } else if (ratePlanCharge.get('ChargeType') == 'OneTime') {
                                                Map<String, String> amendment =
                                                        subscriptionZuoraIdToAmendmentMap.get(subscriptionObject.get('Id'));
                                                if (amendment != null && amendment.get('Type') == 'RemoveProduct') {
                                                    endDate = toDate(amendment.get('EffectiveDate'));
                                                } else {
                                                    endDate = toDate(subscriptionObject.get('SubscriptionEndDate'));
                                                }
                                            } else {
                                                endDate = chargeNumbersWithNoEffectiveEndDate.contains(ratePlanCharge.get('ChargeNumber')) ? null : currentLatestRatePlanChargeEffectiveEndDate;
                                            }

                                            // Determine if Metroclient Account Product Geography record exists
                                            MetroclientAccountProductGeographyKey metroclientAccountProductGeographyKeyToLookup =
                                                    new MetroclientAccountProductGeographyKey(ratePlanCharge.get('ChargeNumber'),
                                                            toId(ratePlanCharge.get('Record_Id__c')),
                                                            zuoraAccountLookupMap.get(subscriptionObject.get('AccountId')).get('CrmId'),
                                                            subscriptionObject.get('Name'));
                                            System.debug('**** MAPG KEY TO LOOKUP: ' + metroclientAccountProductGeographyKeyToLookup);
                                            if (provisionedMetroclientAccountProductGeographiesMap.containsKey(
                                                    metroclientAccountProductGeographyKeyToLookup)) {

                                                MetroclientAccountProductGeography__c provisionedMetroclientAccountProductGeographyRecord =
                                                        provisionedMetroclientAccountProductGeographiesMap.get(
                                                                metroclientAccountProductGeographyKeyToLookup);

                                                if (!provisionedMetroclientAccountProductGeographyRecord.Override__c) {

                                                    if (provisionedMetroclientAccountProductGeographyRecord.Id != null) {

                                                        // Metroclient Account Product Geography record exists; Update it
                                                        MetroclientAccountProductGeography__c metroclientAccountProductGeographyToUpdate =
                                                                ACCOUNT_PRODUCT_GEOGRAPHIES_TO_UPDATE_MAP.get(
                                                                        provisionedMetroclientAccountProductGeographyRecord.Id);
                                                        if (metroclientAccountProductGeographyToUpdate == null) {
                                                            metroclientAccountProductGeographyToUpdate =
                                                                    new MetroclientAccountProductGeography__c(
                                                                            Id = provisionedMetroclientAccountProductGeographyRecord.Id);
                                                            ACCOUNT_PRODUCT_GEOGRAPHIES_TO_UPDATE_MAP.put(
                                                                    provisionedMetroclientAccountProductGeographyRecord.Id,
                                                                    metroclientAccountProductGeographyToUpdate);
                                                        }
                                                        metroclientAccountProductGeographyToUpdate.StartDate__c = startDate;
                                                        metroclientAccountProductGeographyToUpdate.EndDate__c = endDate;

                                                        System.debug('**** UPDATING EXISTING MAPG: ' + metroclientAccountProductGeographyToUpdate);

                                                    } else {

                                                        /* Metroclient Account Product Geography record has not been
                                                         * committed yet. Update the fields on the current object.
                                                         */
                                                        provisionedMetroclientAccountProductGeographyRecord.StartDate__c = startDate;
                                                        provisionedMetroclientAccountProductGeographyRecord.EndDate__c = endDate;

                                                        System.debug('**** UPDATING NON-EXISTING MAPG: ' + provisionedMetroclientAccountProductGeographyRecord);
                                                    }

                                                }

                                            } else {

                                                // Metroclient Account Product Geography record does not exist; Insert it
                                                MetroclientAccountProductGeography__c metroclientAccountProductGeographyRecordToInsert =
                                                        new MetroclientAccountProductGeography__c(
                                                                Name = String.format('{0} | {1}', new String[]{
                                                                        subscriptionObject.get('Name'), ratePlanCharge.get('ChargeNumber')
                                                                }),
                                                                Account__c = zuoraAccountLookupMap.get(subscriptionObject.get('AccountId')).get('CrmId'),
                                                                StartDate__c = startDate,
                                                                EndDate__c = endDate,
                                                                MetroclientProductGeography__c = toId(ratePlanCharge.get('Record_Id__c')),
                                                                ChargeNumber__c = ratePlanCharge.get('ChargeNumber'),
                                                                SubscriptionName__c = subscriptionObject.get('Name'));

                                                ACCOUNT_PRODUCT_GEOGRAPHIES_TO_INSERT.add(metroclientAccountProductGeographyRecordToInsert);

                                                System.debug('**** MAPG RECORD DOES NOT EXIST, INSERTING: ' + metroclientAccountProductGeographyRecordToInsert);

                                                /* The new records also need to be added to the map so that they are not
                                                 * duplicated later.
                                                 */
                                                provisionedMetroclientAccountProductGeographiesMap.put(new MetroclientAccountProductGeographyKey(
                                                        metroclientAccountProductGeographyRecordToInsert.ChargeNumber__c,
                                                        metroclientAccountProductGeographyRecordToInsert.MetroclientProductGeography__c,
                                                        metroclientAccountProductGeographyRecordToInsert.Account__c,
                                                        metroclientAccountProductGeographyRecordToInsert.SubscriptionName__c),
                                                        metroclientAccountProductGeographyRecordToInsert);
                                                provisionedRatePlanChargeKeysToMetroclientAccountProductGeographiesMap.put(new ChargeNumberMetroclientProductGeographyKey(
                                                        metroclientAccountProductGeographyRecordToInsert.ChargeNumber__c,
                                                        metroclientAccountProductGeographyRecordToInsert.MetroclientProductGeography__c),
                                                        metroclientAccountProductGeographyRecordToInsert);
                                            }

                                        }
                                    }
                                }

                            }

                        }
                    }
                }
            }

            System.debug('**** VISITED RPC KEYS: ' + visitedRatePlanChargeKeys);

            // Determine Metroclient Account Product Geography record to mark as deleted.
            Set<ChargeNumberMetroclientProductGeographyKey> markAsDeletedRatePlanChargeKeys =
                    provisionedRatePlanChargeKeysToMetroclientAccountProductGeographiesMap.keySet().clone();
            System.debug('**** BEFORE DELETING RPC KEYS: ' + markAsDeletedRatePlanChargeKeys);
            markAsDeletedRatePlanChargeKeys.removeAll(visitedRatePlanChargeKeys);
            if (!markAsDeletedRatePlanChargeKeys.isEmpty()) {
                System.debug('**** AFTER DELETING RPC KEYS: ' + markAsDeletedRatePlanChargeKeys);
                for (ChargeNumberMetroclientProductGeographyKey markAsDeletedRatePlanChargeKey : markAsDeletedRatePlanChargeKeys) {

                    MetroclientAccountProductGeography__c provisionedMetroclientAccountProductGeographyRecord =
                            provisionedRatePlanChargeKeysToMetroclientAccountProductGeographiesMap.get(markAsDeletedRatePlanChargeKey);

                    // Metroclient Account Product Geography record should be marked as deleted
                    MetroclientAccountProductGeography__c metroclientAccountProductGeographyToUpdate =
                            ACCOUNT_PRODUCT_GEOGRAPHIES_TO_UPDATE_MAP.get(
                                    provisionedMetroclientAccountProductGeographyRecord.Id);
                    if (metroclientAccountProductGeographyToUpdate == null && provisionedMetroclientAccountProductGeographyRecord.Id != null) {
                        metroclientAccountProductGeographyToUpdate =
                                new MetroclientAccountProductGeography__c(
                                        Id = provisionedMetroclientAccountProductGeographyRecord.Id);
                        ACCOUNT_PRODUCT_GEOGRAPHIES_TO_UPDATE_MAP.put(
                                provisionedMetroclientAccountProductGeographyRecord.Id,
                                metroclientAccountProductGeographyToUpdate);
                    }
                    if (metroclientAccountProductGeographyToUpdate != null) {
                        metroclientAccountProductGeographyToUpdate.Deleted__c = true;
                    }

                }
            }
            System.debug('**** DONE DELETING RPC KEYS');

        } finally {
            ZUORA_CLIENT_TRANSACTION_NOTES.addAll(client.TRANSACTION_NOTES);
            client.TRANSACTION_NOTES.clear();
        }

    }

    public static void clearProvisioningRecordsToCommit() {
        ACCOUNT_PRODUCT_GEOGRAPHIES_TO_INSERT.clear();
        ACCOUNT_PRODUCT_GEOGRAPHIES_TO_UPDATE_MAP.clear();
        ZUORA_CLIENT_TRANSACTION_NOTES.clear();
    }

    public static void commitProvisioningRecords() {
        Note[] notesToInsert = new List<Note>();
        Map<Id, Note[]> opportunityIdToNotesMap = new Map<Id, Note[]>();
        for (Note zuoraClientTransactionNote : ZUORA_CLIENT_TRANSACTION_NOTES) {
            if (zuoraClientTransactionNote.ParentId != null && zuoraClientTransactionNote.ParentId.getSobjectType() == Schema.Opportunity.SObjectType) {
                Note[] opportunityZuoraTransactionNotes = opportunityIdToNotesMap.get(zuoraClientTransactionNote.ParentId);
                if (opportunityZuoraTransactionNotes == null) {
                    opportunityZuoraTransactionNotes = new List<Note>();
                    opportunityIdToNotesMap.put(zuoraClientTransactionNote.ParentId, opportunityZuoraTransactionNotes);
                }
                opportunityZuoraTransactionNotes.add(zuoraClientTransactionNote);
            } else {
                notesToInsert.add(zuoraClientTransactionNote);
            }
        }

        System.debug('*** BEFORE INSERT MAP: ' + opportunityIdToNotesMap);
        Map<Id, FC_Opportunity_Zuora_Transaction__c> opportunityIdToOpportunityZuoraTransactionMap = new Map<Id, FC_Opportunity_Zuora_Transaction__c>();
        if (!opportunityIdToNotesMap.isEmpty()) {
            for (Id opportunityId : opportunityIdToNotesMap.keySet()) {
                opportunityIdToOpportunityZuoraTransactionMap.put(opportunityId, new FC_Opportunity_Zuora_Transaction__c(Opportunity__c = opportunityId));
            }
            insert opportunityIdToOpportunityZuoraTransactionMap.values();
        }

        System.debug('*** AFTER INSERT MAP: ' + opportunityIdToNotesMap);
        for (Id opportunityId : opportunityIdToNotesMap.keySet()) {
            Note[] opportunityZuoraTransactionNotes = opportunityIdToNotesMap.get(opportunityId);
            for (Note opportunityZuoraTransactionNote : opportunityZuoraTransactionNotes) {
                opportunityZuoraTransactionNote.ParentId = opportunityIdToOpportunityZuoraTransactionMap.get(opportunityId).Id;
            }
            notesToInsert.addAll(opportunityZuoraTransactionNotes);
        }

        if (!notesToInsert.isEmpty()) {
            insert notesToInsert;
        }
        if (!ACCOUNT_PRODUCT_GEOGRAPHIES_TO_INSERT.isEmpty()) {
            Integer counter = 0;
            for (MetroclientAccountProductGeography__c record : ACCOUNT_PRODUCT_GEOGRAPHIES_TO_INSERT) {
                System.debug('*** INSERTING MAPG ' + (++counter) + ': ' + record);
            }
            insert ACCOUNT_PRODUCT_GEOGRAPHIES_TO_INSERT;
        }
        if (!ACCOUNT_PRODUCT_GEOGRAPHIES_TO_UPDATE_MAP.isEmpty()) {
            MetroclientAccountProductGeography__c[] recordsToUpdate = ACCOUNT_PRODUCT_GEOGRAPHIES_TO_UPDATE_MAP.values();
            Integer counter = 0;
            for (MetroclientAccountProductGeography__c record : recordsToUpdate) {
                System.debug('*** UPDATING MAPG ' + (++counter) + ': ' + record);
            }
            update recordsToUpdate;
        }
        clearProvisioningRecordsToCommit();
    }

    public static MetroclientAccountProductGeography__c[] getProvisioningRecordsToInsert() {
        return ACCOUNT_PRODUCT_GEOGRAPHIES_TO_INSERT.clone();
    }

    public static MetroclientAccountProductGeography__c[] getProvisioningRecordsToUpdate() {
        return ACCOUNT_PRODUCT_GEOGRAPHIES_TO_UPDATE_MAP.values().clone();
    }

    private static Id toId(String idString) {
        Id result = null;
        try {
            if (String.isNotBlank(idString)) {
                result = Id.valueOf(idString);
            }
        } catch (Exception e) {
        }
        return result;
    }

    private static Date toDate(String dateString) {
        Date result = null;
        if (String.isNotBlank(dateString)) {
            result = Date.valueOf(dateString);
        }
        return result;
    }

    private static Boolean toBoolean(String booleanString) {
        Boolean result = false;
        if (String.isNotBlank(booleanString)) {
            result = booleanString.equalsIgnoreCase('true');
        }
        return result;
    }

    private static Integer toInteger(String integerString) {
        Integer result = null;
        if (String.isNotBlank(integerString)) {
            result = Integer.valueOf(integerString);
        }
        return result;
    }

    private static List<List<String>> splitStringList(List<String> listToSplit, Integer maxItemsPerList) {
        List<List<String>> result = new List<List<String>>();
        Integer listToSplitSize = listToSplit.size();
        for (Integer i = 0; i < (listToSplitSize / maxItemsPerList) + 1; i++) {
            List<String> sublist = new List<String>();
            for (Integer j = (i * maxItemsPerList); (j < (i * maxItemsPerList) + maxItemsPerList) && j < listToSplitSize; j++) {
                sublist.add(listToSplit[j]);
            }
            result.add(sublist);
        }
        return result;
    }

    private static List<List<Id>> splitIdList(List<Id> listToSplit, Integer maxItemsPerList) {
        List<List<Id>> result = new List<List<Id>>();
        Integer listToSplitSize = listToSplit.size();
        for (Integer i = 0; i < (listToSplitSize / maxItemsPerList) + 1; i++) {
            List<Id> sublist = new List<Id>();
            for (Integer j = (i * maxItemsPerList); (j < (i * maxItemsPerList) + maxItemsPerList) && j < listToSplitSize; j++) {
                sublist.add(listToSplit[j]);
            }
            result.add(sublist);
        }
        return result;
    }

    private virtual class ChargeNumberMetroclientProductGeographyKey {

        public String chargeNumber;
        public Id metroclientProductGeographyId;

        public ChargeNumberMetroclientProductGeographyKey(String chargeNumber, Id metroclientProductGeographyId) {
            this.chargeNumber = chargeNumber;
            this.metroclientProductGeographyId = metroclientProductGeographyId;
        }

        public virtual Boolean equals(Object otherObject) {
            if (otherObject instanceof ChargeNumberMetroclientProductGeographyKey) {
                ChargeNumberMetroclientProductGeographyKey other = (ChargeNumberMetroclientProductGeographyKey) otherObject;
                return (this === other) || (other != null && this.chargeNumber == other.chargeNumber &&
                        this.metroclientProductGeographyId == other.metroclientProductGeographyId);
            }
            return false;
        }

        public virtual Integer hashCode() {
            final Integer PRIME = 31;
            Integer result = 1;
            result = PRIME * result + (chargeNumber == null ? 0 : chargeNumber.hashCode());
            result = PRIME * result + (metroclientProductGeographyId == null ? 0 :
                    String.valueOf(metroclientProductGeographyId).hashCode());
            return result;
        }

    }

    private class MetroclientAccountProductGeographyKey extends ChargeNumberMetroclientProductGeographyKey {

        public Id accountId;
        public String subscriptionNumber;

        public MetroclientAccountProductGeographyKey(String chargeNumber, Id metroclientProductGeographyId,
                Id accountId, String subscriptionNumber) {
            super(chargeNumber, metroclientProductGeographyId);
            this.accountId = accountId;
            this.subscriptionNumber = subscriptionNumber;
        }

        public override Boolean equals(Object otherObject) {
            if (otherObject instanceof MetroclientAccountProductGeographyKey) {
                MetroclientAccountProductGeographyKey other = (MetroclientAccountProductGeographyKey) otherObject;
                return (this === other) || (other != null &&
                        super.equals((ChargeNumberMetroclientProductGeographyKey) other) &&
                        this.accountId == other.accountId && this.subscriptionNumber == other.subscriptionNumber);
            }
            return false;
        }

        public override Integer hashCode() {
            final Integer PRIME = 31;
            Integer result = 1;
            result = PRIME * result + super.hashCode();
            result = PRIME * result + (accountId == null ? 0 : String.valueOf(accountId).hashCode());
            result = PRIME * result + (subscriptionNumber == null ? 0 : subscriptionNumber.hashCode());
            return result;
        }

    }

}