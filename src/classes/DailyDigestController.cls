/**
 * Created by mikegill on 05/10/2017
 */

public class DailyDigestController {

    public String digestFilter {get;set;}
    public String query {get;set;}
    String soqlString = ApexUtils.getObjectFields('Opportunity');

    public List<Opportunity> getopptys()

    {
        List<Opportunity> oppty;

        if (digestFilter == 'cancel'){
            query = 'SELECT ' + soqlString + ' ,Owner.Name FROM Opportunity where IncludeInCancelDigest__c = true';
        }


        else if (digestFilter == 'win'){
            query = 'SELECT ' + soqlString + ' ,Owner.Name FROM Opportunity where IncludeInWinDigest__c = true';
        }


        else if (digestFilter == 'renewal'){
            query = 'SELECT ' + soqlString + ' ,Owner.Name FROM Opportunity where IncludeInRenewalDigest__c = true';
        }

        oppty = Database.query(query); // Fetch my data

        return oppty; // return my data
    }



}