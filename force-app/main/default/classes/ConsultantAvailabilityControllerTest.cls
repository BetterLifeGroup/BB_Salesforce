/**
 * Created by frans fourie on 2023/10/06.
 */

@IsTest
public with sharing class ConsultantAvailabilityControllerTest {

    @TestSetup
    public static void setupTestData() {

        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%Consultant%' LIMIT 1];

        UserRole ur = [SELECT Id FROM UserRole WHERE Name LIKE '%Direct%' LIMIT 1];

        User u = new User(Alias = 'standt40',
                Email = 'standarduser123@testorg123.com',
                EmailEncodingKey = 'UTF-8',
                FirstName = 'Consultant',
                LastName = 'Availability',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_ZA',
                ProfileId = p.Id,
                TimeZoneSidKey = 'Africa/Johannesburg',
                AvailableforRouting__c = true,
                UserRoleId = ur.Id,
                Username = 'standarduser4387549387589435@testorg.com.tyrr');

        insert u;

    }


    @IsTest
    public static void GetNumberOfConsultantsAvailableTest() {
        User createdUser = [SELECT Id FROM User WHERE Name LIKE '%Consultant Availability%'];
        createdUser.AvailableforRouting__c = false;
        update createdUser;
        String unavailableReasons = 'Lunch;Travelling;Admin Time;Sick Leave;Annual Leave;Meeting/Training';
        List<String> unavailableReasonsList = unavailableReasons.split(';');
        for(String st : unavailableReasonsList){
        Consultant_Availability__c ca = new Consultant_Availability__c(Consultant__c = createdUser.Id, Unavailable_Reason__c = st, Unavailable_From__c = Datetime.now().addDays(-1));
        insert ca;
        }
        Test.startTest();
        Assert.isNotNull(ConsultantAvailabilityController.GetNumberOfConsultantsAvailable());
        Test.stopTest();
    }
    @IsTest
    public static void getUnavailableUsersTest() {
        User createdUser = [SELECT Id FROM User WHERE Name LIKE '%Consultant Availability%'];
        Consultant_Availability__c ca = new Consultant_Availability__c(Consultant__c = createdUser.Id, Unavailable_Reason__c = 'Travelling', Unavailable_From__c = Datetime.now().addDays(-1));
        insert ca;
        Test.startTest();
        Assert.isNotNull(ConsultantAvailabilityController.getUnavailableUsers('Lunch'));
        Test.stopTest();
    }
    @IsTest
    public static void userAvailableTest() {
        User createdUser = [SELECT Id FROM User WHERE Name LIKE '%Consultant Availability%'];
        Consultant_Availability__c ca = new Consultant_Availability__c(Consultant__c = createdUser.Id, Unavailable_Reason__c = 'Travelling', Unavailable_From__c = Datetime.now().addDays(-1));
        insert ca;
        Test.startTest();
        Assert.isNotNull(ConsultantAvailabilityController.userAvailable(createdUser.Id));
        Test.stopTest();
    }
    @IsTest
    public static void userAvailableTestNegative() {
        Test.startTest();
        Assert.isNotNull(ConsultantAvailabilityController.userAvailable('fakeUserId'));
        Test.stopTest();
    }
    @IsTest
    public static void futureUnavailabilitiesTest() {
        User createdUser = [SELECT Id FROM User WHERE Name LIKE '%Consultant Availability%'];
        Consultant_Availability__c ca = new Consultant_Availability__c(Consultant__c = createdUser.Id, Unavailable_Reason__c = 'Travelling', Unavailable_From__c = Datetime.now().addDays(20));
        insert ca;
        Test.startTest();
        Assert.isNotNull(ConsultantAvailabilityController.futureUnavailabilities(createdUser.Id));
        Test.stopTest();
    }
    @IsTest
    public static void futureUnavailabilitiesNegativeTest() {
        User createdUser = [SELECT Id FROM User WHERE Name LIKE '%Consultant Availability%'];
        Consultant_Availability__c ca = new Consultant_Availability__c(Consultant__c = createdUser.Id, Unavailable_Reason__c = 'Travelling', Unavailable_From__c = Datetime.now().addDays(-20));
        insert ca;
        Test.startTest();
        Assert.isNotNull(ConsultantAvailabilityController.futureUnavailabilities(createdUser.Id));
        Test.stopTest();
    }
    @IsTest
    public static void DeleteFutureAvailabilityRecordTest() {
        User createdUser = [SELECT Id FROM User WHERE Name LIKE '%Consultant Availability%'];
        Consultant_Availability__c ca = new Consultant_Availability__c(Consultant__c = createdUser.Id, Unavailable_Reason__c = 'Travelling', Unavailable_From__c = Datetime.now().addDays(-1));
        insert ca;
        Test.startTest();
        Assert.isNotNull(ConsultantAvailabilityController.DeleteFutureAvailabilityRecord(createdUser.ID));
        Test.stopTest();
    }
    @IsTest
    public static void DeleteFutureAvailabilityRecordTestNegative() {
        Test.startTest();
        Assert.isNotNull(ConsultantAvailabilityController.DeleteFutureAvailabilityRecord('fakeUserId'));
        Test.stopTest();
    }
    @IsTest
    public static void MarkUserAvailableTest() {
        User createdUser = [SELECT Id FROM User WHERE Name LIKE '%Consultant Availability%'];
        Consultant_Availability__c ca = new Consultant_Availability__c(Consultant__c = createdUser.Id, Unavailable_Reason__c = 'Travelling', Unavailable_From__c = Datetime.now().addDays(-1));
        insert ca;
        Test.startTest();
        Assert.isNotNull(ConsultantAvailabilityController.MarkUserAvailable(createdUser.Id));
        Test.stopTest();
    }
    @IsTest
    public static void MarkUserAvailableTestNegative() {
        Test.startTest();
        Assert.isNotNull(ConsultantAvailabilityController.MarkUserAvailable('fakeUserId'));
        Test.stopTest();
    }
    @IsTest
    public static void CreateConsultantAvailabilityTest() {
        User createdUser = [SELECT Id FROM User WHERE Name LIKE '%Consultant Availability%'];
        Consultant_Availability__c ca = new Consultant_Availability__c(Consultant__c = createdUser.Id, Unavailable_Reason__c = 'Travelling', Unavailable_From__c = Datetime.now().addDays(-1));
        insert ca;
        Test.startTest();
        Assert.isNotNull(ConsultantAvailabilityController.CreateConsultantAvailability(createdUser.Id, 'SomeFakeReason', false, null));
        Test.stopTest();
    }
    @IsTest
    public static void MarkUserUnavailableTest() {
        User createdUser = [SELECT Id FROM User WHERE Name LIKE '%Consultant Availability%'];
        Consultant_Availability__c ca = new Consultant_Availability__c(Consultant__c = createdUser.Id, Unavailable_Reason__c = 'Travelling', Unavailable_From__c = Datetime.now().addDays(-1));
        insert ca;
        Test.startTest();
        Assert.isNotNull(ConsultantAvailabilityController.MarkUserUnavailable(createdUser.Id));
        Test.stopTest();
    }
    @IsTest
    public static void DirectOnlyAvailableConsultantsTest() {
        User createdUser = [SELECT Id FROM User WHERE Name LIKE '%Consultant Availability%'];
        Consultant_Availability__c ca = new Consultant_Availability__c(Consultant__c = createdUser.Id, Unavailable_Reason__c = 'Travelling', Unavailable_From__c = Datetime.now().addDays(-1));
        insert ca;
        Test.startTest();
        Assert.isNotNull(ConsultantAvailabilityController.DirectOnlyAvailableConsultants(createdUser.Id));
        Test.stopTest();
    }

}