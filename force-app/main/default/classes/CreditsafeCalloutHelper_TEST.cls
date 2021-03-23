/**
 * @description       : Test class for the CreditsafeCalloutHelper class
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 12-11-2020
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   11-13-2020   Bluewave | Tomasz Piechota   Initial Version
**/

@IsTest
public class CreditsafeCalloutHelper_TEST {

    /**
    * @description Test data setup
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    **/
    @TestSetup
    static void makeData() {
        List<Countries__c> countryList = TestDataFactory.createCountryListSettings();
        insert countryList;
    }

    @IsTest
    static void formatMoneyT01() {
        String result;
        String value = '500';
        String currencyCode = 'GBP';

        Test.startTest();
        result = CreditsafeCalloutHelper.formatMoney(value, currencyCode);
        Test.stopTest();

        System.assertEquals('GBP 500.00', result, 'Incorrect format');
    }

    @IsTest
    static void formatMoneyT02() {
        String result;
        String value = '500';
        String currencyCode = '';

        Test.startTest();
        result = CreditsafeCalloutHelper.formatMoney(value, currencyCode);
        Test.stopTest();

        System.assertEquals('500.00', result, 'Incorrect format');
    }

    @IsTest
    static void formatMoneyT03() {
        String result;
        String value;
        String currencyCode = 'GBP';

        Test.startTest();
        result = CreditsafeCalloutHelper.formatMoney(value, currencyCode);
        Test.stopTest();

        System.assertEquals('GBP 0.0', result, 'Incorrect format');
    }

    @IsTest
    static void formatMoneyT04() {
        String result;
        String value;
        String currencyCode;

        Test.startTest();
        result = CreditsafeCalloutHelper.formatMoney(value, currencyCode);
        Test.stopTest();

        System.assertEquals('0.0', result, 'Incorrect format');
    }

    @IsTest
    static void formatMoneyT05() {
        String result;
        String value = '500.25';
        String currencyCode = 'GBP';

        Test.startTest();
        result = CreditsafeCalloutHelper.formatMoney(value, currencyCode);
        Test.stopTest();

        System.assertEquals('GBP 500.25', result, 'Incorrect format');
    }

    @IsTest
    static void formatMoneyT06() {
        String result;
        String value = '500.2';
        String currencyCode = 'GBP';

        Test.startTest();
        result = CreditsafeCalloutHelper.formatMoney(value, currencyCode);
        Test.stopTest();

        System.assertEquals('GBP 500.20', result, 'Incorrect format');
    }

    @IsTest
    static void getDecimalValueT01() {
        Decimal result;
        String value = '500.2';

        Test.startTest();
        result = CreditsafeCalloutHelper.getDecimalValue(value);
        Test.stopTest();

        System.assertEquals(500.2, result, 'Incorrect format');
    }

    @IsTest
    static void getDecimalValueT02() {
        Decimal result;
        String value;

        Test.startTest();
        result = CreditsafeCalloutHelper.getDecimalValue(value);
        Test.stopTest();

        System.assertEquals(0.0, result, 'Incorrect format');
    }

    @IsTest
    static void getDecimalValueT03() {
        Decimal result;
        String value = 'test';

        Test.startTest();
        result = CreditsafeCalloutHelper.getDecimalValue(value);
        Test.stopTest();

        System.assertEquals(0.0, result, 'Incorrect format');
    }

    @IsTest
    static void isValidDecimalT01() {
        Boolean result;
        String value = 'test';

        Test.startTest();
        result = CreditsafeCalloutHelper.isValidDecimal(value);
        Test.stopTest();

        System.assertEquals(false, result, 'Value should be FALSE');
    }

    @IsTest
    static void isValidDecimalT02() {
        Boolean result;
        String value;

        Test.startTest();
        result = CreditsafeCalloutHelper.isValidDecimal(value);
        Test.stopTest();

        System.assertEquals(false, result, 'Value should be FALSE');
    }

    @IsTest
    static void isValidDecimalT03() {
        Boolean result;
        String value = '100';

        Test.startTest();
        result = CreditsafeCalloutHelper.isValidDecimal(value);
        Test.stopTest();

        System.assertEquals(true, result, 'Value should be TRUE');
    }

    @IsTest
    static void getIntegerValueT01() {
        Integer result;
        String value = '100';

        Test.startTest();
        result = CreditsafeCalloutHelper.getIntegerValue(value);
        Test.stopTest();

        System.assertEquals(100, result, 'Value should be TRUE');
    }

