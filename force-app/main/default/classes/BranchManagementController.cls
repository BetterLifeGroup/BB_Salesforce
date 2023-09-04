/**
 * Created by frans fourie on 2023/05/23.
 */

public without sharing class BranchManagementController {

    @AuraEnabled
    public static List<Account> getRelatedAccounts(String accountId) {

        return [
                SELECT Id, RecordType.Name
                FROM Account
                WHERE Account.ParentId = :accountId OR Account.Parent.ParentId = :accountId
        ];
    }

}