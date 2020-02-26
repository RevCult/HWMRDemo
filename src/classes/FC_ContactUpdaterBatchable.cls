public class FC_ContactUpdaterBatchable implements Database.Batchable<SObject>, Database.Stateful {
    
    Contact[] contactsToQuery;
    Contact[] contacts;
    Map<Id, Contact> contactMap;
    Map<Id, MetroclientContactProductGeography__c[]> contactToGeos;
    Map<Id, Contact> contactsToUpdate;
    Contact[] erroredContacts;
    private final Integer PROD_GEOS = 0;
    private final Integer IS_TRUNCATED =1 ;
    
    private Map<ID, Set<Zuora__Subscription__c>> accountIdToSubscriptionsMap = new Map<ID, Set<Zuora__Subscription__c>>();

    public FC_ContactUpdaterBatchable() {
        erroredContacts = new List<Contact>();
    }
    
    public FC_ContactUpdaterBatchable(Contact[] contactsToQuery) {
        this();
        this.contactsToQuery = contactsToQuery;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        if (contactsToQuery != null) {
            return Database.getQueryLocator([select AccountId, Account_Has_Active_Subscription__c, Customer_Status__c, Is_Prod_Geos_Truncated__c, Product_Geographies__c from Contact where Id in :contactsToQuery]);
        }
        return Database.getQueryLocator([select AccountId, Account_Has_Active_Subscription__c, Customer_Status__c, Is_Prod_Geos_Truncated__c, Product_Geographies__c from Contact]);

    }
    
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        contacts = (Contact[]) scope;
        
        bulkBefore();

        contactsToUpdate = new Map<Id, Contact>();
        
        for (Contact cntct : contacts) {
            updateCustomerStatus(cntct);
            updateProductGeographies(cntct);
        }
        
        Database.SaveResult[] results = Database.update(contactsToUpdate.values(), false);
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                erroredContacts.add(contactMap.get(result.getId()));
            }
        }
        
    }
    
    private void bulkBefore() {
        
        contactMap = new Map<Id, Contact>(contacts);
        contactToGeos = new Map<Id, MetroclientContactProductGeography__c[]>();

        Set<ID> accountIds = new Set<ID>();
        for (Contact contactRecord : contacts) {
            if (contactRecord.accountId != null) {
                accountIds.add(contactRecord.AccountId);
            }
        }
        accountIdToSubscriptionsMap = FC_SubscriptionCache.findByAccountIds(accountIds);

        for (MetroclientContactProductGeography__c prodGeo :
                [select Contact__c, Status__c, MetroclientProductGeography__c, 
                    MetroclientProductGeography__r.Name from MetroclientContactProductGeography__c where Contact__c in :contacts]) {

            MetroclientContactProductGeography__c[] geos = contactToGeos.get(prodGeo.Contact__c);
            if (geos == null) {
                contactToGeos.put(prodGeo.Contact__c, new List<MetroclientContactProductGeography__c>{ prodGeo });
            } else {
                geos.add(prodGeo);
            }
        }
    }
    
    private void updateCustomerStatus(Contact cntct) {
        MetroclientContactProductGeography__c[] prodGeos = contactToGeos.get(cntct.Id);
        if (prodGeos == null || prodGeos.size() == 0) {
            if (cntct.Account_Has_Active_Subscription__c) {
                addIfFieldUpdate(cntct, 'Customer_Status__c', 'Current');
            } else if (accountIdToSubscriptionsMap.containsKey(cntct.AccountId) && 
                    accountIdToSubscriptionsMap.get(cntct.AccountId).size() > 0) {
                addIfFieldUpdate(cntct, 'Customer_Status__c', 'Past');
            } else {
                addIfFieldUpdate(cntct, 'Customer_Status__c', '');
            }
        } else {
            if (containsGeosWithStatus(prodGeos, 'On Hold')) {
                addIfFieldUpdate(cntct, 'Customer_Status__c', 'On Hold');
            } else if (containsGeosWithStatus(prodGeos, 'Future')) {
                addIfFieldUpdate(cntct, 'Customer_Status__c', 'Future');
            } else if (containsGeosWithStatus(prodGeos, 'Active')) {
                addIfFieldUpdate(cntct, 'Customer_Status__c', 'Current');
            } else if (containsGeosWithStatus(prodGeos, 'Expired')) {
                addIfFieldUpdate(cntct, 'Customer_Status__c', 'Past');
            }
        }
    }
    
    private void updateProductGeographies(Contact cntct) {
        MetroclientContactProductGeography__c[] prodGeos = contactToGeos.get(cntct.Id);
        if (prodGeos == null || prodGeos.size() == 0) {
            addIfFieldUpdate(cntct, 'Product_Geographies__c', '');
            addIfFieldUpdate(cntct, 'Is_Prod_Geos_Truncated__c', false);
        } else {
            Object[] results = getConcatenatedGeos(prodGeos);
            addIfFieldUpdate(cntct, 'Product_Geographies__c', (String) results[PROD_GEOS]);
            addIfFieldUpdate(cntct, 'Is_Prod_Geos_Truncated__c', (Boolean) results[IS_TRUNCATED]);
        }
    }
    
    /**
     * Returns a string array.  
     * First cell contains the concatenated geos.
     * Second cell contains whether the concatenation was truncated or not.
     */
    private Object[] getConcatenatedGeos(MetroclientContactProductGeography__c[] prodGeos) {
        Set<String> activeGeos = new Set<String>();
        Integer totalLength = 0;
        Boolean geosTruncated = false;
        for (MetroclientContactProductGeography__c geo : prodGeos) {
            system.debug(logginglevel.error, geo.MetroclientProductGeography__r.Name);
            if (geo.Status__c == 'Active' && geo.MetroclientProductGeography__c != null) {
                String[] geoParts = geo.MetroclientProductGeography__r.Name.split('\\|');
                for (Integer i = 0; i < geoParts.size(); i++) {
                    geoParts[i] = geoParts[i].trim();
                }
                String trimmedGeo = String.join(geoParts, '|');
                // For the first iteration, you don't add the tilde to the length of the string
                totalLength += (trimmedGeo.length() + (totalLength == 0 ? 0 : 1));
                if (totalLength <= 4000) {
                    activeGeos.add(trimmedGeo);
                } else {
                    geosTruncated = true;
                    break;
                }

            }
        }
        String concatenated = String.join(new List<String>(activeGeos), '~');
        System.debug(Logginglevel.error, 'geos concatenated size: ' + concatenated.length());
        return new List<Object>{concatenated, geosTruncated};
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug(LoggingLevel.ERROR, 'List of errored contacts: \n');
        for (Contact cntct : erroredContacts) {
            System.debug(LoggingLevel.ERROR, cntct);
        }
    }
    
    private Boolean containsGeosWithStatus(MetroclientContactProductGeography__c[] prodGeos, String geoStatus) {
        for (MetroclientContactProductGeography__c prodGeo : prodGeos) {
            if (prodGeo.Status__c == geoStatus) {
                return true;
            }
        }
        return false;
    }
    
    private void addIfFieldUpdate(Contact cntct, String fieldName, Object newValue) {
        if (newValue instanceOf String) {
            if (newValue == null || newValue == '') {
                if (String.isNotBlank((String) cntct.get(fieldName))) {
                    getContactToUpdate(cntct.Id).put(fieldName, '');
                }
            } else {
                if ((String) cntct.get(fieldName) != newValue) {
                    getContactToUpdate(cntct.Id).put(fieldName, newValue);
                }
            }
        } else if (newValue instanceOf Boolean) {
            if ((Boolean) cntct.get(fieldName) != newValue) {
                getContactToUpdate(cntct.Id).put(fieldName, newValue);
            }
        }
    }
    
    private Contact getContactToUpdate(Id contactId) {
        Contact cntctToUpdate = contactsToUpdate.get(contactId);
        if (cntctToUpdate == null) {
            cntctToUpdate = new Contact(Id = contactId);
            contactsToUpdate.put(cntctToUpdate.Id, cntctToUpdate);
        }
        return cntctToUpdate;
    }
}