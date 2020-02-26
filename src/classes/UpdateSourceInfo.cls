/****************************************************************************************************
*Description:           This class handles the processing from the CampaignMemberUpdateSourceInfo
*						and CampaignUpdateSourceInfo triggers that updates the sourced Lead/Contact 
*						with the Campaigns that it belongs to for Silverpop Reporting			
*
*Required Class(es):   UpdateSourceInfo_TEST
*
*Organization: Rainmaker-LLC
*
*Revision   |Date       |Author             |AdditionalNotes
*====================================================================================================
*   1.0     09/21/2015   Justin Padilla     Initial Implementation - S-01574
*****************************************************************************************************/
public class UpdateSourceInfo
{
	//Lead.Recent_Campaigns__c
	//Contact.Recent_Campaigns__c
	public static void ProcessInsertOrUpdate(List<CampaignMember> members)
	{
		Set<Id> leadIds = new Set<Id>();
		Set<Id> contactIds = new Set<Id>();
		Set<Id> campaignIds = new Set<Id>();
		for (CampaignMember cm: members)
		{
			if (cm.LeadId != null) leadIds.add(cm.LeadId);
			if (cm.ContactId != null) contactIds.add(cm.ContactId);
			if (cm.CampaignId != null && !campaignIds.contains(cm.CampaignId)) campaignIds.add(cm.CampaignId);
		}		
		Map<Id,Lead> leads = new Map<Id,Lead>();
		Map<Id,Contact> contacts = new Map<Id,Contact>();
		Map<Id,Campaign> campaigns = new Map<Id,Campaign>([SELECT Id, Name, Status FROM Campaign WHERE Id IN: campaignIds]);
		if (!leadIds.isEmpty()) leads = new Map<Id,Lead>([SELECT Id, Recent_Campaigns__c FROM Lead WHERE Id IN: leadIds AND isConverted = false]);
		if (!contactIds.isEmpty()) contacts = new Map<Id,Contact>([SELECT Id, Recent_Campaigns__c FROM Contact WHERE Id IN: contactIds]);

		//Create a Map for updating - bulkified handling
		Map<Id,Lead> leads2Update = new Map<Id,Lead>();
		Map<Id,Contact> contacts2Update = new Map<Id,Contact>();
		
		for (CampaignMember cm: members)
		{
			//Lead Processing
			if (cm.LeadId != null)
			{
				//Retrieve the current Lead Details				
				Lead tempLead = leads2Update.get(cm.LeadId);
				if (tempLead == null) tempLead = leads.get(cm.LeadId);
				//Retrieve the current Campaign Details to be added
				Campaign currentCampaign = campaigns.get(cm.CampaignId);
				if (tempLead == null) continue;
				if (tempLead != null && currentCampaign != null)
				{
					//Create a Listing of Recent Campaigns for this Lead if it already exists
					Map<string,string> recentCampaigns = new Map<string,string>();
					if (tempLead.Recent_Campaigns__c != null)
					{
						for (string line: tempLead.Recent_Campaigns__c.split('\r\n'))
						{
							string[] campaignDetails = line.split(' - ');
							if (campaignDetails.size() == 2)
							{
								recentCampaigns.put(campaignDetails[0].trim(),campaignDetails[1].trim());
							}
						}										
					}
					//Because of the Ordering of the following 2 lines, Update and Insert can be handled accordingly
					if (recentCampaigns.containsKey(currentCampaign.Name)) recentCampaigns.put(currentCampaign.Name,cm.Status);
					if (!recentCampaigns.containsKey(currentCampaign.Name)) recentCampaigns.put(currentCampaign.Name,cm.Status);
					if (!recentCampaigns.isEmpty())
					{
						tempLead.Recent_Campaigns__c = '';
						for (string s: recentCampaigns.keySet())
						{
							tempLead.Recent_Campaigns__c += s+' - '+recentCampaigns.get(s)+'\r\n';
						}
						leads2Update.put(tempLead.Id,tempLead);
					}
				}
			}		
			//Contact Processing
			if (cm.ContactId != null)
			{
				//Retrieve the current Contact Details
				Contact tempContact = contacts2Update.get(cm.ContactId);
				if (tempContact == null) tempContact = contacts.get(cm.ContactId);
				//Retrieve the current Campaign Details to be added
				Campaign currentCampaign = campaigns.get(cm.CampaignId);
				if (cm.ContactId != null && currentCampaign != null)
				{
					//Create a Listing of Recent Campaigns for this Lead if it already exists
					Map<string,string> recentCampaigns = new Map<string,string>();
					if (tempContact.Recent_Campaigns__c != null)
					{
						for (string line: tempContact.Recent_Campaigns__c.split('\r\n'))
						{
							string[] campaignDetails = line.split(' - ');
							if (campaignDetails.size() == 2)
							{
								recentCampaigns.put(campaignDetails[0].trim(),campaignDetails[1].trim());
							}
						}										
					}
					//Because of the Ordering of the following 2 lines, Update and Insert can be handled accordingly
					if (recentCampaigns.containsKey(currentCampaign.Name)) recentCampaigns.put(currentCampaign.Name,cm.Status);
					if (!recentCampaigns.containsKey(currentCampaign.Name)) recentCampaigns.put(currentCampaign.Name,cm.Status);
					if (!recentCampaigns.isEmpty())
					{
						tempContact.Recent_Campaigns__c = '';
						for (string s: recentCampaigns.keySet())
						{
							tempContact.Recent_Campaigns__c += s+' - '+recentCampaigns.get(s)+'\r\n';
						}
						contacts2Update.put(tempContact.Id,tempContact);
					}
				}
			}
		}
		
		if (!leads2Update.isEmpty()) update(leads2Update.values());
		if (!contacts2Update.isEmpty()) update(contacts2Update.values());
	}
	
