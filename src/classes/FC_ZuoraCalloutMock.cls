@isTest
public class FC_ZuoraCalloutMock implements HttpCalloutMock {

    public Boolean testError = false;
    public Boolean testCancelSubscriptionError = false;
    public Boolean testUpdateSubscriptionError = false;
    public Boolean testRenewSubscriptionError = false;
    public Boolean testSubscribeKnownError = false;
    public Boolean testSubscribeUnknownError = false;
    public Id testBillingInstructionSetId = null;
    public Id testMetroclientProductGeographyId = null;
    public Id testAccountId = null;
    public Boolean testReturnCancelledSubscriptionObject = false;

    public FC_ZuoraCalloutMock() {
        this(false);
    }

    public FC_ZuoraCalloutMock(Boolean testError) {
        this.testError = testError;
    }

    public HttpResponse respond(HttpRequest request) {

        String endpoint = request.getEndpoint();
        HttpResponse response = null;
        if (request.getMethod().equalsIgnoreCase('PUT') &&
                endpoint.startsWith(FC_ZuoraClient.getPrefixedPath(FC_ZuoraClient.CANCEL_SUBSCRIPTION_PATH_TEMPLATE).replace('{0}', '').replace('/cancel', '')) &&
                endpoint.endsWith('/cancel')) {
            response = buildCancelSubscriptionResponse(request);
        } else if (request.getMethod().equalsIgnoreCase('GET') &&
                endpoint.startsWith(FC_ZuoraClient.getPrefixedPath(FC_ZuoraClient.GET_AMENDMENT_BY_SUBSCRIPTION_ID_PATH_TEMPLATE).replace('{0}', ''))) {
            response = buildGetAmendmentResponse(request);
        } else if (request.getMethod().equalsIgnoreCase('GET') &&
                endpoint.startsWith(FC_ZuoraClient.getPrefixedPath(FC_ZuoraClient.GET_SUBSCRIPTION_BY_KEY_PATH_TEMPLATE).replace('{0}', ''))) {
            response = buildGetSubscriptionByKeyResponse(request);
        } else if (request.getMethod().equalsIgnoreCase('GET') &&
                endpoint.startsWith(FC_ZuoraClient.getPrefixedPath(FC_ZuoraClient.GET_SUBSCRIPTION_OBJECT_PATH_TEMPLATE).replace('{0}', ''))) {
            response = buildGetSubscriptionObjectResponse(request);
        } else if (request.getMethod().equalsIgnoreCase('PUT') &&
                endpoint.startsWith(FC_ZuoraClient.getPrefixedPath(FC_ZuoraClient.RENEW_SUBSCRIPTION_PATH_TEMPLATE).replace('{0}', '').replace('/renew', '')) &&
                endpoint.endsWith('/renew')) {
            response = buildRenewSubscriptionResponse(request);
        } else if (request.getMethod().equalsIgnoreCase('POST') && endpoint == FC_ZuoraClient.getPrefixedPath(FC_ZuoraClient.QUERY_ACTION_PATH)) {
            List<Map<String, String>> records = new List<Map<String, String>>();
            FC_ZuoraClient.QueryActionRequest queryActionRequest = (FC_ZuoraClient.QueryActionRequest) JSON.deserialize(request.getBody(), FC_ZuoraClient.QueryActionRequest.class);
            String queryLocator = null;
            if (queryActionRequest.queryString.contains('from Subscription')) {
                records.addAll(new List<Map<String, String>>{
                        new Map<String, String>{
                                'Id' => 'S-1', 'AccountId' => 'A-1',
                                'CancelledDate' => !testReturnCancelledSubscriptionObject ? null : String.valueOf(Date.today().addDays(-1)),
                                'Name' => 'S-1',
                                'PreviousSubscriptionId' => null, 'Status' => !testReturnCancelledSubscriptionObject ? 'Active' : 'Cancelled',
                                'SubscriptionEndDate' => String.valueOf(Date.today().addYears(1)),
                                'SubscriptionStartDate' => String.valueOf(Date.today())
                        }
                });
                queryLocator = 'QL-S-1';
            } else if (queryActionRequest.queryString.contains('from Account')) {
                records.addAll(new List<Map<String, String>>{
                        new Map<String, String>{
                                'Id' => 'A-1', 'CrmId' => this.testAccountId
                        }
                });
                queryLocator = 'QL-A-1';
            } else if (queryActionRequest.queryString.contains('from RatePlanCharge')) {
                records.addAll(new List<Map<String, String>>{
                        new Map<String, String>{
                                'Id' => 'RPC-1', 'ChargeNumber' => 'RPC-1', 'IsLastSegment' => 'true',
                                'EffectiveEndDate' => !testReturnCancelledSubscriptionObject ? String.valueOf(Date.today().addYears(1)) : String.valueOf(Date.today().addDays(-1)),
                                'EffectiveStartDate' => String.valueOf(Date.today()),
                                'RatePlanId' => 'RP-1', 'Record_Id__c' => this.testMetroclientProductGeographyId
                        }
                });
                queryLocator = 'QL-RPC-1';
            } else if (queryActionRequest.queryString.contains('from RatePlan')) {
                records.addAll(new List<Map<String, String>>{
                        new Map<String, String>{
                                'Id' => 'RP-1', 'SubscriptionId' => 'S-1'
                        }
                });
                queryLocator = 'QL-RP-1';
            } else if (queryActionRequest.queryString.contains('from Amendment')) {
                records.addAll(new List<Map<String, String>>{
                        new Map<String, String>{
                                'Id' => 'AM-1', 'SubscriptionId' => 'S-1',
                                'EffectiveDate' => String.valueOf(Date.today() + 15),
                                'Type' => 'RemoveProduct'
                        }
                });
                queryLocator = 'QL-AM-1';
            }
            response = buildQueryResponse(request, records, queryLocator);
        } else if (request.getMethod().equalsIgnoreCase('POST') && endpoint == FC_ZuoraClient.getPrefixedPath(FC_ZuoraClient.QUERY_MORE_ACTION_PATH)) {
            List<Map<String, String>> records = new List<Map<String, String>>();
            FC_ZuoraClient.QueryMoreActionRequest queryMoreActionRequest = (FC_ZuoraClient.QueryMoreActionRequest) JSON.deserialize(request.getBody(), FC_ZuoraClient.QueryMoreActionRequest.class);
            if (queryMoreActionRequest.queryLocator.startsWith('QL-A-')) {
                records.addAll(new List<Map<String, String>>{
                        new Map<String, String>{
                                'Id' => 'A-2', 'CrmId' => this.testAccountId
                        }
                });
            } else if (queryMoreActionRequest.queryLocator.startsWith('QL-RPC-')) {
                records.addAll(new List<Map<String, String>>{
                        new Map<String, String>{
                                'Id' => 'RPC-2', 'ChargeNumber' => 'RPC-2', 'IsLastSegment' => 'true',
                                'EffectiveEndDate' => !testReturnCancelledSubscriptionObject ? String.valueOf(Date.today().addYears(1)) : String.valueOf(Date.today().addDays(-1)),
                                'EffectiveStartDate' => String.valueOf(Date.today()),
                                'RatePlanId' => 'RP-1', 'Record_Id__c' => this.testMetroclientProductGeographyId
                        }
                });
            } else if (queryMoreActionRequest.queryLocator.startsWith('QL-RP-')) {
                records.addAll(new List<Map<String, String>>{
                        new Map<String, String>{
                                'Id' => 'RP-2', 'SubscriptionId' => 'S-1'
                        }
                });
            } else if (queryMoreActionRequest.queryLocator.startsWith('QL-AM-')) {
                records.addAll(new List<Map<String, String>>{
                        new Map<String, String>{
                                'Id' => 'AM-2', 'SubscriptionId' => 'S-1',
                                'EffectiveDate' => String.valueOf(Date.today()),
                                'Type' => 'RemoveProduct'
                        }
                });
            }
            response = buildQueryResponse(request, records, null);
        } else if (request.getMethod().equalsIgnoreCase('POST') && endpoint == FC_ZuoraClient.getPrefixedPath(FC_ZuoraClient.SUBSCRIBE_ACTION_PATH)) {
            response = buildSubscribeResponse(request);
        } else if (endpoint.startsWith(FC_ZuoraClient.getPrefixedPath(FC_ZuoraClient.UPDATE_SUBSCRIPTION_PATH_TEMPLATE).replace('{0}', ''))) {
            response = buildUpdateSubscriptionResponse(request);
        }
        return response;
    }

