/**
 * @description       : Test class for class AnnualReviewsController
 * @author            : Bluewave | Ismail Basser
 * @group             :
 * @last modified on  : 25-02-2021
 * @last modified by  : Bluewave | Ismail Basser
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   25-02-2021   Bluewave | Tomasz Piechota   Initial Version
**/
@isTest
public class AnnualReviewsController_Test {

    @IsTest
    static void T01_getAnnualReviewsScheduledPast_PositiveAR() {
        Id annualReviewId = Schema.SObjectType.Annual_Review__c.getRecordTypeInfosByDeveloperName().get('Annual_Review').getRecordTypeId();
        Id annualConflictCheckId = Schema.SObjectType.Annual_Review__c.getRecordTypeInfosByDeveloperName().get('Annual_Conflict_Check').getRecordTypeId();

        Account testAcc = new Account(Name = 'Test Acc A');
        insert testAcc;

        Date yesterday = Date.today().addDays(-1);
        Annual_Review__c testReview = new Annual_Review__c(RecordTypeId = annualReviewId, Account__c = testAcc.Id, Status__c = 'Scheduled', Next_Review_Date__c = yesterday);
        insert  testReview;

        Test.startTest();
        List<AnnualReviewsController.AnnualReviewWrapper> wrapperList = AnnualReviewsController.getAnnualReviews();
        Test.stopTest();

        System.assertEquals(1, wrapperList.size());
        System.assertEquals(testReview.Id, wrapperList[0].Id);
        System.assertEquals(true, wrapperList[0].annualReviewRT);
        System.assertEquals(true, wrapperList[0].errorFlag);
        System.assertEquals(null, wrapperList[0].warningFlag);
        System.assertEquals(null, wrapperList[0].successFlag);
        System.assertEquals('Test Acc A', wrapperList[0].accountName);
        System.assertEquals('Scheduled', wrapperList[0].status);
        System.assertEquals(yesterday, wrapperList[0].nextReviewDate);
    }

    @IsTest
    static void T02_getAnnualReviewsScheduledToday_PositiveAR() {
        Id annualReviewId = Schema.SObjectType.Annual_Review__c.getRecordTypeInfosByDeveloperName().get('Annual_Review').getRecordTypeId();
        Id annualConflictCheckId = Schema.SObjectType.Annual_Review__c.getRecordTypeInfosByDeveloperName().get('Annual_Conflict_Check').getRecordTypeId();

        Account testAcc = new Account(Name = 'Test Acc A');
        insert testAcc;

        Annual_Review__c testReview = new Annual_Review__c(RecordTypeId = annualReviewId, Account__c = testAcc.Id, Status__c = 'Scheduled', Next_Review_Date__c = Date.today());
        insert  testReview;

        Test.startTest();
        List<AnnualReviewsController.AnnualReviewWrapper> wrapperList = AnnualReviewsController.getAnnualReviews();
        Test.stopTest();

        System.assertEquals(1, wrapperList.size());
        System.assertEquals(testReview.Id, wrapperList[0].Id);
        System.assertEquals(true, wrapperList[0].annualReviewRT);
        System.assertEquals(null, wrapperList[0].errorFlag);
        System.assertEquals(true, wrapperList[0].warningFlag);
        System.assertEquals(null, wrapperList[0].successFlag);
        System.assertEquals('Test Acc A', wrapperList[0].accountName);
        System.assertEquals('Scheduled', wrapperList[0].status);
        System.assertEquals(Date.today(), wrapperList[0].nextReviewDate);
    }

    @IsTest
    static void T03_getAnnualReviewsScheduledFuture_PositiveAR() {
        Id annualReviewId = Schema.SObjectType.Annual_Review__c.getRecordTypeInfosByDeveloperName().get('Annual_Review').getRecordTypeId();
        Id annualConflictCheckId = Schema.SObjectType.Annual_Review__c.getRecordTypeInfosByDeveloperName().get('Annual_Conflict_Check').getRecordTypeId();

        Account testAcc = new Account(Name = 'Test Acc A');
        insert testAcc;

        Date tomorrow = Date.today().addDays(1);
        Annual_Review__c testReview = new Annual_Review__c(RecordTypeId = annualReviewId, Account__c = testAcc.Id, Status__c = 'Scheduled', Next_Review_Date__c = tomorrow);
        insert  testReview;

        Test.startTest();
        List<AnnualReviewsController.AnnualReviewWrapper> wrapperList = AnnualReviewsController.getAnnualReviews();
        Test.stopTest();

        System.assertEquals(1, wrapperList.size());
        System.assertEquals(testReview.Id, wrapperList[0].Id);
        System.assertEquals(true, wrapperList[0].annualReviewRT);
        System.assertEquals(null, wrapperList[0].errorFlag);
        System.assertEquals(null, wrapperList[0].warningFlag);
        System.assertEquals(true, wrapperList[0].successFlag);
        System.assertEquals('Test Acc A', wrapperList[0].accountName);
        System.assertEquals('Scheduled', wrapperList[0].status);
        System.assertEquals(tomorrow, wrapperList[0].nextReviewDate);
    }

