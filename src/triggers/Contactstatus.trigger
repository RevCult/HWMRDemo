trigger Contactstatus on Zonda_User__c (after insert, after update) {
    List<Contact> liftOfusers = new List<Contact>();
    set<id> listZonda = new set<id>();
    List<Zonda_User__c> liftOfZonda = trigger.new;
    for(Zonda_User__c zu : liftOfZonda){
        listZonda.add(zu.Contact__c);
     }
    List<Contact> liftFilter = new List<Contact>();     
    List<Contact> liftFilterNactive = new List<Contact>();  
    liftOfusers = [select id,name,Contact_Status__c from contact where id IN :listZonda];
        integer i=0;
        for(Contact con:liftOfusers){
                i=[select count() from Zonda_User__c where status__c='Active' and Contact__c=:con.id];
                if(i!=0){
                    con.Contact_Status__c='User';
                    liftFilter.add(con);
                }else{
                    con.Contact_Status__c='Prospect';
                    liftFilterNactive.add(con);
                }
            }
        update liftFilter;
        update liftFilterNactive;
    }