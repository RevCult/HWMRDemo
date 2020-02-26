public class MetroclientContactProvisioningByAccount{

    private final Account acct;
    
    // The extension constructor initializes the private member variable acct by using the getRecord method from the standard controller.
    public MetroclientContactProvisioningByAccount(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
    }
    
    public Boolean getRenderIframe() {
        Boolean metrostudyUserExists = getMetrostudyUserExists();
        Boolean invalidHierarchyDepth = getInvalidHierarchyDepth();
        Boolean validProductsExist = getValidProductsExist();
        
        return (metrostudyUserExists && !invalidHierarchyDepth && validProductsExist);
    }

    public Boolean getMetrostudyUserExists() {
        Boolean metrostudyUserExists = false;
        
        Account account = [SELECT Id, (SELECT Metrostudy_User__c FROM Contacts) FROM Account WHERE Id = :acct.Id];
        
        // Loop through all the contacts for the account
        for (Contact contact : account.Contacts)
        {
            if (contact.Metrostudy_User__c) {
                metrostudyUserExists = true;
                break;
            }
        }   
        return metrostudyUserExists;
    }
    
    public Boolean getInvalidHierarchyDepth() {
        return (acct.UltimateParentAccountId__c == 'MAXIMUM_ALLOWABLE_HIERARCHY_DEPTH_EXCEEDED');
    }     
    
    public Boolean getValidProductsExist() {        
        Map<Id,Account> accounts = new Map<Id,Account>([SELECT Id FROM Account WHERE UltimateParentAccountId__c = :acct.UltimateParentAccountId__c]);
        Set<Id> accountIdSet = accounts.keySet();
        
        List<MetroclientAccountProductGeography__c> accountProductGeographyList = [SELECT Id FROM MetroclientAccountProductGeography__c WHERE Account__r.Id IN :accountIdSet AND Deleted__c = false AND (EndDate__c = NULL OR EndDate__c > :system.now().date())];     //
                
        return (accountProductGeographyList.size() > 0) ;
    }    
}