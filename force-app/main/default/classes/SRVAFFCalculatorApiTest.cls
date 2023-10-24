@isTest
private class SRVAFFCalculatorApiTest {
    /**
     * Calculate affordabilities
     *
     * Calculate affordabilities
     */
//    @isTest
//    private static void postCalculateaffordabilitiesTest() {
//        HttpResponse res = new HttpResponse();
//        res.setStatusCode(200);
//        res.setStatus('OK');
//        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));
//
//        Map<String, Object> params = new Map<String, Object>{
//            'srVAFFAffordabilityRequestModel' => '[{"grossMonthlyIncome":0,"netMonthlyIncome":0,"totalMonthlyExpenses":0,"interestRate":0,"repaymentTermInYears":0,"email":"string","fromEmail":"string","bodyMessage":"string","templateType":"string","existingBondRepayments":0,"calculatorType":"string","roundData":true,"platform":"string"}]'
//        };
//
//        SRVAFFClient client;
//        SRVAFFCalculatorApi api;
//        List<SRVAFFAffordabilityResultVm> response;
//        List<SRVAFFAffordabilityResultVm> expectedResponse;
//        String js = '';
//
//        client = new SRVAFFClient();
//        api = new SRVAFFCalculatorApi(client);
//        ((OAS.ApiKeyAuth)client.getAuthentication('apiKeyHeader')).setApiKey('foo-bar-api-key');
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//        client = new SRVAFFClient();
//        api = new SRVAFFCalculatorApi(client);
//        ((OAS.ApiKeyAuth)client.getAuthentication('apiKeyQuery')).setApiKey('foo-bar-api-key');
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFAffordabilityResultVm>{SRVAFFAffordabilityResultVm.getExample()};
//        response = (List<SRVAFFAffordabilityResultVm>) api.postCalculateaffordabilities(params);
//        System.assertEquals(expectedResponse, response);
//    }
//
    /**
     * Calculate affordability
     *
     * Calculate affordability
     */

    @isTest
    private static void postCalculateaffordabilityTest() {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        res.setBody(JSON.serialize(SRVAFFAffordabilityRequestModel.getExample()));
        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));

        SRVAFFAffordabilityRequestModel req = new SRVAFFAffordabilityRequestModel();

        req.grossMonthlyIncome = 70000;
        req.netMonthlyIncome = 55000;
        req.roundData = true;
        req.interestRate = 10;
        req.repaymentTermInYears = 20;
        req.totalMonthlyExpenses = 23000;
        req.existingBondRepayments = 0;

        Map<String, Object> params = new Map<String, Object>{
            'SRVAFFAffordabilityRequestModel' => req
        };

        SRVAFFClient client;
        SRVAFFCalculatorApi api;
        SRVAFFAffordabilityResultVm response;
        SRVAFFAffordabilityResultVm expectedResponse;
        String js = '';

        client = new SRVAFFClient();
        api = new SRVAFFCalculatorApi(client);
        ((OAS.ApiKeyAuth)client.getAuthentication('apiKeyHeader')).setApiKey('foo-bar-api-key');


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        System.debug(api.postCalculateaffordability(params));
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;false');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;true');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;false');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;true');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;false');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;true');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;false');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;true');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);
        client = new SRVAFFClient();
        api = new SRVAFFCalculatorApi(client);
        ((OAS.ApiKeyAuth)client.getAuthentication('apiKeyQuery')).setApiKey('foo-bar-api-key');


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;false');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;true');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;false');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;true');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;false');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;true');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;false');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;true');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);


        js = JSON.serialize(SRVAFFAffordabilityResultVm.getExample());
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        expectedResponse = SRVAFFAffordabilityResultVm.getExample();
        response = (SRVAFFAffordabilityResultVm) api.postCalculateaffordability(params);
        System.assertEquals(expectedResponse, response);
    }
