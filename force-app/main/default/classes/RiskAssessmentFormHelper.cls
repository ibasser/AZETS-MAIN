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
public with sharing class RiskAssessmentFormHelper {

    private static Map<Id, RiskAssessmentQuestion> result;
    private static Map<Id, Id> childIdMap;

    public static RiskAssessmentFormConfig getFormConfig(String initData, String action) {
        RiskAssessmentFormConfig result;
        System.debug('CONFIG OBJECT FROM AURA >>>>');

        System.debug(initData);

        if(initData != null){
            InitData data = (InitData) System.JSON.deserialize(initData, InitData.class);

            switch on action {
                when 'createNew' {
                    result = createNewRiskAssessmentObject(data.raAccountId, data.raOnboardingId);
                }
                when 'updateNew' {
                    result = resetRiskAssessmentFormConfig(data.raInProgress, null);
                }
                when 'updateLoad' {
                    Id raId = data.raInProgress;
                    result = (RiskAssessmentFormConfig) System.JSON.deserialize([SELECT Id, Saved_Assessment_JSON__c FROM Risk_Assessment__c WHERE Id =: raId]?.Saved_Assessment_JSON__c, RiskAssessmentFormConfig.class);
                }
                when else {
                    throw new RiskAssessmentFormHelper.RiskAssessmentException('Couldn\'t understand the requested action: ' + action);
                }
            }
        } else {
            throw new RiskAssessmentFormHelper.RiskAssessmentException('Invalid or missing initial data required to render the form');
        }
        System.debug('RETURN CONFIG OBJECT >>>>');
        System.debug(result);
        return result;
    }

    public static InitData getInitInformation(String recordId) {
        InitData initRecordDetails = verifyRecordId(recordId);
        List<Risk_Assessment__c> raList;
        List<Risk_Assessment__c> raInProgress = new List<Risk_Assessment__c>();
        String query;

        if(initRecordDetails.sObjectType != 'Risk_Assessment__c') {
            query = String.format(
                'SELECT {0}, (SELECT {1} FROM Risk_Assessments__r) FROM {2} WHERE Id = \'\'{3}\'\'',
                new List<String> {
                    String.join(new List<String>(Id.valueOf(recordId).getSObjectType().getDescribe().fields.getMap().keySet()), ','),
                    String.join(new List<String>(Risk_Assessment__c.SObjectType.getDescribe().fields.getMap().keySet()), ','),
                    Id.valueOf(recordId).getSObjectType().getDescribe().getName(),
                    recordId
                }
            );
        } else if(initRecordDetails.sObjectType == 'Risk_Assessment__c') {
            query = String.format(
                'SELECT {0} FROM Risk_Assessment__c WHERE Id = \'\'{1}\'\'',
                new String[] {
                    String.join(new List<String>(Risk_Assessment__c.SObjectType.getDescribe().fields.getMap().keySet()), ','),
                    recordId
                }
            );
        }

        if(initRecordDetails.sObjectType == 'Onboarding__c') {
            Onboarding__c onb = Database.query(query);
            initRecordDetails.raExist = onb.Risk_Assessments__r.size();
            initRecordDetails.raInProgress = checkRiskAssessmentsInProgress(onb.Risk_Assessments__r)?.Id;
            initRecordDetails.raPendingApproval = checkRiskAssessmentsPendingApproval(onb.Risk_Assessments__r)?.Id;
            initRecordDetails.raOnboardingId = onb.Id;
            initRecordDetails.raAccountId = onb.Account__c;
            //initRecordDetails.put('ra', System.JSON.serialize(onb.Risk_Assessments__r));
        } else if (initRecordDetails.sObjectType == 'Account') {
            Account acc = Database.query(query);
            initRecordDetails.raExist = acc.Risk_Assessments__r.size();
            initRecordDetails.raInProgress = checkRiskAssessmentsInProgress(acc.Risk_Assessments__r)?.Id;
            initRecordDetails.raPendingApproval = checkRiskAssessmentsPendingApproval(acc.Risk_Assessments__r)?.Id;
            initRecordDetails.raAccountId = acc.Id;
            //initRecordDetails.put('ra', System.JSON.serialize(acc.Risk_Assessments__r));
        } else if (initRecordDetails.sObjectType == 'Risk_Assessment__c') {
            Risk_Assessment__c ra = Database.query(query);
            initRecordDetails.raExist = new List<Risk_Assessment__c>{ra}?.size();
            initRecordDetails.raInProgress = checkRiskAssessmentsInProgress(new List<Risk_Assessment__c>{ra})?.Id;
            initRecordDetails.raPendingApproval = checkRiskAssessmentsPendingApproval(new List<Risk_Assessment__c>{ra})?.Id;
            initRecordDetails.raOnboardingId = ra.Onboarding__c;
            initRecordDetails.raAccountId = ra.Account__c;
            //initRecordDetails.put('ra', System.JSON.serialize(new List<Risk_Assessment__c>{ra}));
        } else {
            throw new RiskAssessmentFormHelper.RiskAssessmentException('Invalid object. Cannot create or continue Risk Assessment.');
        }

        return initRecordDetails;
    }

    public static Risk_Assessment__c checkRiskAssessmentsInProgress(List<Risk_Assessment__c> raList) {
        Risk_Assessment__c raInProgress;

        for(Risk_Assessment__c ra : raList) {
            if(ra.Stage__c?.toLowerCase() == 'in-progress') {
                raInProgress = ra;
                break;
            }
        }

        return raInProgress;
    }

    public static Risk_Assessment__c checkRiskAssessmentsPendingApproval(List<Risk_Assessment__c> raList) {
        Risk_Assessment__c raPendingApproval;

        for(Risk_Assessment__c ra : raList) {
            if(ra.Stage__c?.toLowerCase() == 'pending approval') {
                raPendingApproval = ra;
                break;
            }
        }

        return raPendingApproval;
    }

    /**
    * @description
    * @author Bluewave | Tomasz Piechota | 20-02-2021
    * @param String recordId
    * @return String (RiskAssessment Id)
    **/
    public static InitData verifyRecordId(String recordId) {
        System.debug(recordId);
        try{
            InitData initRecordDetails = new InitData();
            String sObjectType = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            initRecordDetails.sObjectId = recordId;
            initRecordDetails.sObjectType = sObjectType;
            System.debug(initRecordDetails);

            return initRecordDetails;
        } catch(Exception e) {
            throw new RiskAssessmentFormHelper.RiskAssessmentException(e.getMessage());
        }
    }

    /**
    * @description
    * @author Bluewave | Tomasz Piechota | 20-02-2021
    * @param String recordId
    * @return String (RiskAssessment Id)
    **/
    public static String verifyRecordIdAndCreateRiskAssessment(String recordId) {
        try{
            Map<String, Id> riskAssessmentDetails = new Map<String, Id>();
            String obj = Id.valueOf(recordId).getSObjectType().getDescribe().getName();

            if(obj == 'Onboarding__c') {
                // Populate map with details
                riskAssessmentDetails.put('OnboadringId', Id.valueOf(recordId));
                riskAssessmentDetails.put('AccountId', [SELECT Id, Account__c FROM Onboarding__c WHERE Id = :recordId]?.Account__c);
                // Verify if the context object has existing In-Progress risk assessment
                List<Risk_Assessment__c> raList = checkIfRiskAssessmentInProgressExsists(recordId, obj, riskAssessmentDetails);

                return null;
            } else if(obj == 'Account') {
                // Populate map with details
                riskAssessmentDetails.put('OnboadringId', null);
                riskAssessmentDetails.put('AccountId', Id.valueOf(recordId));
                // Verify if the context object has existing In-Progress risk assessment
                List<Risk_Assessment__c> raList = checkIfRiskAssessmentInProgressExsists(recordId, obj, riskAssessmentDetails);

                return null;
            } else if(obj == 'Risk_Assessment__c') {
                return recordId;
            } else {
                throw new RiskAssessmentFormHelper.RiskAssessmentException('Invalid risk assessment Id');
            }
        } catch(Exception e) {
            throw new RiskAssessmentFormHelper.RiskAssessmentException(e.getMessage());
        }
    }

    /* public static RiskAssessmentFormConfig getRiskAssessmentForm(String recordId) {

        RiskAssessmentFormHelper.getRiskAssessmentFormConfig();
        return null;
    } */

    /**
    * @description
    * @author Bluewave | Tomasz Piechota | 20-02-2021
    * @param String recordId
    * @return String (RiskAssessment Id)
    **/
    public static List<Risk_Assessment__c> checkIfRiskAssessmentInProgressExsists(String recordId, String obj, Map<String, Id> riskAssessmentDetails) {
        if(String.isNotBlank(obj)) {
            try{
                List<Risk_Assessment__c> raList;
                List<Risk_Assessment__c> raInProgress = new List<Risk_Assessment__c>();

                String query = String.format('SELECT Risk_Assessments__r FROM {0} WHERE Id = {1}',
                    new String[] {
                        obj,
                        recordId
                    }
                );

                if(obj == 'Onboarding__c') {
                    Onboarding__c onb = Database.query(query);
                    raList = onb.Risk_Assessments__r;
                } else if (obj == 'Account') {
                    Account acc = Database.query(query);
                    raList = acc.Risk_Assessments__r;
                } else {
                    throw new RiskAssessmentFormHelper.RiskAssessmentException('Invalid object. Cannot create opr copntinue Risk Assessment.');
                }

                if(raList != null && raList?.size() > 0) {
                    for(Risk_Assessment__c ra : raList) {
                        if(ra.Stage__c == 'In-Progress') {
                            raInProgress.add(ra);
                        }
                    }
                }

                return raInProgress;
            } catch(Exception e) {
                throw new RiskAssessmentFormHelper.RiskAssessmentException(e.getMessage());
            }
        } else {
            throw new RiskAssessmentFormHelper.RiskAssessmentException('Something went wrong and risk assessment form could not be created.');
        }
    }

    public static RiskAssessmentFormConfig createNewRiskAssessmentObject(String accountId, String onboardingId) {
        try{
            Risk_Assessment__c ra = new Risk_Assessment__c(
                Account__c = accountId,
                Onboarding__c = onboardingId,
                Stage__c = 'In-Progress'
            );
            insert ra;
            RiskAssessmentFormConfig formConfig = resetRiskAssessmentFormConfig(ra.Id, ra);
            ra.Saved_Assessment_JSON__c = System.JSON.serialize(formConfig);
            update ra;

            return formConfig;
        } catch(Exception e) {
            throw new RiskAssessmentFormHelper.RiskAssessmentException(e.getMessage());
        }
    }

    public static RiskAssessmentFormConfig resetRiskAssessmentFormConfig(String raId, Risk_Assessment__c ra) {
        RiskAssessmentFormConfig formConfig;
        System.debug('resetRiskAssessmentFormConfig: ');
        System.debug(raId);
        System.debug(ra);
        if(ra != null) {
            formConfig = getRiskAssessmentFormConfig(ra.Id);
            ra.Saved_Assessment_JSON__c = System.JSON.serialize(formConfig);
            update ra;
        } else if(String.isNotBlank(raId) && ra == null) {
            formConfig = getRiskAssessmentFormConfig(raId);
            ra = [SELECT Id, Saved_Assessment_JSON__c FROM Risk_Assessment__c WHERE Id =: raId];
            ra.Saved_Assessment_JSON__c = System.JSON.serialize(formConfig);
            update ra;
        }

        System.debug(formConfig);
        return formConfig;
    }

    /**
    * @description Returns Risk Assessment form configuration
    * @author Bluewave | Tomasz Piechota | 18-02-2021
    * @return RiskAssessmentFormConfig
    **/
    public static RiskAssessmentFormConfig getRiskAssessmentFormConfig(Id raId) {
        result = new Map<Id, RiskAssessmentQuestion>();
        childIdMap = new Map<Id, Id>();

        String query = String.format('SELECT {0} FROM Risk_Assessment_Question__mdt WHERE Parent_Id__c = NULL AND Active__c = TRUE ORDER BY Field_Question_No__c ASC',
            new String[] {
                String.join(
                    new List<String>(
                        Risk_Assessment_Question__mdt.SObjectType.getDescribe().fields.getMap().keySet()
                    ),
                    ','
                )
            }
        );
        List<Risk_Assessment_Question__mdt> questions = Database.query(query);

        // MDT questions map
        Map<Id, Risk_Assessment_Question__mdt> mdtMap = new Map<Id, Risk_Assessment_Question__mdt>(questions);

        if(!mdtMap.isEmpty()){
            startFetchingMdtDetails(mdtMap);
        }

        return new RiskAssessmentFormConfig(raId, groupQuestionsByRiskArea(result.values()));
    }

    /**
    * @description Method that uses recursion to create tree structure of questions and child questions
    * @author Bluewave | Tomasz Piechota | 18-02-2021
    * @param Map<Id Risk_Assessment_Question__mdt> mdtMap map of questions configured in custom metadata settings
    * @return List<RiskAssessmentQuestion>
    **/
    private static List<RiskAssessmentQuestion> startFetchingMdtDetails(Map<Id, Risk_Assessment_Question__mdt> mdtMap){
        Map<Id, RiskAssessmentQuestion> parentStructure = gatherAllQuestionInformation(mdtMap);

        //attach the first level to actual result and rest will auotmatically link
        //due to pass by reference way
        if(result == null || result.isEmpty()){
            result.putAll(parentStructure);
        }

        // Create map of child questions
        Set<Id> mdtIdSet = mdtMap.keySet();
        String query = String.format('SELECT {0} FROM Risk_Assessment_Question__mdt WHERE Active__c = TRUE AND Parent_Id__c =: mdtIdSet ORDER BY Field_Question_No__c ASC',
            new String[] {
                String.join(
                    new List<String>(
                        Risk_Assessment_Question__mdt.SObjectType.getDescribe().fields.getMap().keySet()
                    ),
                    ','
                )
            }
        );

        List<Risk_Assessment_Question__mdt> childQuestions = Database.query(query);
        Map<Id, Risk_Assessment_Question__mdt> childMap = new Map<Id, Risk_Assessment_Question__mdt>(childQuestions);

        if(childMap != null && !childMap.isEmpty() && childMap.size() > 0){
            Map<Id, Id> mdtChildIdMap = new Map<Id, Id>();
            for(Id childMdtId : childMap.keySet()) {
                Risk_Assessment_Question__mdt child = childMap.get(childMdtId);
                childIdMap.put(child.Id, child.Parent_Id__c);
            }

            //run this method recursively to get all child levels.
            List<RiskAssessmentQuestion> childStructure = startFetchingMdtDetails(childMap);
            for(RiskAssessmentQuestion child : childStructure){
                RiskAssessmentQuestion parent = parentStructure.get(childIdMap.get(child.id));
                parent.items.add(child);
            }
        }

        return parentStructure.values();
    }

    /**
    * @description Crates individual risk questions structure and gathers all into a map
    * @author Bluewave | Tomasz Piechota | 18-02-2021
    * @param Map<Id Risk_Assessment_Question__mdt> mdtMap
    * @return Map<Id, RiskAssessmentQuestion>
    **/
    private static Map<Id, RiskAssessmentQuestion> gatherAllQuestionInformation( Map<Id, Risk_Assessment_Question__mdt> mdtMap){
        Map<Id, RiskAssessmentQuestion> result = new Map<Id, RiskAssessmentQuestion>();

        for(Id mdtId : mdtMap.keySet()){
            Risk_Assessment_Question__mdt mdt = mdtMap.get(mdtId);
            RiskAssessmentQuestion mdtStructure = new RiskAssessmentQuestion(mdtId, mdt, null, null);

            result.put(mdtId, mdtStructure);
        }
        return result;
    }

    /**
    * @description Groups all questions by Risk Area
    * @author Bluewave | Tomasz Piechota | 18-02-2021
    * @param List<RiskAssessmentQuestion> questions
    * @return Map<String, List<RiskAssessmentQuestion>>
    **/
    private static Map<String, List<RiskAssessmentQuestion>> groupQuestionsByRiskArea( List<RiskAssessmentQuestion> questions ) {
        Map<String, List<RiskAssessmentQuestion>> qMap = new Map<String, List<RiskAssessmentQuestion>>();

        for (RiskAssessmentQuestion q : questions) {

            System.debug('before: ' + q.questionNo);
            if(qMap.containsKey(q.riskArea)) {
                List<RiskAssessmentQuestion> qList = qMap.get(q.riskArea);
                qList.add(q);
                qMap.put(q.riskArea, qList);
            } else {
                qMap.put(q.riskArea, new List<RiskAssessmentQuestion> { q });
            }
            System.debug('before: ' + q.questionNo);
        }

        return qMap;
    }

    /**
    * @description Create Progress indicator settings
    * @author Bluewave | Tomasz Piechota | 18-02-2021
    * @param Map<String List<RiskAssessmentQuestion>> qMap
    * @return List<RiskAssessmentFormHelper.ProgressIndicatorStep>
    **/
    private static List<RiskAssessmentFormHelper.ProgressIndicatorStep> getProgressIndicatorStep(Map<String, List<RiskAssessmentQuestion>> qMap) {
        List<RiskAssessmentFormHelper.ProgressIndicatorStep> steps = new List<RiskAssessmentFormHelper.ProgressIndicatorStep>();
        Set<String> pages = qMap.keySet();

        for(Integer i = 0; i < pages.size(); i++) {
            steps.add(new RiskAssessmentFormHelper.ProgressIndicatorStep((new list<String>(pages) )[i], i + 1));
        }

        return steps;
    }

    public static Boolean saveProgress(String recordId, String raObject) {
        try {
            Risk_Assessment__c ra = [SELECT Id, Saved_Assessment_JSON__c FROM Risk_Assessment__c WHERE Id =: recordId];
            ra.Saved_Assessment_JSON__c = raObject;
            System.debug(raObject);
            Database.SaveResult dmlResult = Database.update(ra);
            return dmlResult.isSuccess();
        } catch (Exception e) {
            throw new RiskAssessmentFormHelper.RiskAssessmentException(e.getMessage());
        }
    }

    public class RiskAssessmentFormConfig {
        @AuraEnabled
        public String raId {get; set;}
        @AuraEnabled
        public Map<String, List<RiskAssessmentQuestion>> questions {get; set;}
        @AuraEnabled
        public List<RiskAssessmentFormHelper.ProgressIndicatorStep> steps {get; set;}

        public RiskAssessmentFormConfig(String raId, Map<String, List<RiskAssessmentQuestion>> data) {
            this.raId = raId;
            this.steps = RiskAssessmentFormHelper.getProgressIndicatorStep(data);
            this.questions = data;
        }
    }

    public class ProgressIndicatorStep {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        public ProgressIndicatorStep(String label, Integer value) {
            this.label = label;
            this.value = String.valueOf(value);
        }
    }

    public class RiskAssessmentQuestion implements Comparable {
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public String riskArea {get; set;}
        @AuraEnabled
        public Decimal questionNo {get; set;}
        @AuraEnabled
        public String answerValue {get; set;}
        @AuraEnabled
        public String answerString {get; set;}
        @AuraEnabled
        public String answerDetailsValue {get; set;}
        @AuraEnabled
        public String answerDetailsString {get; set;}
        @AuraEnabled
        public List<RiskAssessmentQuestion> items {get; set;}
        @AuraEnabled
        public Risk_Assessment_Question__mdt definition {get; set;}

        public RiskAssessmentQuestion(String id, Risk_Assessment_Question__mdt definition, String answer, List<RiskAssessmentQuestion> items) {
            this.id = id;
            this.questionNo = definition.Field_Question_No__c;
            this.riskArea = definition.Field_Risk_Area__c;
            this.definition = definition;
            this.answerValue = String.isNotBlank(answer) ? String.valueOf(answer) : String.isNotBlank(this.answerValue) ? this.answerValue : '';
            this.answerString = String.isNotBlank(this.answerString) ? String.valueOf(answer) : '';
            this.answerDetailsValue = String.isNotBlank(this.answerDetailsValue) ? this.answerDetailsValue : '';
            this.answerDetailsString = String.isNotBlank(this.answerDetailsString) ? this.answerDetailsString : '';
            if(items != null && items.size() > 0){
                this.items = items;
            }else{
                this.items = new List<RiskAssessmentQuestion>();
            }
        }

        // Compare questions based on the Field_Question_No__c field.
        public Integer compareTo(Object compareTo) {
            // Cast argument to RiskAssessmentQuestion Wrapper
            RiskAssessmentQuestion compareToQuestionNo = (RiskAssessmentQuestion)compareTo;

            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (definition.Field_Question_No__c > compareToQuestionNo.definition.Field_Question_No__c) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (definition.Field_Question_No__c < compareToQuestionNo.definition.Field_Question_No__c) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            return returnValue;
        }
    }

    public class InitData {
        @AuraEnabled
        public String sObjectId { get; set; }
        @AuraEnabled
        public String sObjectType { get; set; }
        @AuraEnabled
        public Integer raExist { get; set; }
        @AuraEnabled
        public String raInProgress { get; set; }
        @AuraEnabled
        public String raOnboardingId { get; set; }
        @AuraEnabled
        public String raAccountId { get; set; }
        @AuraEnabled
        public String raPendingApproval { get; set; }
    }

    /**
    * @description Custom exception class
    * @author Bluewave | Tomasz Piechota | 11-16-2020
    **/
    public class RiskAssessmentException extends Exception {}
}