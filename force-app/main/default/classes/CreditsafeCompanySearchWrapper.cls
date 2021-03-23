/**
 * @description Wrapper class for the CreditsafeCallout.creditsafeCompanySearch good HTTPResponse.
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 11-27-2020
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   11-05-2020   Bluewave | Tomasz Piechota   Initial Version
**/
public class CreditsafeCompanySearchWrapper {
    @AuraEnabled
    public List<Company> companies{get;set;}
    @AuraEnabled
    public Integer totalSize{get;set;}
    @AuraEnabled
    public List<Message> messages{get;set;}
    @AuraEnabled
    public String correlationId{get;set;}

    public class Address {
        @AuraEnabled
        public String simpleValue {get;set;}
        @AuraEnabled
        public String street {get;set;}
        @AuraEnabled
        public String city {get;set;}
        @AuraEnabled
        public String postCode {get;set;}
    }

    public class Company {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String country {get;set;}
        @AuraEnabled
        public String regNo {get;set;}
        @AuraEnabled
        public String registrationNumber {get;set;}
        @AuraEnabled
        public String safeNo {get;set;}
        @AuraEnabled
        public String safeNumber {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public Address address {get;set;}
        @AuraEnabled
        public String status {get;set;}
        @AuraEnabled
        public String dateOfLatestAccounts {get;set;}
        @AuraEnabled
        public String dateOfLatestChange {get;set;}
        @AuraEnabled
        public List<String> phoneNumbers {get;set;}
        @AuraEnabled
        public String activityCode {get;set;}
        @AuraEnabled
        public String statusDescription {get;set;}
        @AuraEnabled
        public List<String> previousNames {get;set;}
        @AuraEnabled
        public String vatNumber {get;set;}
        /* @AuraEnabled
        public List<String> vatNo {get;set;} */
        @AuraEnabled
        public String fullAddress {get;set;}
    }

    public class Message {
        @AuraEnabled
        public String type{get;set;}
        @AuraEnabled
        public String code{get;set;}
        @AuraEnabled
        public String text{get;set;}
    }
}