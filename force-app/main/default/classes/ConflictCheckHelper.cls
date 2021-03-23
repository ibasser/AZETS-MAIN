/**
 * @description       : Conflict Check helper class. Entire conflict check logic is in this class.
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 03-03-2021
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   15-01-2021   Bluewave | Tomasz Piechota   Initial Version (Release 2.1)
**/
public with sharing class ConflictCheckHelper {

    public static Integer index = 0;
    private static Id onboardingId {get; set;}

    /**
    * @description Verify if the initiating record is Account or Onboarding and return Account Id
    * @author Bluewave | Tomasz Piechota | 20-02-2021
    * @param String recordId
    * @return String
    **/
    public static String verifyRecordId(String recordId) {
        try{
            if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'Onboarding__c') {
                onboardingId = Id.valueOf(recordId);
                return [SELECT Id, Account__c FROM Onboarding__c WHERE Id = :recordId].Account__c;
            } else {
                return recordId;
            }
        } catch(Exception e) {
            throw new ConflictCheckHelper.ConflictCheckException(e.getMessage());
        }
    }

    /**
    * @description Starts the Conflict Check process directly from the Account
    * @author Bluewave | Tomasz Piechota | 22-01-2021
    * @param String accountId
    * @return List<Conflict_Check__c>
    **/
    public static Map<Id, ConflictCheckResult> startConflictCheck(String accountId) {
        Account a = getAllAccountRelatedCompanyData(accountId);
        List<Company_Data__c> cdList = a?.Company_Data__r;
        List<Company_Data__c> conflictCDs = getAllPotentialMatchingCompanyData(accountId, cdList);
        Map<Company_Data__c, List<Company_Data__c>> mapMatchingRecords = matchSearchResults(accountId, cdList, conflictCDs);

        return generateConflictCheckReport(prepareConflictCheckRecordsMap(removeDuplicatRecords(mapMatchingRecords)));
    }

    /**
    * @description Convert matching Company Data records into Conflict Check records
    * @author Bluewave | Tomasz Piechota | 27-01-2021
    * @param Map<Company_Data__c List<Company_Data__c>> records
    * @return List<Conflict_Check__c>
    **/
    /* private static List<Conflict_Check__c> prepareConflictCheckRecordsList(Map<Company_Data__c, List<Company_Data__c>> records) {
        List<Conflict_Check__c> matchingConflictChecks = new List<Conflict_Check__c>();
        for(Company_Data__c cd : records.keyset()) {
            List<Company_Data__c> cdList = records.get(cd);
            for(Company_Data__c c : cdList) {
                Conflict_Check__c cc = new Conflict_Check__c();

                // Matched company darta record details
                cc.Company_Data_Match__c = c.Id;
                cc.Conflict_Account__c = c.Account__c;
                cc.temp__c = c.Entity_Type__c;

                // Source Data against which the conflict check is performed
                cc.Source_Company_Data__c = cd.Id;
                cc.Source_Account__c = cd.Account__c;

                // Set relationship to Onboarding if CC has been run from Onboarding object
                cc.Onboarding__c = onboardingId;

                matchingConflictChecks.add(cc);
            }
        }

        return matchingConflictChecks;
    } */

    /**
    * @description Convert matching Company Data records into Conflict Check records
    * @author Bluewave | Tomasz Piechota | 27-01-2021
    * @param Map<Company_Data__c List<Company_Data__c>> records
    * @return Map<Company_Data__c, List<Conflict_Check__c>>
    **/
    private static Map<Company_Data__c, List<Conflict_Check__c>> prepareConflictCheckRecordsMap(Map<Company_Data__c, List<Company_Data__c>> records) {
        Map<Company_Data__c, List<Conflict_Check__c>> matchingConflictChecks = new Map<Company_Data__c, List<Conflict_Check__c>>();

        for(Company_Data__c sourceCD : records.keyset()) {
            // List of CCs for this "current" Company Data
            List<Company_Data__c> cdList = records.get(sourceCD);

            // Loop through the CD list and convert/create CC
            for(Company_Data__c conflictCD : cdList) {
                Conflict_Check__c cc = new Conflict_Check__c();
                // Matched company darta record details
                cc.Company_Data_Match__c = conflictCD.Id;
                cc.Conflict_Account__c = conflictCD.Account__c;
                //cc.temp__c = conflictCD.Entity_Type__c;

                // Source Data against which the conflict check is performed
                cc.Source_Company_Data__c = sourceCD.Id;
                cc.Source_Account__c = sourceCD.Account__c;

                // Set relationship to Onboarding if CC has been run from Onboarding object
                cc.Onboarding__c = onboardingId;

                // Add to map
                if(matchingConflictChecks.containsKey(sourceCD)) {
                    List<Conflict_Check__c> ccList = matchingConflictChecks.get(sourceCD);
                    ccList.add(cc);
                    matchingConflictChecks.put(sourceCD, ccList);
                } else {
                    matchingConflictChecks.put(sourceCD, new List<Conflict_Check__c> { cc });
                }
            }
        }

        return matchingConflictChecks;
    }

    /**
    * @description Removes duplicate matching records if exist for a single Company Data record
    * @author Bluewave | Tomasz Piechota | 22-01-2021
    * @param Map<Company_Data__c List<Company_Data__c>> records
    * @return Map<Company_Data__c, List<Company_Data__c>>
    **/
    private static Map<Company_Data__c, List<Company_Data__c>> removeDuplicatRecords(Map<Company_Data__c, List<Company_Data__c>> records) {
        Map<Company_Data__c, List<Company_Data__c>> cleanCompanyDataMap = new Map<Company_Data__c, List<Company_Data__c>>();

        for(Company_Data__c cd : records.keyset()) {
            List<Company_Data__c> dirtyDirtyList = records.get(cd);
            Set<Company_Data__c> superDuperSet = new Set<Company_Data__c>();
            List<Company_Data__c> superDuperList = new List<Company_Data__c>();

            superDuperSet.addAll(dirtyDirtyList);
            superDuperList.addAll(superDuperSet);

            cleanCompanyDataMap.put(cd, superDuperList);
        }

        return cleanCompanyDataMap;
    }

    /**
    * @description Get Account and all related Company Data records
    * @author Bluewave | Tomasz Piechota | 22-01-2021
    * @param String accountId
    * @return Account
    **/
    private static Account getAllAccountRelatedCompanyData(String accountId) {
        Account a;
        try {
            return [SELECT Id
                        , Connect_Id__c
                        , (SELECT Id
                                , Date_of_Birth__c
                                , CC_Dob_Month__c
                                , CC_Dob_Year__c
                                , Entity_Type__c
                                , CC_Name__c
                                , Account__c
                                , Name
                                , Registration_Number__c
                                , Safe_Number__c
                                , Company_ID__c
                                , RecordType.Name
                        FROM Company_Data__r)
                FROM Account
                WHERE Id = :accountId
                LIMIT 1
                FOR UPDATE];
        } catch (Exception e) {
            throw new ConflictCheckException(e.getMessage());
        }
    }

    /**
    * @description Query all potential matching Company Data records based on the matching criteria.
    * It creates a number of Sets that are used to find potential conflicts. It's done thgis way to
    * avoid putting querying inside the loop.
    * @author Bluewave | Tomasz Piechota | 27-01-2021
    * @param Id sourceAccountId
    * @param List<Company_Data__c> sourceCompanyData
    * @return List<Company_Data__c>
    **/
    private static List<Company_Data__c> getAllPotentialMatchingCompanyData(Id sourceAccountId, List<Company_Data__c> sourceCompanyData) {
        Set<Id> sourceSourceCompanyDataIds = new Set<Id>();
        Set<String> sourceEntityTypes = new Set<String>();
        Set<String> sourceCcNames = new Set<String>();
        Set<String> sourceSafeNumbers = new Set<String>();
        Set<String> sourceCompanyIds = new Set<String>();
        Set<String> sourceRegNos = new Set<String>();
        Set<Integer> sourceDobMonths = new Set<Integer>();
        Set<Integer> sourceDobYears = new Set<Integer>();
        List<Company_Data__c> cdList = new List<Company_Data__c>();

        for(Company_Data__c scd : sourceCompanyData) {
            if(String.isNotBlank(scd.Id)) { sourceSourceCompanyDataIds.add(scd.Id); }
            if(String.isNotBlank(scd.Entity_Type__c)) { sourceEntityTypes.add(scd.Entity_Type__c); }
            if(String.isNotBlank(scd.CC_Name__c)) { sourceCcNames.add(scd.CC_Name__c); }
            if(String.isNotBlank(scd.Safe_Number__c)) { sourceSafeNumbers.add(scd.Safe_Number__c); }
            if(String.isNotBlank(scd.Company_ID__c)) { sourceCompanyIds.add(scd.Company_ID__c); }
            if(String.isNotBlank(scd.Safe_Number__c)) { sourceRegNos.add(scd.Safe_Number__c); }
            if(scd.CC_Dob_Month__c != null) { sourceDobMonths.add(Integer.valueOf(scd.CC_Dob_Month__c)); }
            if(scd.CC_Dob_Year__c != null) { sourceDobYears.add(Integer.valueOf(scd.CC_Dob_Year__c)); }
        }

        try {
            cdList = [SELECT Id
                            , Name
                            , Account__c
                            , CC_Name__c
                            , CC_Dob_Month__c
                            , CC_Dob_Year__c
                            , Date_of_Birth__c
                            , Entity_Type__c
                            , Registration_Number__c
                            , Safe_Number__c
                            , Company_ID__c
                            , RecordType.Name
                        FROM Company_Data__c
                        WHERE Entity_Type__c IN :sourceEntityTypes
                        AND Account__c != :sourceAccountId
                        AND Id NOT IN :sourceSourceCompanyDataIds
                        AND (
                            (
                                CC_Name__c != NULL
                                AND
                                CC_Name__c IN :sourceCcNames
                            )
                            OR
                            (
                                CC_Name__c != NULL
                                AND
                                CC_Name__c IN :sourceCcNames
                                AND
                                Date_of_Birth__c != NULL
                                AND
                                CC_Dob_Month__c IN :sourceDobMonths
                                AND
                                CC_Dob_Year__c IN :sourceDobYears
                            )
                            OR
                            (
                                Safe_Number__c != NULL
                                AND
                                Safe_Number__c IN :sourceSafeNumbers
                            )
                            OR
                            (
                                Company_ID__c != NULL
                                AND
                                Company_ID__c IN :sourceCompanyIds
                            )
                            OR
                            (
                                CC_Name__c != NULL
                                AND
                                CC_Name__c IN :sourceCcNames
                                AND
                                Registration_Number__c != NULL
                                AND
                                Registration_Number__c IN :sourceRegNos
                            )
                        )
                    ];
        } catch (Exception e) {
            throw new ConflictCheckException(e.getMessage());
        }

        return cdList;
    }

    /**
    * @description Create a map of source Company Data records and a corresponding matching list of conflict Company Data records
    * @author Bluewave | Tomasz Piechota | 27-01-2021
    * @param Id sourceAccountId
    * @param List<Company_Data__c> sourceCompanyData
    * @param List<Company_Data__c> conflictCompanyData
    * @return Map<Company_Data__c, List<Company_Data__c>>
    **/
    private static Map<Company_Data__c, List<Company_Data__c>> matchSearchResults(Id sourceAccountId, List<Company_Data__c> sourceCompanyData, List<Company_Data__c> conflictCompanyData) {
        Map<Company_Data__c, List<Company_Data__c>> conflictsMap = new Map<Company_Data__c, List<Company_Data__c>>();

        for(Company_Data__c scd : sourceCompanyData) {
            for(Company_Data__c ccd : conflictCompanyData) {

                /* SOQL: Entity_Type__c IN :sourceEntityTypes */
                if(ccd.Entity_Type__c == scd.Entity_Type__c) {

                    /* SOQL: CC_Name__c != NULL AND CC_Name__c IN :sourceCcNames */
                    if(String.isNotBlank(ccd.CC_Name__c) && ccd.CC_Name__c == scd.CC_Name__c) {
                        if(conflictsMap.containsKey(scd)) {
                            List<Company_Data__c> ccdList = conflictsMap.get(scd);
                            ccdList.add(ccd);
                            conflictsMap.put(scd, ccdList);
                        } else {
                            conflictsMap.put(scd, new List<Company_Data__c> { ccd });
                        }
                    }

                    /* SOQL: CC_Name__c != NULL AND CC_Name__c IN :sourceCcNames AND Date_of_Birth__c != NULL AND CC_Dob_Month__c IN :sourceDobMonths AND CC_Dob_Year__c IN :sourceDobYears */
                    if(String.isNotBlank(ccd.CC_Name__c) && ccd.CC_Name__c == scd.CC_Name__c && ccd.Date_of_Birth__c != null && ccd.CC_Dob_Month__c == scd.CC_Dob_Month__c && ccd.CC_Dob_Year__c == scd.CC_Dob_Year__c) {
                        if(conflictsMap.containsKey(scd)) {
                            List<Company_Data__c> ccdList = conflictsMap.get(scd);
                            ccdList.add(ccd);
                            conflictsMap.put(scd, ccdList);
                        } else {
                            conflictsMap.put(scd, new List<Company_Data__c> { ccd });
                        }
                    }

                    /* SOQL: Safe_Number__c != NULL AND Safe_Number__c IN :sourceSafeNumbers */
                    if(String.isNotBlank(ccd.Safe_Number__c) && ccd.Safe_Number__c == scd.Safe_Number__c) {
                        if(conflictsMap.containsKey(scd)) {
                            List<Company_Data__c> ccdList = conflictsMap.get(scd);
                            ccdList.add(ccd);
                            conflictsMap.put(scd, ccdList);
                        } else {
                            conflictsMap.put(scd, new List<Company_Data__c> { ccd });
                        }
                    }

                    /* SOQL: Company_ID__c != NULL AND Company_ID__c IN :sourceCompanyIds */
                    if(String.isNotBlank(ccd.Company_ID__c) && ccd.Company_ID__c == scd.Company_ID__c) {
                        if(conflictsMap.containsKey(scd)) {
                            List<Company_Data__c> ccdList = conflictsMap.get(scd);
                            ccdList.add(ccd);
                            conflictsMap.put(scd, ccdList);
                        } else {
                            conflictsMap.put(scd, new List<Company_Data__c> { ccd });
                        }
                    }

                    /*  SOQL: CC_Name__c != NULL AND CC_Name__c IN :sourceCcNames AND Registration_Number__c != NULL AND Registration_Number__c IN :sourceRegNos */
                    if(String.isNotBlank(ccd.CC_Name__c) && String.isNotBlank(ccd.Registration_Number__c) && ccd.CC_Name__c == scd.CC_Name__c && ccd.Registration_Number__c == scd.Registration_Number__c) {
                        if(conflictsMap.containsKey(scd)) {
                            List<Company_Data__c> ccdList = conflictsMap.get(scd);
                            ccdList.add(ccd);
                            conflictsMap.put(scd, ccdList);
                        } else {
                            conflictsMap.put(scd, new List<Company_Data__c> { ccd });
                        }
                    }
                }
            }
        }

        return conflictsMap;
    }

    public static Map<Id, ConflictCheckResult> generateInitialConflictCheckReport(Map<Company_Data__c, List<Conflict_Check__c>> conflictCheckMap) {
        Map<Id, ConflictCheckResult> initReport = new Map<Id, ConflictCheckResult>();

        for (Company_Data__c sourceCD : conflictCheckMap.keySet()) {
            initReport.put(sourceCD.Id, new ConflictCheckResult(false, conflictCheckMap.get(sourceCD)?.size() + ' x ' + sourceCD.RecordType.Name, sourceCD, conflictCheckMap.get(sourceCD), conflictCheckMap.get(sourceCD)?.size(), 0));
        }

        return initReport;
    }

    /**
    * @description Updates information of the DML operation based on which UI renders information
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    * @param data CompanyUpdateResult apex object
    * @param status Boolean DML operation status
    * @return CompanyUpdateResult
    **/
    private static ConflictCheckResult updateOperationStatus(ConflictCheckResult data, Boolean status, Integer noOfCreatedConflictChecks) {
        data.noOfCreatedConflictChecks = noOfCreatedConflictChecks;
        data.noOfFailedConflictChecks = data.noOfConflictChecks - noOfCreatedConflictChecks;

        if(data.noOfConflictChecks > noOfCreatedConflictChecks) {
            data.message = data.message + ' Failed to create ' + (data.noOfConflictChecks - noOfCreatedConflictChecks) + ' records.';
        }

        if(status) {
            data.status = true;
            data.iconName = 'utility:check';
            data.variant = 'success';
            data.messageClass = 'cc-row slds-text-color_success';
        }

        return data;
    }

    public static Map<Id, ConflictCheckResult> generateConflictCheckReport(Map<Company_Data__c, List<Conflict_Check__c>> conflictCheckMap) {
        // List of Ids of inserted CC records
        List<Id> insertedConflictCheckList = new List<Id>();
        // List of all CCs extracted from the map param
        List<Conflict_Check__c> conflictCheckList = new List<Conflict_Check__c>();
        // DML result list
        List<Database.SaveResult> srList;
        // Map of <sourceCD.Id and list of booleans
        Map<Id, List<Boolean>> insertedConflictCheckMap = new Map<Id, List<Boolean>>();
        // Generate a list of all Conflict Check types <sourceCD.Id, ConflictCheckResult>
        Map<Id, ConflictCheckResult> ccMap = generateInitialConflictCheckReport(conflictCheckMap);

        System.debug(ccMap);
        // Extract CCs from map param
        for (Company_Data__c sourceCD : conflictCheckMap.keySet()) {
            conflictCheckList.addAll(conflictCheckMap.get(sourceCD));
        }

        // Insert CC records
        try {
            // TODO: Verify with Azets whether to it should be "all or nothing" or "allow partial processing of records on failure"
            srList = Database.insert(conflictCheckList, false);
        } catch(Exception e) {
            throw new ConflictCheckException(e.getMessage());
        }

        System.debug('AFTER INSERT MAP');
        System.debug(ccMap);
        System.debug('AFTER INSERT LIST');
        System.debug(conflictCheckList);

        // Go through DML results and add successfull inserts to insertedConflictCheckList list<Id>
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted Conflict Check. ID: ' + sr.getId());
                insertedConflictCheckList.add(sr.getId());
            }
        }


        //Map<Id, Conflict_Check__c> conflictCheckMap  = new Map<Id, Conflict_Check__c>(conflictCheckList);
        for(Conflict_Check__c cc : conflictCheckList) {
            if(insertedConflictCheckList.contains(cc.Id)) {
                if(insertedConflictCheckMap.containsKey(cc.Source_Company_Data__c)) {
                    List<Boolean> boolList = insertedConflictCheckMap.get(cc.Source_Company_Data__c);
                    boolList.add(true);
                    insertedConflictCheckMap.put(cc.Source_Company_Data__c, boolList);
                } else {
                    insertedConflictCheckMap.put(cc.Source_Company_Data__c, new List<Boolean> { true });
                }
            }
        }

        for(Id scdId : ccMap.keySet()) {
            if(insertedConflictCheckMap.containsKey(scdId)) {
                updateOperationStatus(ccMap.get(scdId), insertedConflictCheckMap.get(scdId).size() == ccMap.get(scdId).noOfConflictChecks, insertedConflictCheckMap.get(scdId).size());
            }
        }
        System.debug('AFTER INSERT AND UPDATE MAP');
        System.debug(ccMap);
        return ccMap;
    }

    /**
    * @description Wrapper class for the CreditsafeCallout.creditsafeCompanyCreditReport.
    * @author Bluewave | Tomasz Piechota | 11-16-2020
    **/
    public class ConflictCheckResult {
        @AuraEnabled
        public Integer key{get;set;}
        @AuraEnabled
        public Boolean status{get;set;}
        @AuraEnabled
        public String message{get;set;}
        @AuraEnabled
        public String iconName{get;set;}
        @AuraEnabled
        public String variant{get;set;}
        @AuraEnabled
        public String messageClass{get;set;}
        @AuraEnabled
        public Company_Data__c sourceCompanyData{get;set;}
        @AuraEnabled
        public List<Conflict_Check__c> conflictChecks{get;set;}
        @AuraEnabled
        public Integer noOfConflictChecks{get;set;}
        @AuraEnabled
        public Integer noOfCreatedConflictChecks{get;set;}
        @AuraEnabled
        public Integer noOfFailedConflictChecks{get;set;}

        public ConflictCheckResult(Boolean status, String message, Company_Data__c sourceCompanyData, List<Conflict_Check__c> conflictChecks, Integer noOfConflictChecks, Integer noOfCreatedConflictChecks) {
            this.status = status;
            this.message = message;
            this.iconName = status == true ? 'utility:check' : 'utility:close';
            this.variant = status == true ? 'success' : 'error';
            this.messageClass = status == true ? 'cc-row slds-text-color_success' : 'cc-row slds-text-color_error';
            this.sourceCompanyData = sourceCompanyData;
            this.conflictChecks = conflictChecks;
            this.noOfConflictChecks = noOfConflictChecks;
            this.noOfCreatedConflictChecks = noOfCreatedConflictChecks;
            this.noOfFailedConflictChecks = noOfConflictChecks - noOfCreatedConflictChecks;
            key = index++;
        }
    }

    /**
    * @description Custom exception class
    * @author Bluewave | Tomasz Piechota | 11-16-2020
    **/
    public class ConflictCheckException extends Exception {}

}