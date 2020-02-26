/****************************************************************************************************
*Description:           This is the test class for the CampaignBatchRenameUpdate and CampaignBatchRenameRevertUpdate
*						batch classes
*
*Required Class(es):   N/A
*
*Organization: Rainmaker-LLC
*
*Revision   |Date       |Author             |AdditionalNotes
*====================================================================================================
*   1.0     10/26/2015   Justin Padilla     Initial Implementation - S-01574
*****************************************************************************************************/
public class CampaignBatchRename_TEST
{

    static testMethod void CampaignBatchRenameUpdate_TEST()
	{
        //Create a Campaign to be updated
        Campaign c = new Campaign(Name = 'Test Campagin');
        insert(c);
        
        CampaignBatchRenameUpdate b = new CampaignBatchRenameUpdate();
        b.startDate = DateTime.now().addDays(-1);
        b.endDate = DateTime.now();
        
        Test.startTest();
        database.executeBatch(b);
        Test.stopTest();
    }
    
    static testMethod void CampaignBatchRenameRevertUpdate_TEST()
    {
    	//Create a Campaign to be updated with replacement string included
        Campaign c = new Campaign(Name = 'Test Campagin[JGP]');
        insert(c);
        
        CampaignBatchRenameRevertUpdate b = new CampaignBatchRenameRevertUpdate();
        b.startDate = DateTime.now().addDays(-1);
        b.endDate = DateTime.now();
        
        Test.startTest();
        database.executeBatch(b);
        Test.stopTest();
    }
}