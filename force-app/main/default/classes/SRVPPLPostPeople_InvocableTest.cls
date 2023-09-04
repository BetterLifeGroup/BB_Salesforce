/**
 * Created by frans fourie on 2022/11/14.
 */
@IsTest
public with sharing class SRVPPLPostPeople_InvocableTest {

    @IsTest
    public static void postPeopleTest() {


        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));

        List<SRVPPLPostPeople_Invocable.SRVPPLRequest> reqList = new List<SRVPPLPostPeople_Invocable.SRVPPLRequest>();
        SRVPPLPostPeople_Invocable.SRVPPLRequest req = new SRVPPLPostPeople_Invocable.SRVPPLRequest();
        req.lastName = '';
        req.firstName = '';
        req.email = '';
        reqList.add(req);
        SRVPPLPostPeople_Invocable.postPeople(reqList);
    }
    @IsTest
    public static void postPeopleExceptionTest() {

        Test.setMock(HttpCalloutMock.class, new ResponseExceptionMock());

        List<SRVPPLPostPeople_Invocable.SRVPPLRequest> reqList = new List<SRVPPLPostPeople_Invocable.SRVPPLRequest>();
        SRVPPLPostPeople_Invocable.SRVPPLRequest req = new SRVPPLPostPeople_Invocable.SRVPPLRequest();
        req.lastName = '';
        req.firstName = '';
        req.email = '';
        reqList.add(req);
        SRVPPLPostPeople_Invocable.postPeople(reqList);
    }
}