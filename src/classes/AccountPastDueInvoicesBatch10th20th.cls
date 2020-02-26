global class AccountPastDueInvoicesBatch10th20th implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'select id,Invoices_Sent_on_20th__c,Invoices_Sent_on_10th__c,Max_Days_Open__c from Account where Max_Days_Open__c > 44 AND Summary_of_Invoices_Balance__c > 0 AND Hold_Past_Due_Emails__c = NULL';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        list<account> acclist = [select id,Invoices_Sent_on_10th__c,Invoices_Sent_on_20th__c,Max_Days_Open__c,(select id,blng__Account__c from blng__AccountInvoices__r where blng__InvoiceStatus__c IN ('Posted','Rebilled') AND blng__Balance__c > 10) from Account where Max_Days_Open__c > 44 AND Summary_of_Invoices_Balance__c > 0 AND Hold_Past_Due_Emails__c = NULL AND ID IN:scope];
        for(Account acc : acclist){
            //if(acc.blng__AccountInvoices__r.size() >0 && acc.Invoices_Sent_on_20th__c == False){
            //    acc.Invoices_Sent_on_10th__c = true;
            //}
            //else 
                if(acc.blng__AccountInvoices__r.size() >0 && acc.Invoices_Sent_on_10th__c == False){
                acc.Invoices_Sent_on_20th__c = true;
            } 
        }
        if(acclist.size()>0)
            update acclist;
    }
    
    global void finish(Database.BatchableContext BC){
    }
}