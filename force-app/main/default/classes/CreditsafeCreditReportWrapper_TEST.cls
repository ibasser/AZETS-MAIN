/**
 * @description       :
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 12-11-2020
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   12-11-2020   Bluewave | Tomasz Piechota   Initial Version
**/
@IsTest
public class CreditsafeCreditReportWrapper_TEST {

    /**
    * @description Test data setup
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @TestSetup
    static void makeData(){
        Credisafe_Callout_Settings__c creditsafeCalloutSettings = TestDataFactory.createCredisafeCalloutSettings();
        insert creditsafeCalloutSettings;

        List<Countries__c> countryList = TestDataFactory.createCountryListSettings();
        insert countryList;

        Account a = TestDataFactory.createAccount('Test Company 2', 'GB-0-XXXXXXXX');
        insert a;
    }

    @IsTest
    static void CreditsafeCreditReportWrapperT01() {
        CreditsafeCreditReportWrapper cr;
        String connectId = 'GB-0-XXXXXXXX';
        List<Account> acc = [SELECT Id, Connect_Id__c FROM Account WHERE Connect_Id__c = :connectId LIMIT 1];

        Test.startTest();
            // Create the mock response based on a static resource
            StaticResourceCalloutMock mockAuth = new StaticResourceCalloutMock();
            mockAuth.setStaticResource('CreditsafeCalloutMockAuthentication_SUCCESS');
            mockAuth.setStatusCode(200);
            mockAuth.setStatus('OK');
            mockAuth.setHeader('Content-Type', 'application/json');

            Test.setMock(HttpCalloutMock.class, mockAuth);

            // Call method to test
            HttpResponse resultMockAuth = CreditsafeCallout.creditsafeAuthenticate();

            // Verify mock response is not null
            System.assertNotEquals(null, resultMockAuth, 'The callout returned a null response.');

            // Verify status code
            System.assertEquals(200, resultMockAuth.getStatusCode(), 'The status code is not 200.');

            // Verify content type
            System.assertEquals('application/json', resultMockAuth.getHeader('Content-Type'), 'The content type value is not expected.');

            // Verify the response
            CreditsafeCalloutHelper.CredisafeToken authTokenObject = new CreditsafeCalloutHelper.CredisafeToken(resultMockAuth);

            System.assertNotEquals(null, authTokenObject.token, 'Token is NULL');
            System.assert(String.isNotBlank(authTokenObject.token), 'Authentication successful');

            StaticResourceCalloutMock mockReport = new StaticResourceCalloutMock();
            mockReport.setStaticResource('CreditsafeCalloutMockCompanyCreditReport_SUCCESS');
            mockReport.setStatusCode(200);
            mockReport.setStatus('OK');
            mockReport.setHeader('Content-Type', 'application/json');

            Test.setMock(HttpCalloutMock.class, mockReport);

            // Call method to test
            HttpResponse resultMockReport = CreditsafeCallout.creditsafeCompanyCreditReport(authTokenObject.token, 'GB-0-XXXXXXXX', null);
            // Verify mock response is not null
            System.assertNotEquals(null, resultMockReport, 'The callout returned a null response.');
            // Verify status code
            System.assertEquals(200, resultMockReport.getStatusCode(), 'The status code is not 200.');
            // Verify content type
            System.assertEquals('application/json', resultMockReport.getHeader('Content-Type'), 'The content type value is not expected.');

            cr = CreditsafeCreditReportWrapper.parse(resultMockReport.getBody());
        Test.stopTest();

        System.assertNotEquals(null, cr, 'null creditReport.');

        System.assertEquals('TESTTEST-TEST-TEST-TEST-TESTTESTTEST', cr.correlationId, 'String does not match');
        System.assertEquals('111111111', cr.orderId, 'String does not match');
        System.assertEquals('GB-0-XXXXXXXX', cr.companyId, 'String does not match');
        System.assertEquals('2020-12-04T15:33:25.646Z', cr.dateOfOrder, 'String does not match');
        System.assertEquals('en', cr.language, 'String does not match');
        System.assertEquals('111111111', cr.userId, 'String does not match');
        System.assertEquals('chargeReference TEST', cr.chargeReference, 'String does not match');

        System.assertNotEquals(null, cr.messages, 'Message does not exist');
        System.assertEquals(true, cr.messages.size() == 2, 'No messages');
        System.assertEquals('XXX', cr.messages.get(0).code, 'String does not match');
        System.assertEquals('TEST MESSAge', cr.messages.get(0).text, 'String does not match');
        System.assertEquals('XXX', cr.messages.get(1).code, 'String does not match');
        System.assertEquals('TEST MESSAge', cr.messages.get(1).text, 'String does not match');

        System.assertNotEquals(null, cr.failedSections, 'failedSections does not exist');
        System.assertEquals(true, cr.failedSections.size() > 0, 'No failedSections');
        System.assertEquals('Nothing to do', cr.failedSections.get(0), 'String does not match');
        System.assertEquals('Nothing to do', cr.failedSections.get(1), 'String does not match');

        CreditsafeCreditReportWrapper.Report r = cr.report;
        System.assertNotEquals(null, r, 'Report does not exist');
        System.assertEquals('GB-0-11111111', r.companyId, 'String does not match');
        System.assertEquals('EN', r.language, 'String does not match');



        //System.assertEquals('TESTTEST-TEST-TEST-TEST-TESTTESTTEST', cr.correlationId, 'String does not match');
    }
}