	public static void ProcessDeletions(List<CampaignMember> members)
	{
		Set<Id> leadIds = new Set<Id>();
		Set<Id> contactIds = new Set<Id>();
		Set<Id> campaignIds = new Set<Id>();
		for (CampaignMember cm: members)
		{
			if (cm.LeadId != null) leadIds.add(cm.LeadId);
			if (cm.ContactId != null) contactIds.add(cm.ContactId);
			if (cm.CampaignId != null && !campaignIds.contains(cm.CampaignId)) campaignIds.add(cm.CampaignId);
		}		
		Map<Id,Lead> leads = new Map<Id,Lead>();
		Map<Id,Contact> contacts = new Map<Id,Contact>();
		Map<Id,Campaign> campaigns = new Map<Id,Campaign>([SELECT Id, Name, Status FROM Campaign WHERE Id IN: campaignIds]);
		if (!leadIds.isEmpty()) leads = new Map<Id,Lead>([SELECT Id, Recent_Campaigns__c FROM Lead WHERE Id IN: leadIds AND isConverted = false]);
		if (!contactIds.isEmpty()) contacts = new Map<Id,Contact>([SELECT Id, Recent_Campaigns__c FROM Contact WHERE Id IN: contactIds]);

		List<Lead> leads2Update = new List<Lead>();
		List<Contact> contacts2Update = new List<Contact>();
		for (CampaignMember cm: members)
		{
						//Lead Processing
			if (cm.LeadId != null)
			{
				//Retrieve the current Lead Details
				Lead tempLead = leads.get(cm.LeadId);
				//Retrieve the current Campaign Details to be added
				Campaign currentCampaign = campaigns.get(cm.CampaignId);
				if (tempLead != null && currentCampaign != null)
				{
					//Create a Listing of Recent Campaigns for this Lead if it already exists
					Map<string,string> recentCampaigns = new Map<string,string>();
					if (tempLead.Recent_Campaigns__c != null)
					{
						for (string line: tempLead.Recent_Campaigns__c.split('\r\n'))
						{
							string[] campaignDetails = line.split(' - ');
							if (campaignDetails.size() == 2)
							{
								recentCampaigns.put(campaignDetails[0].trim(),campaignDetails[1].trim());
							}
						}										
					}
					if (!recentCampaigns.isEmpty())
					{
						tempLead.Recent_Campaigns__c = '';
						for (string s: recentCampaigns.keySet())
						{
							if (s != currentCampaign.Name) tempLead.Recent_Campaigns__c += s+' - '+recentCampaigns.get(s)+'\r\n';
						}
						if (tempLead.Recent_Campaigns__c == '') tempLead.Recent_Campaigns__c = null;
						leads2Update.add(tempLead);
					}
				}
			}		
			//Contact Processing
			if (cm.ContactId != null)
			{
				//Retrieve the current Contact Details
				Contact tempContact = contacts.get(cm.ContactId);
				//Retrieve the current Campaign Details to be added
				Campaign currentCampaign = campaigns.get(cm.CampaignId);
				if (cm.ContactId != null && currentCampaign != null)
				{
					//Create a Listing of Recent Campaigns for this Lead if it already exists
					Map<string,string> recentCampaigns = new Map<string,string>();
					if (tempContact.Recent_Campaigns__c != null)
					{
						for (string line: tempContact.Recent_Campaigns__c.split('\r\n'))
						{
							string[] campaignDetails = line.split(' - ');
							if (campaignDetails.size() == 2)
							{
								recentCampaigns.put(campaignDetails[0].trim(),campaignDetails[1].trim());
							}
						}										
					}
					if (!recentCampaigns.isEmpty())
					{
						tempContact.Recent_Campaigns__c = '';
						for (string s: recentCampaigns.keySet())
						{
							if (s != currentCampaign.Name) tempContact.Recent_Campaigns__c += s+' - '+recentCampaigns.get(s)+'\r\n';
						}
						if (tempContact.Recent_Campaigns__c == '') tempContact.Recent_Campaigns__c = null;
						contacts2Update.add(tempContact);
					}
				}
			}
		}		
		if (!leads2Update.isEmpty()) update(leads2Update);
		if (!contacts2Update.isEmpty()) update(contacts2Update);
	}
	
