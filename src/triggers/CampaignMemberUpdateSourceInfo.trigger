/****************************************************************************************************
*Description:           This trigger updates the sourced Lead/Contact with the Campaigns that it 
*						belongs to for Silverpop Reporting
*
*Required Class(es):   UpdateSourceInfo [Class], UpdateSourceInfo_TEST
*
*Organization: Rainmaker-LLC
*
*Revision   |Date       |Author             |AdditionalNotes
*====================================================================================================
*   1.0     09/21/2015   Justin Padilla     Initial Implementation
*****************************************************************************************************/
trigger CampaignMemberUpdateSourceInfo on CampaignMember (before delete, before insert, before update)
{
	List<CampaignMember> insertUpdateProcess = new List<CampaignMember>();
	List<CampaignMember> deleteProcess = new List<CampaignMember>();
	
	if (trigger.isInsert)
	{
		for (CampaignMember cm: trigger.new)
		{
			if (cm.ContactId != null || cm.LeadId != null) insertUpdateProcess.add(cm);
		}
	}
	if (trigger.isUpdate)
	{
		for (CampaignMember cm: trigger.new)
		{
			if (cm.Status != trigger.oldMap.get(cm.Id).Status) insertUpdateProcess.add(cm);
		}
	}
	if (trigger.isDelete)
	{
		for (CampaignMember cm: trigger.old)
		{
			deleteProcess.add(cm);
		}
	}	
	if (!insertUpdateProcess.isEmpty()) UpdateSourceInfo.ProcessInsertOrUpdate(insertUpdateProcess);
	if (!deleteProcess.isEmpty()) UpdateSourceInfo.ProcessDeletions(deleteProcess);
}