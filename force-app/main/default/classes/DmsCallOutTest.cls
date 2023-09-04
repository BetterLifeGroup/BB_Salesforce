/**
 * Created by frans fourie on 2023/05/30.
 */

@IsTest
public with sharing class DmsCallOutTest {

    @IsTest
    public static void testDmsPositive() {
        Test.setMock(HttpCalloutMock.class, new DmsCallOutMock(true));
        Test.startTest();
        List<DmsCallOut.DmsRequest> reqList = new List<DmsCallOut.DmsRequest>();
        DmsCallOut.DmsRequest req = new DmsCallOut.DmsRequest();
        req.loanType = 'building loan';
        req.consultantEntityId = 'somefakeId';
        reqList.add(req);
        Assert.isNotNull(DmsCallOut.GenerateDmsNumber(reqList));
        Test.stopTest();

    }

    @IsTest
    public static void testDmsNegative() {
        Test.setMock(HttpCalloutMock.class, new DmsCallOutMock(false));
        Test.startTest();
        List<DmsCallOut.DmsRequest> reqList = new List<DmsCallOut.DmsRequest>();
        DmsCallOut.DmsRequest req = new DmsCallOut.DmsRequest();
        req.loanType = 'building loan';
        req.consultantEntityId = 'somefakeId';
        reqList.add(req);
        try {
            DmsCallOut.GenerateDmsNumber(reqList);
        } catch (Exception e) {
        }
        Test.stopTest();
    }
}