	//Method is used for Name Updates and Deletions
	public static void CampaignProcessing(List<Campaign> currentCampaigns, Map<Id,Campaign> oldValues, Boolean isUpdate)
	{
		//Retrieve a Listing of CampaignMembers for the Campaigns being Updated
		Set<Id> campaignIds = new Set<Id>();
		for (Campaign c: currentCampaigns)
		{
			campaignIds.add(c.Id);
		}
		//Create a Map keyed from CampaignId and containing a List of Campaign Members
		Map<Id,List<CampaignMember>> campaignMembers = new Map<Id,List<CampaignMember>>();
		Set<Id> leadIds = new Set<Id>();
		Set<Id> contactIds = new Set<Id>();
		for (CampaignMember cm: [SELECT Id, LeadId, ContactId, CampaignId, Status FROM CampaignMember WHERE CampaignId IN: campaignIds])
		{
			if (!campaignMembers.containsKey(cm.CampaignId)) campaignMembers.put(cm.CampaignId, new List<CampaignMember>());
			if (campaignMembers.containsKey(cm.CampaignId)) campaignMembers.get(cm.CampaignId).add(cm);
			
			if (cm.LeadId != null) leadIds.add(cm.LeadId);
			if (cm.ContactId != null) contactIds.add(cm.ContactId);
		}
		//Populate Lead and Contact Information for updating
		Map<Id,Lead> leads = new Map<Id,Lead>();
		Map<Id,Contact> contacts = new Map<Id,Contact>();
		if (!leadIds.isEmpty()) leads = new Map<Id,Lead>([SELECT Id, Recent_Campaigns__c FROM Lead WHERE Id IN: leadIds AND isConverted = false]);
		if (!contactIds.isEmpty()) contacts = new Map<Id,Contact>([SELECT Id, Recent_Campaigns__c FROM Contact WHERE Id IN: contactIds]);
		//Create a Map of Leads and Contacts to update if needed - map is used to bulkify for multiple campaign/lead/contact changes
		Map<Id,Lead> leads2Update = new Map<Id,Lead>();
		Map<Id,Contact> contacts2Update = new Map<Id,Contact>();
		
		for (Campaign c: currentCampaigns)
		{
			//Retieve the listing of CampaignMembers 
			List<CampaignMember> members = campaignMembers.get(c.Id);
			if (members != null && !members.isEmpty())
			{
				for (CampaignMember cm: members)
				{
					//Lead Processing
					if (cm.LeadId != null && cm.ContactId == null) //Lead Processing - if both LeadId and ContactId present, 
					//the lead has been converted and we'll act upon the contact element only
					{
						Lead tempLead = leads2Update.get(cm.LeadId);
						if (tempLead == null) tempLead = leads.get(cm.LeadId);
						//Create a Listing of Recent Campaigns for this Lead if it already exists
						Map<string,string> recentCampaigns = new Map<string,string>();
						if (tempLead == null) continue;
						if (tempLead.Recent_Campaigns__c != null)
						{
							for (string line: tempLead.Recent_Campaigns__c.split('\r\n'))
							{
								string[] campaignDetails = line.split(' - ');
								if (campaignDetails.size() == 2)
								{
									recentCampaigns.put(campaignDetails[0].trim(),campaignDetails[1].trim());
								}
							}										
						}
						//Remove the old Campaign Name, if it exists
						Campaign oldCampaign = oldValues.get(c.Id);
						if (recentCampaigns.containsKey(oldCampaign.Name)) recentCampaigns.remove(oldCampaign.Name);
						//Now add in the new campaign - Only if it's an Update
						if (isUpdate) recentCampaigns.put(c.Name,cm.Status);
						if (!recentCampaigns.isEmpty())
						{
							tempLead.Recent_Campaigns__c = '';
							for (string s: recentCampaigns.keySet())
							{
								tempLead.Recent_Campaigns__c += s+' - '+recentCampaigns.get(s)+'\r\n';
							}
							if (tempLead.Recent_Campaigns__c == '') tempLead.Recent_Campaigns__c = null;
							leads2Update.put(tempLead.Id,tempLead);
						}
						if (recentCampaigns.isEmpty())
						{
							tempLead.Recent_Campaigns__c = null;
							leads2Update.put(tempLead.Id,tempLead);
						}
					}
					
					//Contact Processing
					if (cm.ContactId != null)
					{
						Contact tempContact = contacts2Update.get(cm.ContactId);
						if (tempContact == null) tempContact = contacts.get(cm.ContactId);
						//Create a Listing of Recent Campaigns for this Lead if it already exists
						Map<string,string> recentCampaigns = new Map<string,string>();
						if (tempContact.Recent_Campaigns__c != null)
						{
							for (string line: tempContact.Recent_Campaigns__c.split('\r\n'))
							{
								string[] campaignDetails = line.split(' - ');
								if (campaignDetails.size() == 2)
								{
									recentCampaigns.put(campaignDetails[0].trim(),campaignDetails[1].trim());
								}
							}										
						}
						system.debug('recentCampaigns: '+recentCampaigns);
						//Remove the old Campaign Name, if it exists
						Campaign oldCampaign = oldValues.get(c.Id);
						if (recentCampaigns.containsKey(oldCampaign.Name)) recentCampaigns.remove(oldCampaign.Name);
						//Now add in the new campaign - Only if it's an Update
						if (isUpdate) recentCampaigns.put(c.Name,cm.Status);
						if (!recentCampaigns.isEmpty())
						{
							tempContact.Recent_Campaigns__c = '';
							for (string s: recentCampaigns.keySet())
							{
								tempContact.Recent_Campaigns__c += s+' - '+recentCampaigns.get(s)+'\r\n';
							}
							if (tempContact.Recent_Campaigns__c == '') tempContact.Recent_Campaigns__c = null;
							contacts2Update.put(tempContact.Id,tempContact);
						}
						if (recentCampaigns.isEmpty())
						{
							tempContact.Recent_Campaigns__c = null;
							contacts2Update.put(tempContact.Id,tempContact);
						}
					}
				}
			}
		}
		if (!leads2Update.isEmpty()) update(leads2Update.values());
		if (!contacts2Update.isEmpty()) update(contacts2Update.values());
	}
}