    public HttpResponse buildCancelSubscriptionResponse(HttpRequest hRequest) {

        String[] pathParts = hRequest.getEndpoint().split('/');
        String subscriptionKey = pathParts[pathParts.size() - 2];

        String fixedJsonRequestBody = hRequest.getBody().replace('__QT', '_q').replace('collect', 'collect_x');

        FC_ZuoraClient.CancelSubscriptionRequest request = (FC_ZuoraClient.CancelSubscriptionRequest)
                JSON.deserialize(fixedJsonRequestBody, FC_ZuoraClient.CancelSubscriptionRequest.class);

        FC_ZuoraClient.CancelSubscriptionResponse response = new FC_ZuoraClient.CancelSubscriptionResponse();
        response.subscriptionId = subscriptionKey;
        if (!this.testError && !this.testCancelSubscriptionError) {
            response.success = true;
        } else {
            response.success = false;
            FC_ZuoraClient.ZuoraError error = new FC_ZuoraClient.ZuoraError();
            error.message = 'TEST ERROR';
            error.code = '1';
            response.reasons = new FC_ZuoraClient.ZuoraError[]{
                    error
            };
        }

        HttpResponse hResponse = new HttpResponse();
        hResponse.setStatusCode(200);
        hResponse.setStatus('OK');
        hResponse.setHeader('Content-Type', 'application/json');
        hResponse.setBody(JSON.serialize(response, true));

        return hResponse;
    }

