/**
 * @description       : Display list of onboarding opportunity related products
 * @author            : Bluewave | Tomasz Piechota
 * @group             : Bluewave
 * @last modified on  : 11-02-2021
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   03-02-2021   Bluewave | Tomasz Piechota   Initial Version
**/
@IsTest
public with sharing class OppProductsController_TEST {
    @IsTest
    static void getRelatedProducts_FAILURE_T01() {
        List<OppProductsHelper.Product> result;
        Boolean hasError = false;
        Exception capturedException;

        try {
        	Test.startTest();
                result = OppProductsController.getRelatedProducts(null);
            Test.stopTest();
        } catch (Exception e) {
            hasError = true;
            capturedException = e;
        }

        System.assertEquals(true, hasError, 'No exception was thrown');
        System.assertNotEquals(null, capturedException, 'Exception should be thrown');
        System.assertEquals(AuraHandledException.class.getName(), capturedException.getTypeName(), 'AuraHandledException is expected');
        System.assertEquals('Opportunity Id is invalid or missing.', capturedException.getMessage(), 'Specific error message is expected');
    }

    @IsTest
    static void getRelatedProducts_FAILURE_T02() {
        List<OppProductsHelper.Product> result;
        Boolean hasError = false;
        Exception capturedException;

        try {
        	Test.startTest();
                result = OppProductsController.getRelatedProducts('XXXXXXXXXXXXXXX');
            Test.stopTest();
        } catch (Exception e) {
            hasError = true;
            capturedException = e;
        }

        System.assertEquals(true, hasError, 'No exception was thrown');
        System.assertNotEquals(null, capturedException, 'Exception should be thrown');
        System.assertEquals(AuraHandledException.class.getName(), capturedException.getTypeName(), 'AuraHandledException is expected');
        System.assertEquals('List has no rows for assignment to SObject', capturedException.getMessage(), 'Specific error message is expected');
    }

    @IsTest
    static void getRelatedProducts_FAILURE_T03() {
        List<OppProductsHelper.Product> result;
        Boolean hasError = false;
        Exception capturedException;

        try {
        	Test.startTest();
                result = OppProductsController.getRelatedProducts(null);
            Test.stopTest();
        } catch (Exception e) {
            hasError = true;
            capturedException = e;
        }

        System.assertEquals(true, hasError, 'No exception was thrown');
        System.assertNotEquals(null, capturedException, 'Exception should be thrown');
        System.assertEquals(AuraHandledException.class.getName(), capturedException.getTypeName(), 'AuraHandledException is expected');
        System.assertEquals('Opportunity Id is invalid or missing.', capturedException.getMessage(), 'Specific error message is expected');
    }

    @IsTest
    static void getRelatedProducts_SUCCESS_T01() {
        List<OppProductsHelper.Product> result;
        Onboarding__c onb = TestDataFactory.createOnboardingWithOppAndOppLineItems();

        System.assertEquals(true, onb.Id != null, 'Opportunity does not exist.');

        Test.startTest();
            result = OppProductsController.getRelatedProducts(onb.Id);
        Test.stopTest();

        // assert
        System.assertEquals(true, result.size() > 0, 'No products found.');

        OppProductsHelper.Product p = result.get(0);
        System.assertEquals('Test Opp Test Product', p.Name , 'Name is incorrect.');
        System.assertEquals('Test Product', p.ProductName , 'Name is incorrect.');
        System.assertEquals(10, p.Quantity , 'Quantity is incorrect.');
        System.assertEquals(1000, p.ListPrice , 'ListPrice is incorrect.');
        System.assertEquals(1000, p.UnitPrice , 'UnitPrice is incorrect.');
        System.assertEquals(10000, p.TotalPrice , 'TotalPrice is incorrect.');
        System.assertEquals(10000, p.Subtotal , 'Subtotal is incorrect.');
        System.assertEquals(null , p.Discount , 'Discount is incorrect.');
        System.assertEquals('TP', p.ProductCode , 'ProductCode is incorrect.');
        System.assertEquals('Test Product', p.Description , 'Description is incorrect.');
        System.assertEquals(System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + p.Id, p.Url , 'Url is incorrect.');
    }
}