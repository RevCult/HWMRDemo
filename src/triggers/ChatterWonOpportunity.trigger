trigger ChatterWonOpportunity on Opportunity (after insert, after update) {

String status;
String OppAccName;
String OppOwnerName;

FeedItem post = new FeedItem();
    
    for(Opportunity o : Trigger.new) {
        if(o.OwnerId == '00580000004SwOg') { //It will not post record for for this user to group.
            return;
        }
        else {
            if(Trigger.isInsert ) { 
                if( o.Amount >= 1000.00 && o.IsWon == true ) { //This will be executed on new record insertion with amount >= 1,000.00
                    for (Opportunity oppty : [SELECT Account.Name, Owner.Name FROM Opportunity WHERE Id =:o.Id] ) {
                        OppAccName = oppty.Account.Name;
                        OppOwnerName = oppty.Owner.Name;
                     }    
                    status = OppOwnerName + ' just closed ' + OppAccName + ' for ' + ' !';

                    post.ParentId = '0F9Q0000000CjHx';
                    post.Title = o.Name;
                    post.Body = status;
                    
                    insert post;
                }
            }    
            else {
                if ( Trigger.isUpdate ) {
                    if( o.Amount >= 1000.00 && o.IsWon == true && Trigger.oldMap.get(o.id).IsWon == false) { //This will be executed on update to existing record with amount >= 1,000.00
                        for (Opportunity oppty : [SELECT Account.Name, Owner.Name FROM Opportunity WHERE Id =:o.Id] ) {
                            OppAccName = oppty.Account.Name;
                            OppOwnerName = oppty.Owner.Name;
                        }    
                        status = OppOwnerName + ' just won ' + OppAccName + ' for ' + o.Amount + '!';
                            
                        post.ParentId = '0F9Q0000000CjHx';
                        post.Title = o.Name;
                        post.Body = status;
                        
                        insert post;      
                    }
                }
            }
        }
    }    
}