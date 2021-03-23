/**
* @description       : LWC Update Company Data component controller.
* @author            : Bluewave | Tomasz Piechota
* @group             :
* @last modified on  : 12-09-2020
* @last modified by  : Bluewave | Tomasz Piechota
* Modifications Log
* Ver   Date         Author                               Modification
* 1.0   11-03-2020   Bluewave | Tomasz Piechota           Initial Version
**/
public with sharing class UpdateCompanyDataController {

    /**
    * @description Return the requested Creditsafe callout custom settings back to LWC
    * @author Bluewave | Tomasz Piechota | 11-26-2020
    * @param config Name of the requested config settings
    * @return Object
    **/
    @AuraEnabled(cacheable=true)
    public static Object getCreditsafeCalloutSettings(String config) {
        String name = String.isNotBlank(config) ? config : 'Default';
        return Credisafe_Callout_Settings__c.getInstance(name);
    }

    /**
    * @description Retrieve company(ies) information with the Credisafe Company Search callout
    * @author Bluewave | Tomasz Piechota | 11-03-2020
    * @param countries comma separated string of country ISO-2 codes, ie: GB,FR
    * @param name Opportunity related Account Name
    * @param postCode Opportunity related Account BillingPostalCode
    * @return ResponseData Object
    **/
    @AuraEnabled
    public static ResponseData newCompanySearch(String countries, String name, String postCode, Integer page, Integer pageSize, String regNo) {
        CreditsafeCalloutHelper.CredisafeToken auth = new CreditsafeCalloutHelper.CredisafeToken(CreditsafeCallout.creditsafeAuthenticate());
        if(auth != null && String.isNotBlank(auth.token)) {
            HTTPResponse response = CreditsafeCallout.creditsafeCompanySearch(auth.token, countries, name, postCode, page, pageSize, regNo);
            if (response != null && (response.getStatusCode() == 200 && response.getStatus() == 'OK')) {
                CreditsafeCompanySearchWrapper searchResult = (CreditsafeCompanySearchWrapper) System.JSON.deserialize(response.getBody(), CreditsafeCompanySearchWrapper.class);
                return new ResponseData(true, CreditsafeCalloutHelper.generateFullAddress(searchResult));
            } else {
                return new ResponseData(false, (CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper) System.JSON.deserialize(response.getBody(), CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper.class));
            }
        } else {
            return new ResponseData(false, 'Creditsafe authentication failed. If the problem persists, please contact you System Administrator.');
        }
    }

    /**
    * @description Retrieve company(ies) credit report data with the Credisafe CreditReport callout,
    * process the results and send the message back to the LWC UI component (updateCompanyData)
    * @author Bluewave | Tomasz Piechota | 11-13-2020
    * @param connectId account connect Id retrieved with the Creditsafe Company Search callout
    * @param accountId account record Id
    * @return ResponseData Object
    **/
    @AuraEnabled
    public static ResponseData newCompanyCreditReport(String connectId, String accountId) {
        if(String.isNotBlank(connectId)) {
            CreditsafeCalloutHelper.CredisafeToken auth = new CreditsafeCalloutHelper.CredisafeToken(CreditsafeCallout.creditsafeAuthenticate());
            if(auth != null && String.isNotBlank(auth.token)) {
                HTTPResponse response = CreditsafeCallout.creditsafeCompanyCreditReport(auth.token, connectId, null);
                if(response != null) {
                    if (response.getStatusCode() == 200 && response.getStatus() == 'OK') {
                        CreditsafeCreditReportWrapper creditReport = CreditsafeCreditReportWrapper.parse(response.getBody());
                        return CreditsafeCalloutHelper.processCreditReportResult(creditReport, accountId);
                    } else {
                        return new ResponseData(false, (CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper) System.JSON.deserialize(response.getBody(), CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper.class));
                    }
                } else {
                    return new ResponseData(false, 'Credit Report callout failed. If the problem persists, please contact your System Administrator.');
                }
            } else {
                return new ResponseData(false, System.Label.Message_Creditsafe_Company_Credit_Report_Authentication_Failed);
            }
        } else {
            return new ResponseData(false, System.Label.Message_Creditsafe_Company_Credit_Report_Invalid_Connect_Id);
        }
    }


    /**
    * @description Retrieve company(ies) credit report data with the Credisafe CreditReport callout,
    * process the results and send the message back to the LWC UI component (updateCompanyData)
    * @author Bluewave | Tomasz Piechota | 12-09-2020
    * @param connectId
    * @param accountId
    * @param reason
    * @return ResponseData
    **/
    @AuraEnabled
    public static ResponseData newCompanyCreditReportDE(String connectId, String accountId, String reason) {
        if(String.isNotBlank(connectId) || String.isNotBlank(reason)) {
            CreditsafeCalloutHelper.CredisafeToken auth = new CreditsafeCalloutHelper.CredisafeToken(CreditsafeCallout.creditsafeAuthenticate());
            if(auth != null && String.isNotBlank(auth.token)) {
                HTTPResponse response = CreditsafeCallout.creditsafeCompanyCreditReport(auth.token, connectId, reason);
                if(response != null) {
                    if (response.getStatusCode() == 200 && response.getStatus() == 'OK') {
                        CreditsafeCreditReportWrapper creditReport = CreditsafeCreditReportWrapper.parse(response.getBody());
                        return CreditsafeCalloutHelper.processCreditReportResult(creditReport, accountId);
                    } else {
                        return new ResponseData(false, (CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper) System.JSON.deserialize(response.getBody(), CreditsafeCalloutHelper.CreditsafeCompanySearchErrorWrapper.class));
                    }
                } else {
                    return new ResponseData(false, 'Credit Report callout failed. If the problem persists, please contact your System Administrator.');
                }
            } else {
                return new ResponseData(false, System.Label.Message_Creditsafe_Company_Credit_Report_Authentication_Failed);
            }
        } else {
            return new ResponseData(false, 'Connect Id or credit repord reason is invalid or missing.');
        }
    }

    /**
    * @description Get the list of all Country names defined in the Countries__c custom Settings
    * @author Bluewave | Tomasz Piechota | 11-19-2020
    * @return ResponseData Object
    **/
    @AuraEnabled(cacheable=true)
    public static ResponseData getCountriesList() {
        List<Countries__c> allCountries = Countries__c.getAll().values();
        if(allCountries != null && allCountries.size() > 0) {
            return new ResponseData(true, CreditsafeCalloutHelper.extractCountryNames(allCountries));
        } else {
            return new ResponseData(false, 'Error while retrieving countries.');
        }
    }

    /**
    * @description Return the requested Creditsafe Credit Report Reasons (DE) custom settings back to LWC
    * @author Bluewave | Tomasz Piechota | 12-09-2020
    * @param country
    * @return ResponseData Object
    **/
    @AuraEnabled(cacheable=true)
    public static ResponseData getCredisafeCreditReportReasonsDE() {
        List<Credisafe_Credit_Report_Reasons_DE__c> reasonsDE = Credisafe_Credit_Report_Reasons_DE__c.getAll().values();
        if(reasonsDE != null && reasonsDE.size() > 0) {
            return new ResponseData(true, CreditsafeCalloutHelper.createCreditReportReasonsList(reasonsDE));
        } else {
            return new ResponseData(false, 'Error while retrieving credit report reasons.');
        }
    }
}