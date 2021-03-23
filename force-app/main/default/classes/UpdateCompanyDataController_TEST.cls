/**
 * @description       : Test class for the UpdateCompanyDataController class
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 12-09-2020
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   11-13-2020   Bluewave | Tomasz Piechota   Initial Version
**/
@IsTest
public class UpdateCompanyDataController_TEST {

    /**
    * @description Test data setup
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @TestSetup
    static void makeData(){
        Credisafe_Callout_Settings__c creditsafeCalloutSettings = TestDataFactory.createCredisafeCalloutSettings();
        insert creditsafeCalloutSettings;

        List<Account> accList = new List<Account> {
            TestDataFactory.createAccount('Test Company 1'),
            TestDataFactory.createAccount('Test Company 2', 'GB-0-XXXXXXXX')
        };
        insert accList;
    }

    /**
    * @description Verify if the default custom setting exist by name
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void getCreditsafeCalloutSettingsT01() {
        Credisafe_Callout_Settings__c cs;

        Test.startTest();
            cs = (Credisafe_Callout_Settings__c) UpdateCompanyDataController.getCreditsafeCalloutSettings('Default');
        Test.stopTest();

        System.assert(cs != null, 'Credisafe Callout Settings cannot be null.');
        System.assertEquals('Default', cs.Name, 'Name did not match the default settings name.');
        System.assert(cs.Exact__c != null, 'Exact cannot be null.');
        System.assert(cs.Encoding__c != null, 'Encoding cannot be null.');
        System.assert(cs.Language__c != null, 'Language cannot be null.');
        System.assert(cs.Page_Size_Max__c != null, 'Page Size Max cannot be null.');
        System.assert(cs.Page_Size__c != null, 'Page Size cannot be null.');
        System.assert(cs.Page__c != null, 'Page cannot be null.');
    }

    /**
    * @description Verify if the default custom setting
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void getCreditsafeCalloutSettingsT02() {
        Credisafe_Callout_Settings__c cs;

        Test.startTest();
            cs = (Credisafe_Callout_Settings__c) UpdateCompanyDataController.getCreditsafeCalloutSettings(null);
        Test.stopTest();

        System.assert(cs != null, 'Credisafe Callout Settings cannot be null.');
        System.assertEquals('Default', cs.Name, 'Name did not match the default settings name.');
        System.assert(cs.Exact__c != null, 'Exact cannot be null.');
        System.assert(cs.Encoding__c != null, 'Encoding cannot be null.');
        System.assert(cs.Language__c != null, 'Language cannot be null.');
        System.assert(cs.Page_Size_Max__c != null, 'Page Size Max cannot be null.');
        System.assert(cs.Page_Size__c != null, 'Page Size cannot be null.');
        System.assert(cs.Page__c != null, 'Page cannot be null.');
    }

    /**
    * @description Get list of countries (Custom Settings) - SUCCESS
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void getCountriesListT01() {
        ResponseData result;

        List<Countries__c> countryList = TestDataFactory.createCountryListSettings();
        insert countryList;


        Test.startTest();
            result = UpdateCompanyDataController.getCountriesList();
        Test.stopTest();

        List<CreditsafeCalloutHelper.Country> cl = (List<CreditsafeCalloutHelper.Country>) result.returnData;
        System.assert(cl.size() > 0, 'Countries do not exist');
        System.assertEquals(true, result.status, 'Status cannot be false if countries do exist.');
    }

    /**
    * @description Get list of countries (Custom Settings) - FAILURE
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void getCountriesListT02() {
        ResponseData result;

        List<Countries__c> countryList = new List<Countries__c>();
        insert countryList;

        Test.startTest();
            result = UpdateCompanyDataController.getCountriesList();
        Test.stopTest();

        System.assertEquals(false, result.status, 'Status cannot be true if countries do not exist.');
        System.assertEquals('Error while retrieving countries.', result.message, 'Message is mising.');
    }

    /**
    * @description Get list of countries (Custom Settings) - FAILURE
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void getCountriesListT03() {
        ResponseData result;

        Test.startTest();
            result = UpdateCompanyDataController.getCountriesList();
        Test.stopTest();

        System.assertEquals(false, result.status, 'Status cannot be true if countries do not exist.');
        System.assertEquals('Error while retrieving countries.', result.message, 'Message is mising.');
    }

    /**
    * @description Get list of Reasons (Custom Settings) - SUCCESS
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void getCredisafeCreditReportReasonsDET01() {
        ResponseData result;

        List<Credisafe_Credit_Report_Reasons_DE__c> reasonList = TestDataFactory.createCredisafeCreditReportReasons();
        insert reasonList;

        Test.startTest();
            result = UpdateCompanyDataController.getCredisafeCreditReportReasonsDE();
        Test.stopTest();

        List<CreditsafeCalloutHelper.Reason> rl = (List<CreditsafeCalloutHelper.Reason>) result.returnData;
        System.assert(rl.size() > 0, 'Reasons do not exist');
        System.assertEquals(true, result.status, 'Status cannot be false if countries do exist.');
    }

    /**
    * @description Get list of Reasons (Custom Settings) - FAILURE
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void getCredisafeCreditReportReasonsDET02() {
        ResponseData result;

        List<Credisafe_Credit_Report_Reasons_DE__c> reasonList = new List<Credisafe_Credit_Report_Reasons_DE__c>();
        insert reasonList;


        Test.startTest();
            result = UpdateCompanyDataController.getCredisafeCreditReportReasonsDE();
        Test.stopTest();

        System.assertEquals(false, result.status, 'Status cannot be true if reasons do not exist.');
        System.assertEquals('Error while retrieving credit report reasons.', result.message, 'Message is mising.');
    }

    /**
    * @description Get list of Reasons (Custom Settings) - FAILURE
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void getCredisafeCreditReportReasonsDET03() {
        ResponseData result;

        Test.startTest();
            result = UpdateCompanyDataController.getCredisafeCreditReportReasonsDE();
        Test.stopTest();

        System.assertEquals(false, result.status, 'Status cannot be true if countries do not exist.');
        System.assertEquals('Error while retrieving credit report reasons.', result.message, 'Message is mising.');
    }

    /**
    * @description
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void newCompanySearchT01() {
        ResponseData result;
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

            result = UpdateCompanyDataController.newCompanySearch(countries, name, postCode, page, pageSize, regNo);

            System.assertEquals(result.status, false, 'TRUE is not expected');
            System.assertEquals(result.message, 'Creditsafe authentication failed. If the problem persists, please contact you System Administrator.', 'There should be an error messge');

        Test.stopTest();
    }

    /**
    * @description
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void newCompanySearchT02() {
        ResponseData result;
        List<Countries__c> countryList = TestDataFactory.createCountryListSettings();
        insert countryList;
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

            result = UpdateCompanyDataController.newCompanySearch(countries, name, postCode, page, pageSize, regNo);

            System.assertEquals(result.status, true, 'FALSE is not expected');
            System.assertNotEquals(result.returnData, null, 'There should be response data');
        Test.stopTest();
    }

    /**
    * @description Retrieve company(ies) credit report data with the Credisafe CreditReport callout - FAILURE,
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void newCompanySearchT03() {
        ResponseData result;
        List<Countries__c> countryList = TestDataFactory.createCountryListSettings();
        insert countryList;
        String connectId = 'GB-0-XXXXXXXX';
        Account acc = [SELECT Id, Connect_Id__c FROM Account WHERE Connect_Id__c = :connectId LIMIT 1];
        String countries = 'United Kingdom';
        String name = 'CREDITSAFE';
        String postCode = 'CF10*';
        Integer page = 1;
        Integer pageSize = 1;
        String regNo = null;

        String queryParams = CreditsafeCalloutHelper.getCompanySearchParamsString(countries, name, postCode, page, pageSize, regNo);
        queryParams = CreditsafeCalloutHelper.encodeUrlParams(queryParams);

        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();

        multimock.setStaticResource('callout:CredisafeCallout/authenticate', 'CreditsafeCalloutMockAuthentication_SUCCESS'  );      // 3 test contacts
        multimock.setStaticResource('callout:CredisafeCallout/companies?' + queryParams, 'CreditsafeCalloutMockCompanySearch_ERROR');
        multimock.setStatusCode(500);
        multimock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, multimock);
        result = UpdateCompanyDataController.newCompanySearch(countries, name, postCode, page, pageSize, regNo);
        Test.stopTest();

        System.assertEquals(false, result.status, 'Status should be false');
        System.assertEquals(null, result.message, 'Message should not exist');
        System.assertEquals(true, result.returnData instanceof CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper, 'The response data should be of type CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper');

        CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper crw = (CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper) result.returnData;
        System.assertEquals('Bad request', crw.details, 'Message should say "Bad request"');
    }

    /**
    * @description Retrieve company(ies) credit report data with the Credisafe CreditReport callout - FAILURE,
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void getNewCompanyCreditReportT01() {
        ResponseData result;

        Test.startTest();
            result = UpdateCompanyDataController.newCompanyCreditReport(null, null);
        Test.stopTest();

        System.assertEquals(false, result.status, 'Status cannot be true if countries do not exist.');
        System.assertEquals(System.Label.Message_Creditsafe_Company_Credit_Report_Invalid_Connect_Id, result.message, 'Message is mising.');
    }

    /**
    * @description Retrieve company(ies) credit report data with the Credisafe CreditReport callout - FAILURE,
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void getNewCompanyCreditReportT02() {
        ResponseData result;
        List<Countries__c> countryList = TestDataFactory.createCountryListSettings();
        insert countryList;
        String connectId = 'GB-0-XXXXXXXX';
        Account acc = [SELECT Id, Connect_Id__c FROM Account WHERE Connect_Id__c = :connectId LIMIT 1];
        String countries = 'United Kingdom';
        String name = 'CREDITSAFE';
        String postCode = 'CF10*';
        Integer page = 1;
        Integer pageSize = 1;
        String regNo = null;

        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();

        multimock.setStaticResource('callout:CredisafeCallout/authenticate', 'CreditsafeCalloutMockAuthentication_ERROR'  );      // 3 test contacts
        multimock.setStaticResource('callout:CredisafeCallout/companies/' + connectId + '?language=' + 'en', 'CreditsafeCalloutMockCompanyCreditReport_ERROR');
        multimock.setStatusCode(401);
        multimock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, multimock);
        result = UpdateCompanyDataController.newCompanyCreditReport(connectId, acc.Id);
        Test.stopTest();

        System.assertEquals(false, result.status, 'TRUE is not expected');
        System.assertEquals(System.Label.Message_Creditsafe_Company_Credit_Report_Authentication_Failed, result.message, 'There should be message');
    }

    /**
    * @description Retrieve company(ies) credit report data with the Credisafe CreditReport callout - SUCCESS,
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    /*@IsTest
    static void getNewCompanyCreditReportT04() {
        ResponseData result;
        List<Countries__c> countryList = TestDataFactory.createCountryListSettings();
        insert countryList;
        String connectId = 'GB-0-XXXXXXXX';
        Account acc = [SELECT Id, Connect_Id__c FROM Account WHERE Connect_Id__c = :connectId LIMIT 1];
        String countries = 'United Kingdom';
        String name = 'CREDITSAFE';
        String postCode = 'CF10*';
        Integer page = 1;
        Integer pageSize = 1;
        String regNo = null;

        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();

        multimock.setStaticResource('callout:CredisafeCallout/authenticate', 'CreditsafeCalloutMockAuthentication_SUCCESS'  );      // 3 test contacts
        multimock.setStaticResource('callout:CredisafeCallout/companies/' + connectId + '?language=' + 'en', 'CreditsafeCalloutMockCompanyCreditReport_SUCCESS');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, multimock);
        result = UpdateCompanyDataController.newCompanyCreditReport('GB-0-XXXXXXXX', acc.Id);
        Test.stopTest();

        System.assertEquals(true, result.status, 'Status should be TRUE');
        System.assertNotEquals(null, result.returnData, 'The response data should not be NULL');
        System.assertEquals(true, result.returnData instanceof List<CreditsafeCalloutHelper.CompanyUpdateResult>, 'Status should be TRUE');
    } */

