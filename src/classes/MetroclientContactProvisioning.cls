public class MetroclientContactProvisioning{

    private final Contact contact;
    
    // The extension constructor initializes the private member variable acct by using the getRecord method from the standard controller.
    public MetroclientContactProvisioning(ApexPages.StandardController stdController) {       
        this.contact= (Contact)stdController.getRecord();
    }
    
    public Boolean getRenderIframe() {
        Boolean metrostudyUserExists = getMetrostudyUserExists();
        Boolean invalidHierarchyDepth = getInvalidHierarchyDepth();
        Boolean validProductsExist = getValidProductsExist();
        
        return (metrostudyUserExists && !invalidHierarchyDepth && validProductsExist);
    }

    public Boolean getMetrostudyUserExists() {  
        Contact c = [SELECT Metrostudy_User__c FROM Contact WHERE Id = :contact.Id];
        return (c.Metrostudy_User__c == true);
    }
    
    public Boolean getInvalidHierarchyDepth() {       
        return (this.contact.Account.UltimateParentAccountId__c == 'MAXIMUM_ALLOWABLE_HIERARCHY_DEPTH_EXCEEDED');
    }     
    
    public Boolean getValidProductsExist() {        
        Map<Id,Account> accounts = new Map<Id,Account>([SELECT Id FROM Account WHERE UltimateParentAccountId__c = :contact.Account.UltimateParentAccountId__c]);
        Set<Id> accountIdSet = accounts.keySet();
        
        List<MetroclientAccountProductGeography__c> accountProductGeographyList = [SELECT Id FROM MetroclientAccountProductGeography__c WHERE Account__r.Id IN :accountIdSet AND Deleted__c = false AND (EndDate__c = NULL OR EndDate__c > :system.now().date())];      //
                
        return (accountProductGeographyList.size() > 0) ;
    }    
}