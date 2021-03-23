/**
* @description       : All Creditsafe related callout
* @author            : Bluewave | Tomasz Piechota
* @group             :
* @last modified on  : 12-10-2020
* @last modified by  : Bluewave | Tomasz Piechota
* Modifications Log
* Ver   Date         Author                               Modification
* 1.0   11-03-2020   Bluewave | Tomasz Piechota           Initial Version
**/
public with sharing class CreditsafeCallout {

    /**
    * @description Endpoint to generate a Bearer JWT (Authentication Token).
    * It is mandatory to include this token under the Header Authorization
    * when calling all other endpoints as proof of authenticity. Tokens can
    * exist concurrently and persist for 1 hour from its issued time.
    * @author Bluewave | Tomasz Piechota
    * @return HTTPResponse
    **/
    public static HTTPResponse creditsafeAuthenticate() {
        Http http = new Http();
        HttpRequest req = new HttpRequest();

        // Set endpoint URL from Named Credentials: 'Credisafe Callout'
        req.setEndpoint('callout:CredisafeCallout/authenticate');

        // Prepare merge fields for the request body defined in the Named Credentials: 'Credisafe Callout'
        String password = '{!$Credential.Password}';
        String username = '{!$Credential.Username}';
        req.setBody('{"username": "' + username + '","password": "' + password + '"}');

        // Set content type in the request header
        req.setHeader('Content-Type', 'application/json');

        // Set callout method
        req.setMethod('POST');

        // Send the authentiocation request
        HTTPResponse response = http.send(req);

        return response;
    }

    /**
    * @description Callout to search for Companies according to the provided Search Criteria.
    * @author Bluewave | Tomasz Piechota
    * @param bearerToken Bearer Token retriever from the creditsafeAuthenticate callout method
    * @param countries comma separated string of country ISO-2 codes
    * @param name Opportunity related Account Name
    * @param postCode Opportunity related Account BillingPostalCode
    * @param page number of the page to be retrieved
    * @param pageSize number of results to be retrieved per page
    * @return HTTPResponse
    **/
    public static HTTPResponse creditsafeCompanySearch(String bearerToken, String countries, String name, String postCode, Integer page, Integer pageSize, String regNo) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HTTPResponse response;

        if (String.isNotBlank(countries) && String.isNotBlank(bearerToken)) {
            // Generate query parameter string
            String queryParams = CreditsafeCalloutHelper.getCompanySearchParamsString(countries, name, postCode, page, pageSize, regNo);
            String encoding = Credisafe_Callout_Settings__c.getInstance('Default').Encoding__c;

            // Set endpoint URL from Named Credentials: 'Credisafe Callout'
            // DEV NOTE: EncodingUtil.URLENCODE does not work correctly in this case.
            // req.setEndpoint('callout:CredisafeCallout/companies?' + EncodingUtil.URLENCODE(queryParams, encoding));
            req.setEndpoint('callout:CredisafeCallout/companies?' + CreditsafeCalloutHelper.encodeUrlParams(queryParams));

            // Set content type & bearer token in the request header
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + bearerToken);

            // Set callout method
            req.setMethod('GET');

            // Send the authentiocation request
            response = http.send(req);
        }

        return response;
    }

    /**
    * @description Creditsafe Connect API Company Credit Report. To retrieve the Company Credit Report,
    * a call will be made to the API (GET) to retrieve a company's Credit Report based on
    * the id (Connect Id) retrieved in the Company Search and stored against the Account
    * related to the Opportunity that the process is initiated from.
    * @author Bluewave | Tomasz Piechota
    * @param connectId ie: 'GB-0-03836192' string retrieved in the creditsafeCompanySearch callout and stored
    * in the Connect Id field on the Account record.
    * @return HTTPResponse
    **/
    public static HTTPResponse creditsafeCompanyCreditReport(String bearerToken, String connectId, String reason) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HTTPResponse response;
        String language = Credisafe_Callout_Settings__c.getInstance('Default').Language__c;
        Integer timeout = Integer.valueOf(Credisafe_Callout_Settings__c.getInstance('Default').Timeout__c);
        language = (language != null && language != '') ? language : 'en';
        String de_reason_code = String.isNotBlank(reason) ? '&customData=de_reason_code::' + reason : '';

        if (String.isNotBlank(connectId) && String.isNotBlank(bearerToken)) {
            // Set endpoint URL from Named Credentials: 'Credisafe Callout'
            req.setEndpoint('callout:CredisafeCallout/companies/' + CreditsafeCalloutHelper.encodeUrlParams(connectId + '?language=' + language + de_reason_code));

            // Set content type & bearer token in the request header
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + bearerToken);
            req.setTimeout(timeout); // timeout in milliseconds

            // Set callout method
            req.setMethod('GET');

            // Send the authentiocation request
            response = http.send(req);
        }

        return response;
    }
}