    public HttpResponse buildGetAmendmentResponse(HttpRequest hRequest) {

        String[] pathParts = hRequest.getEndpoint().split('/');
        String subscriptionId = pathParts[pathParts.size() - 1];

        FC_ZuoraClient.GetAmendmentResponse response = new FC_ZuoraClient.GetAmendmentResponse();
        response.id = 'A-' + subscriptionId;
        HttpResponse hResponse = new HttpResponse();
        if (!this.testError) {
            response.success = true;
            hResponse.setStatusCode(200);
            hResponse.setStatus('OK');
        } else {
            response.success = false;
            hResponse.setStatusCode(404);
            hResponse.setStatus('NOT FOUND');
        }

        hResponse.setHeader('Content-Type', 'application/json');
        hResponse.setBody(JSON.serialize(response, true));

        return hResponse;
    }

    public HttpResponse buildGetSubscriptionByKeyResponse(HttpRequest hRequest) {

        String[] pathParts = hRequest.getEndpoint().split('/');
        String subscriptionKey = pathParts[pathParts.size() - 1];

        FC_ZuoraClient.GetSubscriptionResponse response = new FC_ZuoraClient.GetSubscriptionResponse();
        response.id = subscriptionKey;
        HttpResponse hResponse = new HttpResponse();
        if (!this.testError) {
            response.success = true;
            response.ratePlans = new List<FC_ZuoraClient.GetSubscriptionResponseRatePlan>();

            FC_ZuoraClient.GetSubscriptionResponseRatePlan ratePlan = new FC_ZuoraClient.GetSubscriptionResponseRatePlan();
            ratePlan.productId = 'P-1';
            ratePlan.productName = 'Test Product';
            ratePlan.productSku = 'P-1';
            ratePlan.productRatePlanId = 'PRP-1';
            ratePlan.ratePlanName = 'Test Rate Plan';
            ratePlan.ratePlanCharges = new List<FC_ZuoraClient.GetSubscriptionResponseRatePlanCharge>();

            for (Integer i = 0; i < 4; i++) {
                FC_ZuoraClient.GetSubscriptionResponseRatePlanCharge ratePlanCharge = new FC_ZuoraClient.GetSubscriptionResponseRatePlanCharge();
                ratePlanCharge.productRatePlanChargeId = 'PRPC-1';
                ratePlanCharge.number_x = 'C-' + (i + 1);
                ratePlanCharge.name = 'Test Rate Plan Charge ' + (i + 1);
                ratePlanCharge.type = (Math.mod(i, 2) == 0) ? 'Recurring' : 'OneTime';
                if (this.testBillingInstructionSetId != null) {
                    ratePlanCharge.BillingInstructionSetId_c = this.testBillingInstructionSetId;
                }
                if (this.testMetroclientProductGeographyId != null) {
                    ratePlanCharge.Record_Id_c = this.testMetroclientProductGeographyId;
                }
                ratePlanCharge.effectiveStartDate = Date.today();
                ratePlanCharge.effectiveEndDate = Date.today() + 120;
                ratePlan.ratePlanCharges.add(ratePlanCharge);
            }

            response.ratePlans.add(ratePlan);

            hResponse.setStatusCode(200);
            hResponse.setStatus('OK');
        } else {
            response.success = false;
            hResponse.setStatusCode(404);
            hResponse.setStatus('NOT FOUND');
        }

        hResponse.setHeader('Content-Type', 'application/json');
        hResponse.setBody(JSON.serialize(response, true));

        return hResponse;
    }

