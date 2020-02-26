global class BatchDeleteSubscriberActivity implements Database.Batchable<sObject> {
    
    String query;
    
    global BatchDeleteSubscriberActivity() {
        query = 'SELECT Id FROM MC4SF__MC_Subscriber_Activity__c WHERE MC4SF__Action__c != \'bounce\'';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<MC4SF__MC_Subscriber_Activity__c> scope) {
        delete scope;
    }
    
    global void finish(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(new String[] {'nteyssier@meyersllc.com'});
        mail.setReplyTo('nteyssier@meyersllc.com');
        mail.setSenderDisplayName('Meyers Batch Processing');
        mail.setSubject('Batch Process Completed :: Nightly Subscriber Activity Deletion');
        mail.setPlainTextBody('This process runs regularly to remove MailChimp Subscriber Activity records that are not bounces. There is not currently a way to remove these from the sync that MailChimp provides and they consume a great deal of storage usage in Salesforce.');
        try {
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch (EmailException e){
            if(!e.getMessage().contains('NO_MASS_MAIL_PERMISSION')){
                throw e;
            }
        }
    }
    
}