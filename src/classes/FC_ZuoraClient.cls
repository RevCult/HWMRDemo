public class FC_ZuoraClient {

    @testVisible
    private static final String CANCEL_SUBSCRIPTION_PATH_TEMPLATE = '/v1/subscriptions/{0}/cancel';

    @testVisible
    private static final String GET_AMENDMENT_BY_SUBSCRIPTION_ID_PATH_TEMPLATE = '/v1/amendments/subscriptions/{0}';

    @testVisible
    private static final String GET_SUBSCRIPTION_BY_KEY_PATH_TEMPLATE = '/v1/subscriptions/{0}';

    @testVisible
    private static final String GET_SUBSCRIPTION_BY_KEY_AND_VERSION_PATH_TEMPLATE = '/v1/subscriptions/{0}/versions/{1}';

    @testVisible
    private static final String GET_SUBSCRIPTION_OBJECT_PATH_TEMPLATE = '/v1/object/subscription/{0}';

    @testVisible
    private static final String QUERY_ACTION_PATH = '/v1/action/query';

    @testVisible
    private static final String QUERY_MORE_ACTION_PATH = '/v1/action/queryMore';

    @testVisible
    private static final String RENEW_SUBSCRIPTION_PATH_TEMPLATE = '/v1/subscriptions/{0}/renew';

    @testVisible
    private static final String SUBSCRIBE_ACTION_PATH = '/v1/action/subscribe';

    @testVisible
    private static final String UPDATE_SUBSCRIPTION_PATH_TEMPLATE = '/v1/subscriptions/{0}';

    private Id transactionParentId;

    public final Note[] TRANSACTION_NOTES = new List<Note>();

    public FC_ZuoraClient() {
        this(null);
    }

    public FC_ZuoraClient(Id transactionParentId) {
        this.transactionParentId = transactionParentId;
    }

    public CancelSubscriptionResponse cancelSubscription(CancelSubscriptionRequest request, String subscriptionKey) {
        String path = String.format(CANCEL_SUBSCRIPTION_PATH_TEMPLATE, new String[]{
                EncodingUtil.urlEncode(subscriptionKey, 'UTF-8')
        });
        Http httpClient = new Http();
        HttpRequest hRequest = buildHttpRequest('PUT', path,
                fixRequestJsonKeys(JSON.serialize(request, true)), new Map<String, String>{
                        'zuora-version' => '211.0'
                });
        HttpResponse hResponse = httpClient.send(hRequest);
        addTransaction('Cancel Subscription', hRequest, hResponse);
        CancelSubscriptionResponse response = (CancelSubscriptionResponse) JSON.deserialize(hResponse.getBody(),
                CancelSubscriptionResponse.class);
        return response;
    }

    public GetAmendmentResponse getAmendmentBySubscriptionId(String subscriptionZuoraId) {
        String path = String.format(GET_AMENDMENT_BY_SUBSCRIPTION_ID_PATH_TEMPLATE, new String[]{
                EncodingUtil.urlEncode(subscriptionZuoraId, 'UTF-8')
        });
        Http httpClient = new Http();
        HttpRequest hRequest = buildHttpRequest('GET', path, null);
        HttpResponse hResponse = httpClient.send(hRequest);
        addTransaction('Get Amendment By Subscription Id', hRequest, hResponse);
        GetAmendmentResponse response = null;
        if (hResponse.getStatusCode() == 200) {
            String fixedResponseBody = hResponse.getBody();
            response = (GetAmendmentResponse) JSON.deserialize(fixedResponseBody, GetAmendmentResponse.class);
        }
        return response;
    }

    public GetSubscriptionResponse getSubscriptionByKey(String subscriptionKey) {
        String path = String.format(GET_SUBSCRIPTION_BY_KEY_PATH_TEMPLATE, new String[]{
                EncodingUtil.urlEncode(subscriptionKey, 'UTF-8')
        });
        Http httpClient = new Http();
        HttpRequest hRequest = buildHttpRequest('GET', path, null);
        HttpResponse hResponse = httpClient.send(hRequest);
        addTransaction('Get Subscription By Key', hRequest, hResponse);
        GetSubscriptionResponse response = null;
        if (hResponse.getStatusCode() == 200) {
            String fixedResponseBody = hResponse.getBody().replace('__c', '_c').replace('number', 'number_x');
            response = (GetSubscriptionResponse) JSON.deserialize(fixedResponseBody, GetSubscriptionResponse.class);
        }
        return response;
    }

    public GetSubscriptionResponse getSubscriptionByKeyAndVersion(String subscriptionKey, Integer version) {
        String path = String.format(GET_SUBSCRIPTION_BY_KEY_AND_VERSION_PATH_TEMPLATE, new String[]{
                EncodingUtil.urlEncode(subscriptionKey, 'UTF-8'),
                EncodingUtil.urlEncode(String.valueOf(version), 'UTF-8')
        });
        Http httpClient = new Http();
        HttpRequest hRequest = buildHttpRequest('GET', path, null);
        HttpResponse hResponse = httpClient.send(hRequest);
        addTransaction('Get Subscription By Key and Version', hRequest, hResponse);
        GetSubscriptionResponse response = null;
        if (hResponse.getStatusCode() == 200) {
            String fixedResponseBody = hResponse.getBody().replace('__c', '_c').replace('number', 'number_x');
            response = (GetSubscriptionResponse) JSON.deserialize(fixedResponseBody, GetSubscriptionResponse.class);
        }
        return response;
    }

    public Subscription getSubscriptionObject(String subscriptionZuoraId) {
        String path = String.format(GET_SUBSCRIPTION_OBJECT_PATH_TEMPLATE, new String[]{
                EncodingUtil.urlEncode(subscriptionZuoraId, 'UTF-8')
        });
        Http httpClient = new Http();
        HttpRequest hRequest = buildHttpRequest('GET', path, null);
        HttpResponse hResponse = httpClient.send(hRequest);
        addTransaction('Get Subscription Object', hRequest, hResponse);
        Subscription response = null;
        if (hResponse.getStatusCode() == 200) {
            String fixedResponseBody = hResponse.getBody().replace('__QT', '_q').replace('__c', '_c').replace('number', 'number_x');
            response = (Subscription) JSON.deserialize(fixedResponseBody, Subscription.class);
        }
        return response;
    }

    public QueryActionResponse query(QueryActionRequest request) {
        Http httpClient = new Http();
        HttpRequest hRequest = buildHttpRequest('POST', QUERY_ACTION_PATH, JSON.serialize(request, true));
        HttpResponse hResponse = httpClient.send(hRequest);
        addTransaction('Query', hRequest, hResponse);
        QueryActionResponse response = (QueryActionResponse) JSON.deserialize(hResponse.getBody(), QueryActionResponse.class);
        if (hResponse.getStatusCode() != 200) {
            throw new FC_Exception(String.format('Error {0}: {1} - {2}', new String[]{
                    String.valueOf(hResponse.getStatusCode()), response.faultcode, response.faultstring
            }));
        }
        return response;
    }

    public QueryActionResponse queryMore(QueryMoreActionRequest request) {
        Http httpClient = new Http();
        HttpRequest hRequest = buildHttpRequest('POST', QUERY_MORE_ACTION_PATH, JSON.serialize(request, true));
        HttpResponse hResponse = httpClient.send(hRequest);
        addTransaction('Query More', hRequest, hResponse);
        QueryActionResponse response = (QueryActionResponse) JSON.deserialize(hResponse.getBody(), QueryActionResponse.class);
        if (hResponse.getStatusCode() != 200) {
            throw new FC_Exception(String.format('Error {0}: {1} - {2}', new String[]{
                    String.valueOf(hResponse.getStatusCode()), response.faultcode, response.faultstring
            }));
        }
        return response;
    }

    public RenewSubscriptionResponse renewSubscription(RenewSubscriptionRequest request, String subscriptionKey) {
        String path = String.format(RENEW_SUBSCRIPTION_PATH_TEMPLATE, new String[]{
                EncodingUtil.urlEncode(subscriptionKey, 'UTF-8')
        });
        Http httpClient = new Http();
        HttpRequest hRequest = buildHttpRequest('PUT', path, fixRequestJsonKeys(JSON.serialize(request, true)), new Map<String, String>{
                'zuora-version' => '211.0'
        });
        HttpResponse hResponse = httpClient.send(hRequest);
        addTransaction('Renew Subscription', hRequest, hResponse);
        RenewSubscriptionResponse response = (RenewSubscriptionResponse) JSON.deserialize(hResponse.getBody(),
                RenewSubscriptionResponse.class);
        return response;
    }

    public SubscribeActionResponse[] subscribe(SubscribeActionRequest request) {
        Http httpClient = new Http();
        HttpRequest hRequest = buildHttpRequest('POST', SUBSCRIBE_ACTION_PATH,
                fixRequestJsonKeys(JSON.serialize(request, true)));
        HttpResponse hResponse = httpClient.send(hRequest);
        addTransaction('Subscribe', hRequest, hResponse);
        SubscribeActionResponse[] responses = null;
        if (hResponse.getStatusCode() == 200) {
            responses = (SubscribeResult[]) JSON.deserialize(hResponse.getBody(), SubscribeResult[].class);
        } else if (hResponse.getStatusCode() == 400) {
            responses = new List<SubscribeError>{
                    (SubscribeError) JSON.deserialize(hResponse.getBody(), SubscribeError.class)
            };
        } else {
            throw new FC_Exception(String.format('Unknown Error: {0} - {1}', new String[]{
                    String.valueOf(hResponse.getStatusCode()), hResponse.getStatus()
            }));
        }
        return responses;
    }

    public UpdateSubscriptionResponse updateSubscription(UpdateSubscriptionRequest request, String subscriptionKey) {
        String path = String.format(UPDATE_SUBSCRIPTION_PATH_TEMPLATE, new String[]{
                EncodingUtil.urlEncode(subscriptionKey, 'UTF-8')
        });
        Http httpClient = new Http();
        HttpRequest hRequest = buildHttpRequest('PUT', path, fixRequestJsonKeys(JSON.serialize(request, true)), new Map<String, String>{
                'zuora-version' => '211.0'
        });
        HttpResponse hResponse = httpClient.send(hRequest);
        addTransaction('Update Subscription', hRequest, hResponse);
        UpdateSubscriptionResponse response = (UpdateSubscriptionResponse) JSON.deserialize(hResponse.getBody(),
                UpdateSubscriptionResponse.class);
        return response;
    }

    public void flushTransactions() {
        if (!TRANSACTION_NOTES.isEmpty()) {
            if (this.transactionParentId != null &&
                    this.transactionParentId.getSobjectType() == Schema.Opportunity.SObjectType) {
                FC_Opportunity_Zuora_Transaction__c opportunityZuoraTransactionRecord =
                        new FC_Opportunity_Zuora_Transaction__c(Opportunity__c = this.transactionParentId);
                insert opportunityZuoraTransactionRecord;
                for (Note transactionNote : TRANSACTION_NOTES) {
                    transactionNote.ParentId = opportunityZuoraTransactionRecord.Id;
                }
            }
            insert TRANSACTION_NOTES;
        }
        TRANSACTION_NOTES.clear();
    }

    private void addTransaction(String title, HttpRequest hRequest, HttpResponse hResponse) {
        if (this.transactionParentId != null) {
            TRANSACTION_NOTES.add(new Note(ParentId = this.transactionParentId,
                    Title = TRANSACTION_NOTES.size() + ': Zuora Request' + (String.isNotBlank(title) ? ' - ' + title : ''),
                    Body = serialize(hRequest).left(32000)));
            TRANSACTION_NOTES.add(new Note(ParentId = this.transactionParentId,
                    Title = TRANSACTION_NOTES.size() + ': Zuora Response' + (String.isNotBlank(title) ? ' - ' + title : ''),
                    Body = serialize(hResponse).left(32000)));
        }
    }

    private static String fixRequestJsonKeys(String inputJson) {
        return inputJson.replace('_c', '__c').replace('_x', '').replace('_q', '__QT');
    }

    @testVisible
    private static String getPrefixedPath(String path) {
        FC_Zuora_Client_Settings__c config = FC_Zuora_Client_Settings__c.getInstance();
        if (path.startsWith('/v1/action/') || path.startsWith('/v1/object/')) {
            return 'callout:FC_ZuoraRest' + (config.Is_Production_Copy_Tenant__c ? 'Proxy' : '') + path;
        }
        return 'callout:FC_ZuoraRest' + (config.Is_Production_Copy_Tenant__c ? '/apps' : '') + path;
    }

    private HttpRequest buildHttpRequest(String method, String path, String body) {
        return buildHttpRequest(method, path, body, null);
    }

    private HttpRequest buildHttpRequest(String method, String path, String body, Map<String, String> additionalHeaders) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(getPrefixedPath(path));
        request.setMethod(method);
        request.setHeader('apiAccessKeyId', '{!$Credential.Username}');
        request.setHeader('apiSecretAccessKey', '{!$Credential.Password}');
        if (additionalHeaders != null) {
            for (String headerKey : additionalHeaders.keySet()) {
                request.setHeader(headerKey, additionalHeaders.get(headerKey));
            }
        }
        if (String.isNotBlank(body) && !method.equalsIgnoreCase('GET')) {
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
        }
        request.setTimeout(120000);
        return request;
    }

    private String serialize(HttpRequest hRequest) {
        String result = hRequest.getMethod() + ' ' + hRequest.getEndpoint() + '\n\n' + hRequest.getBody();
        return result;
    }

    private String serialize(HttpResponse hResponse) {
        String result = hResponse.getStatusCode() + ' ' + hResponse.getStatus() + '\n';
        for (String headerKey : hResponse.getHeaderKeys()) {
            result += headerKey + ': ' + hResponse.getHeader(headerKey) + '\n';
        }
        result += '\n' + hResponse.getBody();
        return result;
    }

    public class ZuoraError {

        public String code;
        public String message;
        public String field;

    }

    public class CancelSubscriptionRequest {

        public Boolean applyCreditBalance;
        public Date cancellationEffectiveDate;
        public String cancellationPolicy;
        public Boolean collect_x;
        public Date OpportunityCloseDate_q;
        public String OpportunityName_q;
        public Boolean runBilling;
        public Date targetDate;

    }

    public class CancelSubscriptionResponse {

        public Date cancelledDate;
        public String invoiceId;
        public Decimal paidAmount;
        public String paymentId;
        public String processId;
        public ZuoraError[] reasons;
        public String subscriptionId;
        public Boolean success;
        public Decimal totalDeltaMrr;
        public Decimal totalDeltaTcv;

    }

    public class GetAmendmentResponse {

        public String id;
        public String baseSubscriptionId;
        public Date effectiveDate;
        public String newSubscriptionId;
        public Boolean success;
        public String type;

    }

    public class GetSubscriptionResponse {

        public Boolean success;
        public String id;
        public String subscriptionNumber;
        public Date subscriptionStartDate;
        public GetSubscriptionResponseRatePlan[] ratePlans;

    }

    public class GetSubscriptionResponseRatePlan {

        public String id;
        public String productId;
        public String productName;
        public String productSku;
        public String productRatePlanId;
        public String ratePlanName;
        public GetSubscriptionResponseRatePlanCharge[] ratePlanCharges;

    }

    public class GetSubscriptionResponseRatePlanCharge {

        public String id;
        public Id BillingInstructionSetId_c;
        public Date effectiveEndDate;
        public Date effectiveStartDate;
        public String productRatePlanChargeId;
        public String number_x;
        public String name;
        public Id Record_Id_c;
        public String type;

    }

    public class AddRatePlan {

        public AddRatePlanChargeOverride[] chargeOverrides;
        public Date contractEffectiveDate;
        public String productRatePlanId;

    }

    public class AddRatePlanChargeOverride {

        public String BillCase_c;
        public String billCycleDay;
        public String billCycleType;
        public Id BillingInstructionSetId_c;
        public String billingPeriod;
        public String billingPeriodAlignment;
        public String description;
        public String endDateCondition;
        public String GeographyName_c;
        public String geoName_c;
        public String ListPrice_c;
        public Decimal price;
        public String productRatePlanChargeId;
        public String ProductName_c;
        public Decimal quantity;
        public Id Record_Id_c;
        public Id Seg3RecordID_c;
        public String Segment2_c;
        public String Segment3_c;
        public Integer specificBillingPeriod;
        public Date specificEndDate;
        public Date triggerDate;
        public String triggerEvent;
        public Integer upToPeriods;
        public String upToPeriodsType;

    }

    public class PaymentMethod {

        public String Id;

    }

    public class QueryActionRequest {

        public QueryActionRequestConf conf;
        public String queryString;

    }

    public class QueryMoreActionRequest {

        public String queryLocator;

    }

    public class QueryActionRequestConf {

        public Integer batchSize;

    }

    public class QueryActionResponse {

        public List<Map<String, String>> records;
        public Integer size;
        public Boolean done;
        public String faultcode;
        public String faultstring;
        public String queryLocator;

    }

    public class PreviewOptions {

        public Boolean EnablePreviewMode;
        public Boolean IncludeExistingDraftInvoices;
        public Integer NumberOfPeriods;
        public Boolean PreviewThroughTermEnd;
        public String PreviewType;

    }

    public class SubscriptionData {

        public RatePlanData[] RatePlanData;
        public Subscription Subscription;
    }

    public class RatePlanData {

        public RatePlan RatePlan;
        public RatePlanChargeData[] RatePlanChargeData;
    }

    public class RatePlan {

        public String ProductRatePlanId;

    }

    public class RatePlanChargeData {

        public RatePlanCharge RatePlanCharge;

    }

    public class RatePlanCharge {

        public String AccountingCode;
        public String ApplyDiscountTo;
        public String BillCase_c;
        public Integer BillCycleDay;
        public String BillCycleType;
        public Id BillingInstructionSetId_c;
        public String BillingPeriod;
        public String BillingPeriodAlignment;
        public String Description;
        public String EndDateCondition;
        public String GeographyName_c;
        public String geoName_c;
        public String ListPrice_c;
        public Decimal Price;
        public String ProductName_c;
        public String ProductRatePlanChargeId;
        public Decimal Quantity;
        public Id Record_Id_c;
        public String Segment2_c;
        public String Segment3_c;
        public Id Seg3RecordID_c;
        public Integer SpecificBillingPeriod;
        public Date SpecificEndDate;
        public Date TriggerDate;
        public String TriggerEvent;
        public Integer UpToPeriods;
        public String UpToPeriodsType;
        public String WeeklyBillCycleDay;

    }

    public class RemoveRatePlan {

        public Date contractEffectiveDate;
        public Date customerAcceptanceDate;
        public String ratePlanId;
        public Date serviceActivationDate;

    }

    public class RenewSubscriptionRequest {

        public Boolean collect_x;
        public Boolean runBilling;
        public Date targetDate;

    }

    public class RenewSubscriptionResponse {

        public String invoiceId;
        public Decimal paidAmount;
        public String paymentId;
        public ZuoraError[] reasons;
        public String subscriptionId;
        public Boolean success;
        public Date termEndDate;
        public Date termStartDate;
        public Decimal totalDeltaMrr;
        public Decimal totalDeltaTcv;

    }

    public class Subscribe {

        public ZuoraAccount Account;
        public ZuoraContact BillToContact;
        public PreviewOptions PreviewOptions;
        public ZuoraContact SoldToContact;
        public SubscriptionData SubscriptionData;
        public SubscribeOptions SubscribeOptions;

    }

    public class SubscribeActionRequest {

        public Subscribe[] subscribes;

    }

    public virtual class SubscribeActionResponse {
    }

    public class SubscribeError extends SubscribeActionResponse {

        public ZuoraError[] Errors;
        public Boolean Success;

    }

    public class SubscribeInvoiceProcessingOptions {

        public Date InvoiceDate;
        public String InvoiceProcessingScope;
        public Date InvoiceTargetDate;

    }

    public class SubscribeOptions {

        public Boolean GenerateInvoice;
        public Boolean ProcessPayments;
        public SubscribeInvoiceProcessingOptions SubscribeInvoiceProcessingOptions;

    }

    public class SubscribeResult extends SubscribeActionResponse {

        public String AccountId;
        public String AccountNumber;
        public ZuoraError[] Errors;
        public String InvoiceId;
        public String InvoiceNumber;
        public String PaymentId;
        public String PaymentTransactionNumber;
        public String SubscriptionId;
        public String SubscriptionNumber;
        public Boolean Success;
        public Decimal TotalMrr;
        public Decimal TotalTcv;

    }

    public class Subscription {

        public Boolean AutoRenew;
        public String BillCase_c;
        public Date CancelledDate;
        public Date ContractAcceptanceDate;
        public Date ContractEffectiveDate;
        public String Id;
        public Integer InitialTerm;
        public String InitialTermPeriodType;
        public Boolean IsInvoiceSeparate;
        public String Name;
        public String Notes;
        public Date OpportunityCloseDate_q;
        public String OpportunityID_c;
        public String OpportunityName_q;
        public String PreviousSubscriptionId;
        public String Region_c;
        public Integer RenewalTerm;
        public String RenewalTermPeriodType;
        public Date ServiceActivationDate;
        public String Status;
        public Date SubscriptionEndDate;
        public Date TermStartDate;
        public String TermType;
        public Integer Version;

    }

    public class UpdateRatePlan {

        public UpdateRatePlanChargeUpdateDetail[] chargeUpdateDetails;
        public Date contractEffectiveDate;
        public String ratePlanId;

    }

    public class UpdateRatePlanChargeUpdateDetail {

        public String BillCase_c;
        public Id BillingInstructionSetId_c;
        public String billingPeriodAlignment;
        public String description;
        public String GeographyName_c;
        public String geoName_c;
        public String ListPrice_c;
        public Decimal price;
        public String ProductName_c;
        public Decimal quantity;
        public String ratePlanChargeId;
        public Id Record_Id_c;
        public Id Seg3RecordID_c;
        public String Segment2_c;
        public String Segment3_c;
        public Date triggerDate;
        public String triggerEvent;

    }

    public class UpdateSubscriptionRequest {

        public AddRatePlan[] add;
        public Boolean autoRenew;
        public String BillCase_c;
        public Boolean collect_x;
        public Integer currentTerm;
        public String currentTermPeriodType;
        public String notes;
        public Date OpportunityCloseDate_q;
        public Id OpportunityID_c;
        public String OpportunityName_q;
        public RemoveRatePlan[] remove;
        public Boolean preview;
        public String renewalSetting;
        public Integer renewalTerm;
        public String renewalTermPeriodType;
        public Boolean runBilling;
        public Date targetDate;
        public Date termStartDate;
        public String termType;
        public UpdateRatePlan[] update_x;

    }

    public class UpdateSubscriptionResponse {

        public Decimal amount;
        public Decimal amountWithoutTax;
        public String invoiceId;
        public Decimal paidAmount;
        public String paymentId;
        public String processId;
        public ZuoraError[] reasons;
        public String subscriptionId;
        public Boolean success;
        public Date targetDate;
        public Decimal taxAmount;
        public Decimal totalDeltaMrr;
        public Decimal totalDeltaTcv;

    }

    public class ZuoraAccount {

        public Boolean AutoPay;
        public String Batch;
        public Integer BillCycleDay;
        public String BillToId;
        public String Currency_x;
        public Id CrmId;
        public String DefaultPaymentMethodId;
        public String Id;
        public Boolean InvoiceDeliveryPrefsEmail;
        public Boolean InvoiceDeliveryPrefsPrint;
        public String Name;
        public String PaymentTerm;
        public String SalesRepName;
        public String SoldToId;
        public String Status;

    }

    public class ZuoraContact {

        public String Address1;
        public String Address2;
        public String City;
        public String Country;
        public String County;
        public String Fax;
        public String FirstName;
        public String Id;
        public String LastName;
        public String PostalCode;
        public String State;
        public String WorkEmail;
        public String WorkPhone;

    }

}