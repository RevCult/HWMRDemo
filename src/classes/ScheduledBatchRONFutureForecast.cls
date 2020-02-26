/****************************************************************************************************
*Description:   	Scheduled Batch Class for Processing RON Current CSV Information
*
*Required Class(es):BatchRONForecast_Test
*
*Revision   |Date       |Author             |AdditionalNotes
*====================================================================================================
*   1.0    	10/09/2014	Justin Padilla      WO#1748 Initial Version
*****************************************************************************************************/
global class ScheduledBatchRONFutureForecast implements Schedulable 
{
	global void execute(SchedulableContext sc)
	{
		BatchRONForecast b = new BatchRONForecast();
		b.runReport = BatchRONForecast.ReportType.Future;
		database.executeBatch(b);
	}
}