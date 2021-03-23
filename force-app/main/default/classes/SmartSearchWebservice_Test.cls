@isTest
private class SmartSearchWebservice_Test {

    @TestSetup
    static void makeData() {
        Account account = new Account(name='Test Account', SSID__c='1234');
        insert account;
        Company_Data__c companyData = new Company_Data__c(account__c = account.id, ssid__c = '5678', Person_Name__c='Pepito Perez',ownerId = UserInfo.getUserId());
        insert companyData;
    }

    @isTest
    static void testDoPostAccount() {

        Map<Id,Account> fixedResultAccounts = new Map<Id,Account>([SELECT id FROM account]);
        //List<Account> fixedResultAccounts = [SELECT id FROM account];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = 'https://devtom-sscallback.cs127.force.com/SmartSearch/services/apexrest/SmartSearch/';
        req.httpMethod = 'POST';
        String str = '{\"data\": {\"id\": \"123456\",\"type\": \"callback-info\",\"attributes\": {\"ssid\": \"1234\",\"status\": \"processed\"}}}';
        req.requestBody= Blob.valueOf(str);

        RestContext.request = req;
        RestContext.response = res;

        List<Id> fixedIdList = new list<id>(fixedResultAccounts.keySet());

        Test.setFixedSearchResults(fixedIdList);
        Test.startTest();
        String result = SmartSearchWebservice.doPost();
        Test.stopTest();

        System.assertEquals('Success', result);

    }

    @isTest
    static void testDoPostCompanyData() {

        Map<Id,Company_Data__c> fixedResultData = new Map<Id,Company_Data__c>([SELECT id FROM Company_Data__c]);

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = 'https://devtom-sscallback.cs127.force.com/SmartSearch/services/apexrest/SmartSearch/';
        req.httpMethod = 'POST';
        String str = '{\"data\": {\"id\": \"123456\",\"type\": \"callback-info\",\"attributes\": {\"ssid\": \"5678\",\"status\": \"processed\"}}}';
        req.requestBody= Blob.valueOf(str);

        RestContext.request = req;
        RestContext.response = res;

        List<Id> fixedIdList = new list<id>(fixedResultData.keySet());

        Test.setFixedSearchResults(fixedIdList);
        Test.startTest();
        String result = SmartSearchWebservice.doPost();
        Test.stopTest();

        System.assertEquals('Success', result);

    }

    @isTest
    static void testDoPostCompanyData_FAIL() {

        Map<Id,Company_Data__c> fixedResultData = new Map<Id,Company_Data__c>([SELECT id FROM Company_Data__c]);

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = 'https://devtom-sscallback.cs127.force.com/SmartSearch/services/apexrest/SmartSearch/';
        req.httpMethod = 'POST';
        String str = '{\"data\": {\"id\": \"123456\",\"type\": \"callback-info\",\"attributes\": {\"ssid\": \"90123\",\"status\": \"processed\"}}}';
        req.requestBody= Blob.valueOf(str);

        RestContext.request = req;
        RestContext.response = res;

        List<Id> fixedIdList = new list<id>(fixedResultData.keySet());

        Test.setFixedSearchResults(fixedIdList);
        Test.startTest();
        String result = SmartSearchWebservice.doPost();
        Test.stopTest();


        System.assertEquals('Unable to process entity', result);

    }
    
    

}