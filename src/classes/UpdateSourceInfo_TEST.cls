/****************************************************************************************************
*Description:           This is the test class for the following:
*						CampaignMemberUpdateSourceInfo [Class]
*						CampaignUpdateSourceInfo [Trigger]
*						UpdateSourceInfo [Class]
*
*Required Class(es):   N/A
*
*Organization: Rainmaker-LLC
*
*Revision   |Date       |Author             |AdditionalNotes
*====================================================================================================
*   1.0     09/24/2015   Justin Padilla     Initial Implementation - S-01574
*****************************************************************************************************/
@isTest
private class UpdateSourceInfo_TEST
{
    static testMethod void TriggerTests()
	{
        //Create a Lead
        Lead l = new Lead(FirstName='Rainmaker', LastName='Test', Company='Rainmaker');
        insert(l);
        //Create an Account and Contact
        Account a = new Account(Name='Rainmaker', BillingPostalCode = '12345');
        insert(a);
        Contact c = new Contact(FirstName='Rainmaker', LastName='Test', AccountId=a.Id);
        insert(c);
        //Create Campaigns
        Campaign camp1 = new Campaign(Name='TEST #1');
        insert(camp1);
        Campaign camp2 = new Campaign(Name='TEST #2');
        insert(camp2);
        //Create the Campaign Members
        List<CampaignMember> members = new List<CampaignMember>();
        CampaignMember cm1 = new CampaignMember(Status='Sent',LeadId = l.Id,CampaignId = camp1.Id); 
        members.add(cm1);
        CampaignMember cm2 = new CampaignMember(Status='Sent',ContactId = c.Id,CampaignId = camp1.Id);
        members.add(cm2);

        CampaignMember cm3 = new CampaignMember(Status='Sent',LeadId = l.Id,CampaignId = camp2.Id);
        members.add(cm3);     
        CampaignMember cm4 = new CampaignMember(Status='Sent',ContactId = c.Id,CampaignId = camp2.Id);
        members.add(cm4);

        //Insert
        insert(members);
        
        //Modify Member Status
        cm1.Status = 'Responded';
        update(cm1);
        cm2.Status = 'Responded';
        update(cm2);
        
        //Delete Members
        delete(cm1);
        delete(cm2);
        
        //Modify the Campaign Name
        camp2.Name = 'Named Changed';
        update(camp2);
        
        //Delete the Campaign
        delete(camp2);
    }
}