    @IsTest
    static void T04_getAnnualReviewsNonScheduled_NegativeAR() {
        Id annualReviewId = Schema.SObjectType.Annual_Review__c.getRecordTypeInfosByDeveloperName().get('Annual_Review').getRecordTypeId();
        Id annualConflictCheckId = Schema.SObjectType.Annual_Review__c.getRecordTypeInfosByDeveloperName().get('Annual_Conflict_Check').getRecordTypeId();

        Account testAcc = new Account(Name = 'Test Acc A');
        insert testAcc;

        Date tomorrow = Date.today().addDays(1);
        Annual_Review__c testReview = new Annual_Review__c(RecordTypeId = annualReviewId, Account__c = testAcc.Id, Status__c = 'New', Next_Review_Date__c = tomorrow);
        insert  testReview;

        Test.startTest();
        List<AnnualReviewsController.AnnualReviewWrapper> wrapperList = AnnualReviewsController.getAnnualReviews();
        Test.stopTest();

        System.assertEquals(0, wrapperList.size());
    }

    @IsTest
    static void T05_getAnnualReviewsScheduledPast_PositiveACC() {
        Id annualReviewId = Schema.SObjectType.Annual_Review__c.getRecordTypeInfosByDeveloperName().get('Annual_Review').getRecordTypeId();
        Id annualConflictCheckId = Schema.SObjectType.Annual_Review__c.getRecordTypeInfosByDeveloperName().get('Annual_Conflict_Check').getRecordTypeId();

        Account testAcc = new Account(Name = 'Test Acc A');
        insert testAcc;

        Onboarding__c testOnboarding = new Onboarding__c(Account__c = testAcc.Id, Stage__c = 'New');
        insert testOnboarding;

        Date yesterday = Date.today().addDays(-1);
        Annual_Review__c testReview = new Annual_Review__c(RecordTypeId = annualConflictCheckId, Account__c = testAcc.Id, Status__c = 'Scheduled', 
                                        Next_Review_Date__c = yesterday, Onboarding__c = testOnboarding.Id);
        insert  testReview;

        Test.startTest();
        List<AnnualReviewsController.AnnualReviewWrapper> wrapperList = AnnualReviewsController.getAnnualReviews();
        Test.stopTest();

        System.assertEquals(1, wrapperList.size());
        System.assertEquals(testReview.Id, wrapperList[0].Id);
        System.assertEquals(false, wrapperList[0].annualReviewRT);
        System.assertEquals(true, wrapperList[0].errorFlag);
        System.assertEquals(null, wrapperList[0].warningFlag);
        System.assertEquals(null, wrapperList[0].successFlag);
        System.assertEquals('Test Acc A', wrapperList[0].accountName);
        System.assertEquals('Scheduled', wrapperList[0].status);
        System.assertEquals(yesterday, wrapperList[0].nextReviewDate);
    }

    @IsTest
    static void T06_getAnnualReviewsScheduledToday_PositiveACC() {
        Id annualReviewId = Schema.SObjectType.Annual_Review__c.getRecordTypeInfosByDeveloperName().get('Annual_Review').getRecordTypeId();
        Id annualConflictCheckId = Schema.SObjectType.Annual_Review__c.getRecordTypeInfosByDeveloperName().get('Annual_Conflict_Check').getRecordTypeId();

        Account testAcc = new Account(Name = 'Test Acc A');
        insert testAcc;

        Onboarding__c testOnboarding = new Onboarding__c(Account__c = testAcc.Id, Stage__c = 'New');
        insert testOnboarding;

        Annual_Review__c testReview = new Annual_Review__c(RecordTypeId = annualConflictCheckId, Account__c = testAcc.Id, Status__c = 'Scheduled', 
                                        Next_Review_Date__c = Date.Today(), Onboarding__c = testOnboarding.Id);
        insert testReview;

        Test.startTest();
        List<AnnualReviewsController.AnnualReviewWrapper> wrapperList = AnnualReviewsController.getAnnualReviews();
        Test.stopTest();

        System.assertEquals(1, wrapperList.size());
        System.assertEquals(testReview.Id, wrapperList[0].Id);
        System.assertEquals(false, wrapperList[0].annualReviewRT);
        System.assertEquals(null, wrapperList[0].errorFlag);
        System.assertEquals(true, wrapperList[0].warningFlag);
        System.assertEquals(null, wrapperList[0].successFlag);
        System.assertEquals('Test Acc A', wrapperList[0].accountName);
        System.assertEquals('Scheduled', wrapperList[0].status);
        System.assertEquals(Date.today(), wrapperList[0].nextReviewDate);
    }