    public HttpResponse buildGetSubscriptionObjectResponse(HttpRequest hRequest) {

        String[] pathParts = hRequest.getEndpoint().split('/');
        String subscriptionKey = pathParts[pathParts.size() - 1];

        FC_ZuoraClient.Subscription response = new FC_ZuoraClient.Subscription();
        response.Id = subscriptionKey;
        response.Version = 1;
        response.Name = subscriptionKey;
        response.SubscriptionEndDate = Date.today() + 120;
        if (this.testReturnCancelledSubscriptionObject) {
            response.Status = 'Cancelled';
            response.CancelledDate = Date.today();
        } else {
            response.Status = 'Active';
        }
        HttpResponse hResponse = new HttpResponse();
        if (!this.testError) {
            hResponse.setStatusCode(200);
            hResponse.setStatus('OK');
        } else {
            hResponse.setStatusCode(404);
            hResponse.setStatus('NOT FOUND');
        }

        hResponse.setHeader('Content-Type', 'application/json');
        hResponse.setBody(JSON.serialize(response, true));

        return hResponse;
    }

    public HttpResponse buildQueryResponse(HttpRequest hRequest, List<Map<String, String>> records, String queryLocator) {

        HttpResponse hResponse = new HttpResponse();

        String responseJson = '';
        FC_ZuoraClient.QueryActionResponse response = new FC_ZuoraClient.QueryActionResponse();
        if (!this.testError) {
            hResponse.setStatusCode(200);
            hResponse.setStatus('OK');

            response.records = records;
            response.size = response.records.size();
            response.done = String.isBlank(queryLocator);
            response.queryLocator = queryLocator;
        } else {
            hResponse.setStatusCode(500);
            hResponse.setStatus('TEST ERROR');

            response.faultcode = 'TEST_ERROR';
            response.faultstring = 'TEST ERROR';
        }

        responseJson = JSON.serialize(response);

        hResponse.setHeader('Content-Type', 'application/json');
        hResponse.setBody(responseJson);

        return hResponse;
    }

    public HttpResponse buildRenewSubscriptionResponse(HttpRequest hRequest) {

        String[] pathParts = hRequest.getEndpoint().split('/');
        String subscriptionKey = pathParts[pathParts.size() - 2];

        String fixedJsonRequestBody = hRequest.getBody().replace('__QT', '_q').replace('collect', 'collect_x');

        FC_ZuoraClient.RenewSubscriptionRequest request = (FC_ZuoraClient.RenewSubscriptionRequest)
                JSON.deserialize(fixedJsonRequestBody, FC_ZuoraClient.RenewSubscriptionRequest.class);

        FC_ZuoraClient.RenewSubscriptionResponse response = new FC_ZuoraClient.RenewSubscriptionResponse();
        response.subscriptionId = subscriptionKey;
        if (!this.testError && !this.testRenewSubscriptionError) {
            response.success = true;
            response.subscriptionId = subscriptionKey;
        } else {
            response.success = false;
            FC_ZuoraClient.ZuoraError error = new FC_ZuoraClient.ZuoraError();
            error.message = 'TEST ERROR';
            error.code = '1';
            response.reasons = new FC_ZuoraClient.ZuoraError[]{
                    error
            };
        }

        HttpResponse hResponse = new HttpResponse();
        hResponse.setStatusCode(200);
        hResponse.setStatus('OK');
        hResponse.setHeader('Content-Type', 'application/json');
        hResponse.setBody(JSON.serialize(response, true));

        return hResponse;
    }

