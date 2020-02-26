public with sharing class StategicAccount {
    
    public static void PreProcess(Account[] accounts)
    {
        List<Account> parentUpdate = new List<Account>();
        List<Account> childrenUpdate = new List<Account>();
        
        //modified code (single query)
        
        Set<Id> parentIDs = new Set<Id>();
        for(Account thisAct : accounts)
        {
            if(thisAct.ParentId != null)
            {
                parentIDs.add(thisAct.ParentId);
            }
        }
        
        List<Account> parents = [SELECT Id, Strategic_Account_Owner__c 
                                    FROM Account WHERE id in :parentIDs];

        for(Account childAcc : accounts)
        {
            for(Account parentAcc : parents)
            {
                if(childAcc.parentId == parentAcc.Id)
                {
                    childAcc.Strategic_Account_Owner__c = parentAcc.Strategic_Account_Owner__c;
                }
            }
        }
        
        //original code
        
        /*for (Account a:accounts)
        {
            //Need to determine if this account has an associated Parent Account
            if (a.ParentId != null) //process as a child account
            {
                //Get the parent account's Stategic Account
                Account parent = [SELECT
                Account.Id,
                Account.Strategic_Account_Owner__c
                FROM Account 
                WHERE Account.Id = :a.ParentId];
                //Now that we have the parent account Stategic Account Owner, update this Account with the same information
                a.Strategic_Account_Owner__c = parent.Strategic_Account_Owner__c;
            }
        }*/
    }
    public static void PostProcess(Account[] accounts)
    {
        List<Account> childrenUpdate = new List<Account>();
        
        //modified code (single query)

        Set<Id> accIds = new Set<Id>();
        for(Account acc : accounts)
        {
            accIds.add(acc.id);
        }
        List<Account> children = [SELECT parentId, Id, Strategic_Account_Owner__c 
                                        FROM Account WHERE ParentId in :accIds];
        if(children.size() > 0)
        {
            for(Account child : children)
            {
                for(Account parent : accounts)
                {
                    if(child.ParentId == parent.id)
                    {
                        child.Strategic_Account_Owner__c = parent.Strategic_Account_Owner__c;
                        childrenUpdate.add(child);
                    }
                }
            }
        }
        if (childrenUpdate.size()>0)
        {
            update(childrenUpdate);
        }
        
        //original code
        /*for (Account a:accounts)
        {
            //This could be a parent account, see if there are any childern associated
            List<Account> children = [SELECT
            Account.Id,
            Account.Strategic_Account_Owner__c
            FROM Account
            WHERE Account.ParentId = :a.id];
            if (children.size() > 0)
            {
                //Update all of the childern accounts
                for (Account c:children)
                {
                    c.Strategic_Account_Owner__c = a.Strategic_Account_Owner__c;
                    childrenUpdate.add(c);
                }
            }
        }
        if (childrenUpdate.size()>0)
        {
            update(childrenUpdate);
        }*/
    }
    public class CustomException extends Exception {}
    
    public static testMethod void testAccount()
    {
        GoogleIntegrationHelper.disableAsync = true;
        //Create an Account as a Parent
        Account parent = new Account();
        parent.Name = 'Test Parent';
        parent.Strategic_Account_Owner__c = 'Local';
        parent.Industry_Code__c = 'MISC';
        parent.Industry_Category__c = 'Other';
        parent.Industry_Description__c = 'OTHER INDUSTRY';
        parent.BillingPostalCode = '12345';
        parent.Parent__c = true;
        insert(parent);
        List<Account> test = new List<Account>();
        test.add(parent);
        PreProcess(test);
        //Now create a child Account
        Account child = new Account();
        child.Name = 'Test Child';
        child.BillingPostalCode = '12345';
        child.Strategic_Account_Owner__c = 'Local';
        child.Industry_Code__c = 'MISC';
        child.Industry_Category__c = 'Other';
        child.Industry_Description__c = 'OTHER INDUSTRY';
        child.ParentId = parent.Id;
        test.add(child);
        PreProcess(test);
        insert(child);
        //Now change the parent Stategic_Account_Owner and update (Should test child change also)
        parent.Strategic_Account_Owner__c = 'Local';
        update(parent);
        PostProcess(test);
    }
}