/**
 * @description       : Controller for the onboardingOppProducts LWC.
 * @author            : Bluewave | Tomasz Piechota
 * @group             : Bluewave
 * @last modified on  : 11-02-2021
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   02-02-2021   Bluewave | Tomasz Piechota   Initial Version
**/
public without sharing class OppProductsController {

    /**
    * @description Returns a list of OpportunityLineItems
    * @author Bluewave | Tomasz Piechota | 04-02-2021
    * @param String recordId (Onboarding__c.Id)
    * @return List<OppProductsHelper.Product>
    **/
    @AuraEnabled(cacheable=true)
    public static List<OppProductsHelper.Product> getRelatedProducts(String recordId) {
        if(String.isNotBlank(recordId)) {
            try {
                return OppProductsHelper.getProducts(recordId);
            } catch (Exception e) {
                AuraHandledException ahe = new AuraHandledException(e.getMessage());
                ahe.setMessage(e.getMessage()); // Set the apex exceptions message, orherwise constructor defaults to the value "Script-thrown Exception".
                throw ahe;
            }
        } else {
            AuraHandledException ahe = new AuraHandledException('Opportunity Id is invalid or missing.');
            ahe.setMessage('Opportunity Id is invalid or missing.'); // Set the apex exceptions message, orherwise constructor defaults to the value "Script-thrown Exception".
            throw ahe;
        }
    }
}