//
//    /**
//     * Calculate bond and transfer costs
//     *
//     * Calculate bond and transfer costs
//     */
//    @isTest
//    private static void postCalculatebondtransferTest() {
//        HttpResponse res = new HttpResponse();
//        res.setStatusCode(200);
//        res.setStatus('OK');
//        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));
//
//        Map<String, Object> params = new Map<String, Object>{
//            'srVAFFRepaymentRequestModel' => '{"purchasePrice":0,"depositAmount":0,"homeLoanAmount":0,"interestRate":0,"repaymentTermInYears":0,"additionalPaymentPerMonth":0,"email":"string","fromEmail":"string","bodyMessage":"string","templateType":"string","calculatorType":"string","roundData":true,"platform":"string"}'
//        };
//
//        SRVAFFClient client;
//        SRVAFFCalculatorApi api;
//        SRVAFFBondAndTransferCostsResultVm response;
//        SRVAFFBondAndTransferCostsResultVm expectedResponse;
//        String js = '';
//
//        client = new SRVAFFClient();
//        api = new SRVAFFCalculatorApi(client);
//        ((OAS.ApiKeyAuth)client.getAuthentication('apiKeyHeader')).setApiKey('foo-bar-api-key');
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//        client = new SRVAFFClient();
//        api = new SRVAFFCalculatorApi(client);
//        ((OAS.ApiKeyAuth)client.getAuthentication('apiKeyQuery')).setApiKey('foo-bar-api-key');
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFBondAndTransferCostsResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = SRVAFFBondAndTransferCostsResultVm.getExample();
//        response = (SRVAFFBondAndTransferCostsResultVm) api.postCalculatebondtransfer(params);
//        System.assertEquals(expectedResponse, response);
//    }
//
//    /**
//     * Calculate Loan to value
//     *
//     * Calculate Loan to value
//     */
//    @isTest
//    private static void postCalculateltvTest() {
//        HttpResponse res = new HttpResponse();
//        res.setStatusCode(200);
//        res.setStatus('OK');
//        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));
//
//        Map<String, Object> params = new Map<String, Object>{
//            'srVAFFLtvRequestModel' => '{"requestedDate":"string","fullName":"string","dateOfBirth":"string","income":0,"isJointIncome":true,"purchasePrice":0,"purposeOfLoan":1,"residentialStatus":1,"applicationType":1,"shareholdingType":1,"bankDetails":[{"isPrivateClient":true,"isClient":true,"bank":1}],"email":"string","fromEmail":"string","bodyMessage":"string","templateType":"string","roundData":true}'
//        };
//
//        SRVAFFClient client;
//        SRVAFFCalculatorApi api;
//        SRVAFFLtvResultVm response;
//        SRVAFFLtvResultVm expectedResponse;
//        String js = '';
//
//        client = new SRVAFFClient();
//        api = new SRVAFFCalculatorApi(client);
//        ((OAS.ApiKeyAuth)client.getAuthentication('apiKeyHeader')).setApiKey('foo-bar-api-key');
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//        client = new SRVAFFClient();
//        api = new SRVAFFCalculatorApi(client);
//        ((OAS.ApiKeyAuth)client.getAuthentication('apiKeyQuery')).setApiKey('foo-bar-api-key');
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLtvResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = SRVAFFLtvResultVm.getExample();
//        response = (SRVAFFLtvResultVm) api.postCalculateltv(params);
//        System.assertEquals(expectedResponse, response);
//    }
//
//    /**
//     * Calculate Repayment
//     *
//     * Calculate Repayment
//     */
//    @isTest
//    private static void postCalculaterepaymentTest() {
//        HttpResponse res = new HttpResponse();
//        res.setStatusCode(200);
//        res.setStatus('OK');
//        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));
//
//        Map<String, Object> params = new Map<String, Object>{
//            'srVAFFRepaymentRequestModel' => '{"purchasePrice":0,"depositAmount":0,"homeLoanAmount":0,"interestRate":0,"repaymentTermInYears":0,"additionalPaymentPerMonth":0,"email":"string","fromEmail":"string","bodyMessage":"string","templateType":"string","calculatorType":"string","roundData":true,"platform":"string"}'
//        };
//
//        SRVAFFClient client;
//        SRVAFFCalculatorApi api;
//        SRVAFFRepaymentResultVm response;
//        SRVAFFRepaymentResultVm expectedResponse;
//        String js = '';
//
//        client = new SRVAFFClient();
//        api = new SRVAFFCalculatorApi(client);
//        ((OAS.ApiKeyAuth)client.getAuthentication('apiKeyHeader')).setApiKey('foo-bar-api-key');
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//        client = new SRVAFFClient();
//        api = new SRVAFFCalculatorApi(client);
//        ((OAS.ApiKeyAuth)client.getAuthentication('apiKeyQuery')).setApiKey('foo-bar-api-key');
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFRepaymentResultVm.getExample());
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = SRVAFFRepaymentResultVm.getExample();
//        response = (SRVAFFRepaymentResultVm) api.postCalculaterepayment(params);
//        System.assertEquals(expectedResponse, response);
//    }
//
//    /**
//     * Calculate repayments
//     *
//     * Calculate repayments
//     */
//    @isTest
//    private static void postCalculaterepaymentsTest() {
//        HttpResponse res = new HttpResponse();
//        res.setStatusCode(200);
//        res.setStatus('OK');
//        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));
//
//        Map<String, Object> params = new Map<String, Object>{
//            'srVAFFRepaymentRequestModel' => '[{"purchasePrice":0,"depositAmount":0,"homeLoanAmount":0,"interestRate":0,"repaymentTermInYears":0,"additionalPaymentPerMonth":0,"email":"string","fromEmail":"string","bodyMessage":"string","templateType":"string","calculatorType":"string","roundData":true,"platform":"string"}]'
//        };
//
//        SRVAFFClient client;
//        SRVAFFCalculatorApi api;
//        List<SRVAFFRepaymentResultVm> response;
//        List<SRVAFFRepaymentResultVm> expectedResponse;
//        String js = '';
//
//        client = new SRVAFFClient();
//        api = new SRVAFFCalculatorApi(client);
//        ((OAS.ApiKeyAuth)client.getAuthentication('apiKeyHeader')).setApiKey('foo-bar-api-key');
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//        client = new SRVAFFClient();
//        api = new SRVAFFCalculatorApi(client);
//        ((OAS.ApiKeyAuth)client.getAuthentication('apiKeyQuery')).setApiKey('foo-bar-api-key');
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()});
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = new List<SRVAFFRepaymentResultVm>{SRVAFFRepaymentResultVm.getExample()};
//        response = (List<SRVAFFRepaymentResultVm>) api.postCalculaterepayments(params);
//        System.assertEquals(expectedResponse, response);
//    }
//
//    /**
//     * Get latest loan to value
//     *
//     * Get latest loan to value
//     */
//    @isTest
//    private static void postGetlatestltvTest() {
//        HttpResponse res = new HttpResponse();
//        res.setStatusCode(200);
//        res.setStatus('OK');
//        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));
//
//        SRVAFFClient client;
//        SRVAFFCalculatorApi api;
//        SRVAFFLoanToValueVm response;
//        SRVAFFLoanToValueVm expectedResponse;
//        String js = '';
//
//        client = new SRVAFFClient();
//        api = new SRVAFFCalculatorApi(client);
//        ((OAS.ApiKeyAuth)client.getAuthentication('apiKeyHeader')).setApiKey('foo-bar-api-key');
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//        client = new SRVAFFClient();
//        api = new SRVAFFCalculatorApi(client);
//        ((OAS.ApiKeyAuth)client.getAuthentication('apiKeyQuery')).setApiKey('foo-bar-api-key');
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFLoanToValueVm.getExample());
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = SRVAFFLoanToValueVm.getExample();
//        response = (SRVAFFLoanToValueVm) api.postGetlatestltv();
//        System.assertEquals(expectedResponse, response);
//    }
}