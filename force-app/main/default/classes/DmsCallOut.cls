/**
 * Created by frans fourie on 2023/05/29.
 */

public without sharing class DmsCallOut {

    @InvocableMethod
    public static List<String> GenerateDmsNumber(List<DmsRequest> reqList) {

        try {
            Integration_Parameter__mdt integrationParam = Integration_Parameter__mdt.getInstance('DMS_Subscription_Key');
            Http http = new Http ();

            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:NC_DealMaker/DealMaker/CreateBasicApplication');
            req.setMethod('POST');
//            req.setHeader('Authorization', 'Bearer ' + GetAuth());
            req.setHeader('Content-Type', 'application/json');
            req.setHeader(integrationParam.Parameter_Classifier__c, integrationParam.Parameter_Value__c);
            req.setBody('{"consultantEntityId":"' + reqList[0].consultantEntityId + '","loanType":"' + reqList[0].loanType + '"}');
            req.setHeader('Content-Length', String.valueOf(req.getBody().length()));

            HttpResponse resp = http.send(req);
            System.debug(resp.getBody());

            List<String> response = new List<String>{
                    resp.getBody()
            };
            return response;
        } catch (Exception e) {
            System.debug(e);
            return new List<String>{
                    e.getMessage()
            };
        }

    }


    public class DmsRequest {
        @InvocableVariable public String consultantEntityId;
        @InvocableVariable public String loanType;
    }

}