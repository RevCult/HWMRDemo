/******************************************************************************
*
* @description  ManageCustomerType - Updates Account Customer Type fields
* @author       10KView
* @date         2nd June 2017
* @comments     Runs in System Context
*
*  
*****************************************************************************/
public class ManageCustomerType {

    // Customer Type Constants
    public static String STR_NON_CUSTOMER = 'Non-customer';
    public static String STR_CURRENT_CUSTOMER = 'Current customer';
    public static String STR_PAST_CUSTOMER = 'Past customer';


    /************************************************************************
    *
    * @description  ManageCustomerType - Updates Account Customer Type fields
    * @params       List of Accounts
    * @returns      void
    *
    *************************************************************************/
    public static void UpdateCustomerType(List<Account> scope) {


        Map<Id, Account> acctMap = new Map<Id, Account>(); // Everything else update map
        Map<Id, Account> acctMap_Media = new Map<Id, Account>(); // Media Update Map
        Map<Id, Account> acctMap_Marketing = new Map<Id, Account>(); // Marketing update map
        
        // #1 Accounts with no Opportunities (Non-customer)
        for (Account a: [SELECT Id, Name, Marketing_Customer_Type__c, 
                                Media_Customer_Type__c FROM Account 
                           WHERE Id in: scope AND
                           Id NOT IN (SELECT AccountId from Opportunity)]){

                acctMap.put( a.Id, 
                new Account ( Id = a.Id, Marketing_Customer_Type__c = STR_NON_CUSTOMER, 
                                        Media_Customer_Type__c = STR_NON_CUSTOMER));
                
        }

        // Accounts with Opportunities (Won=True) & HW_Line_Item_End_Date__c <= TODAY (Past current)
        for (OpportunityLineItem o : [
                    SELECT
                    Id,
                    Opportunity.AccountId,
                    Opportunity.Account.Marketing_Customer_Type__c,
                    Opportunity.Account.Media_Customer_Type__c,
                    Opportunity.CloseDate,
                    Opportunity.IsWon,
                    Marketing_Product__c,
                    MetroStudy_Product__c,
                    HW_Line_Item_End_Date__c,
                    HW_Line_Item_Start_Date__c
                    FROM OpportunityLineItem
                    WHERE Opportunity.IsWon = true 
                    And (HW_Line_Item_End_Date__c < THIS_YEAR)
                    AND     Opportunity.AccountId in: scope]) {

            
            // Marketing
            if (o.Marketing_Product__c) {
                    
                    acctMap_Marketing.put( o.Opportunity.AccountId,
                    new Account (Id = o.Opportunity.AccountId,
                    Marketing_Customer_Type__c = STR_PAST_CUSTOMER));
                
                
            }
            // Media
            else if (!o.Marketing_Product__c && !o.MetroStudy_Product__c) {

                    acctMap_Media.put( o.Opportunity.AccountId,
                    new Account (Id = o.Opportunity.AccountId, 
                    Media_Customer_Type__c = STR_PAST_CUSTOMER));
                
            }

        }

    

        // Accounts with Opportunities (Won=True) & HW_Line_Item_End_Date__c >= TODAY (Current current)
        for (OpportunityLineItem o : [
                    SELECT
                    Id,
                    Opportunity.AccountId,
                    Opportunity.Account.Marketing_Customer_Type__c,
                    Opportunity.Account.Media_Customer_Type__c,
                    Opportunity.CloseDate,
                    Opportunity.IsWon,
                    Marketing_Product__c,
                    MetroStudy_Product__c,
                    HW_Line_Item_End_Date__c,
                    HW_Line_Item_Start_Date__c
                    FROM OpportunityLineItem
                    WHERE Opportunity.IsWon = true and 
                    ( HW_Line_Item_Start_Date__c >= TODAY 
                        OR HW_Line_Item_End_Date__c > LAST_YEAR)
                    AND     Opportunity.AccountId in: scope]) {

            
            // Marketing
            if (o.Marketing_Product__c) {
                    
                    acctMap_Marketing.put( o.Opportunity.AccountId,
                    new Account (Id = o.Opportunity.AccountId,
                    Marketing_Customer_Type__c = STR_CURRENT_CUSTOMER));
            
                
            }
            // Media
            else if (!o.Marketing_Product__c && !o.MetroStudy_Product__c) {
                    
                    acctMap_Media.put( o.Opportunity.AccountId,
                    new Account (Id = o.Opportunity.AccountId, 
                    Media_Customer_Type__c = STR_CURRENT_CUSTOMER));
            

            }

        }

    

        //#4 Any Accounts which fall outside the above (Non-customer)
        /*
        for (Account a: [SELECT Id, Name, Marketing_Customer_Type__c, 
                                Media_Customer_Type__c FROM Account 
                           WHERE Id in: scope and
                           (Marketing_Customer_Type__c = null OR 
                           Media_Customer_Type__c = null)]){

                //System.debug(LoggingLevel.ERROR, '****** #4  catch all '+ a);
                if (a.Marketing_Customer_Type__c == null){
                    System.debug(LoggingLevel.ERROR, '****** Marketing Catch All *****');
                    acctMap_Marketing.put( a.Id,
                    new Account (Id = a.Id, 
                    Marketing_Customer_Type__c = STR_NON_CUSTOMER));
                }

                if (a.Media_Customer_Type__c == null){
                    System.debug(LoggingLevel.ERROR, '****** Media Catch All *****');
                    acctMap_Media.put( a.Id,
                    new Account (Id = a.Id, 
                    Media_Customer_Type__c = STR_NON_CUSTOMER));
                }

        }
        */

        
        // Update all account maps
        if (!acctMap.isEmpty()){
            try{
                update acctMap.values();    
            } catch (Exception e){
                System.debug(LoggingLevel.ERROR, '******* e *******' + e);
            }
        }

        if (!acctMap_Media.isEmpty()){
            try{
            update acctMap_Media.values();  
            } catch (Exception e){
                System.debug(LoggingLevel.ERROR, '******* e *******' + e);
            }
        }

        if (!acctMap_Marketing.isEmpty()){
            try {
                update acctMap_Marketing.values();  
                } catch (Exception e){
                    System.debug(LoggingLevel.ERROR, '******* e *******' + e);
                }
        }
        

    }
}