    /**
    * @description Retrieve company(ies) credit report data with the Credisafe CreditReport callout - FAILURE,
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void getNewCompanyCreditReportT05() {
        ResponseData result;
        List<Countries__c> countryList = TestDataFactory.createCountryListSettings();
        insert countryList;
        String connectId = 'GB-0-XXXXXXXX';
        Account acc = [SELECT Id, Connect_Id__c FROM Account WHERE Connect_Id__c = :connectId LIMIT 1];
        String countries = 'United Kingdom';
        String name = 'CREDITSAFE';
        String postCode = 'CF10*';
        Integer page = 1;
        Integer pageSize = 1;
        String regNo = null;

        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();

        multimock.setStaticResource('callout:CredisafeCallout/authenticate', 'CreditsafeCalloutMockAuthentication_SUCCESS'  );      // 3 test contacts
        multimock.setStaticResource('callout:CredisafeCallout/companies/' + connectId + '?language=' + 'en', 'CreditsafeCalloutMockCompanyCreditReport_ERROR');
        multimock.setStatusCode(500);
        multimock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, multimock);
        result = UpdateCompanyDataController.newCompanyCreditReport(connectId, acc.Id);
        Test.stopTest();

        System.assertEquals(false, result.status, 'Status should be false');
        System.assertEquals(null, result.message, 'Message should not exist');
        System.assertEquals(true, result.returnData instanceof CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper, 'The response data should be of type CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper');

        CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper crw = (CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper) result.returnData;
        System.assertEquals('Invalid companyId', crw.details, 'Message should say "Invalid companyId"');
    }

    /**
    * @description Retrieve company(ies) credit report data with the Credisafe CreditReport callout - FAILURE,
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void getNewCompanyCreditReportT06() {
        ResponseData result;
        List<Countries__c> countryList = TestDataFactory.createCountryListSettings();
        insert countryList;
        String connectId = 'GB-0-XXXXXXXX';
        Account acc = [SELECT Id, Connect_Id__c FROM Account WHERE Connect_Id__c = :connectId LIMIT 1];
        String countries = 'United Kingdom';
        String name = 'CREDITSAFE';
        String postCode = 'CF10*';
        Integer page = 1;
        Integer pageSize = 1;
        String regNo = null;

        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();

        multimock.setStaticResource('callout:CredisafeCallout/authenticate', 'CreditsafeCalloutMockAuthentication_SUCCESS'  );      // 3 test contacts
        multimock.setStaticResource('callout:CredisafeCallout/companies/' + connectId + '?language=' + 'en', 'CreditsafeCalloutMockCompanyCreditReport_SUCCESS');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, multimock);
        result = UpdateCompanyDataController.newCompanyCreditReport('GB-0-XXXXXXXX', '');
        Test.stopTest();

        System.assertEquals(false, result.status, 'Status should be FALSE');
        System.assertEquals('Account Id or Credit Report is invalid or missing', result.message, 'Message is missing');
        System.assertEquals(null, result.returnData, 'The response data should be NULL');
    }

    /**
    * @description Retrieve company(ies) credit report data with the Credisafe CreditReport callout - FAILURE,
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void getNewCompanyCreditReportT07() {
        ResponseData result;
        List<Countries__c> countryList = TestDataFactory.createCountryListSettings();
        insert countryList;
        String connectId = 'GB-0-XXXXXXXX';
        String countries = 'United Kingdom';
        String name = 'CREDITSAFE';
        String postCode = 'CF10*';
        Integer page = 1;
        Integer pageSize = 1;
        String regNo = null;

        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();

        multimock.setStaticResource('callout:CredisafeCallout/authenticate', 'CreditsafeCalloutMockAuthentication_SUCCESS'  );      // 3 test contacts
        multimock.setStaticResource('callout:CredisafeCallout/companies/' + connectId + '?language=' + 'en', 'CreditsafeCalloutMockCompanyCreditReport_SUCCESS');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, multimock);
        result = UpdateCompanyDataController.newCompanyCreditReport('GB-0-XXXXXXXX', 'XXXXXXXXXXXXXXX');
        Test.stopTest();

        System.assertEquals(false, result.status, 'Status should be FALSE');
        System.assertEquals('Failed to update company data. Couldn\'t reterieve related account information.', result.message, 'Message is missing');
        System.assertEquals(null, result.returnData, 'The response data should be NULL');
    }

    /**
    * @description Retrieve company(ies) credit report data with the Credisafe CreditReport callout - FAILURE,
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void getNewCompanyCreditReportDET01() {
        ResponseData result;

        Test.startTest();
            result = UpdateCompanyDataController.newCompanyCreditReportDE(null, null, null);
        Test.stopTest();

        System.assertEquals(false, result.status, 'Status cannot be true if countries do not exist.');
        System.assertEquals('Connect Id or credit repord reason is invalid or missing.', result.message, 'Message is mising.');
    }

    /**
    * @description Retrieve company(ies) credit report data with the Credisafe CreditReport callout - FAILURE,
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void getNewCompanyCreditReportDET02() {
        ResponseData result;
        List<Countries__c> countryList = TestDataFactory.createCountryListSettings();
        insert countryList;
        String connectId = 'GB-0-XXXXXXXX';
        Account acc = [SELECT Id, Connect_Id__c FROM Account WHERE Connect_Id__c = :connectId LIMIT 1];
        String countries = 'United Kingdom';
        String name = 'CREDITSAFE';
        String postCode = 'CF10*';
        Integer page = 1;
        Integer pageSize = 1;
        String regNo = null;
        String reason = '1';

        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();

        multimock.setStaticResource('callout:CredisafeCallout/authenticate', 'CreditsafeCalloutMockAuthentication_ERROR'  );      // 3 test contacts
        multimock.setStaticResource('callout:CredisafeCallout/companies/' + connectId + '?language=' + 'en', 'CreditsafeCalloutMockCompanyCreditReport_ERROR');
        multimock.setStatusCode(401);
        multimock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, multimock);
        result = UpdateCompanyDataController.newCompanyCreditReportDE(connectId, acc.Id, reason);
        Test.stopTest();

        System.assertEquals(false, result.status, 'TRUE is not expected');
        System.assertEquals(System.Label.Message_Creditsafe_Company_Credit_Report_Authentication_Failed, result.message, 'There should be message');
    }

    /**
    * @description Retrieve company(ies) credit report data with the Credisafe CreditReport callout - SUCCESS,
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    /*@IsTest
    static void getNewCompanyCreditReportDET04() {
        ResponseData result;
        List<Countries__c> countryList = TestDataFactory.createCountryListSettings();
        insert countryList;
        String connectId = 'GB-0-XXXXXXXX';
        Account acc = [SELECT Id, Connect_Id__c FROM Account WHERE Connect_Id__c = :connectId LIMIT 1];
        String countries = 'United Kingdom';
        String name = 'CREDITSAFE';
        String postCode = 'CF10*';
        Integer page = 1;
        Integer pageSize = 1;
        String regNo = null;
        String reason = '1';
        String de_reason_code = String.isNotBlank(reason) ? '&customData=de_reason_code::' + reason : '';

        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();

        multimock.setStaticResource('callout:CredisafeCallout/authenticate', 'CreditsafeCalloutMockAuthentication_SUCCESS'  );      // 3 test contacts
        multimock.setStaticResource('callout:CredisafeCallout/companies/' + connectId + '?language=' + 'en' + de_reason_code, 'CreditsafeCalloutMockCompanyCreditReport_SUCCESS');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, multimock);
        result = UpdateCompanyDataController.newCompanyCreditReportDE(connectId, acc.Id, reason);

        System.assertEquals(true, result.status, 'Status should be TRUE');
        System.assertNotEquals(null, result.returnData, 'The response data should not be NULL');
        System.assertEquals(true, result.returnData instanceof List<CreditsafeCalloutHelper.CompanyUpdateResult>, 'Status should be TRUE');
        Test.stopTest();
    } */

