@isTest
public with sharing class SmartSearchCallManagerController_Test {

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
    static void test01_getCompanyDataSUCCESS()
    {
        Account testAcc = new Account(Name = 'BW_Test1', Company_Reg_Number__c = '12345678', Registered_Postcode__c = 'LS1 5SH');
        insert testAcc;

        Company_Data__c testCompany = new Company_Data__c(Account__c = testAcc.Id,  Company_Name__c = 'BW_Test1', Registration_Number__c = '12345678', Address_Postcode__c = 'LS1 5SH');
        insert testCompany;

        Test.startTest();
        Company_Data__c companyData = SmartSearchCallManagerController.getCompanyData(testCompany.Id);
        Test.stopTest();
        System.assertEquals(testCompany.Id, companyData.Id);
    }

    @isTest
    static void test02_getCompanyDataERROR()
    {
        Test.startTest();
        try
        {
            SmartSearchCallManagerController.getCompanyData('');
        }
        catch(exception e)
        {
            System.assert(e.getmessage().contains('List has no rows for assignment to SObject'));
        }
        Test.stopTest();
    }

    @isTest
    static void test03_getAccountSUCCESS()
    {
        Account testAcc = new Account(Name = 'BW_Test1', Company_Reg_Number__c = '12345678', Registered_Postcode__c = 'LS1 5SH');
        insert testAcc;
        
        Test.startTest();
        Account accountRetrieve = SmartSearchCallManagerController.getAccount(testAcc.Id);
        Test.stopTest();
        System.assertEquals(testAcc.Id, accountRetrieve.Id);
    }

    @isTest
    static void test04_getAccountERROR()
    {
        Account accountRetrieve = null;
        Test.startTest();
        try 
        {
            accountRetrieve = SmartSearchCallManagerController.getAccount(null);
        } 
        catch (Exception e) 
        {
            System.debug(e.getMessage());
        }
        Test.stopTest();

        System.assertEquals(null, accountRetrieve);
    }

    @isTest
    static void test05_runDJO_AccountSUCCESS()
    {
        StaticResourceCalloutMock mock = setUpMock('SmartSearchMockDJO_SUCCESS');
        Test.setMock(HttpCalloutMock.class, mock);
        Account testAcc = new Account(Name = 'BW_Test1', Company_Reg_Number__c = '12345678', Registered_Postcode__c = 'LS1 5SH');
        insert testAcc;

        Test.startTest();
        String djoString = SmartSearchCallManagerController.runDjo(testAcc, null, true);
        Test.stopTest();

        SmartSearchWrappers.DJO_Response djoResponse = new SmartSearchWrappers.DJO_Response();
        Type djoResponseType = Type.forName('SmartSearchWrappers.DJO_Response');
        djoResponse = (SmartSearchWrappers.DJO_Response)JSON.deserialize(djoString, djoResponseType);

        System.assertEquals('BW_Test1', djoResponse.data.attributes.company_name);

        //assertion for updateAccount method
        Account accountRecord = [SELECT Id, SSID__c FROM Account WHERE Id =:testAcc.Id];
        System.assertEquals('0001234', accountRecord.SSID__c);

    }

    @isTest
    static void test06_runDJO_CompanyDataSUCCESS()
    {
        StaticResourceCalloutMock mock = setUpMock('SmartSearchMockDJO_SUCCESS');
        Test.setMock(HttpCalloutMock.class, mock);

        Account testAcc = new Account(Name = 'BW_Test1', Company_Reg_Number__c = '12345678', Registered_Postcode__c = 'LS1 5SH');
        insert testAcc;
        Company_Data__c testCompany = new Company_Data__c(Account__c = testAcc.Id,  Company_Name__c = 'BW_Test1', Registration_Number__c = '12345678', Address_Postcode__c = 'LS1 5SH');
        insert testCompany;

        Test.startTest();
        String djoString = SmartSearchCallManagerController.runDjo(null, testCompany, false);
        Test.stopTest();

        SmartSearchWrappers.DJO_Response djoResponse = new SmartSearchWrappers.DJO_Response();
        Type djoResponseType = Type.forName('SmartSearchWrappers.DJO_Response');
        djoResponse = (SmartSearchWrappers.DJO_Response)JSON.deserialize(djoString, djoResponseType);

        System.assertEquals('BW_Test1', djoResponse.data.attributes.company_name);
    }

    @isTest
    static void test07_runAMLApxUK_SUCCESS()
    {
        StaticResourceCalloutMock mock = setUpMock('SmartSearchMockUKAMLRun_SUCCESS');
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
        String amlString = SmartSearchCallManagerController.runAMLApx(testCompany, 'GBR', 'normal');
        Test.stopTest();

        SmartSearchWrappers.AML_Response amlResponse = new SmartSearchWrappers.AML_Response();
        Type amlResponseType = Type.forName('SmartSearchWrappers.AML_Response');
        amlResponse = (SmartSearchWrappers.AML_Response)JSON.deserialize(amlString, amlResponseType);

        System.assertEquals('John', amlResponse.data.attributes.name.first); 
        System.assertEquals('Howard', amlResponse.data.attributes.name.middle); 
        System.assertEquals('Smith', amlResponse.data.attributes.name.last); 
    }

    // ******* Test removed according to change incode. Reactivate if US aml becomes available.*********
    // @isTest
    // static void test08_runAMLApxUS_SUCCESS()
    // {
    //     StaticResourceCalloutMock mock = setUpMock('SmartSearchMockUSAMLRun_SUCCESS');
    //     Test.setMock(HttpCalloutMock.class, mock);

    //     Account testAcc = new Account(Name = 'BW_Test1', Company_Reg_Number__c = '12345678', Registered_Postcode__c = '46892');
    //     insert testAcc;

    //     Date dob = Date.newInstance(1988, 12, 26);
    //     Company_Data__c testCompany = new Company_Data__c(Account__c = testAcc.Id,  Company_Name__c = 'BW_Test1', Registration_Number__c = '12345678', 
    //     Title__c = 'Miss', First_Name__c = 'Evalyn', Last_Name__c = 'Croft', Middle_Name__c = 'Catherine', date_of_birth__c = dob, Address_Building__c = 'Midway Lane',
    //     Address_Flat__c = '', Address_Street_1__c = '43 Midway Lane', Address_Street_2__c = '', Address_Town__c = 'Franklin', Address_Region__c = '',
    //     Address_State__c = 'CA', Address_Postcode__c = '46892', Country__c = 'USA');
    //     insert testCompany;

    //     Test.startTest();
    //     String amlString = SmartSearchCallManagerController.runAMLApx(testCompany, 'USA', '');
    //     Test.stopTest();

    //     SmartSearchWrappers.AML_Response amlResponse = new SmartSearchWrappers.AML_Response();
    //     Type amlResponseType = Type.forName('SmartSearchWrappers.AML_Response');
    //     amlResponse = (SmartSearchWrappers.AML_Response)JSON.deserialize(amlString, amlResponseType);

    //     System.assertEquals('Evalyn', amlResponse.data.attributes.name.first); 
    //     System.assertEquals('Katherine', amlResponse.data.attributes.name.middle); 
    //     System.assertEquals('Croft', amlResponse.data.attributes.name.last); 
    // }

    @isTest
    static void test09_runAMLApx_ERROR()
    {

        Account testAcc = new Account(Name = 'BW_Test1', Company_Reg_Number__c = '12345678', Registered_Postcode__c = '30564');
        insert testAcc;

        Date dob = Date.newInstance(1977, 05, 22);
        Company_Data__c testCompany = new Company_Data__c(Account__c = testAcc.Id,  Company_Name__c = 'BW_Test1', Registration_Number__c = '12345678', 
        Title__c = 'Miss', First_Name__c = 'Angela', Last_Name__c = 'Gordillo', Middle_Name__c = 'Lucinda', date_of_birth__c = dob,
        Address_Street_1__c = '71 Cartagena', Address_Street_2__c = '', Address_Town__c = 'Lorqui', Address_Region__c = 'Lorqui',
        Address_State__c = 'Murcia', Address_Postcode__c = '46892', Country__c = 'ESP');

        Test.startTest();
        String amlString = SmartSearchCallManagerController.runAMLApx(testCompany, 'ESP', '');
        Test.stopTest();

        System.assertEquals('Unable to run an international URL', amlString); 
    }

    @isTest
    static void test10_retrieveDjoApx_SUCCESS()
    {

        StaticResourceCalloutMock mock = setUpMock('SmartSearchMockDJORetrieve_SUCCESS');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        String djoString = SmartSearchCallManagerController.retrieveDjoApx('2720942');
        Test.stopTest();
        
        SmartSearchWrappers.DJO_Response djoResponse = new SmartSearchWrappers.DJO_Response();
        Type djoResponseType = Type.forName('SmartSearchWrappers.DJO_Response');
        djoResponse = (SmartSearchWrappers.DJO_Response)JSON.deserialize(djoString, djoResponseType);

        System.assertEquals('IBM', djoResponse.data.attributes.company_name); 
    }

    @isTest
    static void test11_retrieveAMLApx_SUCCESS()
    {
        StaticResourceCalloutMock mock = setUpMock('SmartSearchMockUKAMLRetrieve_SUCCESS');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        String amlString = SmartSearchCallManagerController.retrieveAMLApx('2729623', 'GBR');
        Test.stopTest();

        SmartSearchWrappers.AML_Response amlResponse = new SmartSearchWrappers.AML_Response();
        Type amlResponseType = Type.forName('SmartSearchWrappers.AML_Response');
        amlResponse = (SmartSearchWrappers.AML_Response)JSON.deserialize(amlString, amlResponseType);

        System.assertEquals('John', amlResponse.data.attributes.name.first); 
        System.assertEquals('Howard', amlResponse.data.attributes.name.middle); 
        System.assertEquals('Smith', amlResponse.data.attributes.name.last);  
    }

    @isTest
    static void test12_listDueDiligence_SUCCESS()
    {
        StaticResourceCalloutMock mock = setUpMock('SmartSearchMockBusinessDDRetrieve_SUCCESS');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        String duediligenceList = SmartSearchCallManagerController.listDueDiligence('2720942');
        Test.stopTest();

        Map<String, Object> responseMap  = (Map<String, Object>)JSON.deserializeUntyped(duediligenceList);
        List<Object> dataList = (List<Object>)responseMap.get('data');
        Map<String, Object> dataMap = (Map<String, Object>)dataList[0];
        Map<String, Object> attributesMap = (Map<String, Object>)dataMap.get('attributes');
        System.assertEquals('847530', attributesMap.get('ddid'));
        System.assertEquals('IBM', attributesMap.get('name'));
        System.assertEquals('847530', attributesMap.get('dowjones_id'));
    }

    @isTest
    static void test13_updateDueDiligence_SUCCESS()
    {
        StaticResourceCalloutMock mock = setUpMock('SmartSearchMockUpdateDD_SUCCESS');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        String duediligenceUpdate = SmartSearchCallManagerController.updateDueDiligence('2720942', '847530', 'no');
        Test.stopTest();

        Map<String, Object> responseMap  = (Map<String, Object>)JSON.deserializeUntyped(duediligenceUpdate);
        Map<String, Object> dataMap = (Map<String, Object>)responseMap.get('data');
        Map<String, Object> attributesMap = (Map<String, Object>)dataMap.get('attributes');
        System.assertEquals('847530', attributesMap.get('ddid'));
        System.assertEquals('IBM', attributesMap.get('name'));
        System.assertEquals('847530', attributesMap.get('dowjones_id'));
        System.assertEquals('no', attributesMap.get('your_client'));
    }

    @isTest
    static void test14_saveAMLApxDJO_SUCCESS()
    {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'SmartSearchMockDJO_SUCCESS' LIMIT 1];
        String bodyJSON = sr.Body.toString();

        Account testAcc = new Account(Name = 'BW_Test1', Company_Reg_Number__c = '12345678', Registered_Postcode__c = 'LS1 5SH');
        insert testAcc;

        Test.startTest();
        Boolean amlRecord = SmartSearchCallManagerController.saveAMLApx(bodyJSON, testAcc.Id, 'Account','');
        Test.stopTest();

        System.assertEquals(true, amlRecord);

        List<Anti_Money_Laundering__c> amlCreated = [SELECT Id, Account__c, Entity_Type__c FROM Anti_Money_Laundering__c WHERE Account__c =:testAcc.Id];
        System.assertEquals(1, amlCreated.size());
        System.assertEquals(testAcc.Id, amlCreated[0].Account__c);
        System.assertEquals('Corporate', amlCreated[0].Entity_Type__c);
    }

    @isTest
    static void test15_saveAMLApxCompanyUk_SUCCESS()
    {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'SmartSearchMockSaveAMLCompany_SUCCESS' LIMIT 1];
        String bodyJSON = sr.Body.toString();

        Account testAcc = new Account(Name = 'BW_Test1', Company_Reg_Number__c = '12345678', Registered_Postcode__c = 'BA133BN');
        insert testAcc;

        Date dob = Date.newInstance(1950, 05, 26);
        Company_Data__c testCompany = new Company_Data__c(Account__c = testAcc.Id,  Company_Name__c = 'Blackstone', Registration_Number__c = '12345678', 
        Entity_Type__c = 'Company', SSID__c = '2736694');
        insert testCompany;

        Test.startTest();
        Boolean amlRecord = SmartSearchCallManagerController.saveAMLApx(bodyJSON, testCompany.Id, 'Company_Data__c','gbr');
        Test.stopTest();

        System.assertEquals(true, amlRecord);

        List<Anti_Money_Laundering__c> amlCreated = [SELECT Id, Account__c, Entity_Type__c FROM Anti_Money_Laundering__c WHERE Account__c =:testAcc.Id];
        System.assertEquals(1, amlCreated.size());
        System.assertEquals(testCompany.Account__c, amlCreated[0].Account__c);
        System.assertEquals(testAcc.Id, amlCreated[0].Account__c);
        System.assertEquals('Corporate', amlCreated[0].Entity_Type__c);
    }

    @isTest
    static void test16_saveAMLApxUk_SUCCESS()
    {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'SmartSearchMockSaveAMLUK_SUCCESS' LIMIT 1];
        String bodyJSON = sr.Body.toString();

        Account testAcc = new Account(Name = 'BW_Test1', Company_Reg_Number__c = '12345678', Registered_Postcode__c = 'BA133BN');
        insert testAcc;

        Date dob = Date.newInstance(1950, 05, 26);
        Company_Data__c testCompany = new Company_Data__c(Account__c = testAcc.Id,  Company_Name__c = 'BW_Test1', Registration_Number__c = '12345678', Date_of_Birth__c = dob,
        Gender__c = 'Male', Person_Name__c = 'John I Smith', Title__c = 'Mr', First_Name__c = 'John', Middle_Name__c = 'I', Last_Name__c = 'Smith', Entity_Type__c = 'Person', 
        SSID__c = '2736696', Address_Building__c = '25 High Street',  Address_Postcode__c = 'BA133BN', Address_Region__c = 'Wiltshire', Address_Town__c = 'Westbury', 
        Address_Street_1__c = '25 High Street', Address_State__c = 'Wiltshire', Country__c = 'GBR');
        insert testCompany;

        Test.startTest();
        Boolean amlRecord = SmartSearchCallManagerController.saveAMLApx(bodyJSON, testCompany.Id, 'Company_Data__c','gbr');
        Test.stopTest();

        System.assertEquals(true, amlRecord);

        List<Anti_Money_Laundering__c> amlCreated = [SELECT Id, Account__c, Entity_Type__c, Result__c FROM Anti_Money_Laundering__c WHERE Account__c =:testAcc.Id];
        System.assertEquals(1, amlCreated.size());
        System.assertEquals(testCompany.Account__c, amlCreated[0].Account__c);
        System.assertEquals(testAcc.Id, amlCreated[0].Account__c);
        System.assertEquals('Person', amlCreated[0].Entity_Type__c);
        System.assertEquals('Pass', amlCreated[0].Result__c);
    }

    @isTest
    static void test17_saveAMLApxUkRefer_SUCCESS()
    {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'SmartSearchMockSaveAMLUKRefer_SUCCESS' LIMIT 1];
        String bodyJSON = sr.Body.toString();

        Account testAcc = new Account(Name = 'BW_Test1', Company_Reg_Number__c = '12345678', Registered_Postcode__c = 'BA133BN');
        insert testAcc;

        Date dob = Date.newInstance(1950, 05, 26);
        Company_Data__c testCompany = new Company_Data__c(Account__c = testAcc.Id,  Company_Name__c = 'BW_Test1', Registration_Number__c = '12345678', Date_of_Birth__c = dob,
        Gender__c = 'Male', Person_Name__c = 'John I Smith', Title__c = 'Mr', First_Name__c = 'John', Middle_Name__c = 'I', Last_Name__c = 'Smith', Entity_Type__c = 'Person', 
        SSID__c = '2736696', Address_Building__c = '25 High Street',  Address_Postcode__c = 'BA133BN', Address_Region__c = 'Wiltshire', Address_Town__c = 'Westbury', 
        Address_Street_1__c = '25 High Street', Address_State__c = 'Wiltshire', Country__c = 'GBR');
        insert testCompany;

        Test.startTest();
        Boolean amlRecord = SmartSearchCallManagerController.saveAMLApx(bodyJSON, testCompany.Id, 'Company_Data__c','gbr');
        Test.stopTest();

        System.assertEquals(true, amlRecord);

        List<Anti_Money_Laundering__c> amlCreated = [SELECT Id, Account__c, Entity_Type__c, Result__c FROM Anti_Money_Laundering__c WHERE Account__c =:testAcc.Id];
        System.assertEquals(1, amlCreated.size());
        System.assertEquals(testCompany.Account__c, amlCreated[0].Account__c);
        System.assertEquals(testAcc.Id, amlCreated[0].Account__c);
        System.assertEquals('Person', amlCreated[0].Entity_Type__c);
        System.assertEquals('Fail', amlCreated[0].Result__c);
    }

    @isTest
    static void test18_saveAMLApxEsp_SUCCESS()
    {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'SmartSearchMockSaveAMLESP_SUCCESS' LIMIT 1];
        String bodyJSON = sr.Body.toString();

        Account testAcc = new Account(Name = 'BW_Test1', Company_Reg_Number__c = '12345678', Registered_Postcode__c = '30560');
        insert testAcc;

        Date dob = Date.newInstance(1977, 05, 22);
        Company_Data__c testCompany = new Company_Data__c(Account__c = testAcc.Id,  Company_Name__c = 'BW_Test1', Registration_Number__c = '12345678', Date_of_Birth__c = dob,
        Gender__c = 'Female', Person_Name__c = 'Angela Lucinda Gordillo', Title__c = 'Miss', First_Name__c = 'Angela', Middle_Name__c = 'Lucinda', Last_Name__c = 'Gordillo', Entity_Type__c = 'Person', 
        SSID__c = '2733739', Address_Building__c = '71',  Address_Postcode__c = '30560', Address_Region__c = 'Murcia', Address_Town__c = 'Lorqui', 
        Address_Street_1__c = null, Country__c = 'Other');
        insert testCompany;

        Test.startTest();
        Boolean amlRecord = SmartSearchCallManagerController.saveAMLApx(bodyJSON, testCompany.Id, 'Company_Data__c','esp');
        Test.stopTest();

        System.assertEquals(true, amlRecord);

        List<Anti_Money_Laundering__c> amlCreated = [SELECT Id, Account__c, Entity_Type__c, Result__c FROM Anti_Money_Laundering__c WHERE Account__c =:testAcc.Id];
        System.assertEquals(1, amlCreated.size());
        System.assertEquals(testCompany.Account__c, amlCreated[0].Account__c);
        System.assertEquals(testAcc.Id, amlCreated[0].Account__c);
        System.assertEquals('Person', amlCreated[0].Entity_Type__c);
        System.assertEquals('Pass', amlCreated[0].Result__c);
    }

    @isTest
    static void test19_saveAMLApxAmlEspRefer_SUCCESS()
    {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'SmartSearchMockSaveAMLReferESP_SUCCESS' LIMIT 1];
        String bodyJSON = sr.Body.toString();

        Account testAcc = new Account(Name = 'BW_Test1', Company_Reg_Number__c = '12345678', Registered_Postcode__c = '30560');
        insert testAcc;

        Date dob = Date.newInstance(1977, 05, 22);
        Company_Data__c testCompany = new Company_Data__c(Account__c = testAcc.Id,  Company_Name__c = 'BW_Test1', Registration_Number__c = '12345678', Date_of_Birth__c = dob,
        Gender__c = 'Female', Person_Name__c = 'Angela Lucinda Gordillo', Title__c = 'Miss', First_Name__c = 'Angela', Middle_Name__c = 'Lucinda', Last_Name__c = 'Gordillo', Entity_Type__c = 'Person', 
        SSID__c = '2733739', Address_Building__c = '71',  Address_Postcode__c = '30560', Address_Region__c = 'Murcia', Address_Town__c = 'Lorqui', 
        Address_Street_1__c = null, Country__c = 'Other');
        insert testCompany;

        Test.startTest();
        Boolean amlRecord = SmartSearchCallManagerController.saveAMLApx(bodyJSON, testCompany.Id, 'Company_Data__c','esp');
        Test.stopTest();

        System.assertEquals(true, amlRecord);

        List<Anti_Money_Laundering__c> amlCreated = [SELECT Id, Account__c, Entity_Type__c, Result__c FROM Anti_Money_Laundering__c WHERE Account__c =:testAcc.Id];
        System.assertEquals(1, amlCreated.size());
        System.assertEquals(testCompany.Account__c, amlCreated[0].Account__c);
        System.assertEquals(testAcc.Id, amlCreated[0].Account__c);
        System.assertEquals('Person', amlCreated[0].Entity_Type__c);
        System.assertEquals('Fail', amlCreated[0].Result__c);
    }

    @isTest
    static void test20_saveAMLApx_ERROR()
    {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'SmartSearchMockDJO_SUCCESS' LIMIT 1];
        String bodyJSON = sr.Body.toString();

        Test.startTest();
        Boolean amlRecord = SmartSearchCallManagerController.saveAMLApx(bodyJSON, null, '','');
        Test.stopTest();

        System.assertEquals(false, amlRecord);
    }

    @isTest
    static void test21_getDueDiligenceLink_SUCCESS()
    {
        SmartSearchDetails__c testDetails = SmartSearchDetails__c.getInstance('Sandbox');
        testDetails.DD_URL__c = 'https://testURL.com';
        update testDetails;

        Test.startTest();
        String actualURL = SmartSearchCallManagerController.getDueDiligenceLink('2730041', '847530','djo');
        Test.stopTest();
        String expectedURL = 'https://testURL.com/djo/results/2730041/847530';
        System.assertEquals(expectedURL, actualURL);
    }

    @isTest
    static void test22_getDueDiligenceLink_ERROR()
    {
        Test.startTest();
        String actualURL = SmartSearchCallManagerController.getDueDiligenceLink('2730041', '847530','aml');
        Test.stopTest();
        System.assertEquals('', actualURL);
    }

    public static StaticResourceCalloutMock setUpMock(String resource)
    {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource(resource);
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        return mock;
    }
}