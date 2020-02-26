public class FC_EchosignAgreementCache {

    private static String[] ECHOSIGN_AGREEMENT_FIELDS = new String[] {
            'Id', 'Quote__c', 'echosign_dev1__Status__c' };

    private static final Map<ID, echosign_dev1__SIGN_Agreement__c> BY_ID_MAP = new Map<ID, echosign_dev1__SIGN_Agreement__c>();

    private static final Map<ID, Set<echosign_dev1__SIGN_Agreement__c>> BY_QUOTE_ID_MAP = new Map<ID, Set<echosign_dev1__SIGN_Agreement__c>>();

    private static final String SOQL_BASE;
    
    static {
        SOQL_BASE = String.format('select {0} from echosign_dev1__SIGN_Agreement__c', 
                                  new String[] { String.join(ECHOSIGN_AGREEMENT_FIELDS, ', ') });              
    }
    
    public static void clearCache() {
        BY_ID_MAP.clear();
        BY_QUOTE_ID_MAP.clear();
    }
    
    public static Map<ID, Set<echosign_dev1__SIGN_Agreement__c>> findSignedAgreementsByQuoteIds(Set<ID> quoteIds) {
        Map<ID, Set<echosign_dev1__SIGN_Agreement__c>> results = new Map<ID, Set<echosign_dev1__SIGN_Agreement__c>>();
        Set<ID> quoteIdsToQuery = new Set<ID>();
        for (ID quoteId : quoteIds) {
            if (BY_QUOTE_ID_MAP.containsKey(quoteId)) {
                results.put(quoteId, BY_QUOTE_ID_MAP.get(quoteId));
            } else {
                quoteIdsToQuery.add(quoteId);
            }
        }
        if (quoteIdsToQuery.size() > 0) {
            String soql = SOQL_BASE + ' where Quote__c in :quoteIdsToQuery and echosign_dev1__Status__c = \'Signed\'';
            for (echosign_dev1__SIGN_Agreement__c agreementRecord : Database.query(soql)) {
                Set<echosign_dev1__SIGN_Agreement__c> agreements = results.get(agreementRecord.Quote__c);
                if (agreements == null) {
                    agreements = new Set<echosign_dev1__SIGN_Agreement__c>();
                    results.put(agreementRecord.Quote__c, agreements);
                }
                agreements.add(agreementRecord);
                BY_QUOTE_ID_MAP.put(agreementRecord.Quote__c, agreements);                
                BY_ID_MAP.put(agreementRecord.Id, agreementRecord);
            }
        }
        return results;
    }
    
}