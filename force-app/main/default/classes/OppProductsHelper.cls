/**
 * @description       : Generate a list of apex objects (Product class) that holds info about onboarding opportunity related products
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 11-02-2021
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   02-02-2021   Bluewave | Tomasz Piechota   Initial Version (Release 2.1)
**/
public without sharing class OppProductsHelper {

    /**
    * @description Return list of apex objects (Product) that holds info about onboarding opportunity related products
    * @author Bluewave | Tomasz Piechota | 04-02-2021
    * @param String recordId
    * @return List<Product>
    **/
    public static List<Product> getProducts(String recordId) {
        List<Product> productList = new List<Product>();
        Id oppId;
        try {
            oppId = [SELECT Id, Opportunity__c FROM Onboarding__c WHERE Id = :recordId].Opportunity__c;
        } catch (QueryException e) {
            throw new OppProductsException(e.getMessage());
        }

        //try {
            for(OpportunityLineItem item : [SELECT Id
                                                , (SELECT Id
                                                        , Name
                                                        , Quantity
                                                        , ListPrice
                                                        , UnitPrice
                                                        , TotalPrice
                                                        , Subtotal
                                                        , Discount
                                                        , ProductCode
                                                        , Product2Id
                                                        , Product2.Name
                                                        , Product2.Assignment_Type__c
                                                        , Product2.Assignment_Template__c
                                                        , OpportunityId
                                                        , Description
                                                        , ServiceDate
                                                    FROM OpportunityLineItems
                                                    WHERE Status__c = 'Service Won'
                                                )
                                            FROM Opportunity
                                            WHERE Id = :oppId].OpportunityLineItems) {
                productList.add(new Product(item));
            }
            return productList;
        //} catch (QueryException e) {
            //throw new OppProductsException(e.getMessage());
        //}
    }

    /**
    * @description Custom apex object (Product) that holds info a OpportunityLineItem
    * @author Bluewave | Tomasz Piechota | 04-02-2021
    * @param OpportunityLineItem item
    **/
    public class Product {
        @AuraEnabled
        public String Id{ get; set; }
        @AuraEnabled
        public String Name{ get; set; }
        @AuraEnabled
        public String ProductName{ get; set; }
        @AuraEnabled
        public Decimal Quantity{ get; set; }
        @AuraEnabled
        public Decimal ListPrice{ get; set; }
        @AuraEnabled
        public Decimal UnitPrice{ get; set; }
        @AuraEnabled
        public Decimal TotalPrice{ get; set; }
        @AuraEnabled
        public Decimal Subtotal{ get; set; }
        @AuraEnabled
        public Decimal Discount{ get; set; }
        @AuraEnabled
        public String ProductCode{ get; set; }
        @AuraEnabled
        public String Product2Id{ get; set; }
        @AuraEnabled
        public String OpportunityId{ get; set; }
        @AuraEnabled
        public String Description{ get; set; }
        @AuraEnabled
        public Date ServiceDate{ get; set; }
        @AuraEnabled
        public String Url{ get; set; }
        @AuraEnabled
        public String AssignmentType{ get; set; }
        @AuraEnabled
        public String AssignmentTemplate{ get; set; }

        public Product(OpportunityLineItem item) {
            this.Id = item.Id;
            this.Name = item.Name;
            this.ProductName = item.Product2.Name;
            this.Quantity = item.Quantity;
            this.ListPrice = item.ListPrice;
            this.UnitPrice = item.UnitPrice;
            this.TotalPrice = item.TotalPrice;
            this.Subtotal = item.Subtotal;
            this.Discount = item.Discount;
            this.ProductCode = item.ProductCode;
            this.Product2Id = item.Product2Id;
            this.OpportunityId = item.OpportunityId;
            this.Description = item.Description;
            this.ServiceDate = item.ServiceDate;
            this.Url = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + item.Id;
            this.AssignmentType = item.Product2.Assignment_Type__c;
            this.AssignmentTemplate = item.Product2.Assignment_Template__c;
        }
    }

    /**
    * @description Custom exception class
    * @author Bluewave | Tomasz Piechota | 11-16-2020
    **/
    public class OppProductsException extends Exception {}
}