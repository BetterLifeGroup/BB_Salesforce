/**
 * Created by frans fourie on 2023/06/29.
 */

@IsTest
public with sharing class updateOpportunityTest {

    @IsTest
    public static void testUpdateOpportunityPositive(){
        List<SObject> sobj = new List<SObject>();

        Account acc = new Account();
        acc.Name = 'test69';

        insert acc;

        acc.Name = 'test70';

        sobj.add(acc);



        System.assert(updateOpportunity.updateOpportunity(sobj)[0] == true);
    }

    @IsTest
    public static void testUpdateOpportunityNegative(){
        List<SObject> sobj = new List<SObject>();

        Account acc = new Account();
        acc.Name = 'test69';

        insert acc;

        acc.Name = 'test70';
        acc.Id = null;

        sobj.add(acc);



        System.assert(updateOpportunity.updateOpportunity(sobj)[0] == false);
    }
}