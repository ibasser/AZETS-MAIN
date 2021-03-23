/**
* @description       : All Creditsafe related callout helper methods
* @author            : Bluewave | Tomasz Piechota
* @group             :
* @last modified on  : 08-02-2021
* @last modified by  : Bluewave | Tomasz Piechota
* Modifications Log
* Ver   Date         Author                               Modification
* 1.0   11-03-2020   Bluewave | Tomasz Piechota           Initial Version
* 2.0   11-03-2020   Bluewave | Tomasz Piechota           [Release 2.1] - Added Entity_Type__c field to the Company_Data__c
*                                                         object to narrow down the conflict check search. As per Creditsafe API EntityType is defined as
*                                                         "Creditsafe.GlobalData.Reports.EntityType": {"enum": ["Other","Person","Company"]}.
*                                                         Added CC_Name__c field to store name information used for conflict checking.
**/
public with sharing class CreditsafeCalloutHelper {

    public static Integer index = 0;

    /**
    * @description String of different parameters required for the Creditsafe Company Search callout
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    * @param countries comma separated string of country ISO-2 codes
    * @param name Opportunity related Account Name
    * @param postCode Opportunity related Account BillingPostalCode
    * @param page number of the page to be retrieved
    * @param pageSize number of results to be retrieved per page
    * @return String concatenated string of param=value
    **/
    public static String getCompanySearchParamsString(String countries, String name, String postCode, Integer page, Integer pageSize, String regNo) {
        String result = '';

        // Get params from Custom Settings (Credisafe Callout Settings)
        Integer pageSizeMax = (Integer) Credisafe_Callout_Settings__c.getInstance('Default').Page_Size_Max__c;
        page = (page != null && page > 0) ? page : (Integer) Credisafe_Callout_Settings__c.getInstance('Default').Page__c;
        pageSize = (pageSize != null && pageSize > 0) ? pageSize > pageSizeMax ? pageSizeMax : pageSize : (Integer) Credisafe_Callout_Settings__c.getInstance('Default').Page_Size__c;
        String language = Credisafe_Callout_Settings__c.getInstance('Default').Language__c;
        Boolean exact = Credisafe_Callout_Settings__c.getInstance('Default').Exact__c;

        // 'countries' is a required parameter for the company search query
        if(String.isNotBlank(countries)) {
            result = result + 'countries=' + Countries__c.getInstance(countries).Country_ISO2_Code__c;
            result = result + '&page=' + page;
            result = result + '&pageSize=' + pageSize;
            if(String.isNotBlank(name)) {
                name = name.replaceAll('&', '%26');
                result = result + '&name=' + name;
            }
            if(exact == true) {
                result = result + '&exact=' + exact;
            }
            if(String.isNotBlank(postCode)) {
                postCode = postCode.replaceAll('&', '%26');
                result = result + '&postCode=' + postCode;
            }
            if(String.isNotBlank(regNo)) {
                result = result + '&regNo=' + regNo;
            }
        }

        return result;
    }

    /**
    * @description Custom URL parameter encoder based on the custom encoding map
    * ┌────────────────────┬────────────────────┐
    * │ Character          │ Encoded Character  │
    * ├────────────────────┼────────────────────┤
    * │ '   (apostrophe)   │ %27                │
    * │ ' ' (space)        │ %20                │
    * │ "   (double quote) │ %22                │
    * └────────────────────┴────────────────────┘
    * @author Bluewave | Tomasz Piechota | 11-05-2020
    * @param url
    * @return String encoded url
    **/
    public static String encodeUrlParams(String url) {

        if(String.isNotBlank(url)) {
            url = url.replaceAll('\'', '%27');
            url = url.replaceAll(' ', '%20');
            url = url.replaceAll('\"', '%22');
        }

        return url;
    }

    /**
    * @description Wrapper class for the CreditsafeCallout.creditsafeAuthenticate HTTPResponse.
    * Object stores the bearer token, status and potential error message.
    * @author Bluewave | Tomasz Piechota
    **/
    public class CredisafeToken {
        public String token;
        public String error;
        public Boolean status;

        public CredisafeToken(HTTPResponse response) {
            // Verify the authentication response object
            if (response == null || (response.getStatusCode() != 200 && response.getStatus() != 'OK')) {
                // Set fail values
                this.error = 'Authentication failed with code: ' + response.getStatusCode();
                this.status = false;
            } else {
                // Verify if the token exists in the response otherwise set fail values
                CredisafeToken ct = (CredisafeToken) System.JSON.deserialize(response.getBody(), CredisafeToken.class);
                if (String.isNotBlank(ct.token)) {
                    this.token = ct.token;
                    this.status = true;
                } else {
                    this.error = 'Authentication failed! No Token.';
                    this.status = false;
                }
            }
        }
    }


    /**
    * @description Process company credit report callout data
    * @author Bluewave | Tomasz Piechota | 11-13-2020
    * @param creditReport
    * @param accountId Account Id
    **/
    public static ResponseData processCreditReportResult(CreditsafeCreditReportWrapper creditReport, String accountId) {
        ResponseData result;
        if(String.isNotBlank(accountId) && creditReport != null && creditReport.report != null) {
            List<Account> al = [SELECT Id
                            , Business_Name__c
                            , Registered_Company_Name__c
                            , Company_Type__c
                            , Sic
                            , SIC_Description__c
                            , Principal_Activity__c
                            , Company_Creation_Date__c
                            , Company_Jurisdiction__c
                            , Company_Reg_Number__c
                            , Company_Status__c
                            , Website
                            , Turnover__c
                            , Credit_Score__c
                            , Credit_Description__c
                            , Credit_Limit__c
                            , International_Score__c
                            , International_Description__c
                            , Credit_Safe_ID__c
                            , Credit_Score_Date__c
                            , Shareholder_Funds__c
                            , VAT_Number__c
                            , Registered_House_Building_Number__c
                            , Registered_Postcode__c
                            , Registered_Street__c
                            , Registered_Town__c
                            , ShippingStreet
                            , ShippingCity
                            , ShippingPostalCode
                            , BillingStreet
                            , BillingCity
                            , BillingPostalCode
                            , Phone
                            , (SELECT Id FROM Company_Data__r)
                        FROM Account WHERE Id = :accountId LIMIT 1];

            if(al.size() > 0) {
                Account a = al.get(0);
                Savepoint sp = Database.setSavepoint();
                try {
                    // Reset all old values
                    a.Business_Name__c = null;
                    a.Registered_Company_Name__c = null;
                    a.Company_Type__c = null;
                    a.Principal_Activity__c = null;
                    a.Sic = null;
                    a.SIC_Description__c = null;
                    a.Company_Creation_Date__c = null;
                    a.Company_Jurisdiction__c = null;
                    a.Company_Reg_Number__c = null;
                    a.Company_Status__c = null;
                    a.Website = null;
                    a.Turnover__c = null;
                    a.Credit_Score__c = null;
                    a.Credit_Description__c = null;
                    a.Credit_Limit__c = null;
                    a.International_Score__c = null;
                    a.International_Description__c = null;
                    a.Credit_Safe_ID__c = null;
                    a.Credit_Score_Date__c = null;
                    a.Shareholder_Funds__c = null;
                    a.VAT_Number__c = null;
                    a.Registered_House_Building_Number__c = null;
                    a.Registered_Postcode__c = null;
                    a.Registered_Street__c = null;
                    a.Registered_Town__c = null;
                    a.BillingStreet = null;
                    a.BillingCity = null;
                    a.BillingPostalCode = null;
                    a.ShippingStreet = null;
                    a.ShippingCity = null;
                    a.ShippingPostalCode = null;
                    a.Phone = null;

                    //Process companyIdentification
                    if(creditReport.report.companyIdentification != null) {
                        if(creditReport.report.companyIdentification.basicInformation != null) {
                            a.Business_Name__c = getValue(creditReport.report.companyIdentification.basicInformation.businessName);
                            a.Registered_Company_Name__c = getValue(creditReport.report.companyIdentification.basicInformation.registeredCompanyName);
                            a.Company_Creation_Date__c = getDateValue(creditReport.report.companyIdentification.basicInformation.companyRegistrationDate);
                            a.Company_Jurisdiction__c = getValue(creditReport.report.companyIdentification.basicInformation.country);
                            a.Company_Reg_Number__c = getValue(creditReport.report.companyIdentification.basicInformation.companyRegistrationNumber);
                            a.VAT_Number__c = getValue(creditReport.report.companyIdentification.basicInformation.vatRegistrationNumber);
                            if(creditReport.report.companyIdentification.basicInformation.legalForm != null) {
                                a.Company_Type__c = getValue(creditReport.report.companyIdentification.basicInformation.legalForm.description);
                            }
                            if(creditReport.report.companyIdentification.basicInformation.principalActivity != null) {
                                a.Principal_Activity__c = getValue(creditReport.report.companyIdentification.basicInformation.principalActivity.description);
                            }
                        }
                        if(creditReport.report.companyIdentification.activityClassifications != null && creditReport.report.companyIdentification.activityClassifications.size() > 0) {
                            if(creditReport.report.companyIdentification.activityClassifications.get(creditReport.report.companyIdentification.activityClassifications.size() - 1).activities != null && creditReport.report.companyIdentification.activityClassifications.get(creditReport.report.companyIdentification.activityClassifications.size() - 1).activities.size() > 0) {
                                a.Sic = getValue(creditReport.report.companyIdentification.activityClassifications.get(creditReport.report.companyIdentification.activityClassifications.size() - 1).activities.get(0).code);
                                a.SIC_Description__c = getValue(creditReport.report.companyIdentification.activityClassifications.get(creditReport.report.companyIdentification.activityClassifications.size() - 1).activities.get(0).description);
                            }
                        }
                    }

                    //Process companySummary
                    if(creditReport.report.companySummary != null) {
                        a.Credit_Safe_ID__c = getValue(creditReport.report.companySummary.companyNumber);
                        if(creditReport.report.companySummary.companyStatus != null) {
                            a.Company_Status__c = getValue(creditReport.report.companySummary.companyStatus.status);
                        }

                        // Turnover
                        if(creditReport.report.companySummary.latestTurnoverFigure != null) {
                            // Creditsafe (Decimal) | Salesforce (String)
                            String currencyCode = String.isNotBlank(getValue(creditReport.report.companySummary.latestTurnoverFigure.currencyCode)) ? getValue(creditReport.report.companySummary.latestTurnoverFigure.currencyCode) : '';
                            a.Turnover__c = formatMoney(getDecimalValue(String.valueOf(creditReport.report.companySummary.latestTurnoverFigure.value)).format(), currencyCode);
                        } else {
                            a.Turnover__c = formatMoney(getDecimalValue(String.valueOf('')).format(), '');
                        }

                        // Shareholder Funds
                        if(creditReport.report.companySummary.latestShareholdersEquityFigure != null) {
                            // Creditsafe (Decimal) | Salesforce (String)
                            String currencyCode = String.isNotBlank(getValue(creditReport.report.companySummary.latestShareholdersEquityFigure.currencyCode)) ? getValue(creditReport.report.companySummary.latestShareholdersEquityFigure.currencyCode) : '';
                            a.Shareholder_Funds__c = formatMoney(getDecimalValue(String.valueOf(creditReport.report.companySummary.latestShareholdersEquityFigure.value)).format(), currencyCode);
                        } else {
                            a.Shareholder_Funds__c = formatMoney(getDecimalValue(String.valueOf('')).format(), '');
                        }
                    }

                    //Process contactInformation
                    if(creditReport.report.contactInformation != null) {
                        if(creditReport.report.contactInformation.websites != null && creditReport.report.contactInformation.websites.size() > 0) {
                            a.Website = getValue(creditReport.report.contactInformation.websites.get(creditReport.report.contactInformation.websites.size() -1));
                        }
                        if(creditReport.report.contactInformation.mainAddress != null) {
                            Map<String, String> registrationAddress = parseRegisteredAddress(creditReport.report.contactInformation.mainAddress);
                            Map<String, String> registrationShippingAddress = parseRegisteredShippingAddress(creditReport.report.contactInformation.mainAddress);

                            // Custom Registeredg Address fields
                            if(registrationAddress.containsKey('Registered_House_Building_Number__c')) {
                                a.Registered_House_Building_Number__c = registrationAddress.get('Registered_House_Building_Number__c');
                            } else {
                                a.Registered_House_Building_Number__c = getValue(creditReport.report.contactInformation.mainAddress.simpleValue);
                            }

                            if(registrationAddress.containsKey('Registered_Postcode__c')) {
                                a.Registered_Postcode__c = registrationAddress.get('Registered_Postcode__c');
                            } else {
                                a.Registered_Postcode__c = getValue(creditReport.report.contactInformation.mainAddress.postalCode);
                            }

                            if(registrationAddress.containsKey('Registered_Street__c')) {
                                a.Registered_Street__c = registrationAddress.get('Registered_Street__c');
                            } else {
                                a.Registered_Street__c = getValue(creditReport.report.contactInformation.mainAddress.street);
                            }

                            if(registrationAddress.containsKey('Registered_Town__c')) {
                                a.Registered_Town__c = registrationAddress.get('Registered_Town__c');
                            } else {
                                a.Registered_Town__c = getValue(creditReport.report.contactInformation.mainAddress.city);
                            }

                            // Shipping Address fields
                            if(registrationShippingAddress.containsKey('ShippingStreet')) {
                                a.ShippingStreet = registrationShippingAddress.get('ShippingStreet');
                            } else {
                                a.ShippingStreet = getValue(creditReport.report.contactInformation.otherAddresses.get(0).simpleValue);
                            }

                            if(registrationShippingAddress.containsKey('ShippingPostalCode')) {
                                a.ShippingPostalCode = registrationShippingAddress.get('ShippingPostalCode');
                            }

                            if(registrationShippingAddress.containsKey('ShippingCity')) {
                                a.ShippingCity = registrationShippingAddress.get('ShippingCity');
                            }
                        }
                        if(creditReport.report.contactInformation.otherAddresses != null && creditReport.report.contactInformation.otherAddresses.size() > 0) {
                            Map<String, String> mainAddress = parseMainAddress(creditReport.report.contactInformation.otherAddresses.get(0));

                            if(mainAddress.containsKey('BillingStreet')) {
                                a.BillingStreet = mainAddress.get('BillingStreet');
                            } else {
                                a.BillingStreet = getValue(creditReport.report.contactInformation.otherAddresses.get(0).simpleValue);
                            }

                            if(mainAddress.containsKey('BillingPostalCode')) {
                                a.BillingPostalCode = mainAddress.get('BillingPostalCode');
                            }

                            if(mainAddress.containsKey('BillingCity')) {
                                a.BillingCity = mainAddress.get('BillingCity');
                            }

                            a.Phone = getValue(creditReport.report.contactInformation.otherAddresses.get(0).telephone);
                        }
                    }

                    // Process creditScore
                    if(creditReport.report.creditScore != null) {
                        if(creditReport.report.creditScore.currentCreditRating != null) {
                            if(creditReport.report.creditScore.currentCreditRating.providerValue != null) {
                                a.Credit_Score__c = getIntegerValue(creditReport.report.creditScore.currentCreditRating.providerValue.value);
                            }
                            if(creditReport.report.creditScore.currentCreditRating.creditLimit != null) {
                                String currencyCode = String.isNotBlank(getValue(creditReport.report.creditScore.currentCreditRating.creditLimit.currencyCode)) ? getValue(creditReport.report.creditScore.currentCreditRating.creditLimit.currencyCode) : '';
                                if(isValidDecimal(String.valueOf(creditReport.report.creditScore.currentCreditRating.creditLimit.value))) {
                                    a.Credit_Limit__c = formatMoney(getDecimalValue(String.valueOf(creditReport.report.creditScore.currentCreditRating.creditLimit.value)).format(), currencyCode);
                                } else {
                                    a.Credit_Limit__c = getValue(creditReport.report.creditScore.currentCreditRating.creditLimit.value);
                                }
                            }
                            a.Credit_Description__c = getValue(creditReport.report.creditScore.currentCreditRating.providerDescription);
                            a.International_Score__c = getValue(creditReport.report.creditScore.currentCreditRating.commonValue);
                            a.International_Description__c = getValue(creditReport.report.creditScore.currentCreditRating.commonDescription);
                        }
                        a.Credit_Score_Date__c = getDateValue(creditReport.report.creditScore.latestRatingChangeDate);
                    }

                    // Generate a list of all Conflict Check types
                    Map<String, CompanyUpdateResult> ccMap = generateConflictCheckReport(creditReport, a);

                    // Update the Account
                    List<Database.SaveResult> dmlResultAccount = Database.update(new Account[] {a});
                    /* if(isDmlSuccessful(dmlResultAccount)) {
                        ccMap.get('account').status = true;
                        ccMap.get('account').iconName = 'utility:check';
                        ccMap.get('account').variant = 'success';
                        ccMap.get('account').messageClass = 'slds-text-color_success';
                    } */
                    updateOperationStatus(ccMap.get('account'), isDmlSuccessful(dmlResultAccount));

                    // Delete existing Conflict Checks
                    List<Database.DeleteResult> dmlResultConflictCheck = Database.delete(a.Company_Data__r);
                    updateOperationStatus(ccMap.get('conflictcheck'), isDmlSuccessful(dmlResultConflictCheck));

                    // Create Directors
                    if(ccMap.containsKey('directors') && ccMap.get('directors').conflictChecks.size() > 0) {
                        List<Database.SaveResult> dmlDirectorsConflictCheck = Database.insert(ccMap.get('directors').conflictChecks);
                        updateOperationStatus(ccMap.get('directors'), isDmlSuccessful(dmlDirectorsConflictCheck));
                    } else {
                        ccMap.put('directors', new CompanyUpdateResult(false, 'Director records found.', new List<Company_Data__c>(), 0));
                        updateOperationStatus(ccMap.get('directors'), true, 'default');
                    }

                    // Create Person ShareHolders
                    if(ccMap.containsKey('PersonShareHolders') && ccMap.get('PersonShareHolders').conflictChecks.size() > 0) {
                        List<Database.SaveResult> dmlPersonShareHoldersConflictCheck = Database.insert(ccMap.get('PersonShareHolders').conflictChecks);
                        updateOperationStatus(ccMap.get('PersonShareHolders'), isDmlSuccessful(dmlPersonShareHoldersConflictCheck));
                    } else {
                        ccMap.put('PersonShareHolders', new CompanyUpdateResult(false, 'Shareholder - Person records found.', new List<Company_Data__c>(), 0));
                        updateOperationStatus(ccMap.get('PersonShareHolders'), true, 'default');
                    }

                    // Create Company ShareHolders
                    if(ccMap.containsKey('CompanyShareHolders') && ccMap.get('CompanyShareHolders').conflictChecks.size() > 0) {
                        List<Database.SaveResult> dmCompanyShareHoldersConflictCheck = Database.insert(ccMap.get('CompanyShareHolders').conflictChecks);
                        updateOperationStatus(ccMap.get('CompanyShareHolders'), isDmlSuccessful(dmCompanyShareHoldersConflictCheck));
                    } else {
                        ccMap.put('CompanyShareHolders', new CompanyUpdateResult(false, 'Shareholder - Company records found.', new List<Company_Data__c>(), 0));
                        updateOperationStatus(ccMap.get('CompanyShareHolders'), true, 'default');
                    }

                    // Create Holding Companies
                    if(ccMap.containsKey('holdingCompanies') && ccMap.get('holdingCompanies').conflictChecks.size() > 0) {
                        List<Database.SaveResult> dmlHoldingCompaniesConflictCheck = Database.insert(ccMap.get('holdingCompanies').conflictChecks);
                        updateOperationStatus(ccMap.get('holdingCompanies'), isDmlSuccessful(dmlHoldingCompaniesConflictCheck));
                    } else {
                        ccMap.put('holdingCompanies', new CompanyUpdateResult(false, 'Client Company records found.', new List<Company_Data__c>(), 0));
                        updateOperationStatus(ccMap.get('holdingCompanies'), true, 'default');
                    }

                    // Create Ultimate Holding Companies
                    if(ccMap.containsKey('ultimateHoldingCompanies') && ccMap.get('ultimateHoldingCompanies').conflictChecks.size() > 0) {
                        List<Database.SaveResult> dmlUltimateHoldingCompaniesConflictCheck = Database.insert(ccMap.get('ultimateHoldingCompanies').conflictChecks);
                        updateOperationStatus(ccMap.get('ultimateHoldingCompanies'), isDmlSuccessful(dmlUltimateHoldingCompaniesConflictCheck));
                    } else {
                        ccMap.put('ultimateHoldingCompanies', new CompanyUpdateResult(false, 'Ultimate Parent records found.', new List<Company_Data__c>(), 0));
                        updateOperationStatus(ccMap.get('ultimateHoldingCompanies'), true, 'default');
                    }

                    // Create Person - Persons With Significant Control
                    if(ccMap.containsKey('PersonPersonsWithSignificantControl') && ccMap.get('PersonPersonsWithSignificantControl').conflictChecks.size() > 0) {
                        List<Database.SaveResult> dmlPersonPersonsWithSignificantControlConflictCheck = Database.insert(ccMap.get('PersonPersonsWithSignificantControl').conflictChecks);
                        updateOperationStatus(ccMap.get('PersonPersonsWithSignificantControl'), isDmlSuccessful(dmlPersonPersonsWithSignificantControlConflictCheck));
                    } else {
                        ccMap.put('PersonPersonsWithSignificantControl', new CompanyUpdateResult(false, 'Person With Significant Control records found.', new List<Company_Data__c>(), 0));
                        updateOperationStatus(ccMap.get('PersonPersonsWithSignificantControl'), true, 'default');
                    }

                    // Create Company - Persons With Significant Control
                    if(ccMap.containsKey('CompanyPersonsWithSignificantControl') && ccMap.get('CompanyPersonsWithSignificantControl').conflictChecks.size() > 0) {
                        List<Database.SaveResult> dmlCompanyPersonsWithSignificantControlConflictCheck = Database.insert(ccMap.get('CompanyPersonsWithSignificantControl').conflictChecks);
                        updateOperationStatus(ccMap.get('CompanyPersonsWithSignificantControl'), isDmlSuccessful(dmlCompanyPersonsWithSignificantControlConflictCheck));
                    } else {
                        ccMap.put('CompanyPersonsWithSignificantControl', new CompanyUpdateResult(false, 'Company With Significant Control records found.', new List<Company_Data__c>(), 0));
                        updateOperationStatus(ccMap.get('CompanyPersonsWithSignificantControl'), true, 'default');
                    }

                    result = new ResponseData(true, ccMap.values());
                } catch(Exception ex) {
                    Database.rollback(sp);
                    result = new ResponseData(false, ex.getMessage());
                }
            } else {
                result = new ResponseData(false, 'Failed to update company data. Couldn\'t reterieve related account information.');
            }
        } else {
            result = new ResponseData(false, 'Account Id or Credit Report is invalid or missing');
        }

        return result;
    }

    /**
    * @description Updates information of the DML operation based on which UI renders information
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    * @param data CompanyUpdateResult apex object
    * @param status Boolean DML operation status
    * @return CompanyUpdateResult
    **/
    private static CompanyUpdateResult updateOperationStatus(CompanyUpdateResult data, Boolean status) {
        if(status) {
            data.status = true;
            data.iconName = 'utility:check';
            data.variant = 'success';
            data.messageClass = 'cd-row slds-text-color_success';
        }

        return data;
    }

    /**
    * @description Updates information of the DML operation based on which UI renders information
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    * @param data CompanyUpdateResult apex object
    * @param status Boolean DML operation status
    * @param variant String manual variant assignment
    * @return CompanyUpdateResult
    **/
    private static CompanyUpdateResult updateOperationStatus(CompanyUpdateResult data, Boolean status, String variant) {
        if(status) {
            data.status = true;
            data.iconName = '';
            data.variant = variant;
            data.messageClass = 'cd-row slds-text-color_' + variant;
        }

        return data;
    }

    /**
    * @description
    * @author Bluewave | Tomasz Piechota | 11-17-2020
    * @param creditReport
    * @param accountId
    * @return Map<String, CompanyUpdateResult>
    **/
    public static Map<String, CompanyUpdateResult> generateConflictCheckReport(CreditsafeCreditReportWrapper creditReport, Account account) {
        List<Company_Data__c> resultList = new List<Company_Data__c>();
        Map<String, CompanyUpdateResult> resultMap = new Map<String, CompanyUpdateResult>();

        resultMap.put('account', new CompanyUpdateResult(false, 'Account details successfully updated.', null, null));
        resultMap.put('conflictcheck', new CompanyUpdateResult(false, 'Previous Company Data records deleted.', null, null));

        // Create Current Directors
        List<Company_Data__c> directors = getDirectors(creditReport, account.Id);
        if(directors.size() > 0) {
            resultMap.put('directors', new CompanyUpdateResult(false, 'Director records created.', directors, directors.size()));
        }

        // Create Shareholders
        Map<String, List<Company_Data__c>> shareHolders = getShareholders(creditReport, account.Id);
        if(shareHolders.containsKey('Person')) {
            if(shareHolders.get('Person').size() > 0) {
                resultMap.put('PersonShareHolders', new CompanyUpdateResult(false, 'Shareholder - Person records created.', shareHolders.get('Person'), shareHolders.get('Person').size()));
            }
        }
        if(shareHolders.containsKey('Company')) {
            if(shareHolders.get('Company').size() > 0) {
                resultMap.put('CompanyShareHolders', new CompanyUpdateResult(false, 'Shareholder - Company records created.', shareHolders.get('Company'), shareHolders.get('Company').size()));
            }
        }

        // Create Holding Companies
        List<Company_Data__c> holdingCompanies = getHoldingCompanies(creditReport, account.Id);
        if(holdingCompanies.size() > 0) {
            resultMap.put('holdingCompanies', new CompanyUpdateResult(false, 'Client Company records created.', holdingCompanies, holdingCompanies.size()));
        }

        // Create Ultimate Holding Companies
        List<Company_Data__c> ultimateHoldingCompanies = getUltimateHoldingCompanies(creditReport, account.Id);
        if(ultimateHoldingCompanies.size() > 0) {
            resultMap.put('ultimateHoldingCompanies', new CompanyUpdateResult(false, 'Ultimate Parent records created.', ultimateHoldingCompanies, ultimateHoldingCompanies.size()));
        }

        // Create Persons with significant control
        Map<String, List<Company_Data__c>> personsWithSignificantControl = getPersonsWithSignificantControl(creditReport, account.Id);
        if(personsWithSignificantControl.containsKey('Person')) {
            if(personsWithSignificantControl.get('Person').size() > 0) {
                resultMap.put('PersonPersonsWithSignificantControl', new CompanyUpdateResult(false, 'Persons With Significant Control records created.', personsWithSignificantControl.get('Person'), personsWithSignificantControl.get('Person').size()));
            }
        }
        if(personsWithSignificantControl.containsKey('Company')) {
            if(personsWithSignificantControl.get('Company').size() > 0) {
                resultMap.put('CompanyPersonsWithSignificantControl', new CompanyUpdateResult(false, 'Company With Significant Control records created.', personsWithSignificantControl.get('Company'), personsWithSignificantControl.get('Company').size()));
            }
        }

        return resultMap;
    }

    /**
    * @description Get directors from Creditsafe credit report
    * @author Bluewave | Tomasz Piechota | 11-17-2020
    * @param creditReport
    * @param accountId
    * @return List<Company_Data__c>
    **/
    public static List<Company_Data__c> getDirectors(CreditsafeCreditReportWrapper creditReport, Id accountId) {
        List<Company_Data__c> resultList = new List<Company_Data__c>();
        if(creditReport.report.directors != null && accountId != null) {
            if(creditReport.report.directors.currentDirectors != null && creditReport.report.directors.currentDirectors.size() > 0) {
                for(CreditsafeCreditReportWrapper.Director d : creditReport.report.directors.currentDirectors) {
                    Company_Data__c director = new Company_Data__c();
                    director.Account__c = accountId;
                    director.Person_ID__c = d.id;
                    if(d.directorType == 'Person') {
                        director.Person_Name__c = getNameString(d?.title, d?.firstName, d?.middleName, d?.surname);
                        director.CC_Name__c = getSearchNameString(d?.firstName, d?.middleName, d?.surname);
                        director.Title__c = d?.title;
                        director.First_Name__c = d?.firstName;
                        director.Middle_Name__c = d?.middleName;
                        director.Last_Name__c = d?.surname;
                    } else {
                        director.Person_Name__c = d.name;
                        director.Company_Name__c = d.name;
                        director.CC_Name__c = getSearchNameString(getSearchCompanyNameString(d.name, true), true);
                    }
                    director.Gender__c = d.gender;
                    director.Date_of_Birth__c = getDateValue(d?.dateOfBirth);
                    director.Nationality__c = d.nationality;
                    director.Registration_Number__c = d.registrationNumber;
                    director.RecordTypeId = SObjectType.Company_Data__c.getRecordTypeInfosByDeveloperName().get('Director').getRecordTypeId();
                    director.Entity_Type__c = d.directorType;
                    resultList.add(director);
                }
            }
        }
        return resultList;
    }

    /**
    * @description Join strings into a single full name string excluding null values
    * @author Bluewave | Tomasz Piechota | 12-01-2020
    * @param title String
    * @param firstname String
    * @param middlename String
    * @param lastname String
    * @return String
    **/
    private static String getNameString(String title, String firstname, String middlename, String lastname) {
        Set<String> sStrings = new Set<String>{title?.trim(), firstname?.trim(), middlename?.trim(), lastname?.trim()};
        sStrings.remove(null);
        sStrings.remove(' ');
        List<String> lStrings = new List<String>(sStrings);
        return String.join(lStrings, ' ');
    }

    /**
    * @description [Release 2.1] Join strings into a single full name string excluding title/salutation and null values.
    * This string is used for conflict Check person name matching.
    * @author Bluewave | Tomasz Piechota | 12-01-2020
    * @param firstname String
    * @param middlename String
    * @param lastname String
    * @return String
    **/
    private static String getSearchNameString(String firstname, String middlename, String lastname) {
        Set<String> sStrings = new Set<String>{firstname?.trim(), middlename?.trim(), lastname?.trim()};
        sStrings.remove(null);
        sStrings.remove(' ');
        List<String> lStrings = new List<String>(sStrings);
        return String.join(lStrings, ' ');
    }

    /**
    * @description [Release 2.1] Remove title/salutation from a single name string.
    * This string is used for conflict Check person name matching.
    * @author Bluewave | Tomasz Piechota | 12-01-2020
    * @param String name
    * @param Boolean onlyFirst
    * @return String
    **/
    private static String getSearchNameString(String name, Boolean onlyFirst) {
        Set<String> titleSet = new Set<String>();
        List<String> querywordsMain = name?.split(' ');
        List<String> querywords = name?.split(' ');

        // Create a set of all active abbreviations
        for (Salutations__c s : Salutations__c.getall().values()) {
            if(s.Active__c){
                titleSet.add(s.Title__c.toLowerCase());
            }
        }

        // Check if name contains title
        if(onlyFirst) {
            if(titleSet.contains(querywordsMain[0].toLowerCase())) {
                querywords.remove(0);
            }
        } else {
            for(Integer i = 0; i < querywordsMain.size(); i++) {
                if(titleSet.contains(querywordsMain[i].toLowerCase())) {
                    querywords.remove(i);
                }
            }
        }

        return String.join(querywords, ' ');
    }

    /**
    * @description [Release 2.1] Remove company abbreviation from company name.
    * This string is used for conflict Check person name matching.
    * @author Bluewave | Tomasz Piechota | 12-01-2020
    * @param String name
    * @param Boolean onlyLast
    * @return String
    **/
    private static String getSearchCompanyNameString(String name, Boolean onlyLast) {
        Set<String> abbrSet = new Set<String>();
        List<String> querywordsMain = name?.split(' ');
        List<String> querywords = name?.split(' ');

        // Create a set of all active abbreviations
        for (Business_Entities_Abbreviations__c s : Business_Entities_Abbreviations__c.getall().values()) {
            if(s.Active__c){
                abbrSet.add(s.Abbr__c.toLowerCase());
            }
        }

        // Check if company name contains abbrev.
        if(onlyLast) {
            if(abbrSet.contains(querywordsMain[querywordsMain.size() - 1].toLowerCase())) {
                querywords.remove(querywordsMain.size() - 1);
            }
        } else {
            for(Integer i = querywordsMain.size() - 1; i >= 0; i--) {
                if(abbrSet.contains(querywordsMain[i].toLowerCase())) {
                    querywords.remove(i);
                }
            }
        }

        return String.join(querywords, ' ');
    }

    /**
    * @description
    * @author Bluewave | Tomasz Piechota | 11-17-2020
    * @param creditReport
    * @param accountId
    * @return List<Company_Data__c>
    **/
    public static Map<String, List<Company_Data__c>> getShareholders(CreditsafeCreditReportWrapper creditReport, Id accountId) {
        List<Company_Data__c> resultList = new List<Company_Data__c>();
        Map<String, List<Company_Data__c>> resultMap = new Map<String, List<Company_Data__c>>();

        if(creditReport.report.shareCapitalStructure != null && accountId != null) {
            if(creditReport.report.shareCapitalStructure.shareHolders != null && creditReport.report.shareCapitalStructure.shareHolders.size() > 0) {
                for(CreditsafeCreditReportWrapper.ShareHolder sh : creditReport.report.shareCapitalStructure.shareHolders) {
                    if(sh.shareholderType == 'Person') {
                        Company_Data__c shareHolder = new Company_Data__c();
                        shareHolder.Account__c = accountId;
                        shareHolder.Percent_Shares_Held__c = sh.percentSharesHeld;
                        shareHolder.Person_Name__c = sh.name;
                        shareHolder.CC_Name__c = getSearchNameString(sh.name, true);
                        shareHolder.RecordTypeId = SObjectType.Company_Data__c.getRecordTypeInfosByDeveloperName().get('Shareholder_Person').getRecordTypeId();
                        shareHolder.Entity_Type__c = sh.shareholderType;
                        shareHolder.Title__c = sh?.title;
                        shareHolder.First_Name__c = sh?.firstName;
                        shareHolder.Middle_Name__c = sh?.middleName;
                        shareHolder.Last_Name__c = sh?.surname;
                        if(resultMap.containsKey('Person')) {
                            List<Company_Data__c> ccList = resultMap.get('Person');
                            ccList.add(shareHolder);
                            resultMap.put('Person', ccList);
                        } else {
                            resultMap.put('Person', new List<Company_Data__c> { shareHolder });
                        }
                    }
                    if(sh.shareholderType == 'Company') {
                        Company_Data__c shareHolder = new Company_Data__c();
                        shareHolder.Account__c = accountId;
                        shareHolder.Company_ID__c = sh.id;
                        shareHolder.Percent_Shares_Held__c = sh.percentSharesHeld;
                        shareHolder.Company_Name__c = sh.name;
                        shareHolder.CC_Name__c = getSearchCompanyNameString(sh.name, true);
                        shareHolder.RecordTypeId = SObjectType.Company_Data__c.getRecordTypeInfosByDeveloperName().get('Shareholder_Company').getRecordTypeId();
                        shareHolder.Entity_Type__c = sh.shareholderType;
                        if(resultMap.containsKey('Company')) {
                            List<Company_Data__c> ccList = resultMap.get('Company');
                            ccList.add(shareHolder);
                            resultMap.put('Company', ccList);
                        } else {
                            resultMap.put('Company', new List<Company_Data__c> { shareHolder });
                        }
                    }
                }
            }
        }
        return resultMap;
    }

    /**
    * @description
    * @author Bluewave | Tomasz Piechota | 11-17-2020
    * @param creditReport
    * @param accountId
    * @return List<Company_Data__c>
    **/
    public static List<Company_Data__c> getHoldingCompanies(CreditsafeCreditReportWrapper creditReport, Id accountId) {
        List<Company_Data__c> resultList = new List<Company_Data__c>();
        if(creditReport.report.groupStructure != null && accountId != null) {
            if(creditReport.report.groupStructure.immediateParent != null) {
                Company_Data__c holdingCompany = new Company_Data__c();
                holdingCompany.Account__c = accountId;
                holdingCompany.RecordTypeId = SObjectType.Company_Data__c.getRecordTypeInfosByDeveloperName().get('Immediate_Parent').getRecordTypeId();
                holdingCompany.Company_ID__c = creditReport.report.groupStructure.immediateParent.id;
                holdingCompany.Safe_Number__c = creditReport.report.groupStructure.immediateParent.safeNumber;
                holdingCompany.Registration_Number__c = creditReport.report.groupStructure.immediateParent.registrationNumber;
                holdingCompany.Company_Name__c = creditReport.report.groupStructure.immediateParent.name;
                holdingCompany.CC_Name__c = getSearchCompanyNameString(creditReport.report.groupStructure.immediateParent.name, true);
                holdingCompany.Entity_Type__c = 'Company';
                resultList.add(holdingCompany);
            }
        }
        return resultList;
    }

    /**
    * @description
    * @author Bluewave | Tomasz Piechota | 11-17-2020
    * @param creditReport
    * @param accountId
    * @return List<Company_Data__c>
    **/
    public static List<Company_Data__c> getUltimateHoldingCompanies(CreditsafeCreditReportWrapper creditReport, Id accountId) {
        List<Company_Data__c> resultList = new List<Company_Data__c>();
        if(creditReport.report.groupStructure != null && accountId != null) {
            if(creditReport.report.groupStructure.ultimateParent != null) {
                Company_Data__c ultimateHoldingCompany = new Company_Data__c();
                ultimateHoldingCompany.Account__c = accountId;
                ultimateHoldingCompany.Account__c = accountId;
                ultimateHoldingCompany.RecordTypeId = SObjectType.Company_Data__c.getRecordTypeInfosByDeveloperName().get('Ultimate_Parent').getRecordTypeId();
                ultimateHoldingCompany.Company_ID__c = creditReport.report.groupStructure.ultimateParent.id;
                ultimateHoldingCompany.Safe_Number__c = creditReport.report.groupStructure.ultimateParent.safeNumber;
                ultimateHoldingCompany.Registration_Number__c = creditReport.report.groupStructure.ultimateParent.registrationNumber;
                ultimateHoldingCompany.Company_Name__c = creditReport.report.groupStructure.ultimateParent.name;
                ultimateHoldingCompany.CC_Name__c = getSearchCompanyNameString(creditReport.report.groupStructure.ultimateParent.name, true);
                ultimateHoldingCompany.Entity_Type__c = 'Company';
                resultList.add(ultimateHoldingCompany);
            }
        }
        return resultList;
    }

    /**
    * @description
    * @author Bluewave | Tomasz Piechota | 11-17-2020
    * @param creditReport
    * @param accountId
    * @return List<Company_Data__c>
    **/
    public static Map<String, List<Company_Data__c>> getPersonsWithSignificantControl(CreditsafeCreditReportWrapper creditReport, Id accountId) {
        //List<Company_Data__c> resultList = new List<Company_Data__c>();
        Map<String, List<Company_Data__c>> resultMap = new Map<String, List<Company_Data__c>>();

        if(creditReport.report.additionalInformation != null && accountId != null && creditReport.report.additionalInformation.PersonsWithSignificantControl != null) {
            if(creditReport.report.additionalInformation.PersonsWithSignificantControl.activePSC != null && creditReport.report.additionalInformation.PersonsWithSignificantControl.activePSC.size() > 0) {
                for(CreditsafeCreditReportWrapper.ActivePSC apsc : creditReport.report.additionalInformation.PersonsWithSignificantControl.activePSC) {
                    if(apsc.personType == 'Person') {
                        Company_Data__c pwsfc = new Company_Data__c();
                        pwsfc.Account__c = accountId;
                        pwsfc.Person_Name__c = apsc.name;
                        pwsfc.CC_Name__c = getSearchNameString(apsc.name, true);
                        pwsfc.Date_of_Birth__c = getDateValue(apsc.dateOfBirth);
                        pwsfc.Nationality__c = apsc.nationality;
                        pwsfc.Entity_Type__c = apsc.personType;
                        pwsfc.RecordTypeId = SObjectType.Company_Data__c.getRecordTypeInfosByDeveloperName().get('Person_with_Significant_Control_Person').getRecordTypeId();
                        pwsfc.Title__c = apsc?.title;
                        pwsfc.First_Name__c = apsc?.firstName;
                        pwsfc.Middle_Name__c = apsc?.middleName;
                        pwsfc.Last_Name__c = apsc?.surname;
                        if(resultMap.containsKey('Person')) {
                            List<Company_Data__c> ccList = resultMap.get('Person');
                            ccList.add(pwsfc);
                            resultMap.put('Person', ccList);
                        } else {
                            resultMap.put('Person', new List<Company_Data__c> { pwsfc });
                        }
                    }
                    if(apsc.personType == 'Company') {
                        Company_Data__c pwsfc = new Company_Data__c();
                        pwsfc.Account__c = accountId;
                        pwsfc.Company_Name__c = apsc.name;
                        pwsfc.CC_Name__c = getSearchCompanyNameString(apsc.name, true);
                        pwsfc.Registration_Number__c = apsc.registrationNumber;
                        pwsfc.Entity_Type__c = apsc.personType;
                        pwsfc.RecordTypeId = SObjectType.Company_Data__c.getRecordTypeInfosByDeveloperName().get('Person_with_Significant_Control_Company').getRecordTypeId();
                        if(resultMap.containsKey('Company')) {
                            List<Company_Data__c> ccList = resultMap.get('Company');
                            ccList.add(pwsfc);
                            resultMap.put('Company', ccList);
                        } else {
                            resultMap.put('Company', new List<Company_Data__c> { pwsfc });
                        }
                    }
                }
            }
        }
        return resultMap;
    }


    /**
    * @description Check if not null and return correct value
    * @author Bluewave | Tomasz Piechota | 11-16-2020
    * @param data
    * @return String
    **/
    public static String getValue(String data) {
        if(String.isNotBlank(data)) {
            return data;
        } else {
            return null;
        }
    }

    /**
    * @description Check if not null and return correct value
    * @author Bluewave | Tomasz Piechota | 11-16-2020
    * @param data
    * @return Decimal
    **/
    public static Decimal getDecimalValue(String data) {
        if(String.isNotBlank(data)) {
            try {
                return Decimal.valueOf(data);
            } Catch (Exception e) {
                System.debug('[ERROR] Get Decimal Value: ' + e);
                return 0.0;
            }
        } else {
            return 0.0;
        }
    }

    /**
    * @description Check if string is a valid decimal
    * @author Bluewave | Tomasz Piechota | 11-16-2020
    * @param data
    * @return Boolean
    **/
    public static Boolean isValidDecimal(String data) {
        try {
            Decimal d = Decimal.valueOf(data);
            return true;
        } Catch (Exception e) {
            System.debug('[ERROR] Not a valid Decimal: ' + e);
            return false;
        }
    }

    /**
    * @description Check if not null and return correct value
    * @author Bluewave | Tomasz Piechota | 11-16-2020
    * @param data
    * @return Integer
    **/
    public static Integer getIntegerValue(String data) {
        if(String.isNotBlank(data)) {
            try {
                return Integer.valueOf(data);
            } Catch (Exception e) {
                System.debug('[ERROR] Get Integer Value: ' + e);
                return 0;
            }
        } else {
            return 0;
        }
    }

    /**
    * @description Check if not null and return correct value
    * @author Bluewave | Tomasz Piechota | 11-16-2020
    * @param data
    * @return Date
    **/
    public static Date getDateValue(String data) {
        if(String.isNotBlank(data)) {
            try {
                return Date.valueOf(data);
            } Catch (Exception e) {
                System.debug('[ERROR] Get Date Value: ' + e);
                return null;
            }
        } else {
            return null;
        }
    }

    /**
    * @description Wrapper class for the CreditsafeCallout.creditsafeCompanySearch bad HTTPResponse.
    * Object stores the error message and status.
    * @author Bluewave | Tomasz Piechota
    **/
    public class CreditsafeCompanySearchErrorWrapper {
        @AuraEnabled
        public String correlationId{get;set;}
        @AuraEnabled
        public String message{get;set;}
        @AuraEnabled
        public String details{get;set;}
    }

    /**
    * @description Verify if a DML SAVE operation was successful
    * @author Bluewave | Tomasz Piechota | 11-16-2020
    * @param dmlResultList
    * @return Boolean
    **/
    public static Boolean isDmlSuccessful(List<Database.SaveResult> dmlResultList) {
        Set<Boolean> dmlResultSet = new Set<Boolean>();

        for (Database.SaveResult dml : dmlResultList) {
            dmlResultSet.add(dml.isSuccess());

        }

        return !dmlResultSet.contains(false);
    }

    /**
    * @description Verify if a DML DELETE operation was successful
    * @author Bluewave | Tomasz Piechota | 11-16-2020
    * @param dmlResultList
    * @return Boolean
    **/
    public static Boolean isDmlSuccessful(List<Database.DeleteResult> dmlResultList) {
        Set<Boolean> dmlResultSet = new Set<Boolean>();

        for (Database.DeleteResult dml : dmlResultList) {
            dmlResultSet.add(dml.isSuccess());
        }

        return !dmlResultSet.contains(false);
    }

    /**
    * @description Wrapper class for the CreditsafeCallout.creditsafeCompanyCreditReport.
    * @author Bluewave | Tomasz Piechota
    **/
    public class CompanyUpdateResult {
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
        public List<Company_Data__c> conflictChecks{get;set;}
        @AuraEnabled
        public Integer noOfConflictChecks{get;set;}

        public CompanyUpdateResult(Boolean status, String message, List<Company_Data__c> conflictChecks, Integer noOfConflictChecks) {
            this.status = status;
            this.message = noOfConflictChecks == null ? message : noOfConflictChecks + ' ' + message;
            this.iconName = status == true ? 'utility:check' : 'utility:close';
            this.variant = status == true ? 'success' : 'error';
            this.messageClass = status == true ? 'cd-row slds-text-color_success' : 'cd-row slds-text-color_error';
            this.conflictChecks = conflictChecks;
            this.noOfConflictChecks = noOfConflictChecks;
            key = index++;
        }
    }

    /**
    * @description Get the list of all Country names defined in the Countries__c Custom Settings
    * and sotr by Name ASC
    * @author Bluewave | Tomasz Piechota | 11-19-2020
    * @param countries List<Countries__c>
    * @return List<Country>
    **/
    public static List<Country> extractCountryNames(List<Countries__c> countries) {
        List<Country> priorityCountryNames = new List<Country>();
        List<Country> countryNames = new List<Country>();
        countries.sort();

        for (Countries__c c : countries) {
            if (c.Priority_Country__c == true) {
                priorityCountryNames.add(new Country(c));
            } else {
                countryNames.add(new Country(c));
            }
        }
        priorityCountryNames.addAll(countryNames);
        priorityCountryNames.sort();

        return priorityCountryNames;
    }

    /**
    * @description Wrapper class for the Country list formatted to be used in LWC combobox field.
    * @author Bluewave | Tomasz Piechota
    **/
    public class Country implements Comparable {
        public Countries__c country;

        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String value{get;set;}

        public Country(Countries__c c) {
            this.country = c;
            this.label = c.name;
            this.value = c.name;
        }

        // Compare Countries based on the Priority_Order__c field.
        public Integer compareTo(Object compareTo) {
            // Cast argument to Country Wrapper
            Country compareToCountry = (Country)compareTo;

            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (country.Priority_Country__c == true && (country.Priority_Order__c > compareToCountry.country.Priority_Order__c)) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (country.Priority_Country__c == true && (country.Priority_Order__c < compareToCountry.country.Priority_Order__c)) {
                // Set return value to a negative value.
                returnValue = -1;
            } else if (country.Priority_Country__c == true && ((country.Priority_Order__c == null) && (compareToCountry.country.Priority_Order__c != null))) {
                // nulls-last implementation
                returnValue = 1;
            } else if (country.Priority_Country__c == true && ((country.Priority_Order__c != null) && (compareToCountry.country.Priority_Order__c == null))) {
                // nulls-last implementation
                returnValue = -1;
            }
            return returnValue;
        }
    }

    /**
    * @description Create the list of Credit Report Reasons for the LWC to use in a combobox
    * @author Bluewave | Tomasz Piechota | 11-19-2020
    * @param countries List<Credisafe_Credit_Report_Reasons_DE__c>
    * @return List<Reason>
    **/
    public static List<Reason> createCreditReportReasonsList(List<Credisafe_Credit_Report_Reasons_DE__c> reasons) {
        List<Reason> reasonsList = new List<Reason>();

        for (Credisafe_Credit_Report_Reasons_DE__c r : reasons) {
            if(r.Active__c == true) {
                reasonsList.add(new Reason(r));
            }
        }

        reasonsList.sort();

        return reasonsList;
    }

    /**
    * @description Wrapper class for the Credit Report Reasons list formatted to be used in LWC combobox field.
    * @author Bluewave | Tomasz Piechota
    **/
    public class Reason implements Comparable {
        public Credisafe_Credit_Report_Reasons_DE__c reason;

        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String value{get;set;}

        public Reason(Credisafe_Credit_Report_Reasons_DE__c r) {
            this.reason = r;
            this.label = r.Description__c;
            this.value = r.Value__c;
        }

        // Compare Countries based on the Priority_Order__c field.
        public Integer compareTo(Object compareTo) {
            // Cast argument to Country Wrapper
            Reason compareToReason = (Reason)compareTo;

            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (reason.Value__c > compareToReason.reason.Value__c) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (reason.Value__c < compareToReason.reason.Value__c) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            return returnValue;
        }
    }

    /**
    * @description Parse registration address and create a map of values
    * @author Bluewave | Tomasz Piechota | 11-20-2020
    * @param CreditsafeCreditReportWrapper.Address
    * @return Map<String, String>
    **/
    public static Map<String, String> parseRegisteredAddress(CreditsafeCreditReportWrapper.Address registeredAddress) {
        Map<String, String> registrationAddress = new Map<String, String>();

        if(String.isNotBlank(registeredAddress.postalCode)) {
            registrationAddress.put('Registered_Postcode__c', registeredAddress.postalCode);
        }

        if(String.isNotBlank(registeredAddress.street)) {
            registrationAddress.put('Registered_Street__c', registeredAddress.street);
        }

        if(String.isNotBlank(registeredAddress.city)) {
            registrationAddress.put('Registered_Town__c', registeredAddress.city);
        }

        // Verify if the postcode in the string is the same as in the postalCode field if so remove from string
        if(String.isNotBlank(registeredAddress.simpleValue)) {
            List<String> simpleValue = registeredAddress.simpleValue.split(',');

            // Remove Postcode
            if(simpleValue.size() > 0 && registrationAddress.containsKey('Registered_Postcode__c')) {
                for(Integer i = simpleValue.size() - 1; i >= 0; i--) {
                    if(simpleValue[i].trim().equals(registrationAddress.get('Registered_Postcode__c').trim())) {
                        simpleValue.remove(i);
                    }
                }
            }

            // Remove Street
            if(simpleValue.size() > 0 && registrationAddress.containsKey('Registered_Street__c')) {
                for(Integer i = simpleValue.size() - 1; i >= 0; i--) {
                    if(simpleValue[i].trim().equals(registrationAddress.get('Registered_Street__c').trim())) {
                        simpleValue.remove(i);
                    }
                }
            }

            // Remove City
            if(simpleValue.size() > 0 && registrationAddress.containsKey('Registered_Town__c')) {
                for(Integer i = simpleValue.size() - 1; i >= 0; i--) {
                    if(simpleValue[i].trim().equals(registrationAddress.get('Registered_Town__c').trim())) {
                        simpleValue.remove(i);
                    }
                }
            }

            String newSimpleValue = String.join(simpleValue, ', ');

            registrationAddress.put('Registered_House_Building_Number__c', newSimpleValue);
        }

        return registrationAddress;
    }

    /**
    * @description Parse registration shipping address and create a map of values
    * @author Bluewave | Tomasz Piechota | 11-20-2020
    * @param CreditsafeCreditReportWrapper.ContactAddress
    * @return Map<String, String>
    **/
    public static Map<String, String> parseRegisteredShippingAddress(CreditsafeCreditReportWrapper.Address registeredAddress) {
        Map<String, String> shippingAddress = new Map<String, String>();

        if(String.isNotBlank(registeredAddress.postalCode)) {
            shippingAddress.put('ShippingPostalCode', registeredAddress.postalCode);
        }

        if(String.isNotBlank(registeredAddress.city)) {
            shippingAddress.put('ShippingCity', registeredAddress.city);
        }

        // Verify if the postcode in the string is the same as in the postalCode field if so remove from string
        if(String.isNotBlank(registeredAddress.simpleValue)) {
            List<String> simpleValue = registeredAddress.simpleValue.split(',');

            // Remove Postcode
            if(simpleValue.size() > 0 && shippingAddress.containsKey('ShippingPostalCode')) {
                for(Integer i = simpleValue.size() - 1; i >= 0; i--) {
                    if(simpleValue[i].trim().equals(shippingAddress.get('ShippingPostalCode').trim())) {
                        simpleValue.remove(i);
                    }
                }
            }

            // Remove City
            if(simpleValue.size() > 0 && shippingAddress.containsKey('ShippingCity')) {
                for(Integer i = simpleValue.size() - 1; i >= 0; i--) {
                    if(simpleValue[i].trim().equals(shippingAddress.get('ShippingCity').trim())) {
                        simpleValue.remove(i);
                    }
                }
            }

            String newSimpleValue = String.join(simpleValue, ', ');

            shippingAddress.put('ShippingStreet', newSimpleValue);
        }

        return shippingAddress;
    }

    /**
    * @description Parse main address and create a map of values
    * @author Bluewave | Tomasz Piechota | 11-20-2020
    * @param CreditsafeCreditReportWrapper.ContactAddress
    * @return Map<String, String>
    **/
    public static Map<String, String> parseMainAddress(CreditsafeCreditReportWrapper.Address mainAddress) {
        Map<String, String> tradingAddress = new Map<String, String>();

        if(String.isNotBlank(mainAddress.postalCode)) {
            tradingAddress.put('BillingPostalCode', mainAddress.postalCode);
        }

        if(String.isNotBlank(mainAddress.city)) {
            tradingAddress.put('BillingCity', mainAddress.city);
        }

        // Verify if the postcode in the string is the same as in the postalCode field if so remove from string
        if(String.isNotBlank(mainAddress.simpleValue)) {
            List<String> simpleValue = mainAddress.simpleValue.split(',');

            // Remove Postcode
            if(simpleValue.size() > 0 && tradingAddress.containsKey('BillingPostalCode')) {
                for(Integer i = simpleValue.size() - 1; i >= 0; i--) {
                    if(simpleValue[i].trim().equals(tradingAddress.get('BillingPostalCode').trim())) {
                        simpleValue.remove(i);
                    }
                }
            }

            // Remove City
            if(simpleValue.size() > 0 && tradingAddress.containsKey('BillingCity')) {
                for(Integer i = simpleValue.size() - 1; i >= 0; i--) {
                    if(simpleValue[i].trim().equals(tradingAddress.get('BillingCity').trim())) {
                        simpleValue.remove(i);
                    }
                }
            }

            String newSimpleValue = String.join(simpleValue, ', ');

            tradingAddress.put('BillingStreet', newSimpleValue);
        }

        return tradingAddress;
    }

    /**
    * @description Expose the the full address in the root of the CreditsafeCompanySearchWrapper.Company record
    * @author Bluewave | Tomasz Piechota | 11-26-2020
    * @param searchResult
    * @return CreditsafeCompanySearchWrapper
    **/
    public static CreditsafeCompanySearchWrapper generateFullAddress(CreditsafeCompanySearchWrapper searchResult) {
        if (searchResult != null && searchResult.companies != null && searchResult.companies.size() > 0) {
            for(CreditsafeCompanySearchWrapper.Company c : searchResult.companies) {
                c.fullAddress = (c.address != null && c.address.simpleValue != null) ? c.address.simpleValue : '';
            }
        }
        return searchResult;
    }

    /**
    * @description
    * @author Bluewave | Tomasz Piechota | 12-02-2020
    * @param value formatted String value of number (Decimal, Integer), ie: '100.00'.format()
    * @param currencyCode
    * @return String
    **/
    public static String formatMoney(String value, String currencyCode) {
        if(String.isNotBlank(value)) {
            value = String.isNotBlank(currencyCode) ? currencyCode + ' ' + value : value;
            if (!value.contains('.')) {
                value = value + '.00';
            } else {
                Integer dPos = value.indexOf('.');
                if (value.length() - dPos < 3) {
                    value = value + '0';
                }
            }
            return value;
        } else {
            return String.isNotBlank(currencyCode) ? currencyCode + ' 0.0' : '0.0';
        }
    }
}