    @IsTest
    static void T07_getAnnualReviewsScheduledFuture_PositiveACC() {
        Id annualReviewId = Schema.SObjectType.Annual_Review__c.getRecordTypeInfosByDeveloperName().get('Annual_Review').getRecordTypeId();
        Id annualConflictCheckId = Schema.SObjectType.Annual_Review__c.getRecordTypeInfosByDeveloperName().get('Annual_Conflict_Check').getRecordTypeId();

        Account testAcc = new Account(Name = 'Test Acc A');
        insert testAcc;

        Onboarding__c testOnboarding = new Onboarding__c(Account__c = testAcc.Id, Stage__c = 'New');
        insert testOnboarding;

        Date tomorrow = Date.today().addDays(1);
        Annual_Review__c testReview = new Annual_Review__c(RecordTypeId = annualConflictCheckId, Account__c = testAcc.Id, Status__c = 'Scheduled', 
                                        Next_Review_Date__c = tomorrow, Onboarding__c = testOnboarding.Id);
        insert testReview;

        Test.startTest();
        List<AnnualReviewsController.AnnualReviewWrapper> wrapperList = AnnualReviewsController.getAnnualReviews();
        Test.stopTest();

        System.assertEquals(1, wrapperList.size());
        System.assertEquals(testReview.Id, wrapperList[0].Id);
        System.assertEquals(false, wrapperList[0].annualReviewRT);
        System.assertEquals(null, wrapperList[0].errorFlag);
        System.assertEquals(null, wrapperList[0].warningFlag);
        System.assertEquals(true, wrapperList[0].successFlag);
        System.assertEquals('Test Acc A', wrapperList[0].accountName);
        System.assertEquals('Scheduled', wrapperList[0].status);
        System.assertEquals(tomorrow, wrapperList[0].nextReviewDate);
    }

    @IsTest
    static void T08_getAnnualReviewsNonScheduled_NegativeACC() {
        Id annualReviewId = Schema.SObjectType.Annual_Review__c.getRecordTypeInfosByDeveloperName().get('Annual_Review').getRecordTypeId();
        Id annualConflictCheckId = Schema.SObjectType.Annual_Review__c.getRecordTypeInfosByDeveloperName().get('Annual_Conflict_Check').getRecordTypeId();

        Account testAcc = new Account(Name = 'Test Acc A');
        insert testAcc;

        Onboarding__c testOnboarding = new Onboarding__c(Account__c = testAcc.Id, Stage__c = 'New');
        insert testOnboarding;

        Date tomorrow = Date.today().addDays(1);
        Annual_Review__c testReview = new Annual_Review__c(RecordTypeId = annualConflictCheckId, Account__c = testAcc.Id, Status__c = 'New', 
                                        Next_Review_Date__c = tomorrow, Onboarding__c = testOnboarding.Id);
        insert testReview;

        Test.startTest();
        List<AnnualReviewsController.AnnualReviewWrapper> wrapperList = AnnualReviewsController.getAnnualReviews();
        Test.stopTest();

        System.assertEquals(0, wrapperList.size());
    }