    @IsTest
    static void getIntegerValueT02() {
        Integer result;
        String value;

        Test.startTest();
        result = CreditsafeCalloutHelper.getIntegerValue(value);
        Test.stopTest();

        System.assertEquals(0, result, 'Value should be 0');
    }

    @IsTest
    static void getIntegerValueT03() {
        Integer result;
        String value = 'test';

        Test.startTest();
        result = CreditsafeCalloutHelper.getIntegerValue(value);
        Test.stopTest();

        System.assertEquals(0, result, 'Value should be 0');
    }

    @IsTest
    static void getDateValueT01() {
        Date result;
        String value = '2012-02-08T00:00:00Z';

        Test.startTest();
        result = CreditsafeCalloutHelper.getDateValue(value);
        Test.stopTest();

        System.assertEquals(Date.valueOf(value), result, 'Value should be 0');
    }

    @IsTest
    static void getDateValueT02() {
        Date result;
        String value;

        Test.startTest();
        result = CreditsafeCalloutHelper.getDateValue(value);
        Test.stopTest();

        System.assertEquals(null, result, 'Value should be null');
    }

    @IsTest
    static void getDateValueT03() {
        Date result;
        String value = 'test';

        Test.startTest();
        result = CreditsafeCalloutHelper.getDateValue(value);
        Test.stopTest();

        System.assertEquals(null, result, 'Value should be null');
    }

    @IsTest
    static void creditsafeCompanySearchErrorWrapperT01() {
        CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper result;
        String data = '{"correlationId":"AAAAAAAA", "message":"BBBBBBBB", "details":"CCCCCCC"}';

        Test.startTest();
        result = (CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper) System.JSON.deserialize(data, CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper.class);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Value should not be null');
        System.assertEquals('AAAAAAAA', result.correlationId, 'Value should be AAAAAAAA');
        System.assertEquals('BBBBBBBB', result.message, 'Value should be BBBBBBBB');
        System.assertEquals('CCCCCCC', result.details, 'Value should be CCCCCCC');
    }

    @IsTest
    static void getCompanySearchParamsStringT01() {
        Credisafe_Callout_Settings__c creditsafeCalloutSettings = TestDataFactory.createCredisafeCalloutSettings();
        insert creditsafeCalloutSettings;

        String result = '';
        String countries;
        String name;
        String postCode;
        Integer page;
        Integer pageSize;
        String regNo;

        Test.startTest();
        result = CreditsafeCalloutHelper.getCompanySearchParamsString(countries, name, postCode, page, pageSize, regNo);
        Test.stopTest();

        System.assertEquals('', result, 'Result should be an empty string.');
    }

    @IsTest
    static void getCompanySearchParamsStringT02() {
        Credisafe_Callout_Settings__c creditsafeCalloutSettings = TestDataFactory.createCredisafeCalloutSettings();
        insert creditsafeCalloutSettings;
        String result = '';
        String countries = 'United Kingdom';
        String name = 'Test';
        String postCode = 'W23*';
        Integer page;
        Integer pageSize;
        String regNo;

        Test.startTest();
        result = CreditsafeCalloutHelper.getCompanySearchParamsString(countries, name, postCode, page, pageSize, regNo);
        Test.stopTest();

        System.assertEquals('countries=' + Countries__c.getInstance(countries).Country_ISO2_Code__c + '&page=' + Credisafe_Callout_Settings__c.getInstance('Default').Page__c + '&pageSize=' + Credisafe_Callout_Settings__c.getInstance('Default').Page_Size__c + '&name=' + name + '&postCode=' + postCode, result, 'Result should not be an empty string.');
    }

    @IsTest
    static void getCompanySearchParamsStringT03() {
        Credisafe_Callout_Settings__c creditsafeCalloutSettings = TestDataFactory.createCredisafeCalloutSettings(true);
        insert creditsafeCalloutSettings;

        String result = '';
        String countries = 'United Kingdom';
        String name;
        String postCode;
        Integer page;
        Integer pageSize;
        String regNo = '12345678';

        Test.startTest();
        result = CreditsafeCalloutHelper.getCompanySearchParamsString(countries, name, postCode, page, pageSize, regNo);
        Test.stopTest();

        System.assertEquals('countries=' + Countries__c.getInstance(countries).Country_ISO2_Code__c + '&page=' + Credisafe_Callout_Settings__c.getInstance('Default').Page__c + '&pageSize=' + Credisafe_Callout_Settings__c.getInstance('Default').Page_Size__c + '&exact=true&regNo=' + regNo, result, 'Result should not be an empty string.');
    }
}