trigger Accounttype on Zonda_Contract__c (after insert,after update) {

      List<Account> liftOfcontracts = new List<Account>();
      set<id> listcontracts = new set<id>();
      list<Zonda_Contract__c> ContractActive = new list<Zonda_Contract__c>();
      list<Zonda_Contract__c> ContractNonActive = new list<Zonda_Contract__c>();
         for (Zonda_Contract__c zc : trigger.new){
                listcontracts.add(zc.id);
            }
            
      list<Zonda_Contract__c> Zondac = [select id,name,Contract_Status__c,Account__c from Zonda_Contract__c where id in :listcontracts];
            for(Zonda_Contract__c zoncon:Zondac){
                    if(zoncon.Contract_Status__c =='Active'){
                        ContractActive.add(zoncon);
                      }
            }   
            Account acc = new Account(); 
            try {
                 if( Zondac.size()>0 && Zondac[0].Account__c!=null){
         
                 acc = [select id,name,Type from Account where id=:Zondac[0].Account__c];
                    integer i=0;
                    i= [select COUNT() from Zonda_Contract__c where Account__c=:Zondac[0].Account__c and Contract_Status__c='active'];
                       
                    if(ContractActive.size()>0){
                      //  acc = [select id,name,Type from Account where id=:ContractActive[0].Account__c];
                        acc.Type  = 'Subscriber';
                        update acc;
                    }
                    if(ContractActive.size()==0 && i==0){
                      //  acc = [select id,name,Type from Account where id=:ContractNonActive[0].Account__c];
                        acc.Type = 'Prospect';
                        update acc;
                    }
            }
            }catch(exception e){
            
            }
}