/**
 * Modified by Oageng Mashele on 2023/10/17.
 */

@IsTest
public class SRVAPICreateSubscriptionKeyTest {
    private static String url;
    private static Integration_Parameter__mdt integrationParam;
    private static final String ADMIN_USER_EMAIL = 'admin@betterhome.co.za';



    @TestSetup
    static void setup(){
        new Better_Home.BuilderUser().generateTestAdminUser(SRVAPICreateSubscriptionKeyTest.ADMIN_USER_EMAIL);
        Better_Home.BuilderUtils.commitRecords();     //insert new user record
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {

        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.

            if(Better_Home.BuilderUtils.isProduction()){
                SRVAPICreateSubscriptionKeyTest.url = 'callout:NC_APIService/Subscriptions';
                SRVAPICreateSubscriptionKeyTest.integrationParam = Integration_Parameter__mdt.getInstance('Subscription_Key');
            }
            else{
                SRVAPICreateSubscriptionKeyTest.url = 'callout:NC_APIService_UAT/Subscriptions';
                SRVAPICreateSubscriptionKeyTest.integrationParam = Integration_Parameter__mdt.getInstance('Subscription_Key_UAT');
            }

            System.assert(url == req.getEndpoint());
            System.assertEquals('POST', req.getMethod());

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"objectId":"1","key":"test","id":"12321312","name":"hello","integrated":true,"userScoped":true,"jobId":1}');
            res.setStatus('SUCCESS');
            res.setStatusCode(200);
            return res;
        }
    }

//    @isTest
//    static void testRequestCall() {
//
//        Better_Home.BuilderUtils.setEnforceFLS(false);
//        Better_Home.BuilderUtils.setEnforceCRUD(false);
//
//        List<User> testUsers = new Better_Home.SelectorUser().getUsersByEmail(SRVAPICreateSubscriptionKeyTest.ADMIN_USER_EMAIL);
//        Assert.isTrue(testUsers.size()==1, 'expecting one User record');
//
//
//        // Set mock callout class
//        Better_Home.HttpRequestBuilderMock.registerMockClass(new MockHttpResponseGenerator());
//
//        // Call method to test.
//        // This causes a fake response to be sent
//        // from the class that implements HttpCalloutMock.
//        SRVAPICreateSubscriptionKey.AddSubscriptionRequest requestBody = new SRVAPICreateSubscriptionKey.AddSubscriptionRequest();
//        requestBody.name = 'test';
//        Test.startTest();
//
//        Better_Home.HttpRequestHelper httpBuilder = new Better_Home.HttpRequestHelper().setEndpoint(url)
//                .post()
//               .setHeader('Content-Type', 'application/json').setHeader(integrationParam.Parameter_Classifier__c, integrationParam.Parameter_Value__c)
//                .setTimeout(10000)
//                .setBody(JSON.serialize(requestBody))
//                .execute();
//
//        Better_Home.BuilderUtils.commitRecords();
//        Better_Home.HttpRequestHelper.generateJsonFiles(httpBuilder);
//
//        HttpResponse res = httpBuilder.getResponse();
//
//        // Verify response received contains fake values
//        String contentType = res.getHeader('Content-Type');
//        System.assert(contentType == 'application/json');
//        String actualValue = res.getBody();
//        String expectedValue = '{"objectId":"1","key":"test","id":"12321312","name":"hello","integrated":true,"userScoped":true,"jobId":1}';
//        System.assertEquals(actualValue, expectedValue);
//        System.assertEquals(200, res.getStatusCode());
//        Test.stopTest();
//}

    @isTest
    static void testCreateSubscriptionKey() {
        // Set mock callout class
        Better_Home.BuilderUtils.setEnforceFLS(false);
        Better_Home.BuilderUtils.setEnforceCRUD(false);

        List<User> testUsers = new Better_Home.SelectorUser().getUsersByEmail(SRVAPICreateSubscriptionKeyTest.ADMIN_USER_EMAIL);
        Assert.isTrue(testUsers.size()==1, 'expecting one User record');


        // Set mock callout class
        Better_Home.HttpRequestBuilderMock.registerMockClass(new MockHttpResponseGenerator());

        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        String[] names = new List<String>{'new name','another new name'};

        Test.startTest();
        List<SRVAPICreateSubscriptionKey.ApiServiceCreateResponse> results = SRVAPICreateSubscriptionKey.createSubscriptionKey(names);
        Assert.isTrue(results.size() > 0);
        for(SRVAPICreateSubscriptionKey.ApiServiceCreateResponse res : results) {
            System.assert(res.id == '12321312');
            System.assert(res.name == 'hello');
            System.assert(res.id != null);
            System.assert(res.name != null);
        }
        Test.stopTest();
    }
}