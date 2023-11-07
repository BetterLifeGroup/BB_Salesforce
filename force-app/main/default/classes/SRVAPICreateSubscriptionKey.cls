/**
 * Modified by Oageng Mashele on 2023/10/17.
 */

public class SRVAPICreateSubscriptionKey {
    @InvocableMethod(Label='APIService create Subscription Key')

    public static List<ApiServiceCreateResponse> createSubscriptionKey(List<String> names) {
        List<ApiServiceCreateResponse> responseList = new List<ApiServiceCreateResponse>();
        Integration_Parameter__mdt integrationParam;
        String url;

        //is env prod?
        if(false){
            url = 'callout:NC_APIService/Subscriptions';
            integrationParam = Integration_Parameter__mdt.getInstance('Subscription_Key');
        }
        else{
            url = 'callout:NC_APIService_UAT/Subscriptions';
            integrationParam = Integration_Parameter__mdt.getInstance('Subscription_Key_UAT');
        }

        Better_Home.HttpRequestHelper httpBuilder = new Better_Home.HttpRequestHelper().setEndpoint(url)
                .post()
                .setHeader('Content-Type', 'application/json').setHeader(integrationParam.Parameter_Classifier__c, integrationParam.Parameter_Value__c)
                .setTimeout(10000);
//                .setBody(JSON.serialize(requestBody))
//                .execute();



        for (String name : names) {
            AddSubscriptionRequest requestBody = new AddSubscriptionRequest();
            requestBody.name = name;
//            HttpResponse request = RequestCall(requestBody);
            httpBuilder.setBody(JSON.serialize(requestBody))
                    .execute();

            Better_Home.BuilderUtils.commitRecords();
            Better_Home.HttpRequestHelper.generateJsonFiles(httpBuilder);

            ApiServiceCreateResponse response = new ApiServiceCreateResponse();
            response.name = name;
              response.statusCode = httpBuilder.getResponse().getStatusCode();

            if (httpBuilder.getResponse().getStatusCode() == 201 || httpBuilder.getResponse().getStatusCode() == 200) {
                JSONParser parser = JSON.createParser(httpBuilder.getResponse().getBody());
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        response = (ApiServiceCreateResponse) parser.readValueAs(ApiServiceCreateResponse.class);
                    }
                }
            }
            responseList.add(response);
        }
        return responseList;
    }
//
//    public static HttpResponse RequestCall(AddSubscriptionRequest requestBody) {
//
//        Integration_Parameter__mdt integrationParam;
//        String url;
//
//        //is env prod?
//        if(false){
//            url = 'callout:NC_APIService/Subscriptions';
//            integrationParam = Integration_Parameter__mdt.getInstance('Subscription_Key');
//        }
//        else{
//            url = 'callout:NC_APIService_UAT/Subscriptions';
//            integrationParam = Integration_Parameter__mdt.getInstance('Subscription_Key_UAT');
//        }
//
//        Better_Home.HttpRequestHelper httpBuilder = new Better_Home.HttpRequestHelper().setEndpoint(url)
//                .post()
//                .setHeader('Content-Type', 'application/json').setHeader(integrationParam.Parameter_Classifier__c, integrationParam.Parameter_Value__c)
//                .setTimeout(10000)
//                .setBody(JSON.serialize(requestBody))
//                .execute();
//
//        Better_Home.BuilderUtils.commitRecords();
//        Better_Home.HttpRequestHelper.generateJsonFiles(httpBuilder);
//
//        return httpBuilder.getResponse();
//    }

    public class AddSubscriptionRequest {
        @InvocableVariable
       public  String name;
    }

    public class ApiServiceCreateResponse {
        @InvocableVariable
        public String id;

        @InvocableVariable
        public String name;

        @InvocableVariable
        public String primaryKey;

        @InvocableVariable
        public Integer statusCode;
    }
}