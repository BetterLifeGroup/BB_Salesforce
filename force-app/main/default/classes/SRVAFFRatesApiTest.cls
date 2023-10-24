@isTest
private class SRVAFFRatesApiTest {
    /**
     * get latest data versions
     *
     * get latest data versions
     */
    @isTest
//    private static void getGetdataversionTest() {
//        HttpResponse res = new HttpResponse();
//        res.setStatusCode(200);
//        res.setStatus('OK');
//        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));
//
//        SRVAFFClient client;
//        SRVAFFRatesApi api;
//        SRVAFFVersionVm response;
//        SRVAFFVersionVm expectedResponse;
//        String js = '';
//
//        client = new SRVAFFClient();
//        api = new SRVAFFRatesApi(client);
//        ((OAS.ApiKeyAuth)client.getAuthentication('apiKeyHeader')).setApiKey('foo-bar-api-key');
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//        client = new SRVAFFClient();
//        api = new SRVAFFRatesApi(client);
//        ((OAS.ApiKeyAuth)client.getAuthentication('apiKeyQuery')).setApiKey('foo-bar-api-key');
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;false');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json;odata.streaming&#x3D;true');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//
//
//        js = JSON.serialize(SRVAFFVersionVm.getExample());
//        res.setHeader('Content-Type', 'application/json');
//        res.setBody(js);
//        expectedResponse = SRVAFFVersionVm.getExample();
//        response = (SRVAFFVersionVm) api.getGetdataversion();
//        System.assertEquals(expectedResponse, response);
//    }
//
//    /**
//     * get latest interest rate
//     *
//     * get latest interest rate
//     */
//    @isTest
    private static void getGetinterestrateTest() {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));

        SRVAFFClient client;
        SRVAFFRatesApi api;
        Double response;
        Double expectedResponse;
        String js = '';

        client = new SRVAFFClient();
        api = new SRVAFFRatesApi(client);
        ((OAS.ApiKeyAuth)client.getAuthentication('apiKeyHeader')).setApiKey('foo-bar-api-key');

        api.getGetinterestrate();
        client = new SRVAFFClient();
        api = new SRVAFFRatesApi(client);
        ((OAS.ApiKeyAuth)client.getAuthentication('apiKeyQuery')).setApiKey('foo-bar-api-key');

        api.getGetinterestrate();
    }
}