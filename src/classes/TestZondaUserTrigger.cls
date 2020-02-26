/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestZondaUserTrigger {

    static testMethod void myZondauser() {
        // TO DO: implement unit test
                       
        Account act = new Account();
        act.Name='xyz';
        act.Industry='BPM';
        act.Type='Prospect';
        act.BillingPostalCode='5600098';
        
        insert act;
        
        Contact con = new Contact();
        con.LastName= 'test';
        con.Email='abc@xyz.com';
        con.AccountId= act.id;
        con.Contact_Status__c='prospect';
        
        insert con;
        
        Zonda_User_Group__c zug = new Zonda_User_Group__c();
        zug.Zonda_Customer_Name__c='Test';
        
        insert zug;
        
        Zonda_User__c zu = new Zonda_User__c();
        zu.Contact__c = con.Id;
        zu.Zonda_User_Group__c =zug.Id;
        zu.status__c='Active';
        
        insert zu;
        
        zu.status__c='Disabled';
        
        update zu;
    

    }
}