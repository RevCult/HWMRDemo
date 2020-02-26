global class AccountInvoicesUncheck19Batch implements Database.Batchable<sObject>{
 //On the 19th Uncheck the "invoices sent on the 20th" AND IF the account is over 120 days uncheck the "invoices sent on the 10th"
 //so that the 'Invoices sent on the 20th' can be checked again
 
    //This needs to be fired after the 10th and before the 20th
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'select id,Invoices_Sent_on_20th__c,Invoices_Sent_on_10th__c,Max_Days_Open__c from Account where Invoices_Sent_on_10th__c=true or Invoices_Sent_on_20th__c=true';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        for(Account acc : scope){
            //Uncheck the "invoices sent on the 20th"
            if(acc.Invoices_Sent_on_20th__c == true){
                acc.Invoices_Sent_on_20th__c = false;
            }
            //IF the account is over 120 days uncheck the "invoices sent on the 10th"  - If the Account is 119 days open on the 19th then on the 20th it will be 120 days old.
            if(acc.Invoices_Sent_on_10th__c == true && acc.Max_Days_Open__c >= 119){
               acc.Invoices_Sent_on_10th__c = false;
            }
        }
        if(scope.size()>0)
            update scope;
    }
    global void finish(Database.BatchableContext BC){
    }
}