    public HttpResponse buildSubscribeResponse(HttpRequest hRequest) {

        HttpResponse hResponse = new HttpResponse();

        String responseJson = '';
        if (!this.testError && !this.testSubscribeKnownError && !this.testSubscribeUnknownError) {
            FC_ZuoraClient.SubscribeActionResponse[] response = new List<FC_ZuoraClient.SubscribeActionResponse>();
            hResponse.setStatusCode(200);
            hResponse.setStatus('OK');

            FC_ZuoraClient.SubscribeResult result = new FC_ZuoraClient.SubscribeResult();
            result.SubscriptionId = 'S-1';
            result.SubscriptionNumber = 'S-1';
            result.Success = true;
            response.add(result);
            responseJson = JSON.serialize(response, true);
        } else if (this.testError || this.testSubscribeKnownError) {
            hResponse.setStatusCode(400);
            hResponse.setStatus('BAD REQUEST');

            FC_ZuoraClient.SubscribeError response = new FC_ZuoraClient.SubscribeError();
            response.Success = false;
            FC_ZuoraClient.ZuoraError error = new FC_ZuoraClient.ZuoraError();
            error.message = 'TEST ERROR';
            error.code = '1';
            response.Errors = new FC_ZuoraClient.ZuoraError[]{
                    error
            };
            responseJson = JSON.serialize(response, true);
        } else if (this.testSubscribeUnknownError) {
            hResponse.setStatusCode(500);

            FC_ZuoraClient.SubscribeError response = new FC_ZuoraClient.SubscribeError();
            response.Success = false;
            FC_ZuoraClient.ZuoraError error = new FC_ZuoraClient.ZuoraError();
            error.message = 'TEST ERROR';
            error.code = '1';
            response.Errors = new FC_ZuoraClient.ZuoraError[]{
                    error
            };
            responseJson = JSON.serialize(response, true);
        }

        hResponse.setHeader('Content-Type', 'application/json');
        hResponse.setBody(responseJson);

        return hResponse;

    }

    public HttpResponse buildUpdateSubscriptionResponse(HttpRequest hRequest) {
        String[] pathParts = hRequest.getEndpoint().split('/');
        String subscriptionKey = pathParts[pathParts.size() - 1];

        String fixedJsonRequestBody = hRequest.getBody().replace('__c', '_z').replace('__QT', '_q').replace('collect', 'collect_x');

        FC_ZuoraClient.UpdateSubscriptionRequest request = (FC_ZuoraClient.UpdateSubscriptionRequest)
                JSON.deserialize(fixedJsonRequestBody, FC_ZuoraClient.UpdateSubscriptionRequest.class);

        FC_ZuoraClient.UpdateSubscriptionResponse response = new FC_ZuoraClient.UpdateSubscriptionResponse();
        response.subscriptionId = subscriptionKey;
        if (!this.testError && !this.testUpdateSubscriptionError) {
            response.success = true;
        } else {
            response.success = false;
            FC_ZuoraClient.ZuoraError error = new FC_ZuoraClient.ZuoraError();
            error.message = 'TEST ERROR';
            error.code = '1';
            response.reasons = new FC_ZuoraClient.ZuoraError[]{
                    error
            };
        }

        HttpResponse hResponse = new HttpResponse();
        hResponse.setStatusCode(200);
        hResponse.setStatus('OK');
        hResponse.setHeader('Content-Type', 'application/json');
        hResponse.setBody(JSON.serialize(response, true));

        return hResponse;
    }

}