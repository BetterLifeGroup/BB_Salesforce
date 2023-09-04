/**
 * Created by frans fourie on 2023/06/08.
 */

public without sharing class updateOpportunity {

    @InvocableMethod
    public static List<Boolean> updateOpportunity(List<SObject> sObjectToUpdate) {
        System.debug('you are here');
        try {
            update sObjectToUpdate[0];
            return new List<Boolean>{true};

        } catch (Exception e) {

            System.debug(e);

            return new List<Boolean>{false};
        }
    }

}