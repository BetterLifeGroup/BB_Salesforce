/**
 * Created by frans fourie on 2023/06/14.
 */

public with sharing class getBranchAndSubBranchFromRegionACR {

    @InvocableMethod
    public static List<Response> accounts(List<Request> req) {

        try {
            List<AccountContactRelation> acrs = [
                    SELECT Id, ContactId, AccountId, Account.ParentId, Account.Parent.ParentId
                    FROM AccountContactRelation
                    WHERE ContactId = :req[0].contactId
            ];

            List<Response> respList = new List<Response>();
            Response res = new Response();
            for (AccountContactRelation acr : acrs) {

                if (acr.Account?.ParentId == req[0].regionId) {
                    res.branch = acr.AccountId;
                } else if (acr.Account?.Parent?.ParentId == req[0].regionId) {
                    res.subBranch = acr.AccountId;
                }
            }
            respList.add(res);


            return respList;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return new List<Response>();
        }
    }

    public class Request {
        @InvocableVariable(label='Region Account Id' Required=true) public String regionId;
        @InvocableVariable(label='Contact Id' Required=true) public String contactId;

    }

    public class Response {
        @InvocableVariable(label='Branch Account Id' Required=true) public String branch;
        @InvocableVariable(label='SubBranch Account Id' Required=true) public String subBranch;

    }

}