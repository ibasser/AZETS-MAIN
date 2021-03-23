/**
 * Purpose: Provide Data to SmartSearchCallManger LWC
 * 
 * Author: PJ (Bluewave)
 * Created Date: Jan 2021
 */
public with sharing class SmartSearchCallManagerController {
    public static Integer timeoutForSmartSearchCall = 10000;
    /**
     * Purpose: Get relevant individual detail to run a SmartSearch AML and pass them to the LWC
     * Description: 
     *      This method returns a serialised JSON object which can be used to make the smart search call
     * Parameters:
     *      -id = Company Data id
     *
     * Author: PJ (Bluewave)
     * Created Date: Jan 2021
     */
    @AuraEnabled(cacheable=true)
    public static Company_Data__c getCompanyData(String id){
        try {
            System.debug('Find person '+ id);
            Company_Data__c companyData = [SELECT id
                            ,	Account__c
                            ,   Address_Building__c
                            ,   Address_Flat__c
                            ,   Address_Postcode__c
                            ,   Address_Region__c
                            ,   Address_State__c
                            ,   Address_Street_1__c
                            ,   Address_Street_2__c
                            ,   Address_Town__c
                            ,   Company_Name__c
                            ,   Country__c
                            ,	Date_of_Birth__c
                            ,	Entity_Type__c
                            ,   First_Name__c
                            ,	Gender__c
                            ,   Last_Name__c
                            ,   Middle_Name__c
                            ,	Name
                            ,	Nationality__c
                            ,   NINO_SSN__c
                            ,	Person_Name__c
                            ,   RecordType.Name
                            ,	Registration_Number__c
                            ,   SSID__c
                            ,   TItle__c
                        FROM Company_Data__c 
                        WHERE id =: id];
            System.debug('RecordType '+ companyData.RecordType.name);
            return companyData;
            
        } catch (Exception e){
            AuraHandledException error = new AuraHandledException(e.getMessage());
            error.setMessage(e.getMessage());
            throw error;       
        }
    }
    /**
     * Purpose: Get relevant business details to run a SmartSearch AML and pass them to the LWC
     * Description: 
     *      This method returns a serialised JSON object which can be used to make the smart search call
     * Parameters:
     *      -recordId AccountId
     *
     * Author: PJ (Bluewave)
     * Created Date: Jan 2021
     */
    @AuraEnabled(cacheable=true)
    public static Account getAccount(String id){
        try {
            System.debug('Find account '+ id);

            List<Account> accs = [SELECT id,
                            BillingAddress,
                            Company_Reg_Number__c,
                            name,
                            Registered_Postcode__c,
                            ShippingAddress,
                            SSID__c
                        FROM account 
                        WHERE id =: id];
            if (accs.size() > 0){
                System.debug('Returning account '+ accs[0].name);
                return accs[0];
            } else{
                return null;
            }   
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
//({account: this.account, companyData:this.companyData, isAccount:this.isAccount})
    @auraEnabled
    public static String runDjo(Account account, Company_Data__c companyData, Boolean isAccount){
        String djoString;
        if (isAccount) {
            djoString = SmartSearchCalloutHandler.runDJOCalloutForAccount(account);
            updateAccount(account,djoString);
        } else {
            djoString = SmartSearchCalloutHandler.runDJOCalloutForCompanyData(companyData);
            updateCompanyData(companyData,djoString);
        }
        return djoString;

    }

    @auraEnabled
    public static String runAMLApx(Company_Data__c companyData, String country, String riskLevel ){

        String amlString;
        if (country == 'GBR') {
            amlString= SmartSearchCalloutHandler.runAMLCalloutGBR(companyData, riskLevel);
            updateCompanyData(companyData,amlString);
        // } else if (country == 'USA') {
        //     amlString= SmartSearchCalloutHandler.runAMLCalloutUSA(companyData);   
        //     updateCompanyData(companyData,amlString);         
        } else {
            return 'Unable to run an international URL';
        }

        return amlString;
    }

    /**
     * Purpose: Store the SSID in the account
     * Description: 
     * Parameters:
     *      - account 
     *      - djoString : Seriliased json object returned from Smart Search djo query
     * Author: PJ (Bluewave)
     * Created Date: Jan 2021
     */    
    @AuraEnabled
    public static boolean updateAccount(Account account,String djoString){
        try {
            
            SmartSearchWrappers.DJO_Response djoResponse = new SmartSearchWrappers.DJO_Response();
            Type djoResponseType = Type.forName('SmartSearchWrappers.DJO_Response');
            djoResponse = (SmartSearchWrappers.DJO_Response)JSON.deserialize(djoString, djoResponseType);
            account.SSID__c = djoResponse.data.attributes.ssid;
            update account;

            return true;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //  /**
    //  * Purpose: Store the SSID in the Company Data record
    //  * Description: 
    //  * Parameters:
    //  *      - record (COmpany_Data__C) 
    //  *      - jsonString : Seriliased json object returned from Smart Search query
    //  *        Can be a djo or aml query (TODO???)
    //  * Author: PJ (Bluewave)
    //  * Created Date: Jan 2021
    //  */    
    @AuraEnabled
    public static boolean updateCompanyData(Company_Data__c record, String amlString){
        try {
            
            SmartSearchWrappers.AML_Response amlResponse = new SmartSearchWrappers.AML_Response();
            Type amlResponseType = Type.forName('SmartSearchWrappers.AML_Response');
            amlResponse = (SmartSearchWrappers.AML_Response)JSON.deserialize(amlString, amlResponseType);

            record.SSID__c = amlResponse.data.attributes.ssid;
            update record;
            return true;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string retrieveDjoApx(String ssid){
        try {
            String djoString = SmartSearchCalloutHandler.retrieveDJOCallout(ssid);

            return djoString;                
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string retrieveAMLApx(String ssid, String country){
        System.debug('in apex controller ssid: ' + ssid + ' country: ' + country);
        try {
            String amlString = SmartSearchCalloutHandler.retrieveAMLCallout(ssid,country);

            return amlString;                
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string listDueDiligence(String ssid){
        try {
            String dueDiligenceListStr = SmartSearchCalloutHandler.listDueDiligenceCallout(ssid);

            return dueDiligenceListStr;
        } catch (Exception e) {
            system.debug('Error getting due diligence list '+ e.getMessage());
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static string updateDueDiligence(String ssid, String ddid, String yourClient){
        try {
            String updateDueDiligenceString = SmartSearchCalloutHandler.updateDueDiligenceCallout(ssid,ddid,yourClient);
            return updateDueDiligenceString;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        } 
    }

    @AuraEnabled
    public static string getDueDiligenceLink(String ssid, String ddid, String checkType){
        String link = '';
    
        try {
            SmartSearchCalloutHandler.getSmartSearchDetails();
            if(SmartSearchCalloutHandler.smartSearchDetails != null && SmartSearchCalloutHandler.smartSearchDetails.DD_URL__c != null)
            {
                link = SmartSearchCalloutHandler.smartSearchDetails.DD_URL__c +'/'+checkType+'/results/'+ssid+'/'+ddid;
            }
            else 
            {
                link = '';
            }
            return link;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        } 
    }

    /**
     * Purpose: Save Smart Search Check results using one of the two related methods 
     * Description: Calls the relevant method
     *      
     * Parameters:
     *      -id = id of the object where the AML search was launched
     *      -jsonString = serialised JSON response from SmartSearch
     *      -sObjectType = type of object from which the AML Search was launched from 
     *
     * Author: PJ (Bluewave)
     * Created Date: Jan 2021
     */

    @AuraEnabled 
    public static Boolean saveAMLApx(String jsonString, String id, String sObjectType, String country){

        if (sObjectType == 'Account') {
            return saveDJO(jsonString,id);
        } else if (sObjectType == 'Company_Data__c'){
            return saveAML(jsonString,id,country);
        }  else {
            return false;
        }
    }
    
    /**
     * Purpose: save the results of a  dow Jones Search into a NEW Anti_Money_laundering__c record 
     * Description:
     *      Updates the original record with the SSID, parses the json string returned from a Dow Jones call to Smart Search
     *      and maps the result to an AML record
     * 
     * Author: PJ (Bluewave)
     * Created Date: Feb 2021
     */
    public static Boolean saveDJO(String djoString, String accountId){

        try {
            SmartSearchWrappers.DJO_Response djoResponse = new SmartSearchWrappers.DJO_Response();
            Type djoResponseType = Type.forName('SmartSearchWrappers.DJO_Response');
            djoResponse = (SmartSearchWrappers.DJO_Response)JSON.deserialize(djoString, djoResponseType);
            SmartSearchWrappers.DJO_Attributes djoAttributes= djoResponse.data.attributes;

            Anti_Money_Laundering__c aml = new Anti_Money_Laundering__c(
                Account__c = accountId,
                Entity_Type__c='Corporate',
                Has_Due_Diligence__c=djoAttributes.due_diligence.has_due_diligence,
                Has_High_Risk_Due_Diligence__c=djoAttributes.due_diligence.has_highrisk_due_diligence,
                Has_Outstanding_Due_Diligence__c=djoAttributes.due_diligence.has_outstanding_due_diligence,
                Hm_Treasury__c=djoAttributes.due_diligence.hm_treasury,
                HMT_Ofacs__c=djoAttributes.due_diligence.hmt_ofacs,
                JSON_Response__c=djoString,
                ofacs_sanctions__c=djoAttributes.due_diligence.ofacs_sanctions,
                Politically_Exposed_Person__c=djoAttributes.due_diligence.politically_exposed_person,
                Run_Date__c=Date.valueOf(djoAttributes.run_date),
                Sanction_Region__c=djoAttributes.due_diligence.sanction_region,
                special_interest_person__c=djoAttributes.due_diligence.special_interest_person,
                SSID__c=djoAttributes.ssid,
                SSID_Chain__c=string.join(djoAttributes.ssid_chain,','),
                Worldwide_Sanctions__c=djoAttributes.due_diligence.worldwide_sanctions);
                
                insert aml;

                return true;
        } catch (System.JSONException jsonEx) {
            System.debug('Error: A JSON exception has been encountered: ' +jsonEx.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return false;
    }

    /**
     * Purpose: save the results of an AML Search into a NEW Anti_Money_laundering__c record 
     * Description:
     *      Updates the original record parses the json string returned from a Dow Jones call to Smart Search
     *      and maps the result to an AML record
     * 
     * Author: PJ (Bluewave)
     * Created Date: Feb 2021
     */
    public static Boolean saveAML(String amlString, String companyDataId, String country){
        Boolean result;
        if (country == 'gbr') {
            result = saveUkAML(amlString,  companyDataId);
        } else {
            result = saveInternationalAML(amlString,  companyDataId);
        }
        return result;
    }

    public static Boolean saveUkAML(String amlString, String companyDataId){
        try {
            SmartSearchWrappers.AML_Response amlResponse = new SmartSearchWrappers.AML_Response();
            Type amlResponseType = Type.forName('SmartSearchWrappers.AML_Response');
            amlResponse = (SmartSearchWrappers.AML_Response)JSON.deserialize(amlString, amlResponseType);
            SmartSearchWrappers.AML_Attributes amlAttributes= amlResponse.data.attributes;

            String amlResult = '';
            if(amlAttributes.result == 'refer' || amlAttributes.result == 'fail')
            {
                amlResult = 'Fail';
            }
            else 
            {
                amlResult = amlAttributes.result;
            }

            Company_Data__c companyDataRecord = [SELECT Account__c, Entity_Type__c FROM Company_Data__c WHERE id =:companyDataId];
            String entityType = '';
            if(companyDataRecord.Entity_Type__c == 'Company')
            {
                entityType = 'Corporate';
            }
            else if(companyDataRecord.Entity_Type__c == 'Person')
            {
                entityType = 'Person';
            }

            SmartSearchWrappers.DueDiligence dueDiligence = amlAttributes.due_diligence;
            Anti_Money_Laundering__c aml = new Anti_Money_Laundering__c(
                Account__c = companyDataRecord.Account__c,
                Birth_Date__c = Date.valueOf(amlAttributes.date_of_birth),
                Company_Data__c = companyDataId,
                Entity_Type__c= entityType,
                Has_Due_Diligence__c=dueDiligence.has_due_diligence,
                Has_High_Risk_Due_Diligence__c=dueDiligence.has_highrisk_due_diligence,
                Has_Outstanding_Due_Diligence__c=dueDiligence.has_outstanding_due_diligence,
                Hm_Treasury__c=dueDiligence.hm_treasury,
                HMT_Ofacs__c=dueDiligence.hmt_ofacs,
                JSON_Response__c=amlString,
                ofacs_sanctions__c=dueDiligence.ofacs_sanctions,
                Politically_Exposed_Person__c=dueDiligence.politically_exposed_person,
                Result__c = amlResult,
                Sanction_Region__c=dueDiligence.sanction_region,
                special_interest_person__c=dueDiligence.special_interest_person,
                SSID__c=amlAttributes.ssid,
                SSID_Chain__c=string.join(amlAttributes.ssid_chain,','),
                Worldwide_Sanctions__c=dueDiligence.worldwide_sanctions);
                
            
                insert aml;
                return true;
        } catch (System.JSONException jsonEx) {
            System.debug('Error: A JSON exception has been encountered: ' +jsonEx.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return false;
    }

    public static Boolean saveInternationalAML(String amlString, String companyDataId){
        try {
            SmartSearchWrappers.AML_ITL_Response amlResponse = new SmartSearchWrappers.AML_ITL_Response();
            Type amlResponseType = Type.forName('SmartSearchWrappers.AML_ITL_Response');
            amlResponse = (SmartSearchWrappers.AML_ITL_Response)JSON.deserialize(amlString, amlResponseType);
            SmartSearchWrappers.AML_ITL_Attributes amlAttributes= amlResponse.data.attributes;
            String amlResult = '';
            if(amlAttributes.result == 'refer' || amlAttributes.result == 'fail')
            {
                amlResult = 'Fail';
            }
            else 
            {
                amlResult = amlAttributes.result;
            }

            Company_Data__c companyDataRecord = [SELECT Account__c, Entity_Type__c FROM Company_Data__c WHERE id =:companyDataId];
            SmartSearchWrappers.DueDiligence dueDiligence = amlAttributes.due_diligence;

            Anti_Money_Laundering__c aml = new Anti_Money_Laundering__c(
                Account__c = companyDataRecord.Account__c,
                Birth_Date__c = Date.valueOf(amlAttributes.date_of_birth),
                Company_Data__c = companyDataId,
                Entity_Type__c= 'Person',
                JSON_Response__c=amlString,
                Result__c = amlResult,
                SSID__c=amlAttributes.ssid,
                Status__c = amlAttributes.status,
                Status_Description__c = amlAttributes.status_description);
            
            if (amlAttributes.result_reasons != null && amlAttributes.result_reasons.size()>0){
                aml.Result_Reason__c = String.join(amlAttributes.result_reasons,',');
            }

            if (dueDiligence != null) {
                aml.Has_Due_Diligence__c=dueDiligence.has_due_diligence;
                aml.Has_High_Risk_Due_Diligence__c=dueDiligence.has_highrisk_due_diligence;
                aml.Has_Outstanding_Due_Diligence__c=dueDiligence.has_outstanding_due_diligence;
                aml.Hm_Treasury__c=dueDiligence.hm_treasury;
                aml.ofacs_sanctions__c=dueDiligence.ofacs_sanctions;
                aml.Politically_Exposed_Person__c=dueDiligence.politically_exposed_person;
                aml.Sanction_Region__c=dueDiligence.sanction_region;
                aml.special_interest_person__c=dueDiligence.special_interest_person;
                aml.Worldwide_Sanctions__c=dueDiligence.worldwide_sanctions;
            }
            
            insert aml;
            return true;
        } catch (System.JSONException jsonEx) {
            System.debug('Error: A JSON exception has been encountered: ' +jsonEx.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return false;
    }


}