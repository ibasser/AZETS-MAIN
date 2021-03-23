/**
 * Purpose: Handle all calls to SmartSearch related to an AML check
 * Description:
 *  SmartSearch authorisation is based on ca bearer token. This token is retrieved on an intial call to Smart Search.
 *  stored in a static variable, coupled with its created date time.
 *  All subsequent calls will be made by generic a method SmartSearchCallout, called with different parameters 
 *  depending on call type (see details below) and returns a JSON object. It will check for validity of tha auth token
 *  and refreh if needed.
 * 
 * Author: PJ (Bluewave)
 * Created Date: Jan 4th 2021
 * */
public with sharing class SmartSearchCalloutHandler {
    public static Boolean orgIsProduction;
    public static SmartSearchDetails__c smartSearchDetails;
    public static String bearerToken;
    public static DateTime tokenCreationDateTime;
    public static Integer tokenLifeMiliseconds;
    public static Boolean suppressApexObjectNulls = true;



    

    /****** TODO **************
     * Purpose: Retrieve the Smart Search login details from custom settings
     */
    public static boolean getSmartSearchDetails(){
        if (orgIsProduction == null) {
            orgIsProduction = !([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox);
            System.debug('Org is production ' + orgIsProduction);
        }
        if (orgIsProduction) {
            smartSearchDetails = SmartSearchDetails__c.getInstance('Production');
        } else {
            smartSearchDetails = SmartSearchDetails__c.getInstance('Sandbox');
        }
        if (smartSearchDetails == null) {
            System.debug('Create a "SmartSearch details" custom setting called ' + (orgIsProduction ? 'Production' : 'Sandbox'));
            return false;
        }
        System.debug('Custom setting retrieved ' + smartSearchDetails.name);

        return true;
    }

    /**
     * Purpose: This method updates the value of the static variables bearerToken and tokenCreatedDateTime
     * Description:
     *  Details of the authentication method can be found in https://sandbox-api.smartsearchsecure.com/#tag/Authentication-Methods
     *  A valid bearer token is returned in response to a MD5 hashed string(blob) of the company 'public key' and date 
     *  
     * Author: PJ (Bluewave)
     * Created Date: Jan 4th 2021
     */ 
    public static boolean getBearerToken(){
        Boolean tokenFound = false;
        
        if (!getSmartSearchDetails()){
            System.debug('Unable to retrieve Smart Search API connection details. Please review custom settings.');
            return false;
        }

        // Generate Company Token
        String today = Datetime.now().format('yyyy-MM-dd');
        String keyAndDate = smartSearchDetails.Company_Key__c+today;
        Blob tempBlob = Blob.valueOf(keyAndDate);
        Blob hashMD5 = Crypto.generateDigest('MD5', tempBlob);
        String company_token = EncodingUtil.convertToHex(hashMD5);

        System.debug('company_token: ' + company_token);
        // Use company token to generate request body
        String body = '{"company_name": "'+ smartSearchDetails.Company_Name__c +'","company_token": "'+company_token+'","user_email": "'+ smartSearchDetails.User_Email__c+'"}';
        System.debug('body: ' + body);
        // Configure request
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(smartSearchDetails.URL__c+'/auth/token');
        req.setMethod('POST');
        req.setTimeout(12000);
        req.setHeader('Accept','application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept-version', '2');
        req.setBody(body);
        
        HttpResponse res = h.send(req);
        
        try{
            Type resultType = Type.forName('SmartSearchWrappers.AuthToken');
            SmartSearchWrappers.AuthToken result = new SmartSearchWrappers.AuthToken();
            result = (SmartSearchWrappers.AuthToken)JSON.deserialize(res.getBody(), resultType);
            System.debug('Result returned. Status = ' + res.getStatusCode());
            System.debug('Result  = ' + result);
            if (null != result.data.attributes.access_token){
                bearerToken= 'Bearer '+result.data.attributes.access_token;
                tokenCreationDateTime=result.meta.timestamp;
                System.debug('Succesfully returned bearer token ' + bearerToken );
                tokenFound = true;
            } else {
                System.debug('Data is null');
                tokenFound = false;
            }

        } catch (Exception e){
            String errorMessage = 'Error: Unable to authenticate with Smart Search: ';
            AuraHandledException error = new AuraHandledException(errorMessage);
            error.setMessage(errorMessage);
            throw error;                                
        }
        return tokenFound;
    }

    /**
     * Purpose: Make the actual call to SmartSearch
     * Description: 
     *  This method will set all of the parameters which are similar for all calls 
     *  providing the first chance for common error handling
     * 
     * Parameters:
     *  - callExtension is the last part of the endpoint '/djo' for Dow Jones only, '/aml' for a GBR aml check and so on
     *  - method type of REST call: POST, GET
     *  - body is the JSON body of the request
     *  - timeout in ms
     * 
     * Author: PJ (Bluewave)
     * Created Date: Jan 4th 2021
     */ 
    public static HttpResponse getSmartSearchCalloutResponse(String callExtension, String method, String body, Integer timeout){
        HttpResponse res = new HttpResponse();

        if (!getSmartSearchDetails()){
            System.debug('Unable to retrieve Smart Search API connection details. Please review custom settings.');
            return res;
        }
        if(!test.isRunningTest())
        {
            getBearerToken();
        }
        else if(test.isRunningTest())
        {
            bearerToken = 'Bearer thisIsAValidToken';
        }

        // Use a Http object to initiate an HTTP request and response
        Http h = new Http();
        // Configure request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(smartSearchDetails.URL__c+callExtension);
        req.setMethod(method);
        req.setTimeout(timeout);
        req.setHeader('Accept','application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept-version', '2');
        req.setHeader('Authorization', bearerToken);

        System.debug('request endpoint: ' + req.getEndpoint());

        System.debug('Body =' + body);
        if (!String.isBlank(body)){
            req.setBody(body);
        }


    
        try {
            // Perform callout and set response
            res = h.send(req);
        } catch (Exception e) {
            String errorMessage = 'Error getting response: ' +e.getMessage();
            System.debug(errorMessage);
            throw new CalloutException(errorMessage);             
        }
        return res;
    }

    public static String runDJOCalloutForAccount(Account account){
        SmartSearchWrappers.DJO_Response result = new SmartSearchWrappers.DJO_Response();


        // Define call parameters
        String method = 'POST';
        String callURLExtension = '/djo';
        Integer timeout = 10000;

        // Generate the call body
        SmartSearchWrappers.DJO_Call accWrapper = new SmartSearchWrappers.DJO_Call();
        accWrapper.client_ref = account.id; 
        accWrapper.company_name = account.name;
        accWrapper.crn = account.Company_Reg_Number__c;
        accWrapper.postcode = account.Registered_Postcode__c;
        accWrapper.sanction_region = 'gbr';
        accWrapper.type = 'business'; 


        System.debug('Call body ' + JSON.serialize(accWrapper));
        
        String body = JSON.serialize(accWrapper, suppressApexObjectNulls);

        HttpResponse response =SmartSearchCalloutHandler.getSmartSearchCalloutResponse(callURLExtension, method, body, timeout);
        System.debug('response body: ' + response.getBody());
        return response.getBody();
    }

    public static String runDJOCalloutForCompanyData(Company_Data__c companyData){
        SmartSearchWrappers.DJO_Response result = new SmartSearchWrappers.DJO_Response();


        // Define call parameters
        String method = 'POST';
        String callURLExtension = '/djo';
        Integer timeout = 10000;

        // Generate the call body
        SmartSearchWrappers.DJO_Call accWrapper = new SmartSearchWrappers.DJO_Call();
        accWrapper.client_ref = companyData.id; 
        accWrapper.company_name = companyData.Company_Name__c;
        accWrapper.crn = companyData.Registration_Number__c;
        accWrapper.postcode = companyData.Address_Postcode__c;
        accWrapper.sanction_region = 'gbr';
        accWrapper.type = 'business'; 


        System.debug('Call body ' + JSON.serialize(accWrapper));
        
        String body = JSON.serialize(accWrapper, suppressApexObjectNulls);

        HttpResponse response =SmartSearchCalloutHandler.getSmartSearchCalloutResponse(callURLExtension, method, body, timeout);

        return response.getBody();
    }

    public static string retrieveDJOCallout(String ssid){
        // Define call parameters
        String method = 'GET';
        String callURLExtension = '/djo/'+ssid;
        Integer timeout = 10000;
        

        HttpResponse response =SmartSearchCalloutHandler.getSmartSearchCalloutResponse(callURLExtension, method, null, timeout);
        System.debug('Retrieve DJO call status ' + response.getStatus());
        return response.getBody();

    }

    public static string retrieveAMLCallout(String ssid, String country){
        // Define call parameters
        String method = 'GET';
        Integer timeout = 10000;
        String callURLExtension;
        if (country == 'GBR') {
            callURLExtension = '/aml/';
        } /*else if(country == 'USA') {
            callURLExtension = '/amlus/';
        } */else {
            callURLExtension = '/doccheck/';
        }
        callURLExtension+=ssid;
        

        HttpResponse response =SmartSearchCalloutHandler.getSmartSearchCalloutResponse(callURLExtension, method, null, timeout);
        System.debug('Retrieve AML call status ' + response.getStatus());
        if(response.getStatus() =='Not Found')
        {
            return response.getStatus();
        }
        else
        {
            return response.getBody();
        }

    }

    // public static string runAMLCallout(Company_Data__c companyData, String country, String riskLevel){
    //     SmartSearchWrappers.AML_Response result = new SmartSearchWrappers.AML_Response();

    //     // Define call parameters
    //     String method = 'POST';
    //     Integer timeout = 10000;
    //     String callURLExtension;
    //     if (country == 'GBR') {
    //         callURLExtension = '/aml';
    //     } else if(country == 'USA') {
    //         callURLExtension = '/amlus';
    //     } else {
    //         return 'Unable to run an international URL';
    //     }

    //     // Generate the call body
    //     // Define first shared parameters, then those which depend on the country
    //     SmartSearchWrappers.SS_Name name = new SmartSearchWrappers.SS_Name();
    //         name.title=companyData.Title__c;
    //         name.first=companyData.First_Name__c;
    //         name.last=companyData.Last_Name__c;
    //         name.middle=companyData.Middle_Name__c;
    //     SmartSearchWrappers.SS_Address address = new SmartSearchWrappers.SS_Address();
    //         address.building = companyData.Address_Building__c; 
    //         address.country = companyData.Country__c;
    //         address.flat = companyData.Address_Flat__c;
    //         address.postcode = companyData.Address_Postcode__c;
    //         address.street_1 = companyData.Address_Street_1__c;
    //         address.street_2 = companyData.Address_Street_2__c;
    //         address.town = companyData.Address_Town__c;
    //     if (country == 'GBR') {
    //         address.region = companyData.Address_Region__c;
    //     } else if(country == 'USA') {
    //         address.state = companyData.Address_State__c;
    //     }
        
    //     if (country == 'GBR') {
    //         SmartSearchWrappers.AML_UK_Call wrapper = new SmartSearchWrappers.AML_UK_Call();
    //     } else {
    //         SmartSearchWrappers.AML_US_Call wrapper = new SmartSearchWrappers.AML_US_Call();
    //     }
    //         wrapper.client_ref =companyData.id;
    //         wrapper.date_of_birth =companyData.Date_of_Birth__c;
    //         wrapper.name =name;
    //         wrapper.addresses = new List<SmartSearchWrappers.SS_Address>();
    //         wrapper.addresses.add(address);
        
    //     if (country == 'GBR') {
    //         wrapper.risk_level =riskLevel;
    //     }

    //     if (country == 'USA'){
    //         SmartSearchWrappers.SS_USA_Documents documents = new SmartSearchWrappers.SS_USA_Documents();
    //         documents.ssn=companyData.NINO_SSN__c;
    //         wrapper.documents = documents;
    //     }
    //     System.debug('Call body ' + JSON.serialize(wrapper));
        
    //     String body = JSON.serialize(wrapper, suppressApexObjectNulls);

    //     HttpResponse response =SmartSearchCalloutHandler.getSmartSearchCalloutResponse(callURLExtension, method, body, timeout);

    //     return response.getBody();
    // }

    public static string runAMLCalloutGBR(Company_Data__c companyData, String riskLevel){
        SmartSearchWrappers.AML_Response result = new SmartSearchWrappers.AML_Response();

        // Define call parameters
        String method = 'POST';
        String callURLExtension = '/aml';
        Integer timeout = 10000;

        // Generate the call body

        // create name
        SmartSearchWrappers.SS_Name name = new SmartSearchWrappers.SS_Name();
            name.title=companyData.Title__c;
            name.first=companyData.First_Name__c;
            name.last=companyData.Last_Name__c;
            name.middle=companyData.Middle_Name__c;
        
        // create address
        SmartSearchWrappers.SS_Address address = new SmartSearchWrappers.SS_Address();
            address.building = companyData.Address_Building__c; 
            address.country = companyData.Country__c;
            address.flat = companyData.Address_Flat__c;
            address.postcode = companyData.Address_Postcode__c;
            address.street_1 = companyData.Address_Street_1__c;
            address.street_2 = companyData.Address_Street_2__c;
            address.town = companyData.Address_Town__c;

        // finalise wrapper
        SmartSearchWrappers.AML_UK_Call wrapper = new SmartSearchWrappers.AML_UK_Call();
            wrapper.client_ref =companyData.id;
            wrapper.date_of_birth =companyData.Date_of_Birth__c;
            wrapper.risk_level =riskLevel;
            wrapper.name =name;
            wrapper.addresses = new List<SmartSearchWrappers.SS_Address>();
            wrapper.addresses.add(address);

        System.debug('Call body ' + JSON.serialize(wrapper));
        
        String body = JSON.serialize(wrapper, suppressApexObjectNulls);

        HttpResponse response =SmartSearchCalloutHandler.getSmartSearchCalloutResponse(callURLExtension, method, body, timeout);

        return response.getBody();
    }

    public static string runAMLCalloutUSA(Company_Data__c companyData){
        SmartSearchWrappers.AML_Response result = new SmartSearchWrappers.AML_Response();

        // Define call parameters
        String method = 'POST';
        Integer timeout = 10000;
        String callURLExtension = '/amlus';


        // Generate the call body

        //create name
        SmartSearchWrappers.SS_Name name = new SmartSearchWrappers.SS_Name();
            name.title=companyData.Title__c;
            name.first=companyData.First_Name__c;
            name.last=companyData.Last_Name__c;
            name.middle=companyData.Middle_Name__c;
        //create address 
        SmartSearchWrappers.SS_Address address = new SmartSearchWrappers.SS_Address();
            address.building = companyData.Address_Building__c; 
            address.country = companyData.Country__c;
            address.flat = companyData.Address_Flat__c;
            address.zip = companyData.Address_Postcode__c;
            address.street_1 = companyData.Address_Street_1__c;
            address.street_2 = companyData.Address_Street_2__c;
            address.town = companyData.Address_Town__c;
            address.state = companyData.Address_State__c;
        
        //create documents
        SmartSearchWrappers.SS_USA_Documents documents = new SmartSearchWrappers.SS_USA_Documents();
            documents.ssn=companyData.NINO_SSN__c;

        //finalise wrapper
        SmartSearchWrappers.AML_US_Call wrapper = new SmartSearchWrappers.AML_US_Call();
            wrapper.client_ref =companyData.id;
            wrapper.date_of_birth =companyData.Date_of_Birth__c;
            wrapper.name =name;
            wrapper.addresses = new List<SmartSearchWrappers.SS_Address>();
            wrapper.addresses.add(address);
            wrapper.documents = documents;
        
        System.debug('Call body ' + JSON.serialize(wrapper));
        
        String body = JSON.serialize(wrapper, suppressApexObjectNulls);

        HttpResponse response =SmartSearchCalloutHandler.getSmartSearchCalloutResponse(callURLExtension, method, body, timeout);

        return response.getBody();
    }

    public static string listDueDiligenceCallout(String ssid){
        // Define call parameters
        String method = 'GET';
        String callURLExtension = '/due_diligence/'+ssid;
        Integer timeout = 10000;
        System.debug('callURLExtension: ' + callURLExtension);

        HttpResponse response =SmartSearchCalloutHandler.getSmartSearchCalloutResponse(callURLExtension, method, null, timeout);
        System.debug('Due diligence call status ' + response.getStatus());
        return response.getBody();

    }

    public static string updateDueDiligenceCallout(String ssid, String ddid, String yourCustomer){
        // Define call parameters
        String method = 'POST';
        String callURLExtension = '/due_diligence/'+ssid+'/'+ddid;
        Integer timeout = 10000;

        //generate call body
        SmartSearchWrappers.UpdateDueDiligence_Call bodyWrapper = new SmartSearchWrappers.UpdateDueDiligence_Call();
        bodyWrapper.your_client = yourCustomer;

        String body = JSON.serialize(bodyWrapper, suppressApexObjectNulls);

        HttpResponse response =SmartSearchCalloutHandler.getSmartSearchCalloutResponse(callURLExtension, method, body, timeout);

        System.debug('Update Due diligence call status ' + response.getStatus());
        System.debug('Response body from updateDDcallout' + response.getBody());

        return response.getBody();

    } 

    public class CalloutException extends Exception {}

}