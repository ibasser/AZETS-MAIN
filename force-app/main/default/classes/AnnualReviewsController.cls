/**
 * @description       : Controller class for LWC annualReview
 * @author            : Bluewave | Ismail Basser
 * @group             :
 * @last modified on  : 25-02-2021
 * @last modified by  : Bluewave | Ismail Basser
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   25-02-2021   Bluewave | Tomasz Piechota   Initial Version
**/
public with sharing class AnnualReviewsController {

    /*
    * Method to get all annual review records with the status of scheduled. 
    * Creates a wrapper class for each record, returns the list of wrappers.
    */
    @AuraEnabled(cacheable=true)
    public static List<AnnualReviewWrapper> getAnnualReviews()
    {
        Id currentUserId = UserInfo.getUserId();
        Date nextSevenDays = Date.today().addDays(7);
        List<Annual_Review__c> scheduledReviews = [SELECT Id, RecordTypeId, RecordType.Name, RecordType.DeveloperName, Name, Account__c, Account__r.Name, Status__c, Next_Review_Date__c
                                                    FROM Annual_Review__c 
                                                    WHERE Status__c = 'Scheduled' AND Next_Review_Date__c <= :nextSevenDays AND CreatedById =:currentUserId
                                                    ORDER BY Next_Review_Date__c ASC];

        List<AnnualReviewWrapper> wrapperList = new List<AnnualReviewWrapper>();

        for(Annual_Review__c review : scheduledReviews)
        {
        
            AnnualReviewWrapper wrapper = new AnnualReviewWrapper();
            wrapper.Id = review.Id;
            wrapper.accountName = review.Account__r.Name;
            wrapper.Status = review.Status__c;
            wrapper.NextReviewDate = review.Next_Review_Date__c;
            wrapper.RecordTypeName = review.RecordType.Name;
            if(review.RecordType.DeveloperName == 'Annual_Review')
            {
                wrapper.annualReviewRT = true;
            }
            else 
            {
                wrapper.annualReviewRT = false;
            }

            if(review.Next_Review_Date__c > Date.today())
            {
                wrapper.successFlag = true;
            }
            else if(review.Next_Review_Date__c == Date.today())
            {
                wrapper.warningFlag = true;
            }
            else if(review.Next_Review_Date__c < Date.today())
            {
                wrapper.errorFlag = true;
            }
            wrapperList.add(wrapper);
        }

        return wrapperList;
    }

    public class AnnualReviewWrapper{
        @AuraEnabled public String Id;
        @AuraEnabled public String RecordTypeName;
        @AuraEnabled public Boolean annualReviewRT;
        @AuraEnabled public Boolean errorFlag;
        @AuraEnabled public Boolean warningFlag;
        @AuraEnabled public Boolean successFlag;
        @AuraEnabled public String accountName;
        @AuraEnabled public String status;
        @AuraEnabled public Date nextReviewDate;
    }

}