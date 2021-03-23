@isTest
public with sharing class SmartSearchCalloutHandler_Test {
    @TestSetup
    static void makeData(){
        
        List<SmartSearchDetails__c> smartSearchDetails = new List<SmartSearchDetails__c>();
        SmartSearchDetails__c sandbox = new SmartSearchDetails__c();
        sandbox.Name = 'Sandbox';
        sandbox.Url__c = 'Whatever';
        smartSearchDetails.add(sandbox);
        SmartSearchDetails__c production = new SmartSearchDetails__c();
        production.Name = 'Production';
        production.Url__c = 'Whatever';
        smartSearchDetails.add(production);

        insert smartSearchDetails;
    }

    @isTest
    static void test01_setSmartSearchDetails(){
        Test.startTest();
        Boolean result = SmartSearchCalloutHandler.getSmartSearchDetails();
        Boolean orgIsProduction = !([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox);
        Test.stopTest();
        System.assertEquals(true,result);

        //Test that code is picking the right Custom Metadata
        if (orgIsProduction) {
            System.assertEquals('Production', SmartSearchCalloutHandler.smartSearchDetails.name);
        } else {
            System.assertEquals('Sandbox', SmartSearchCalloutHandler.smartSearchDetails.name);

        }

    }

    @isTest
    static void test02_getBearerToken(){

        //Instantiate mock using a static resource
        StaticResourceCalloutMock mock = setUpMock('SmartSearchMockAuthToken_SUCCESS');
        
        // Associate the callout with a mock response
        // Note: the actual details of the call are irrelevant, 
        // since the response will be set by the mock
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
            Boolean result = SmartSearchCalloutHandler.getBearerToken();
        Test.stopTest();

        System.assertEquals('Bearer thisIsAValidToken', SmartSearchCalloutHandler.bearerToken);

    }

    @isTest
    static void test03_getBearerTokenERROR(){

        //Instantiate mock using a static resource
        StaticResourceCalloutMock mock = setUpMock('SmartSearchMockAuthToken_ERROR');
        
        // Associate the callout with a mock response
        // Note: the actual details of the call are irrelevant, 
        // since the response will be set by the mock
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        try
        {
            SmartSearchCalloutHandler.getBearerToken();
        }
        catch(AuraHandledException e)
        {
            System.assert(e.getMessage().contains('Error: Unable to authenticate with Smart Search:'));
        }
        Test.stopTest();
    }

    @isTest
    static void test04_runDJOCalloutForAccountSUCCESS(){

        //Instantiate mock using a static resource
        StaticResourceCalloutMock mock = setUpMock('SmartSearchMockDJO_SUCCESS');
        
        // Associate the callout with a mock response
        // Note: the actual details of the call are irrelevant, 
        // since the response will be set by the mock
        Test.setMock(HttpCalloutMock.class, mock);
        Account testAcc = new Account(Name = 'BW_Test1', Company_Reg_Number__c = '12345678', Registered_Postcode__c = 'LS1 5SH');
        insert testAcc;
        Test.startTest();
        String djoString = SmartSearchCalloutHandler.runDJOCalloutForAccount(testAcc);
        Test.stopTest();

        SmartSearchWrappers.DJO_Response djoResponse = new SmartSearchWrappers.DJO_Response();
        Type djoResponseType = Type.forName('SmartSearchWrappers.DJO_Response');
        djoResponse = (SmartSearchWrappers.DJO_Response)JSON.deserialize(djoString, djoResponseType);

        System.assertEquals('BW_Test1', djoResponse.data.attributes.company_name);

    }

    @isTest
    static void test05_runDJOCalloutForCompanyDataSUCCESS(){

        //Instantiate mock using a static resource
        StaticResourceCalloutMock mock = setUpMock('SmartSearchMockDJO_SUCCESS');
        
        // Associate the callout with a mock response
        // Note: the actual details of the call are irrelevant, 
        // since the response will be set by the mock
        Test.setMock(HttpCalloutMock.class, mock);
        Account testAcc = new Account(Name = 'BW_Test1', Company_Reg_Number__c = '12345678', Registered_Postcode__c = 'LS1 5SH');
        insert testAcc;

        Company_Data__c testCompany = new Company_Data__c(Account__c = testAcc.Id,  Company_Name__c = 'BW_Test1', Registration_Number__c = '12345678', Address_Postcode__c = 'LS1 5SH');
        insert testCompany;
        Test.startTest();
        String djoString = SmartSearchCalloutHandler.runDJOCalloutForCompanyData(testCompany);
        Test.stopTest();

        SmartSearchWrappers.DJO_Response djoResponse = new SmartSearchWrappers.DJO_Response();
        Type djoResponseType = Type.forName('SmartSearchWrappers.DJO_Response');
        djoResponse = (SmartSearchWrappers.DJO_Response)JSON.deserialize(djoString, djoResponseType);

        System.assertEquals('BW_Test1', djoResponse.data.attributes.company_name);

    }

    @isTest
    static void test06_retrieveDJOCalloutSUCCESS(){

        //Instantiate mock using a static resource
        StaticResourceCalloutMock mock = setUpMock('SmartSearchMockDJORetrieve_SUCCESS');
        
        // Associate the callout with a mock response
        // Note: the actual details of the call are irrelevant, 
        // since the response will be set by the mock
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        String djoString = SmartSearchCalloutHandler.retrieveDJOCallout('2720942');
        Test.stopTest();
        
        SmartSearchWrappers.DJO_Response djoResponse = new SmartSearchWrappers.DJO_Response();
        Type djoResponseType = Type.forName('SmartSearchWrappers.DJO_Response');
        djoResponse = (SmartSearchWrappers.DJO_Response)JSON.deserialize(djoString, djoResponseType);

        System.assertEquals('IBM', djoResponse.data.attributes.company_name);
    }

    @isTest
    static void test07_retrieveUKAMLCalloutSUCCESS(){

        //Instantiate mock using a static resource
        StaticResourceCalloutMock mock = setUpMock('SmartSearchMockUKAMLRetrieve_SUCCESS');
        
        // Associate the callout with a mock response
        // Note: the actual details of the call are irrelevant, 
        // since the response will be set by the mock
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        String amlString = SmartSearchCalloutHandler.retrieveAMLCallout('2729623', 'GBR');
        Test.stopTest();

        SmartSearchWrappers.AML_Response amlResponse = new SmartSearchWrappers.AML_Response();
        Type amlResponseType = Type.forName('SmartSearchWrappers.AML_Response');
        amlResponse = (SmartSearchWrappers.AML_Response)JSON.deserialize(amlString, amlResponseType);

        System.assertEquals('John', amlResponse.data.attributes.name.first); 
        System.assertEquals('Howard', amlResponse.data.attributes.name.middle); 
        System.assertEquals('Smith', amlResponse.data.attributes.name.last); 
    }

    @isTest
    static void test08_retrieveUSAMLCalloutSUCCESS(){

        //Instantiate mock using a static resource
        StaticResourceCalloutMock mock = setUpMock('SmartSearchMockUSAMLRetrieve_SUCCESS');
        
        // Associate the callout with a mock response
        // Note: the actual details of the call are irrelevant, 
        // since the response will be set by the mock
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        String amlString = SmartSearchCalloutHandler.retrieveAMLCallout('2729657', 'USA');
        Test.stopTest();

        SmartSearchWrappers.AML_Response amlResponse = new SmartSearchWrappers.AML_Response();
        Type amlResponseType = Type.forName('SmartSearchWrappers.AML_Response');
        amlResponse = (SmartSearchWrappers.AML_Response)JSON.deserialize(amlString, amlResponseType);

        System.assertEquals('Evalyn', amlResponse.data.attributes.name.first); 
        System.assertEquals('Katherine', amlResponse.data.attributes.name.middle); 
        System.assertEquals('Croft', amlResponse.data.attributes.name.last); 
    }

    @isTest
    static void test09_runUKAMLCalloutSUCCESS(){

        //Instantiate mock using a static resource
        StaticResourceCalloutMock mock = setUpMock('SmartSearchMockUKAMLRun_SUCCESS');
        
        // Associate the callout with a mock response
        // Note: the actual details of the call are irrelevant, 
        // since the response will be set by the mock
        Test.setMock(HttpCalloutMock.class, mock);

        Account testAcc = new Account(Name = 'BW_Test1', Company_Reg_Number__c = '12345678', Registered_Postcode__c = 'LS1 5SH');
        insert testAcc;

        Date dob = Date.newInstance(2001, 01, 01);
        Company_Data__c testCompany = new Company_Data__c(Account__c = testAcc.Id,  Company_Name__c = 'BW_Test1', Registration_Number__c = '12345678', 
        Title__c = 'Mr', First_Name__c = 'John', Last_Name__c = 'Smith', Middle_Name__c = 'Howard', date_of_birth__c = dob, Address_Building__c = 'Mayfield House',
        Address_Flat__c = 'Flat 1', Address_Street_1__c = 'Lower Railway Road', Address_Street_2__c = '', Address_Town__c = 'Ilkley', Address_Region__c = 'West Yorkshire',
        Address_State__c = 'West Yorkshire', Address_Postcode__c = 'LS208BX', Country__c = 'GBR');
        insert testCompany;

        Test.startTest();
        String amlString = SmartSearchCalloutHandler.runAMLCalloutGBR(testCompany, 'normal');
        Test.stopTest();

        SmartSearchWrappers.AML_Response amlResponse = new SmartSearchWrappers.AML_Response();
        Type amlResponseType = Type.forName('SmartSearchWrappers.AML_Response');
        amlResponse = (SmartSearchWrappers.AML_Response)JSON.deserialize(amlString, amlResponseType);

        System.assertEquals('John', amlResponse.data.attributes.name.first); 
        System.assertEquals('Howard', amlResponse.data.attributes.name.middle); 
        System.assertEquals('Smith', amlResponse.data.attributes.name.last); 
    }

    @isTest
    static void test10_runUSAMLCalloutSUCCESS(){

        //Instantiate mock using a static resource
        StaticResourceCalloutMock mock = setUpMock('SmartSearchMockUSAMLRun_SUCCESS');
        
        // Associate the callout with a mock response
        // Note: the actual details of the call are irrelevant, 
        // since the response will be set by the mock
        Test.setMock(HttpCalloutMock.class, mock);

        Account testAcc = new Account(Name = 'BW_Test1', Company_Reg_Number__c = '12345678', Registered_Postcode__c = '46892');
        insert testAcc;

        Date dob = Date.newInstance(1988, 12, 26);
        Company_Data__c testCompany = new Company_Data__c(Account__c = testAcc.Id,  Company_Name__c = 'BW_Test1', Registration_Number__c = '12345678', 
        Title__c = 'Miss', First_Name__c = 'Evalyn', Last_Name__c = 'Croft', Middle_Name__c = 'Catherine', date_of_birth__c = dob, Address_Building__c = 'Midway Lane',
        Address_Flat__c = '', Address_Street_1__c = '43 Midway Lane', Address_Street_2__c = '', Address_Town__c = 'Franklin', Address_Region__c = '',
        Address_State__c = 'CA', Address_Postcode__c = '46892', Country__c = 'USA');
        insert testCompany;

        Test.startTest();
        String amlString = SmartSearchCalloutHandler.runAMLCalloutUSA(testCompany);
        Test.stopTest();

        SmartSearchWrappers.AML_Response amlResponse = new SmartSearchWrappers.AML_Response();
        Type amlResponseType = Type.forName('SmartSearchWrappers.AML_Response');
        amlResponse = (SmartSearchWrappers.AML_Response)JSON.deserialize(amlString, amlResponseType);

        System.assertEquals('Evalyn', amlResponse.data.attributes.name.first); 
        System.assertEquals('Katherine', amlResponse.data.attributes.name.middle); 
        System.assertEquals('Croft', amlResponse.data.attributes.name.last); 
    }

    @isTest
    static void test11_listDueDiligenceCalloutSUCCESS(){

        //Instantiate mock using a static resource
        StaticResourceCalloutMock mock = setUpMock('SmartSearchMockBusinessDDRetrieve_SUCCESS');
        
        // Associate the callout with a mock response
        // Note: the actual details of the call are irrelevant, 
        // since the response will be set by the mock
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        String updateResponse = SmartSearchCalloutHandler.listDueDiligenceCallout('2720942');
        Test.stopTest();

        Map<String, Object> responseMap  = (Map<String, Object>)JSON.deserializeUntyped(updateResponse);
        List<Object> dataList = (List<Object>)responseMap.get('data');
        Map<String, Object> dataMap = (Map<String, Object>)dataList[0];
        Map<String, Object> attributesMap = (Map<String, Object>)dataMap.get('attributes');
        System.assertEquals('847530', attributesMap.get('ddid'));
        System.assertEquals('IBM', attributesMap.get('name'));
        System.assertEquals('847530', attributesMap.get('dowjones_id'));

    }

    @isTest
    static void test12_updateDueDiligenceCalloutSUCCESS(){

        //Instantiate mock using a static resource
        StaticResourceCalloutMock mock = setUpMock('SmartSearchMockUpdateDD_SUCCESS');
        
        // Associate the callout with a mock response
        // Note: the actual details of the call are irrelevant, 
        // since the response will be set by the mock
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        String updateResponse = SmartSearchCalloutHandler.updateDueDiligenceCallout('2720942', '847530', 'no');
        Test.stopTest();

        Map<String, Object> responseMap  = (Map<String, Object>)JSON.deserializeUntyped(updateResponse);
        Map<String, Object> dataMap = (Map<String, Object>)responseMap.get('data');
        Map<String, Object> attributesMap = (Map<String, Object>)dataMap.get('attributes');
        System.assertEquals('847530', attributesMap.get('ddid'));
        System.assertEquals('IBM', attributesMap.get('name'));
        System.assertEquals('847530', attributesMap.get('dowjones_id'));
        System.assertEquals('no', attributesMap.get('your_client'));
    }

    public static StaticResourceCalloutMock setUpMock(String resource){
        System.debug('Set up mock ' + resource);
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource(resource);
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        return mock;
    }
}