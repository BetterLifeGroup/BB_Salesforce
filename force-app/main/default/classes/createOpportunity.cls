/**
 * Created by frans fourie on 2023/11/02.
 */

public without sharing class createOpportunity {

    @InvocableMethod
    public static List<Boolean> insertOpportunity(List<SObject> sObjectToUpdate) {
        System.debug('you are here');
        try {
            insert sObjectToUpdate[0];
            return new List<Boolean>{true};

        } catch (Exception e) {

            System.debug(e);

            return new List<Boolean>{false};
        }
    }

}