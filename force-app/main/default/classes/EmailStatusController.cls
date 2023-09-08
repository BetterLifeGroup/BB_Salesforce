/**
 * Created by frans fourie on 2023/04/03.
 */

public with sharing class EmailStatusController {

    @AuraEnabled
    public static List<ReturnBody> getEmailData(String opportunityId) {
        System.debug(opportunityId);

        Opportunity currentOp = [SELECT Id, RecordType.Name, PreApprovalOpportunity__c, General_Opportunity__c FROM Opportunity WHERE Id = :opportunityId];
        String relatedOpp;
        if (!test.isRunningTest()) {
            if (currentOp.RecordType.Name == 'General Opportunity' && currentOp.PreApprovalOpportunity__c != null) {
                relatedOpp = currentOp.PreApprovalOpportunity__c;
            } else {
                relatedOpp = currentOp.General_Opportunity__c;
            }
        } else {
            relatedOpp = [SELECT Id FROM Opportunity WHERE Name = 'test70' LIMIT 1].Id;
        }
//        opportunityId = [SELECT Id FROM Opportunity WHERE PreApprovalOpportunity__c = :opportunityId LIMIT 1].Id;
//
//        System.debug(opportunityId);
        Marketing_Cloud_Email_Integration__mdt integrationDetails = Marketing_Cloud_Email_Integration__mdt.getInstance('Marketing_Cloud_Credentials');

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();

        BearerResponse bearer = getBearer();

        System.debug(bearer.access_token);
        System.debug(bearer.rest_instance_url);

        req.setMethod('GET');
        req.setEndpoint(bearer.rest_instance_url + '/data/v1/customobjectdata/key/' + integrationDetails.externalKey__c + '/rowset?$page=1&$filter=oppid%20eq%20\'' + currentOp.Id + '\'%20or%20oppid%20eq%20\'' + relatedOpp + '\'&$pageSize=50000');
//        req.setEndpoint(bearer.rest_instance_url + '/data/v1/customobjectdata/key/' + integrationDetails.externalKey__c + '/rowset?$page=1&$pageSize=12');
        req.setHeader('Authorization', 'Bearer ' + bearer.access_token);
        if (!Test.isRunningTest()) {
            resp = http.send(req);
        } else {
            resp.setBody('{"links":{"self":"/v1/customobjectdata/token/bc4f0a77-41dc-40a3-80f0-729bce3d3546/rowset?$page=1"},"requestToken":"bc4f0a77-41dc-40a3-80f0-729bce3d3546","tokenExpireDateUtc":"2023-04-07T14:24:56.77","customObjectId":"201b706a-50b3-ed11-ba45-f40343e7f760","customObjectKey":"B08B0B22-6174-414A-92D7-6D12FEE4CC4B","pageSize":2500,"page":1,"count":2,"top":0,"items":[{"keys":{},"values":{"contactid":"0033M00001I96CSQAZ","sent":"1","open":"","bounce":"","bouncereason":"","sentdate":"4/6/2023 12:56:22 AM","opendate":"","click":"","bouncedate":"","commsname":"BB_Offline_Lead to OTP Comms_PA_Email_BBFHBCA-E06 - PA requested, awaiting docs follow-up","oppid":"0063M0000087mq4QAA","applicantid":"","jobid":"188791","accountid":"0013M00001MWJmDQAX","emailaddress":""}},{"keys":{},"values":{"contactid":"0033M00001I96CSQAZ","sent":"1","open":"","bounce":"","bouncereason":"","sentdate":"4/6/2023 12:57:40 AM","opendate":"","click":"","bouncedate":"","commsname":"BB_Offline_Lead to OTP Comms_PA_Email_BBFHB-E04a - Credit Check Positive - requesting docs for PA","oppid":"0063M0000087mq4QAA","applicantid":"","jobid":"181553","accountid":"0013M00001MWJmDQAX","emailaddress":""}}]}');
        }
        System.debug(resp.getBody());
        ResponseBody responseBody = (ResponseBody) JSON.deserialize(resp.getBody(), ResponseBody.class);

        List<String> accountIds = new List<String>();


        for (Items it : responseBody.items) {
            accountIds.add(it.values.accountid);
        }

        Map<String, Account> applicantsList = new Map<String, Account>();
        Map<String, List<Values>> applicants = new Map<String, List<Values>>();
        List<Account> accounts = new List<Account>();
        try {
            if (!Test.isRunningTest()) {
                accounts = [SELECT Id, Name FROM Account WHERE Id IN :accountIds];
            } else {
                Account acc = new Account(Name = 'test71', Id = '0013M00001MWJmDQAX');
                accounts = new List<Account>{
                        acc
                };

            }
            System.debug(accounts);

            for (Account acc : accounts) {
                applicantsList.put(acc.Id, acc);
            }
            for (Items item : responseBody.items) {
                item.values.applicantid = applicantsList.get(item.values.accountid).Name;
            }

            for (Items item : responseBody.items) {
                if (!applicants.containsKey(item.values.applicantid)) {
                    List<Values> valList = new List<Values>{
                            item.values
                    };
                    applicants.put(item.values.applicantid, valList);
                } else {
                    List<Values> valList = new List<Values>();
                    valList.addAll(applicants.get(item.values.applicantid));
                    valList.add(item.values);
                    applicants.put(item.values.applicantid, valList);
                }
            }
            List<ReturnBody> respB = new List<ReturnBody>();
            for (String mapKey : applicants.keySet()) {
                ReturnBody rb = new ReturnBody();
                rb.applicantName = mapKey;
                rb.values = applicants.get(mapKey);
                for (Values val : rb.values) {
                    if (val.open == '') {
                        val.open = '0';
                    }
                    if (val.click == '') {
                        val.click = '0';
                    }
                }
                respB.add(rb);
            }
            System.debug(responseBody);
            return respB;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return new List<ReturnBody>();
        }
    }

    @AuraEnabled
    public static List<ReturnBody> getEmailDataNew(String opportunityId) {
        System.debug(opportunityId);

        Opportunity opp = [SELECT Id, RecordType.Name, AccountId FROM Opportunity WHERE Id = :opportunityId LIMIT 1];

        RequestBody reqBody = new RequestBody();
        reqBody.OppId = opportunityId;
        reqBody.OppRecordTypeName = opp.RecordType.Name;

        if (opp.RecordType.Name == 'General Opportunity') {
            reqBody.AccId = new List<String>{
                    opp.AccountId
            };
        } else {

            List<LoanApplicant> laList = [SELECT Id, Contact.AccountId, Contact.Account.Name FROM LoanApplicant WHERE LoanApplicationId = : [SELECT Id from ResidentialLoanApplication where OpportunityId = :opportunityId]];

            reqBody.AccId = new List<String>();
            for (LoanApplicant app : laList) {
                System.debug(app.Contact.Account.Name);
                reqBody.AccId.add(app.Contact.AccountId);
            }
        }

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://cloud.mail.betterbond.co.za/sendlog');
        req.setMethod('GET');
        req.setBody(JSON.serialize(reqBody));
//        req.setBody('{"AccId":["0018d00000ZDWRHAA5"],"OppId":"0068d00000FPm3pAAD"}');

        HttpResponse resp = new HttpResponse();

        if (!Test.isRunningTest()) {
            resp = http.send(req);
        } else {
            resp.setBody('[{"contactid":"0038d00000Wlo1wAAB","sent":"1","open":"1","bounce":"","bouncereason":"","sentdate":"2023-05-03T15:00:42.000","opendate":"2023-05-03T23:00:26.000","click":"","commsname":"BB_Offline_Lead to OTP Comms_PA_Email_BBPA-E06 - PA issued, awaiting OTP, attached PA cert","oppid":"0068d00000FPm3pAAD","jobid":"207441","accountid":"0018d00000ZDWRHAA5","emailaddress":"steven@vwbelectrical.co.za","emaildes":"PA issued - awaiting OTP (attach PA certificate)","vawpurl":"https://view.mail.betterbond.co.za/?qs=d58cacc09291bcd476e58ad4c3790b4409c394556dd5de6215fcfae14607fded34456465a8a4303f53fec09be749942c282935dfa0617017527a66c83c7af810"},\n' +
                    '{"contactid":"0038d00000Wlo1wAAB","sent":"1","open":"1","bounce":"","bouncereason":"","sentdate":"2023-05-25T15:08:46.000","opendate":"2023-05-25T23:28:53.000","click":"","commsname":"BB_Offline_Lead to OTP Comms_PA_Email_BBFHB-E05 - PA issued - sending PA Cert - awaiting OTP","oppid":"0068d00000FPm3pAAD","jobid":"207449","accountid":"0018d00000ZDWRHAA5","emailaddress":"steven@vwbelectrical.co.za","emaildes":"FHB PA issued - awaiting OTP (attach PA certificate)","vawpurl":"https://view.mail.betterbond.co.za/?qs=6f87bdf61097f8af5fa6f77c2b4e95d0bb7f640284b4ce6add0bd46771ae552c64c1f13b86f11d5990547c6960966ede23e14682eb730eea"}]');
        }
        System.debug(resp.getBody());
//        ResponseBody responseBody = (ResponseBody) JSON.deserialize(resp.getBody(), ResponseBody.class);
        List<EmailStatusController.Values> responseValues = new List<EmailStatusController.Values>();
        try {
            responseValues = (List<EmailStatusController.Values>) JSON.deserialize(resp.getBody(), List<EmailStatusController.Values>.class);
        } catch (Exception e) {
            return new List<ReturnBody>();
        }

        ResponseBody responseBody = new ResponseBody();
        System.debug(responseValues);

        Set<String> accountIds = new Set<String>();


        for (Values it : responseValues) {
            accountIds.add(it.accountid);
        }

        System.debug(accountIds);


        Map<String, Account> applicantsList = new Map<String, Account>();
        Map<String, List<Values>> applicants = new Map<String, List<Values>>();
        List<Account> accounts = new List<Account>();
        try {
            if (!Test.isRunningTest()) {
                accounts = [SELECT Id, Name FROM Account WHERE Id IN :accountIds];
//                Account acc = new Account(Name = 'test71', Id = '0018d00000ZDWRHAA5'); // TODO - Commented for PROD
//                accounts = new List<Account>{acc};
            } else {
                Account acc = new Account(Name = 'test71', Id = '0018d00000ZDWRHAA5');
                accounts = new List<Account>{
                        acc
                };

            }

            System.debug(accounts);

            for (Account acc : accounts) {
                applicantsList.put(acc.Id, acc);
            }

            for (Values val : responseValues) {
                val.accountid = applicantsList.get(val.accountid).Name;
                if (!applicants.containsKey(val.accountid)) {
                    List<Values> valList = new List<Values>{
                            val
                    };
                    applicants.put(val.accountid, valList);
                } else {
                    List<Values> valList = new List<Values>();
                    valList.addAll(applicants.get(val.accountid));
                    valList.add(val);
                    applicants.put(val.accountid, valList);
                }
            }

            System.debug(applicants);

            List<ReturnBody> respB = new List<ReturnBody>();
            for (String mapKey : applicants.keySet()) {
                ReturnBody rb = new ReturnBody();
                rb.applicantName = mapKey;
                rb.values = applicants.get(mapKey);


                for (Values val : rb.values) {
                    if (val.open == '') {
                        val.open = '0';
                    }
                    if (val.click == '') {
                        val.click = '0';
                    }
                }
                respB.add(rb);
            }
            System.debug(responseBody);
            return respB;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return new List<ReturnBody>();
        }
    }

    public static BearerResponse getBearer() {

        Marketing_Cloud_Email_Integration__mdt integrationDetails = Marketing_Cloud_Email_Integration__mdt.getInstance('Marketing_Cloud_Credentials');

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();

        req.setMethod('POST');
        req.setEndpoint(integrationDetails.endPoint__c);
        req.setBody('{"grant_type":"client_credentials","client_id":"' + integrationDetails.client_id__c + '","client_secret":"' + integrationDetails.client_secret__c + '","account_id":"' + integrationDetails.account_id__c + '"}');
        req.setHeader('Content-Length', String.valueOf(req.getBody().length()));
        req.setHeader('Content-Type', 'Application/json');

        try {
            resp = http.send(req);
        } catch (Exception e) {
            System.debug('Failed to get bearer' + e.getMessage());
        }

        System.debug(resp.getBody());
        if (!Test.isRunningTest()) {
            return (BearerResponse) JSON.deserialize(resp.getBody(), BearerResponse.class);
        } else {
            return (BearerResponse) JSON.deserialize('{"access_token":"eyJhbGciOiJIUzI1NiIsImtpZCI6IjQiLCJ2ZXIiOiIxIiwidHlwIjoiSldUIn0.eyJhY2Nlc3NfdG9rZW4iOiJXQlY0aVJ2RVBmOWNiWmcyVmlQNXJHanoiLCJjbGllbnRfaWQiOiJuNXlreXZwN2J4cXBzZGV2NnJtd2N3MGciLCJlaWQiOjUzNjAwMTI1MSwic3RhY2tfa2V5IjoiUzUxIiwicGxhdGZvcm1fdmVyc2lvbiI6MiwiY2xpZW50X3R5cGUiOiJTZXJ2ZXJUb1NlcnZlciIsInBpZCI6NDMzfQ.cnJIcHEhP5gXBADlRcxxcIisxf_RreOcqjWvwzwloXc.o8wJdowSyp3qR3qANoa7Auh1V4aZ6gKAlXIy3EddoJshgwxM2KDd3w2l-ytfjzd62eJNERqA27jKieEZ4O1WjabfXrN5bylHl3h58-7WIAU7twJkD4-AoadTgk-_xP8fT26FgDCEAWq4BXmiB-jK82jb3ijq8X4WXr0LJ","token_type":"Bearer","expires_in":1069,"scope":"offline journeys_execute journeys_read journeys_write sms_read sms_send sms_write audiences_read audiences_write list_and_subscribers_read list_and_subscribers_write data_extensions_read file_locations_read marketing_cloud_connect_read journeys_aspr market_audience_view market_audience_member_view contact_bu_mapping_create contact_bu_mapping_view contact_bu_mapping_update","soap_instance_url":"https://mc-nnhlqg3qfjpy4-4dg4q-pj8v1.soap.marketingcloudapis.com/","rest_instance_url":"https://mc-nnhlqg3qfjpy4-4dg4q-pj8v1.rest.marketingcloudapis.com/"}', BearerResponse.class);
        }
    }

    public class RequestBody {
        List<String> AccId;
        String OppId;
        String OppRecordTypeName;
    }

    public class BearerResponse {
        String access_token;
        String rest_instance_url;
    }

    public class ResponseBody {

        @AuraEnabled public Integer pageSize;
        @AuraEnabled public Integer page;
        @AuraEnabled public Integer count;
        @AuraEnabled public List<Items> items;
    }

    public class Items {
        @AuraEnabled public Values values;
    }

    public class Values {
        @AuraEnabled public String contactid;
        @AuraEnabled public String sent = '0';
        @AuraEnabled public String open = '0';
        @AuraEnabled public String bounce;
        @AuraEnabled public String bouncereason;
        @AuraEnabled public String sentdate;
        @AuraEnabled public String opendate;
        @AuraEnabled public String click = '0';
        @AuraEnabled public String bouncedate;
        @AuraEnabled public String commsname;
        @AuraEnabled public String oppid;
        @AuraEnabled public String applicantid;
        @AuraEnabled public String accountid;
        @AuraEnabled public String emailaddress;
        @AuraEnabled public String vawpurl;
    }

    public class ReturnBody {
        @AuraEnabled public String applicantName;
        @AuraEnabled public List<Values> values;
    }

}