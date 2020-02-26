/****************************************************************************************************
*Description:           This batch class renames the Campaigns within Range (Used to Update Campaign Member details)
*
*Required Class(es):   CampaignBatchRename_TEST
*
*Organization: Rainmaker-LLC
*
*Revision   |Date       |Author             |AdditionalNotes
*====================================================================================================
*   1.0     10/26/2015   Justin Padilla     Initial Implementation - S-01574
*****************************************************************************************************/
global class CampaignBatchRenameRevertUpdate implements Database.Batchable<sObject>
{
	global DateTime startDate;
	global DateTime endDate;
	global string query;
	
	global Database.Querylocator start(Database.BatchableContext BC)
	{
		if (startDate == null) startDate = DateTime.now().addDays(-7);
		if (endDate == null) endDate = DateTime.now();
		if (query == null) query = 'SELECT Id, Name, CreatedDate FROM Campaign WHERE CreatedDate > :startDate AND CreatedDate <=: endDate AND Name Like \'%[JGP]\' ORDER BY CreatedDate DESC';
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		List<Campaign> toUpdate = new List<Campaign>();
		for (sObject s: scope)
		{
			Campaign theCampaign = (Campaign)s;
			if (theCampaign.Name.endsWith('[JGP]'))
			{
				theCampaign.Name = theCampaign.Name.replace('[JGP]','');
				toUpdate.add(theCampaign);
			}
		}
		if (!toUpdate.isEmpty()) update(toUpdate);
	}
	
	global void finish(Database.BatchableContext BC)
	{
		
	}
}