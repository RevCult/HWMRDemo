/****************************************************************************************************
*Description:           This trigger Updates the Lead and Contact Recent Campaign Information in the 
*						event that the CampaignMember Name changes
*
*Required Class(es):   UpdateSourceInfo [Class], UpdateSourceInfo_TEST
*
*Organization: Rainmaker-LLC
*
*Revision   |Date       |Author             |AdditionalNotes
*====================================================================================================
*   1.0     09/21/2015   Justin Padilla     Initial Implementation - S-01574
*****************************************************************************************************/
trigger CampaignUpdateSourceInfo on Campaign (before update, before delete)
{
	List<Campaign> toProcess = new List<Campaign>();
	Map<Id,Campaign> oldCampaignInfo = new Map<Id,Campaign>();
	
	if (trigger.isUpdate)
	{
		for (Campaign c: trigger.new)
		{
			if (c.Name != trigger.oldMap.get(c.Id).Name)
			{
				toProcess.add(c);
				oldCampaignInfo.put(trigger.oldMap.get(c.Id).Id,trigger.oldMap.get(c.Id));
			}
		}
		if (!toProcess.isEmpty()) UpdateSourceInfo.CampaignProcessing(toProcess, oldCampaignInfo, true);
	}
	if (trigger.isDelete)
	{
		for (Campaign c: trigger.old)
		{
			//Add in both of the old values for removal
			toProcess.add(trigger.oldMap.get(c.Id));
			oldCampaignInfo.put(trigger.oldMap.get(c.Id).Id,trigger.oldMap.get(c.Id));
		}
		if (!toProcess.isEmpty()) UpdateSourceInfo.CampaignProcessing(toProcess, oldCampaignInfo, false);
	}
}