    /**
    * @description Retrieve company(ies) credit report data with the Credisafe CreditReport callout - FAILURE,
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void getNewCompanyCreditReportDET05() {
        ResponseData result;
        List<Countries__c> countryList = TestDataFactory.createCountryListSettings();
        insert countryList;
        String connectId = 'GB-0-XXXXXXXX';
        Account acc = [SELECT Id, Connect_Id__c FROM Account WHERE Connect_Id__c = :connectId LIMIT 1];
        String countries = 'United Kingdom';
        String name = 'CREDITSAFE';
        String postCode = 'CF10*';
        Integer page = 1;
        Integer pageSize = 1;
        String regNo = null;
        String reason = '1';
        String de_reason_code = String.isNotBlank(reason) ? '&customData=de_reason_code::' + reason : '';

        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();

        multimock.setStaticResource('callout:CredisafeCallout/authenticate', 'CreditsafeCalloutMockAuthentication_SUCCESS'  );      // 3 test contacts
        multimock.setStaticResource('callout:CredisafeCallout/companies/' + connectId + '?language=' + 'en' + de_reason_code, 'CreditsafeCalloutMockCompanyCreditReport_ERROR');
        multimock.setStatusCode(500);
        multimock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, multimock);
        result = UpdateCompanyDataController.newCompanyCreditReportDE(connectId, acc.Id, reason);
        Test.stopTest();

        System.assertEquals(false, result.status, 'Status should be false');
        System.assertEquals(null, result.message, 'Message should not exist');
        System.assertEquals(true, result.returnData instanceof CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper, 'The response data should be of type CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper');

        CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper crw = (CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper) result.returnData;
        System.assertEquals('Invalid companyId', crw.details, 'Message should say "Invalid companyId"');
    }

    /**
    * @description Retrieve company(ies) credit report data with the Credisafe CreditReport callout - FAILURE,
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void getNewCompanyCreditReportDET06() {
        ResponseData result;
        List<Countries__c> countryList = TestDataFactory.createCountryListSettings();
        insert countryList;
        String connectId = 'GB-0-XXXXXXXX';
        Account acc = [SELECT Id, Connect_Id__c FROM Account WHERE Connect_Id__c = :connectId LIMIT 1];
        String countries = 'United Kingdom';
        String name = 'CREDITSAFE';
        String postCode = 'CF10*';
        Integer page = 1;
        Integer pageSize = 1;
        String regNo = null;
        String reason = '1';
        String de_reason_code = String.isNotBlank(reason) ? '&customData=de_reason_code::' + reason : '';

        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();

        multimock.setStaticResource('callout:CredisafeCallout/authenticate', 'CreditsafeCalloutMockAuthentication_SUCCESS'  );      // 3 test contacts
        multimock.setStaticResource('callout:CredisafeCallout/companies/' + connectId + '?language=' + 'en' + de_reason_code, 'CreditsafeCalloutMockCompanyCreditReport_SUCCESS');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, multimock);
        result = UpdateCompanyDataController.newCompanyCreditReportDE(connectId, '', reason);
        Test.stopTest();

        System.assertEquals(false, result.status, 'Status should be FALSE');
        System.assertEquals('Account Id or Credit Report is invalid or missing', result.message, 'Message is missing');
        System.assertEquals(null, result.returnData, 'The response data should be NULL');
    }

    /**
    * @description Retrieve company(ies) credit report data with the Credisafe CreditReport callout - FAILURE,
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @IsTest
    static void getNewCompanyCreditReportDET07() {
        ResponseData result;
        List<Countries__c> countryList = TestDataFactory.createCountryListSettings();
        insert countryList;
        String connectId = 'GB-0-XXXXXXXX';
        String countries = 'United Kingdom';
        String name = 'CREDITSAFE';
        String postCode = 'CF10*';
        Integer page = 1;
        Integer pageSize = 1;
        String regNo = null;
        String reason = '1';
        String de_reason_code = String.isNotBlank(reason) ? '&customData=de_reason_code::' + reason : '';

        Test.startTest();
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();

        multimock.setStaticResource('callout:CredisafeCallout/authenticate', 'CreditsafeCalloutMockAuthentication_SUCCESS'  );      // 3 test contacts
        multimock.setStaticResource('callout:CredisafeCallout/companies/' + connectId + '?language=' + 'en' + de_reason_code, 'CreditsafeCalloutMockCompanyCreditReport_SUCCESS');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, multimock);
        result = UpdateCompanyDataController.newCompanyCreditReportDE(connectId, 'XXXXXXXXXXXXXXX', reason);
        Test.stopTest();

        System.assertEquals(false, result.status, 'Status should be FALSE');
        System.assertEquals('Failed to update company data. Couldn\'t reterieve related account information.', result.message, 'Message is missing');
        System.assertEquals(null, result.returnData, 'The response data should be NULL');
    }
}