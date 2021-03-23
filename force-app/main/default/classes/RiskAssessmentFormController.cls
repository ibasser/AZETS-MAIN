/**
 * @description       :
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 25-02-2021
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   08-02-2021   Bluewave | Tomasz Piechota   Initial Version
**/
public with sharing class RiskAssessmentFormController {

    @AuraEnabled
    public static String createNewRiskAssessment(String recordId) {
        if(String.isNotBlank(recordId)) {
            try {
                return RiskAssessmentFormHelper.verifyRecordIdAndCreateRiskAssessment(recordId);
            } catch (Exception e) {
                throw new RiskAssessmentFormHelper.RiskAssessmentException(e.getMessage());
            }
        } else {
            AuraHandledException ahe = new AuraHandledException('Record Id is invalid or missing.');
            ahe.setMessage('Record Id is invalid or missing.'); // Set the apex exceptions message, orherwise constructor defaults to the value "Script-thrown Exception".
            throw ahe;
        }
    }

    @AuraEnabled(cacheable=true)
    public static RiskAssessmentFormHelper.RiskAssessmentFormConfig getRiskAssessmentFormConfig(Id recordId) {
        try {
            return RiskAssessmentFormHelper.getRiskAssessmentFormConfig(recordId);
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage()); // Set the apex exceptions message, orherwise constructor defaults to the value "Script-thrown Exception".
            throw ahe;
        }
    }

    @AuraEnabled(cacheable=true)
    public static RiskAssessmentFormHelper.RiskAssessmentFormConfig getFormConfig(String initData, String action) {
        try {
            return RiskAssessmentFormHelper.getFormConfig(initData, action);
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage()); // Set the apex exceptions message, orherwise constructor defaults to the value "Script-thrown Exception".
            throw ahe;
        }
    }

    @AuraEnabled
    public static RiskAssessmentFormHelper.InitData getFormConfigWithDML(String recordId, String initData, String action) {
        System.debug('getFormConfigWithDML');
        try {
            RiskAssessmentFormHelper.RiskAssessmentFormConfig formConfig = RiskAssessmentFormHelper.getFormConfig(initData, action);
            return RiskAssessmentFormHelper.getInitInformation(recordId);
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage()); // Set the apex exceptions message, orherwise constructor defaults to the value "Script-thrown Exception".
            throw ahe;
        }
    }

    @AuraEnabled
    public static RiskAssessmentFormHelper.InitData initializeRiskAssessment(String recordId) {
        if(String.isNotBlank(recordId)) {
            try {
                return RiskAssessmentFormHelper.getInitInformation(recordId);
            } catch (Exception e) {
                throw new RiskAssessmentFormHelper.RiskAssessmentException(e.getMessage());
            }
        } else {
            AuraHandledException ahe = new AuraHandledException('Record Id is invalid or missing.');
            ahe.setMessage('Record Id is invalid or missing.'); // Set the apex exceptions message, orherwise constructor defaults to the value "Script-thrown Exception".
            throw ahe;
        }
    }

    @AuraEnabled
    public static Boolean saveRiskAssessmentProgress(String recordId, String riskAssessment) {
        if(String.isNotBlank(recordId) && String.isNotBlank(riskAssessment)) {
            try {
                return RiskAssessmentFormHelper.saveProgress(recordId, riskAssessment);
            } catch (Exception e) {
                throw new RiskAssessmentFormHelper.RiskAssessmentException(e.getMessage());
            }
        } else {
            AuraHandledException ahe = new AuraHandledException('Record Id is invalid or missing.');
            ahe.setMessage('Record Id is invalid or missing.'); // Set the apex exceptions message, orherwise constructor defaults to the value "Script-thrown Exception".
            throw ahe;
        }
    }

    @InvocableMethod(label='Get Risk Assessment Form Config JSON' description='Return orm Config JSON' category='Risk Assessment1')
    public static void getFormConfigAfterInsert(List<Risk_Assessment__c> raList) {
        List<Risk_Assessment__c> updatedList = new List<Risk_Assessment__c>();
        for(Risk_Assessment__c ra : raList) {
            Risk_Assessment__c raNew = ra.clone(true, false, false, false);
            raNew.Saved_Assessment_JSON__c = System.JSON.serialize(getRiskAssessmentFormConfig(raNew.Id));
            updatedList.add(raNew);
        }

        update updatedList;
    }
}