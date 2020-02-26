/****************************************************************************************************
*Description:   	Batch Class for Processing RON XML Information
*
*Required Class(es):BatchRONForecast_Test
*
*Revision   |Date       |Author             |AdditionalNotes
*====================================================================================================
*   1.0    	10/09/2014	Justin Padilla      WO#1748 Initial Version
*	1.1		11/04/2014	Justin Padilla		WO#1748 Modification to add an additional Report for insert (RON Delivered)
*****************************************************************************************************/
global class BatchRONForecast implements Database.Batchable<sObject>,Database.Stateful
{
	public List<Attachment> toProcess;
	public Map<Id,Attachment> reports{get;set;}
	public ReportType runReport{get;set;}
	public Map<Id,List<RON_Forecast__c>> tempInsert{get;set;}
    public Set<string> monitoredAccountIds = new Set<String>{System.label.AccountIdToSaveRON};
	
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		tempInsert = new Map<Id,List<RON_Forecast__c>>();
		//Should be processed Daily
		//Set up Query for Current by Default
		string query = 'SELECT Id, Name, Description, Body FROM Attachment WHERE ParentId IN: monitoredAccountIds AND (CreatedDate = Today OR CreatedDate = Yesterday) AND Description = null AND Name Like \'RON Forecast Current%\'';
		if (runReport != null && runReport == ReportType.Future) query ='SELECT Id, Name, Description, Body FROM Attachment WHERE ParentId IN: monitoredAccountIds AND (CreatedDate = Today OR CreatedDate = Yesterday) AND Description = null AND Name Like \'RON Forecast Next 12 months%\'';
		if (runReport != null && runReport == ReportType.Delivered) query ='SELECT Id, Name, Description, Body FROM Attachment WHERE ParentId IN: monitoredAccountIds AND (CreatedDate = Today OR CreatedDate = Yesterday) AND Description = null AND Name Like \'RON Delivered%\'';
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		toProcess = scope;
		reports = new Map<Id,Attachment>();
		List<RON_Forecast__c> toInsert = new List<RON_Forecast__c>();
		if (toProcess != null && !toProcess.isEmpty())
		{
			for (Attachment a: toProcess)
			{
				reports.put(a.Id,a);
				//Parse Attachment
				toInsert = parseRONCSV(a.body.toString());
				tempInsert.put(a.Id,toInsert);
				//Add new object for each row retrieved in the current month
			}
			if (!toInsert.isEmpty()) insert(toInsert);
		}
	}
	
	global void finish(Database.BatchableContext BC)
	{
		List<Messaging.Singleemailmessage> emails = new List<Messaging.Singleemailmessage>();
		//Mark as processed
		if (toProcess != null && !toProcess.isEmpty())
		{
			for (Attachment att: toProcess)
			{
				List<RON_Forecast__c> temp = tempInsert.get(att.Id);
				att.Description = 'Processed: '+string.valueOf(dateTime.now())+' \r\n'+'Records Processed: '+temp.size();
			}
			update (toProcess);
		}
		else
		{
			//Create an Email saying that there was no information processed during this scheduled run
			emails.add(CreateRONEmail('RON '+runReport+' completed with no source files present'));
		}
		for (Id s: tempInsert.keySet())
		{
			List<RON_Forecast__c> temp = tempInsert.get(s);
			if (temp == null || temp.size() == 0)
			{
				//Create Email Messages
				emails.add(CreateEmail(reports.get(s)));
			}
		}
		if (!emails.isEmpty()) 
		{
			try
	        {
	            Messaging.sendEmail(emails);
	            if (test.isRunningTest()) throw new CustomException('');
	        }
	        catch (Exception ex){} //Fail Silently
		}
	}

	public List<RON_Forecast__c> parseRONCSV(String contents)
	{
		List<RON_Forecast__c> retval = new List<RON_Forecast__c>();
		Xmlstreamreader reader = new Xmlstreamreader(contents);		
		boolean isSafeToGetNextXmlElement = true;
		integer columnCounter = 0;
		while (isSafeToGetNextXmlElement)
		{
			if (reader.getEventType() == XmlTag.START_ELEMENT)
			{
				if (reader.getLocalName() == 'Row')
				{
					//system.debug('Row Identified');
					RON_Forecast__c temp = getRowData(reader);
					if (temp != null)
					{
			       		if (runReport == null || runReport == ReportType.Current)
			       		{
			       			Date doNotProcess = Date.today().toStartOfMonth().addMonths(1);
			       			//Do Not process next month's information - The Future Forecast will handle next month's entries
			       			if (temp.Month_and_Year__c != doNotProcess)retval.add(temp);	
			       		}
			       		else retval.add(temp);
					}
				}
			}
			if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }
		}
		return retval;
	}
	
	public Messaging.Singleemailmessage CreateEmail(Attachment a)
	{
		Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
		List<String> emailAddresses = new List<String>();
		emailAddresses.add(Label.EmptyRONReport);
		if (Label.EmptyRONReport.contains(';')) emailAddresses = Label.EmptyRONReport.split(';');
		email.setToAddresses(emailAddresses);
		email.setSubject(a.Name+' was processed, but no RON records were inserted');
		String HTML = '';
		String PlainText = '';              
		HTML += '<a href="'+Url.getSalesforceBaseUrl().toExternalForm()+'/'+a.Id+'">Link to Attachment Processed</a><br></br>';
		PlainText += 'Link to Attachment Processed: '+Url.getSalesforceBaseUrl().toExternalForm()+'/'+a.Id+'\r\n';
		HTML +='<br></br>';
		PlainText += '\r\n';
		HTML += 'No records were inserted from this report!';
		PlainText += 'No records were inserted from this report!';
		email.setHTMLBody(HTML);
		email.setPlainTextBody(PlainText);
		return email;
	}
	public Messaging.Singleemailmessage CreateRONEmail(string RONName)
	{
		Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
		List<String> emailAddresses = new List<String>();
		emailAddresses.add(Label.EmptyRONReport);
		if (Label.EmptyRONReport.contains(';')) emailAddresses = Label.EmptyRONReport.split(';');
		email.setToAddresses(emailAddresses);
		email.setSubject(RONName);
		String HTML = '';
		String PlainText = '';              
		HTML += 'Scheduled RON task has completed, but no import files were processed';
		PlainText += 'Scheduled RON task has completed, but no import files were processed';
		email.setHTMLBody(HTML);
		email.setPlainTextBody(PlainText);
		return email;
	}
	
	public RON_Forecast__c getRowData(Xmlstreamreader reader)
	{
		RON_Forecast__c retval = new RON_Forecast__c();
		Map<string,string> columnToDataMap = new Map<string,string>();
		Map<string,string> columnNameToObjectFieldMapping = new Map<string,string>();
	    columnNameToObjectFieldMapping.put('advertiserName','Advertiser__c');
	    columnNameToObjectFieldMapping.put('orderName','Order__c');
	    columnNameToObjectFieldMapping.put('lineItemName','Line_Item__c');
	    columnNameToObjectFieldMapping.put('adSlotName','Ad_Unit__c');
	    columnNameToObjectFieldMapping.put('monthYear','Month_and_Year__c');
	    columnNameToObjectFieldMapping.put('lineitemCostPerUnit','Rate__c');
	    columnNameToObjectFieldMapping.put('imfForecastedImpressions','Forecasted_Impressions__c');
	    columnNameToObjectFieldMapping.put('totalReservationImpressionsDelivered','Forecasted_Impressions__c');

		Map<string,integer> monthMap = new Map<string,integer>();
		monthMap.put('january',1);
		monthMap.put('february',2);
		monthMap.put('march',3);
		monthMap.put('april',4);
		monthMap.put('may',5);
		monthMap.put('june',6);
		monthMap.put('july',7);
		monthMap.put('august',8);
		monthMap.put('september',9);
		monthMap.put('october',10);
		monthMap.put('november',11);
		monthMap.put('december',12);
		
		boolean isSafeToGetNextXmlElement = true;
		string colName = '';
        while(isSafeToGetNextXmlElement)
		{
            //system.debug('reader.getLocalName: '+reader.getLocalName());
            //system.debug('reader.getEventType: '+reader.getEventType());
            if (reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'Row') {
                break;
            }
			else if (reader.getLocalName() == 'Column' && reader.getEventType() == XmlTag.START_ELEMENT)
			{
				colName = '';
            	for (Integer i=0;i<reader.getAttributeCount(); i++)
					{
						if (reader.getAttributeLocalName(i) == 'name')
						{
							colName = reader.getAttributeValueAt(i).trim();
						}
					}
            }
            else if (reader.getEventType() == XmlTag.CHARACTERS)
            {
            	//system.debug('Column and Data Identified: '+colName+' '+reader.getText());
            	columnToDataMap.put(colName,reader.getText());
            }
            // Always use hasNext() before calling next() to confirm 
            // that we have not reached the end of the stream
            if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
        //system.debug('BatchRONForecast - getRowData - columnNameToObjectFieldMapping: '+columnNameToObjectFieldMapping);
        //Now that we have the column names and their values, map them and add them to the new record being created
        for (string s: columnToDataMap.keySet())
        {
        	string columnName = s;
        	string value = columnToDataMap.get(s);
        	if (columnName == 'totalReservationImpressionsDelivered') columnName = 'imfForecastedImpressions';
        	//system.debug('ColumnName: '+columnName+' Data: '+value);
        	if (!columnNameToObjectFieldMapping.containsKey(columnName)) continue; //A field that is not supported was found, bypass
        	if (columnName != 'monthYear' && columnName != 'imfForecastedImpressions' && columnName != 'lineitemCostPerUnit')
			{
				retval.put(columnNameToObjectFieldMapping.get(columnName),value);
				continue;
			}
			else if (columnName == 'monthYear')
			{
				try
			    {
			    //Split out the Month and Year. Example Value: 'October 2014'
			    	string[] dateParse = value.split(' ');
			       	Date newDate = Date.parse(string.valueOf(monthMap.get(dateParse[0].trim().toLowerCase())+'/1/'+dateParse[1].trim()));
				    retval.put(columnNameToObjectFieldMapping.get(columnName),newDate);			       						       			
			       	continue;
			    }
			    catch (Exception ex)
			    {
			    	//there was an error processing, bypass
			       	break;
			     }
			 }
			 else if (columnName == 'imfForecastedImpressions' || columnName == 'lineitemCostPerUnit')
			 {
			 	retval.put(columnNameToObjectFieldMapping.get(columnName),Decimal.valueOf(value.replace(',','')));
			    continue;
			 }
        }
        return retval;
	}
	public enum ReportType{Current,Future, Delivered}
	public class CustomException extends Exception{}
}