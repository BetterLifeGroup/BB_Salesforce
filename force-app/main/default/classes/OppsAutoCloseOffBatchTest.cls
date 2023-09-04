@IsTest
private class OppsAutoCloseOffBatchTest {
    @TestSetup
    static void setup() {
        BLG_Workflow__c blg = new BLG_Workflow__c();
        blg.Name = 'Pre-Approval Consent';
        blg.Close_off_Reason__c = 'No PA consent received';
        blg.Close_off_Days__c = 4;
        blg.Close_off_Contact_Attempts__c = 2;

        insert blg;

        BLG_Workflow__c blg2 = new BLG_Workflow__c();
        blg2.Name = 'Awaiting OTP';
        blg2.Close_off_Reason__c = 'No OTP Received';
        blg2.Auto_Close__c = true;
        blg2.Close_off_Days__c = 4;
        blg2.Close_off_Contact_Attempts__c = 2;

        insert blg2;

        BLG_Campaign__c blg3 = new BLG_Campaign__c();
        blg3.Type_of_Campaign__c = 'Create lead/manual';
        blg3.SLA__c = 12;

        insert blg3;

        Opportunity opp = new Opportunity();
        opp.CloseDate = Date.newInstance(2022, 2, 2);
        opp.StageName = 'Working';
        opp.Name = 'test123abc';
        opp.Contact_Attempts__c = 0;
        opp.Status__c = 'PA Requested - awaiting consent';
        opp.Assignment_DateTime__c = Datetime.now().addDays(-300);

        insert opp;

        Opportunity opp2 = new Opportunity();
        opp2.CloseDate = Date.newInstance(2022, 2, 2);
        opp2.StageName = 'Working (Bond)';
        opp2.Name = 'test123abc';
        opp2.Contact_Attempts__c = 67;
        opp2.General_Opportunity__c = opp.Id;
        opp2.Assignment_DateTime__c = Datetime.now().addDays(-300);
        opp2.Status__c = 'Awaiting OTP';

        insert opp2;
    }
    @IsTest
    static void test() {
        Test.startTest();
        OppsAutoCloseOffBatch uca = new OppsAutoCloseOffBatch();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
    }
}
