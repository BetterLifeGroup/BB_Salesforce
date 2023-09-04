/**
 * Created by frans fourie on 2023/05/30.
 */

@IsTest
public with sharing class DmsCallOutMock implements HttpCalloutMock {

    public Boolean mustPass;

    public DmsCallOutMock(Boolean mustPass) {
        this.mustPass = mustPass;
    }

    public HttpResponse respond(HttpRequest request) {
        System.debug(this.mustPass);
        if (this.mustPass) {
            System.debug('true');
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(200);
//            DmsCallOut.AuthResponse mockResp = new DmsCallOut.AuthResponse();
//            mockResp.access_token = 'fakeaccesstoken';
//            resp.setBody(JSON.serialize(mockResp));
            return resp;
        } else {
            System.debug('false');
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(400);
//            DmsCallOut.AuthResponse mockResp = new DmsCallOut.AuthResponse();
//            mockResp.access_token = 'fakeaccesstoken';
            return resp;
        }
    }

}