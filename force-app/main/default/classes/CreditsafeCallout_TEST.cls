/**
 * @description       : Test class for the CreditsafeCallout class
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 12-11-2020
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   11-13-2020   Bluewave | Tomasz Piechota   Initial Version
**/
@IsTest
private class CreditsafeCallout_TEST {

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
    }

    /**
    * @description Creditsafe Authentication - SUCCESS
    * @author Bluewave | Tomasz Piechota | 12-04-2020
    **/
    @IsTest
    static void creditsafeAuthenticateT01() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('CreditsafeCalloutMockAuthentication_SUCCESS');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.startTest();
            // Associate the callout with a mock response
            Test.setMock(HttpCalloutMock.class, mock);

            // Call method to test
            HttpResponse result = CreditsafeCallout.creditsafeAuthenticate();

            // Verify mock response is not null
            System.assertNotEquals(null, result, 'The callout returned a null response.');

            // Verify status code
            System.assertEquals(200, result.getStatusCode(), 'The status code is not 200.');

            // Verify content type
            System.assertEquals('application/json', result.getHeader('Content-Type'), 'The content type value is not expected.');

            // Verify the response
            CreditsafeCalloutHelper.CredisafeToken authTokenObject = new CreditsafeCalloutHelper.CredisafeToken(result);

            System.assertNotEquals(null, authTokenObject.token, 'Token is NULL');
            System.assert(String.isNotBlank(authTokenObject.token), 'Authentication successful');
        Test.stopTest();
    }

    /**
    * @description Creditsafe Authentication - UNAUTHORIZED
    * @author Bluewave | Tomasz Piechota | 12-04-2020
    **/
    @IsTest
    static void creditsafeAuthenticateT02() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('CreditsafeCalloutMockAuthentication_ERROR');
        mock.setStatusCode(401);
        mock.setStatus('Unauthorized');
        mock.setHeader('Content-Type', 'application/json');

        Test.startTest();
            // Associate the callout with a mock response
            Test.setMock(HttpCalloutMock.class, mock);

            // Call method to test
            HttpResponse result = CreditsafeCallout.creditsafeAuthenticate();

            // Verify status code
            System.assertEquals(401, result.getStatusCode(), 'The status code is not 401.');

            // Verify content type
            System.assertEquals('application/json', result.getHeader('Content-Type'), 'The content type value is not expected.');

            // Verify the response
            CreditsafeCalloutHelper.CredisafeToken authTokenObject = new CreditsafeCalloutHelper.CredisafeToken(result);

            System.assertEquals(null, authTokenObject.token, 'Token should be NULL');
            System.assertEquals(authTokenObject.status, false, 'TRUE is not expected');
            System.assert(String.isNotBlank(authTokenObject.error), 'Authentication failed');
        Test.stopTest();
    }

    /**
    * @description Creditsafe Company Search - FAILED AUTHENTICATION
    * @author Bluewave | Tomasz Piechota | 12-04-2020
    **/
    @IsTest
    static void creditsafeCompanySearchT01() {
        String countries = 'United Kingdom';
        String name = 'CREDITSAFE';
        String postCode = 'CF10*';
        Integer page = 1;
        Integer pageSize = 1;
        String regNo = null;

        Test.startTest();
            // Create the mock response based on a static resource
            StaticResourceCalloutMock mockAuth = new StaticResourceCalloutMock();
            mockAuth.setStaticResource('CreditsafeCalloutMockAuthentication_ERROR');
            mockAuth.setStatusCode(401);
            mockAuth.setStatus('Unauthorized');
            mockAuth.setHeader('Content-Type', 'application/json');

            Test.setMock(HttpCalloutMock.class, mockAuth);
            // Call method to test
            HttpResponse resultMockAuth = CreditsafeCallout.creditsafeAuthenticate();
            // Verify status code
            System.assertEquals(401, resultMockAuth.getStatusCode(), 'The status code is not 401.');
            // Verify content type
            System.assertEquals('application/json', resultMockAuth.getHeader('Content-Type'), 'The content type value is not expected.');
            // Verify the response
            CreditsafeCalloutHelper.CredisafeToken authTokenObject = new CreditsafeCalloutHelper.CredisafeToken(resultMockAuth);

            System.assertEquals(null, authTokenObject.token, 'Token should be NULL');
            System.assertEquals(authTokenObject.status, false, 'TRUE is not expected');
            System.assert(String.isNotBlank(authTokenObject.error), 'Authentication failed');

            // Call method to test
            HttpResponse resultMockSearch = CreditsafeCallout.creditsafeCompanySearch(authTokenObject.token, countries, name, postCode, page, pageSize, regNo);
            // Verify mock response is not null
            System.assertEquals(null, resultMockSearch, 'The callout should return a null response.');
        Test.stopTest();
    }

    /**
    * @description Creditsafe Company Search - SUCCESS
    * @author Bluewave | Tomasz Piechota | 12-04-2020
    **/
    @IsTest
    static void creditsafeCompanySearchT02() {
        String countries = 'United Kingdom';
        String name = 'CREDITSAFE';
        String postCode = 'CF10*';
        Integer page = 1;
        Integer pageSize = 1;
        String regNo = null;

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

            StaticResourceCalloutMock mockSearch = new StaticResourceCalloutMock();
            mockSearch.setStaticResource('CreditsafeCalloutMockCompanySearch_SUCCESS');
            mockSearch.setStatusCode(200);
            mockSearch.setStatus('OK');
            mockSearch.setHeader('Content-Type', 'application/json');

            Test.setMock(HttpCalloutMock.class, mockSearch);

            // Call method to test
            HttpResponse resultMockSearch = CreditsafeCallout.creditsafeCompanySearch(authTokenObject.token, countries, name, postCode, page, pageSize, regNo);
            // Verify mock response is not null
            System.assertNotEquals(null, resultMockSearch, 'The callout returned a null response.');
            // Verify status code
            System.assertEquals(200, resultMockSearch.getStatusCode(), 'The status code is not 200.');
            // Verify content type
            System.assertEquals('application/json', resultMockAuth.getHeader('Content-Type'), 'The content type value is not expected.');
        Test.stopTest();
    }

     /**
    * @description Creditsafe Company Credit Report - FAILED AUTHENTICATION
    * @author Bluewave | Tomasz Piechota | 12-04-2020
    **/
    @IsTest
    static void creditsafeCompanyCreditReportT01() {
        Test.startTest();
            // Create the mock response based on a static resource
            StaticResourceCalloutMock mockAuth = new StaticResourceCalloutMock();
            mockAuth.setStaticResource('CreditsafeCalloutMockAuthentication_SUCCESS');
            mockAuth.setStatusCode(401);
            mockAuth.setStatus('Unauthorized');
            mockAuth.setHeader('Content-Type', 'application/json');

            Test.setMock(HttpCalloutMock.class, mockAuth);
            // Call method to test
            HttpResponse resultMockAuth = CreditsafeCallout.creditsafeAuthenticate();
            // Verify status code
            System.assertEquals(401, resultMockAuth.getStatusCode(), 'The status code is not 401.');
            // Verify content type
            System.assertEquals('application/json', resultMockAuth.getHeader('Content-Type'), 'The content type value is not expected.');
            // Verify the response
            CreditsafeCalloutHelper.CredisafeToken authTokenObject = new CreditsafeCalloutHelper.CredisafeToken(resultMockAuth);

            System.assertEquals(null, authTokenObject.token, 'Token should be NULL');
            System.assertEquals(authTokenObject.status, false, 'TRUE is not expected');
            System.assert(String.isNotBlank(authTokenObject.error), 'Authentication failed');

            // Call method to test
            HttpResponse resultMockReport = CreditsafeCallout.creditsafeCompanyCreditReport(null, 'GB-0-XXXXXXXX', null);
            // Verify mock response is not null
            System.assertEquals(null, resultMockReport, 'The callout should return a null response.');
        Test.stopTest();
    }

     /**
    * @description Creditsafe Company Credit Report - SUCCESS
    * @author Bluewave | Tomasz Piechota | 12-04-2020
    **/
    @IsTest
    static void creditsafeCompanyCreditReportT02() {
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
        Test.stopTest();
    }
}