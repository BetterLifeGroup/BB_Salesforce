//Unit Tests for LookupController & LookupSearchResult
@IsTest
public class LookupControllerTest {

    @IsTest
    public static void tests() {
        // create test data
        String country = 'South Africa';
        String city = 'Pretoria';

        Account acc0 = new Account(Name='LookupControllerTest0',
                                   AccountNumber='abc',
                                   ShippingCountry=country,
                                   ShippingCity=country);
        Account acc1 = new Account(Name='LookupControllerTest1',
                                   AccountNumber='def',
                                   ShippingCountry=country,
                                   ShippingCity=country);
        Account acc2 = new Account(Name='LookupControllerTest2',
                                   AccountNumber='xyz',
                                   ShippingCountry=country,
                                   ShippingCity=country);
        insert acc0;
        insert acc1;
        insert acc2;

        // test search results

        Id[] accIds = new Id[3];
        accIds[0] = acc0.Id;
        accIds[1] = acc1.Id;
        accIds[2] = acc2.Id;
		Test.setFixedSearchResults(accIds); //required to get results from sosl in LookupController.search
        
        List<String> selectedIds = new List<String>{acc0.Id};
        List<String> includedIds = new List<String>{acc2.Id};
        List<LookupSearchResult> results = LookupController.search('LookupControllerTest', 
                                                                   '',
                                                                   'Account', 
                                                                   'Name', 
                                                                   'ShippingCountry, ShippingCity', 
                                                                   selectedIds, 
                                                                   'AccountNumber = \'abc\'',
                                                                   1,
                                                                   'standard:account', 
                                                                   includedIds);
        
        System.assertEquals(1, results.size());
        System.assertEquals(acc0.Id, results[0].getId());
        System.assertEquals(String.valueOf(Account.getSObjectType()), results[0].getSObjectType());
        System.assertEquals(acc0.Name, results[0].getTitle());
        System.assert(results[0].getSubtitle().contains(country));
        System.assertEquals('standard:account', results[0].getIcon());
        
        // test search with fake sObject name
        results = LookupController.search('LookupControllerTest', 
                                          '',
                                          'fakeObject', 
                                          'Name', 
                                          'ShippingCountry, ShippingCity', 
                                          selectedIds, 
                                          'AccountNumber = \'abc\'',
                                          2, 
                                          'standard:account', 
                                          includedIds);
        System.assertEquals(0, results.size());
        
        // test search with fake field names
        results = LookupController.search('LookupControllerTest', 
                                          '',
                                          'Account', 
                                          'fakeTitleField', 
                                          'ShippingCountry, ShippingCity',
                                          selectedIds, 
                                          'AccountNumber = \'abc\'',
                                          1,
                                          'standard:account',
                                          includedIds);                                          
        System.assertEquals(1, results.size());
    }
    @IsTest
    public static void test_compareTo_SortTitle(){
        LookupSearchResult searchResult = new LookupSearchResult(null,null, null, 'Test',null);
        Integer rtn = searchResult.compareTo(searchResult); 
        System.assert(rtn==0,true);
    }
}