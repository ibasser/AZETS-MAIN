/**
 * @description       : LWC (conflictCheck) controller.
 * @author            : Bluewave | Tomasz Piechota
 * @group             : Bluewave
 * @last modified on  : 04-02-2021
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   15-01-2021   Bluewave | Tomasz Piechota   Initial Version (Release 2.1)
**/
public with sharing class ConflictCheckController {

    /**
    * @description Check if Company_Data__c records exist under Account with the Id of accountId
    * @author Bluewave | Tomasz Piechota | 22-01-2021
    * @param String accountId
    * @return ResponseData if success return true in the returnData property of the ResponseData object
    **/
    @AuraEnabled(cacheable=true)
    public static ResponseData checkIfCompanyDataExists(String recordId) {
        if(String.isNotBlank(recordId)) {
            try {
                return new ResponseData(true, [SELECT COUNT() FROM Company_Data__c WHERE Account__c = :ConflictCheckHelper.verifyRecordId(recordId)] > 0);
            } catch (Exception e) {
                throw new ConflictCheckHelper.ConflictCheckException(e.getMessage());
            }
        } else {
            AuraHandledException ahe = new AuraHandledException('Record Id is invalid or missing.');
            ahe.setMessage('Record Id is invalid or missing.'); // Set the apex exceptions message, orherwise constructor defaults to the value "Script-thrown Exception".
            throw ahe;
        }
    }

    /**
    * @description Initiate conflict chek on the account with the Id of accountId and return a result summary of the transaction
    * @author Bluewave | Tomasz Piechota | 22-01-2021
    * @param String accountId
    * @return ResponseData if success return result summary in the returnData property of the ResponseData object
    **/
    @AuraEnabled
    public static ResponseData initiateConflictCheck(String recordId) {
        if(String.isNotBlank(recordId)) {
            try {
                return new ResponseData(true, ConflictCheckHelper.startConflictCheck(ConflictCheckHelper.verifyRecordId(recordId)).values());
            } catch (Exception e) {
                throw new ConflictCheckHelper.ConflictCheckException(e.getMessage());
            }
        } else {
            AuraHandledException ahe = new AuraHandledException('Record Id is invalid or missing.');
            ahe.setMessage('Record Id is invalid or missing.'); // Set the apex exceptions message, orherwise constructor defaults to the value "Script-thrown Exception".
            throw ahe;
        }
    }
}