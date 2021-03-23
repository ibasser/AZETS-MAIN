/**
 * @description       :
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 12-08-2020
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   12-08-2020   Bluewave | Tomasz Piechota   Initial Version
**/
@IsTest
public class CreditsafeCompanySearchWrapper_TEST {

    @IsTest
    static void searchWrapperT01() {
        String responseBody = '{"correlationId":"e358c1e0-363a-11eb-abaa-020fd0765c39","totalSize":11,"companies":[{"id":"GB-0-07941364","country":"GB","regNo":"07941364","safeNumber":"UK08186390","registrationNumber":"07941364","vatNumber":"07941364","safeNo":"UK08186390","name":"CREDITSAFE LIMITED","address":{"simpleValue":"CASPIAN POINT ONE, PIERHEAD STREET, CARDIFF, CF10 4DQ","street":"PIERHEAD STREET","city":"CARDIFF","postCode":"CF10 4DQ"},"status":"Active","type":"Ltd","dateOfLatestAccounts":"2019-12-31T00:00:00.000000Z","dateOfLatestChange":"2020-08-28T21:51:36.000Z","phoneNumbers":["02920886500"],"activityCode":"7487","statusDescription":"Non trading","previousNames":["SAFECREDIT LIMITED"]}]}';
        CreditsafeCompanySearchWrapper searchResult;
        Test.startTest();
        searchResult = (CreditsafeCompanySearchWrapper) System.JSON.deserialize(responseBody, CreditsafeCompanySearchWrapper.class);

        CreditsafeCompanySearchWrapper sw = CreditsafeCalloutHelper.generateFullAddress(searchResult);
        Test.stopTest();

        System.assert(sw != null, 'Result should not be NULL');
        System.assertEquals('e358c1e0-363a-11eb-abaa-020fd0765c39', sw.correlationId, 'correlation Id doeas not match.');
        System.assertEquals(11, sw.totalSize, 'totalSize should be 11.');
        System.assertEquals(1, sw.companies.size(), 'There should be 1 company in the list.');

        CreditsafeCompanySearchWrapper.Company c = sw.companies.get(0);
        System.assertEquals('GB-0-07941364', c.id, 'Incorrect company id');
        System.assertEquals('GB', c.country, 'Incorrect company country');
        System.assertEquals('07941364', c.regNo, 'Incorrect company regNo');
        System.assertEquals('UK08186390', c.safeNo, 'Incorrect company safeNo');
        System.assertEquals('CREDITSAFE LIMITED', c.name, 'Incorrect company name');
        System.assertEquals('Active', c.status, 'Incorrect company status');
        System.assertEquals('2019-12-31T00:00:00.000000Z', c.dateOfLatestAccounts, 'Incorrect company dateOfLatestAccounts');
        System.assertEquals('2020-08-28T21:51:36.000Z', c.dateOfLatestChange, 'Incorrect company dateOfLatestChange');
        System.assertEquals('7487', c.activityCode, 'Incorrect company activityCode');
        System.assertEquals('Non trading', c.statusDescription, 'Incorrect company statusDescription');
        System.assertEquals(1, c.previousNames.size(), 'Incorrect company previousNames. Size should be 1');
        System.assertEquals('SAFECREDIT LIMITED', c.previousNames.get(0), 'Incorrect company previous Name');
        System.assertEquals(1, c.phoneNumbers.size(), 'Incorrect company type');
        System.assertEquals('02920886500', c.phoneNumbers.get(0), 'Incorrect company phoneNumber');
        System.assertEquals('07941364', c.registrationNumber, 'Incorrect company registrationNumber');
        System.assertEquals('UK08186390', c.safeNumber, 'Incorrect company safeNumber');
        System.assertEquals('07941364', c.vatNumber, 'Incorrect company vatNumber');

        CreditsafeCompanySearchWrapper.Address ca = c.address;
        System.assertEquals('CASPIAN POINT ONE, PIERHEAD STREET, CARDIFF, CF10 4DQ', ca.simpleValue, 'Incorrect company simpleValue');
        System.assertEquals('PIERHEAD STREET', ca.street, 'Incorrect company street');
        System.assertEquals('CARDIFF', ca.city, 'Incorrect company city');
        System.assertEquals('CF10 4DQ', ca.postCode, 'Incorrect company postCode');

        System.assertEquals(ca.simpleValue, c.fullAddress, 'Incorrect company fullAddress');
    }

    @IsTest
    static void searchWrapperT02() {
        String responseBody = '{"correlationId":"9b45be00-3953-11eb-b4d2-0264ffd6f4df","totalSize":0,"companies":[],"messages":[{"type":"Information","code":"NoResults","text":"No companies matching specified search criteria found."}]}';
        CreditsafeCompanySearchWrapper searchResult;
        Test.startTest();
        searchResult = (CreditsafeCompanySearchWrapper) System.JSON.deserialize(responseBody, CreditsafeCompanySearchWrapper.class);
        Test.stopTest();

        System.assert(searchResult != null, 'Result should not be NULL');
        System.assertEquals('9b45be00-3953-11eb-b4d2-0264ffd6f4df', searchResult.correlationId, 'correlation Id doeas not match.');
        System.assertEquals(0, searchResult.totalSize, 'totalSize should be 0.');
        System.assertEquals(0, searchResult.companies.size(), 'There should be 0 companies in the list.');

        System.assertEquals(1, searchResult.messages.size(), 'Incorrect messages size. Size should be 1');
        CreditsafeCompanySearchWrapper.Message m = searchResult.messages.get(0);
        System.assertEquals('Information', m.type, 'Message type doeas not match.');
        System.assertEquals('NoResults', m.code, 'Message code doeas not match.');
        System.assertEquals('No companies matching specified search criteria found.', m.text, 'Message text doeas not match.');
    }
}