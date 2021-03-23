/**
 * @description       : Tests for the ConflictCheckController class that provides data to conflictCheck LWC
 * @author            : Bluewave | Tomasz Piechota
 * @group             : Bluewave
 * @last modified on  : 05-02-2021
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   04-02-2021   Bluewave | Tomasz Piechota   Initial Version (Release 2.1)
**/
@IsTest
public with sharing class ConflictCheckController_TEST {

    @IsTest
    static void checkIfCompanyDataExists_FAILURE_T01() {
        ResponseData result;
        Boolean hasError = false;
        Exception capturedException;

        try {
        	Test.startTest();
                result = ConflictCheckController.checkIfCompanyDataExists(null);
            Test.stopTest();
        } catch (Exception e) {
            hasError = true;
            capturedException = e;
        }

        System.assertEquals(true, hasError, 'No exception was thrown');
        System.assertNotEquals(null, capturedException, 'Exception should be thrown');
        System.assertEquals(AuraHandledException.class.getName(), capturedException.getTypeName(), 'AuraHandledException is expected');
        System.assertEquals('Record Id is invalid or missing.', capturedException.getMessage(), 'Specific error message is expected');
    }

    @IsTest
    static void checkIfCompanyDataExists_FAILURE_T02() {
        ResponseData result;
        Boolean hasError = false;
        Exception capturedException;

        try {
        	Test.startTest();
                result = ConflictCheckController.checkIfCompanyDataExists('XXXXXXXXXXXXXXX');
            Test.stopTest();
        } catch (Exception e) {
            hasError = true;
            capturedException = e;
        }

        System.assertEquals(true, hasError, 'No exception was thrown');
        System.assertNotEquals(null, capturedException, 'Exception should be thrown');
        System.assertEquals(ConflictCheckHelper.ConflictCheckException.class.getName(), capturedException.getTypeName(), 'ConflictCheckHelper.ConflictCheckException is expected');
        System.assertEquals('Invalid id: XXXXXXXXXXXXXXX', capturedException.getMessage(), 'Specific error message is expected');
    }

    @IsTest
    static void checkIfCompanyDataExists_SUCCESS_T01() {
        ResponseData result;
        Boolean hasError = false;
        Exception capturedException;
        Account a = TestDataFactory.createAccount('test Account');
        insert a;

        try {
        	Test.startTest();
                result = ConflictCheckController.checkIfCompanyDataExists(a.Id);
            Test.stopTest();
        } catch (Exception e) {
            hasError = true;
            capturedException = e;
        }

        System.assertEquals(false, hasError, 'Exception was thrown');
        System.assertEquals(true, result.status, 'Status is false');
        System.assertEquals(false, result.returnData, 'message is true');
    }

    @IsTest
    static void checkIfCompanyDataExists_SUCCESS_T02() {
        ResponseData result;
        Boolean hasError = false;
        Exception capturedException;

        Account acc = TestDataFactory.createAccountAndInsert('test Account');
        System.assertEquals(true, acc.Id != null, 'Account doesn\'t exist');

        List<Company_Data__c> cdl = TestDataFactory.createCompanyDataAndInsert(acc.Id, 10);
        System.assertEquals(10, cdl.size(), 'Company_Data__c list should have be 10');

        try {
        	Test.startTest();
                result = ConflictCheckController.checkIfCompanyDataExists(acc.Id);
            Test.stopTest();
        } catch (Exception e) {
            hasError = true;
            capturedException = e;
        }

        System.assertEquals(false, hasError, 'Exception was thrown');
        System.assertEquals(true, result.status, 'Status is false');
        System.assertEquals(true, result.returnData, 'Message is false');
    }

    @IsTest
    static void checkIfCompanyDataExists_SUCCESS_T03() {
        ResponseData result;
        Boolean hasError = false;
        Exception capturedException;

        Opportunity opp = TestDataFactory.createOppAndOppLineItems();
        System.assertEquals(true, opp.Id != null, 'Opportunity doesn\'t exist');
        System.assertEquals(true, opp.AccountId != null, 'Account doesn\'t exist');

        List<Company_Data__c> cdl = TestDataFactory.createCompanyDataAndInsert(opp.AccountId, 10);
        System.assertEquals(10, cdl.size(), 'Company_Data__c list should have be 10');

        Onboarding__c onb = TestDataFactory.createOnboardingAndInsert(opp.AccountId, opp.Id);
        System.assertEquals(true, onb.Id != null, 'Onboarding doesn\'t exist');

        try {
        	Test.startTest();
                result = ConflictCheckController.checkIfCompanyDataExists(onb.Id);
            Test.stopTest();
        } catch (Exception e) {
            hasError = true;
            capturedException = e;
        }

        System.assertEquals(false, hasError, 'Exception was thrown');
        System.assertEquals(true, result.status, 'Status is false');
        System.assertEquals(true, result.returnData, 'Message is false');
    }

    @IsTest
    static void initiateConflictCheck_FAILURE_T01() {
        ResponseData result;
        Boolean hasError = false;
        Exception capturedException;

        try {
        	Test.startTest();
                result = ConflictCheckController.initiateConflictCheck(null);
            Test.stopTest();
        } catch (Exception e) {
            hasError = true;
            capturedException = e;
        }

        System.assertEquals(true, hasError, 'No exception was thrown');
        System.assertNotEquals(null, capturedException, 'Exception should be thrown');
        System.assertEquals(AuraHandledException.class.getName(), capturedException.getTypeName(), 'AuraHandledException is expected');
        System.assertEquals('Record Id is invalid or missing.', capturedException.getMessage(), 'Specific error message is expected');
    }

    @IsTest
    static void initiateConflictCheck_FAILURE_T02() {
        ResponseData result;
        Boolean hasError = false;
        Exception capturedException;

        try {
            Test.startTest();
                result = ConflictCheckController.initiateConflictCheck('XXXXXXXXXXXXXXX');
            Test.stopTest();
        } catch (Exception e) {
            hasError = true;
            capturedException = e;
        }

        System.assertEquals(true, hasError, 'No exception was thrown');
        System.assertNotEquals(null, capturedException, 'Exception should be thrown');
        System.assertEquals(ConflictCheckHelper.ConflictCheckException.class.getName(), capturedException.getTypeName(), 'ConflictCheckHelper.ConflictCheckException is expected');
        System.assertEquals('Invalid id: XXXXXXXXXXXXXXX', capturedException.getMessage(), 'Specific error message is expected');
    }

    @IsTest
    static void initiateConflictCheck_SUCCESS_T01() {
        ResponseData result1;
        ResponseData result2;
        ResponseData ccResult;
        List<Conflict_Check__c> ccList;
        String connectId = 'GB-0-XXXXXXXX';

        Credisafe_Callout_Settings__c creditsafeCalloutSettings = TestDataFactory.createCredisafeCalloutSettings();
        insert creditsafeCalloutSettings;

        List<Countries__c> countryList = TestDataFactory.createCountryListSettings();
        insert countryList;

        Account acc1 = TestDataFactory.createAccountAndInsert('Test Account 1', connectId);
        System.assertEquals(true, acc1.Id != null, 'Account 1 doesn\'t exist');

        Account acc2 = TestDataFactory.createAccountAndInsert('Test Account 2', connectId);
        System.assertEquals(true, acc2.Id != null, 'Account 2 doesn\'t exist');

        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();

        multimock.setStaticResource('callout:CredisafeCallout/authenticate', 'CreditsafeCalloutMockAuthentication_SUCCESS'  );      // 3 test contacts
        multimock.setStaticResource('callout:CredisafeCallout/companies/' + connectId + '?language=' + 'en', 'CreditsafeCalloutMockCompanyCreditReport_SUCCESS');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, multimock);
        result1 = UpdateCompanyDataController.newCompanyCreditReport(connectId, acc1.Id);

        String parentId = acc1.Id;
        // Query for all Company_Data__c records
        String query = String.format('SELECT {0} FROM {1} WHERE Account__c = \'\'{2}\'\'',
            new String[] {
                String.join(
                    new List<String>(
                        Company_Data__c.SObjectType.getDescribe().fields.getMap().keySet()
                    ),
                    ','
                ),
                String.valueOf(Company_Data__c.SObjectType),
                parentId
            }
        );
        List<Company_Data__c> children = new List<Company_Data__c>();
        for (Company_Data__c child:(List<Company_Data__c>)Database.query(query)) {
            children.add(child.clone(false,true,false,false));
        }

        System.assertEquals(true, !children.isEmpty(), 'Company_Data__c List cloneing failed!');

        for (Company_Data__c child : children) {
            child.Account__c = acc2.Id;
        }
        //Insert the Company_Data__c Records
        Database.insert(children);

        ccResult = ConflictCheckController.initiateConflictCheck(acc1.Id);
        String ccQuery = String.format('SELECT {0} FROM {1} WHERE Source_Account__c = \'\'{2}\'\'',
            new String[] {
                String.join(
                    new List<String>(
                        Conflict_Check__c.SObjectType.getDescribe().fields.getMap().keySet()
                    ),
                    ','
                ),
                String.valueOf(Conflict_Check__c.SObjectType),
                parentId
            }
        );

        ccList = Database.query(ccQuery);
        System.assertEquals(true, !ccList.isEmpty(), 'Conflict_Check__c List is empty!');
        Test.stopTest();

        System.assertEquals(true, result1.status, 'Status should be TRUE');
        System.assertNotEquals(null, result1.returnData, 'The response data should not be NULL');
        System.assertEquals(true, result1.returnData instanceof List<CreditsafeCalloutHelper.CompanyUpdateResult>, 'Status should be TRUE');
        List<CreditsafeCalloutHelper.CompanyUpdateResult> report1 = (List<CreditsafeCalloutHelper.CompanyUpdateResult>)result1.returnData;
        System.assertEquals(9, report1.size(), 'Status should be TRUE');

        System.assertEquals(9, ccList.size(), 'There should be 9 conflicts');
    }
}