global class AccountInvoicesUncheck9Batch implements Database.Batchable<sObject>{
 //On the 9th Uncheck the "invoices sent on the 10th" AND IF the account is over 120 days uncheck the "invoices sent on the 20th"
 //so that the 'Invoices sent on the 10th' can be checked again
    //This needs to be fired after the 20th and before the 10th
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'select id,Invoices_Sent_on_20th__c,Invoices_Sent_on_10th__c,Max_Days_Open__c from Account where Invoices_Sent_on_10th__c=true or Invoices_Sent_on_20th__c=true';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        for(Account acc : scope){
            //Uncheck the "invoices sent on the 10th"
            if(acc.Invoices_Sent_on_10th__c == true){
                acc.Invoices_Sent_on_10th__c = false;
            }
            //IF the account is over 120 days uncheck the "invoices sent on the 20th" - If the Account is 119 days open on the 9th then on the 10th it will be 120 days old.
            if(acc.Invoices_Sent_on_20th__c == true && acc.Max_Days_Open__c >= 119){
               acc.Invoices_Sent_on_20th__c = false;
            }
        }
        if(scope.size()>0)
            update scope;
    }
    global void finish(Database.BatchableContext BC){
    }
}