    @IsTest
    static void T09_getAnnualReviewsScheduledFuture_BulkPositiveAR() {
        Id annualReviewId = Schema.SObjectType.Annual_Review__c.getRecordTypeInfosByDeveloperName().get('Annual_Review').getRecordTypeId();

        List<Account> accountsToInsert = new List<Account>();
        for(Integer i=0; i<200; i++)
        {
            Account testAcc = new Account(Name = 'Test Acc '+i);
            accountsToInsert.add(testAcc);
        }
        insert accountsToInsert;

        Date tomorrow = Date.today().addDays(1);

        List<Annual_Review__c> reviewsToInsert = new List<Annual_Review__c>();
        for(Integer i=0; i<200; i++)
        {
            Annual_Review__c testReview = new Annual_Review__c(RecordTypeId = annualReviewId, Account__c = accountsToInsert[i].Id, Status__c = 'Scheduled', Next_Review_Date__c = tomorrow);
            reviewsToInsert.add(testReview);
        }
        insert reviewsToInsert;

        Test.startTest();
        List<AnnualReviewsController.AnnualReviewWrapper> wrapperList = AnnualReviewsController.getAnnualReviews();
        Test.stopTest();

        System.assertEquals(200, wrapperList.size());
    }

    @IsTest
    static void T10_getAnnualReviewsScheduledFuture_BulkNegativeAR() {
        Id annualReviewId = Schema.SObjectType.Annual_Review__c.getRecordTypeInfosByDeveloperName().get('Annual_Review').getRecordTypeId();

        List<Account> accountsToInsert = new List<Account>();
        for(Integer i=0; i<200; i++)
        {
            Account testAcc = new Account(Name = 'Test Acc '+i);
            accountsToInsert.add(testAcc);
        }
        insert accountsToInsert;

        Date tomorrow = Date.today().addDays(1);

        List<Annual_Review__c> reviewsToInsert = new List<Annual_Review__c>();
        for(Integer i=0; i<200; i++)
        {
            Annual_Review__c testReview = new Annual_Review__c(RecordTypeId = annualReviewId, Account__c = accountsToInsert[i].Id, Status__c = 'New', Next_Review_Date__c = tomorrow);
            reviewsToInsert.add(testReview);
        }
        insert reviewsToInsert;

        Test.startTest();
        List<AnnualReviewsController.AnnualReviewWrapper> wrapperList = AnnualReviewsController.getAnnualReviews();
        Test.stopTest();

        System.assertEquals(0, wrapperList.size());
    }

    @IsTest
    static void T11_getAnnualReviewsScheduledFuture_BulkPositiveACC() {
        Id annualConflictCheckId = Schema.SObjectType.Annual_Review__c.getRecordTypeInfosByDeveloperName().get('Annual_Conflict_Check').getRecordTypeId();

        List<Account> accountsToInsert = new List<Account>();
        for(Integer i=0; i<200; i++)
        {
            Account testAcc = new Account(Name = 'Test Acc '+i);
            accountsToInsert.add(testAcc);
        }
        insert accountsToInsert;

        Date tomorrow = Date.today().addDays(1);

        List<Annual_Review__c> reviewsToInsert = new List<Annual_Review__c>();
        for(Integer i=0; i<200; i++)
        {
            Annual_Review__c testReview = new Annual_Review__c(RecordTypeId = annualConflictCheckId, Account__c = accountsToInsert[i].Id, Status__c = 'Scheduled', Next_Review_Date__c = tomorrow);
            reviewsToInsert.add(testReview);
        }
        insert reviewsToInsert;

        Test.startTest();
        List<AnnualReviewsController.AnnualReviewWrapper> wrapperList = AnnualReviewsController.getAnnualReviews();
        Test.stopTest();

        System.assertEquals(200, wrapperList.size());
    }

    @IsTest
    static void T12_getAnnualReviewsScheduledFuture_BulkNegativeACC() {
        Id annualConflictCheckId = Schema.SObjectType.Annual_Review__c.getRecordTypeInfosByDeveloperName().get('Annual_Conflict_Check').getRecordTypeId();
        List<Account> accountsToInsert = new List<Account>();
        for(Integer i=0; i<200; i++)
        {
            Account testAcc = new Account(Name = 'Test Acc '+i);
            accountsToInsert.add(testAcc);
        }
        insert accountsToInsert;

        Date tomorrow = Date.today().addDays(1);

        List<Annual_Review__c> reviewsToInsert = new List<Annual_Review__c>();
        for(Integer i=0; i<200; i++)
        {
            Annual_Review__c testReview = new Annual_Review__c(RecordTypeId = annualConflictCheckId, Account__c = accountsToInsert[i].Id, Status__c = 'New', Next_Review_Date__c = tomorrow);
            reviewsToInsert.add(testReview);
        }
        insert reviewsToInsert;

        Test.startTest();
        List<AnnualReviewsController.AnnualReviewWrapper> wrapperList = AnnualReviewsController.getAnnualReviews();
        Test.stopTest();

        System.assertEquals(0, wrapperList.size());
    }

}