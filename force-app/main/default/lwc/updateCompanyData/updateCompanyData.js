/**
 * @description       :
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 02-03-2021
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   21-01-2021   Bluewave | Tomasz Piechota   Initial Version
**/
import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import customCssStyles from '@salesforce/resourceUrl/CreditsafeUpdateCompanyDataStyle';
import getCreditsafeCalloutSettings from '@salesforce/apex/UpdateCompanyDataController.getCreditsafeCalloutSettings';
import getCredisafeCreditReportReasonsDE from '@salesforce/apex/UpdateCompanyDataController.getCredisafeCreditReportReasonsDE';
import newCompanySearch from '@salesforce/apex/UpdateCompanyDataController.newCompanySearch';
import newCompanyCreditReport from '@salesforce/apex/UpdateCompanyDataController.newCompanyCreditReport';
import newCompanyCreditReportDE from '@salesforce/apex/UpdateCompanyDataController.newCompanyCreditReportDE';
import getCountriesList from '@salesforce/apex/UpdateCompanyDataController.getCountriesList';
import ACCOUNT_ID from '@salesforce/schema/Account.Id';
import ACCOUNT_NAME from '@salesforce/schema/Account.Name';
import ACCOUNT_COUNTRY from '@salesforce/schema/Account.BillingCountry';
import ACCOUNT_CONNECT_ID from '@salesforce/schema/Account.Connect_Id__c';
import ACCOUNT_BILLING_POSTAL_CODE from '@salesforce/schema/Account.BillingPostalCode';
import CompletedDateTime from '@salesforce/schema/Task.CompletedDateTime';

// Release 2.1
import checkIfCompanyDataExists from '@salesforce/apex/ConflictCheckController.checkIfCompanyDataExists';

const fields = [
    ACCOUNT_ID,
    ACCOUNT_NAME,
    ACCOUNT_COUNTRY,
    ACCOUNT_CONNECT_ID,
    ACCOUNT_BILLING_POSTAL_CODE
];

const columns = [
    {
        type:  'button',
        typeAttributes:
        {
          iconName: 'utility:link',
          label: 'Link',
          name: 'link',
          title: 'Link record',
          disabled: false,
          value: {fieldName: 'id'}
        },
        initialWidth: 85
    },
    { label: 'Company Name', fieldName: 'name' },
    { label: 'Address', fieldName: 'fullAddress', type: 'text' },
    { label: 'Status', fieldName: 'status', type: 'text', initialWidth: 130 },
    {
        type: 'action',
        typeAttributes: {
            rowActions: [{
                label: 'Show details',
                name: 'show_details'
            }]
        },
    },
];


export default class UpdateCompanyData extends LightningElement {
    @api recordId;

    @track wiredAccount;
    @track wiredCountryList;
    @track companySearchData = [];
    @track companyData = [];
    @track countryList = [];
    @track calloutSettings = [];
    @track creditReportReasonsDE = [];

    loading = false;
    columns = columns;
    total = 0;
    page = 1;
    pageSize = 0;
    totalPages = 0;

    companyDetails = '';

    missingCountry = true;
    /* missingPostcode = false;
    missingAccountname = false; */
    missingConnectId = false;
    showCompanyDetails = false;

    companySearchParamForm = false;
    companyUpdateWithReasonForm = false;

    creditsafeCompanySearchName = '';
    creditsafeCompanySearchPostalCode = '';
    creditsafeCompanySearchCountry = '';
    creditsafeCompanyRegistrationNumber = '';
    creditsafeCreditReportReasonValue = '';

    // Release 2.1
    companyDataExist = false;
    wiredCompanyDataCheck;
    manualConflictCheck = true;
    showConflictCheckResults = false

    connectedCallback() {
        Promise.all([
            loadStyle(this, customCssStyles)
        ])
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading 1',
                    message: 'Something went wrong and custom CSS couldn\'t be loaded.',
                    variant: 'error'
                })
            );
        });
    }

    @wire(getCountriesList)
    wireCountryList({ error, data }) {
        if (data) {
            if(data.status) {
                this.countryList = data.returnData;
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ERROR',
                        message: 'Something went wrong when fetching the list of countries.',
                        variant: 'error'
                    })
                );
            }
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR',
                    message: 'Couldn\'t retrieve the list of countries.',
                    variant: 'error'
                })
            );
        }
    }

    @wire(getCreditsafeCalloutSettings)
    wireCalloutSettings({ error, data }) {
        if (data) {
            this.calloutSettings = data;
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR',
                    message: 'Couldn\'t retrieve the callout settings. PLease contact your System Administrator.',
                    variant: 'error'
                })
            );
        }
    }

    @wire(getCredisafeCreditReportReasonsDE)
    wireCreditReportReasonsDE({ error, data }) {
        if (data) {
            if(data.status) {
                this.creditReportReasonsDE = data.returnData;
                if(this.creditReportReasonsDE && this.creditReportReasonsDE.length == 1) {
                    this.creditsafeCreditReportReasonValue = this.creditReportReasonsDE[0].value;
                }
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ERROR',
                        message: 'Something went wrong when fetching the list of credit report reasons.',
                        variant: 'error'
                    })
                );
            }
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR',
                    message: 'Couldn\'t retrieve the list of credit report reasons.',
                    variant: 'error'
                })
            );
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields }) wireAccount(result) {
        this.wiredAccount = result;
        if (result.data) {
            let data = result.data;
            this.missingCountry = !getFieldValue(data, ACCOUNT_COUNTRY);
            this.missingAccountname = !getFieldValue(data, ACCOUNT_NAME);
            this.missingConnectId = !getFieldValue(data, ACCOUNT_CONNECT_ID);
            this.missingPostcode = !getFieldValue(data, ACCOUNT_BILLING_POSTAL_CODE);
            this.germanConnectId = this.checkIfGermanConnectId(getFieldValue(data, ACCOUNT_CONNECT_ID));
        } else if (result.error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: result.error,
                    variant: 'error'
                })
            );
        }
    };

    @wire(checkIfCompanyDataExists, { recordId: '$recordId'}) wireCompanyDataCheck(result) {
        this.wiredCompanyDataCheck = result;
        if (result.data) {
            if(result.data.status) {
                this.companyDataExist = result.data.returnData;
            }
        } else if (result.error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: result.error,
                    variant: 'error'
                })
            );
        }
    };

    get countryOptions() { return this.countryList; }
    get countryOptionsLoaded() { return this.countryList.length > 0; }
    get reasonOptions() { return this.creditReportReasonsDE; }
    get reasonOptionsLoaded() { return this.creditReportReasonsDE.length > 0; }
    get accountId() { return getFieldValue(this.wiredAccount.data, ACCOUNT_ID); }
    get country() { return getFieldValue(this.wiredAccount.data, ACCOUNT_COUNTRY); }
    get accountName() { return getFieldValue(this.wiredAccount.data, ACCOUNT_NAME); }
    get connectId() { return getFieldValue(this.wiredAccount.data, ACCOUNT_CONNECT_ID); }
    get postCode() { return getFieldValue(this.wiredAccount.data, ACCOUNT_BILLING_POSTAL_CODE); }

    //get oppId() { return this.recordId; }
    get currentPage() { return this.page; }
    get isLoading() { return this.loading; }
    get totalResults() { return this.total; }
    get totalPagesAvailable() { return this.totalPages; }
    get companyDataRecords() { return this.companyData; }
    get accountNotLinked() { return this.missingConnectId; }
    get noCompanyData() { return (this.missingConnectId ? true : !this.companyDataExist); } // Release 2.1
    get companyDataRetrieved() { return this.companyData.length > 0; }
    get showCompanySearchParamForm() { return this.companySearchParamForm; }
    get showCompanyUpdateWithReasonForm() { return this.companyUpdateWithReasonForm; }
    get showLoadMoreResults() { return this.companySearchData.length < this.total; }
    get isGermanConnectId() { return this.germanConnectId; }

    /* get hasErrorCountry() {
        return this.missingCountry;
    }

    get hasErrorPostcode() {
        return this.missingPostcode;
    }

    get hasErrorAccountName() {
        return this.missingAccountname;
    } */

    get disableNewCompanySearch() {
        //return this.missingCountry;
        return this.creditsafeCompanySearchCountry == null || typeof this.creditsafeCompanySearchCountry == 'undefined' || this.creditsafeCompanySearchCountry == '';
    }

    get disableUpdateCompanyDataReasons() {
        return this.creditsafeCreditReportReasonValue == null || typeof this.creditsafeCreditReportReasonValue == 'undefined' || this.creditsafeCreditReportReasonValue == '';
    }

    get showSearchResults() {
        return this.companySearchData != null && typeof this.companySearchData != 'undefined' && this.companySearchData.length > 0;
    }

    get loadMoreResultsButtonLabel() {
        if(this.companySearchData) {
            return 'Get More Records (Retrieved ' + this.companySearchData.length + ' of ' + this.total + ')';
        } else {
            return 'Get More Records';
        }
    }

    // Set Creditsafe COmpany Search params
    get creditsafeName() { return this.creditsafeCompanySearchName; }
    get creditsafeCountry() { return this.creditsafeCompanySearchCountry; }
    get creditsafePostalCode() { return this.creditsafeCompanySearchPostalCode; }
    get creditsafeRegistrationNumber() { return this.creditsafeCompanyRegistrationNumber; }
    get creditsafeCompanyDetails() { return this.companyDetails; }
    get disabledCompanyPoscodeField() { return this.creditsafeCompanyRegistrationNumber != null && this.creditsafeCompanyRegistrationNumber != '' && typeof this.creditsafeCompanyRegistrationNumber != 'undefined'; }
    get regNoDisabled() { return (this.creditsafeCompanySearchName != null && this.creditsafeCompanySearchName != '' && typeof this.creditsafeCompanySearchName != 'undefined') || (this.creditsafeCompanySearchPostalCode != null && this.creditsafeCompanySearchPostalCode != '' && typeof this.creditsafeCompanySearchPostalCode != 'undefined'); }
    get creditReportReason() { return this.creditsafeCreditReportReasonValue; }

    // Close quick action modal. Dispatch event to Aura component and close quick action.
    handleCancel() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleChange(event){
        let name = event.target.name;
        let value = event.target.value;
        switch(name) {
            case 'name': {
                this.creditsafeCompanySearchName = value;
                break;
            }
            case 'country': {
                this.creditsafeCompanySearchCountry = value;
                break;
            }
            case 'postcode': {
                this.creditsafeCompanySearchPostalCode = value;
                break;
            }
            case 'regno': {
                this.creditsafeCompanyRegistrationNumber = value;
                break;
            }
            case 'reason': {
                this.creditsafeCreditReportReasonValue = value;
                break;
            }
        }
    }

    // handleNewCompanySearch
    handleNewCompanySearch(currentpage) {
        this.loading = true;
        this.companySearchParamForm = false;

        if(currentpage.target.value) {
            if(currentpage.target.value + 1 <= this.totalPages || currentpage.target.value == 0) {
                this.page = currentpage.target.value + 1;
            }
        } else  {
            if(this.currentPage + 1 <= this.totalPages || this.currentPage == 0) {
                this.page = this.currentPage + 1;
            }
        }

        newCompanySearch({
            countries : this.creditsafeCountry,
            name: this.creditsafeName,
            postCode: this.creditsafePostalCode,
            page: this.currentPage,
            pageSize: this.calloutSettings.Page_Size__c,
            regNo: this.creditsafeRegistrationNumber
        })
        .then(result => {
            this.loading = false;
            this.prepareCompanySearchData(result);
        })
        .catch(error => {
            this.loading = false;
            console.debug('error', error);
            if(error) {
                if(error.body && error.body.message) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: error.statusText,
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                }
            }
        });
    }

    prepareCompanySearchData(data) {
        if(data) {
            if(data.status) {
                if(data.returnData) {
                    let returnData = data.returnData;

                    if(returnData.companies && returnData.companies.length > 0) {
                        const currentData = this.companySearchData;
                        //Appends new data to the end of the table
                        const newData = currentData.concat(returnData.companies);
                        this.companySearchData = newData;
                    }

                    if(returnData.messages && returnData.messages.length > 0) {
                        let msg = returnData.messages[0];
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: msg.code,
                                message: msg.text,
                                variant: 'warning'
                            })
                        );
                    }

                    if(this.totalPagesAvailable == 0 && this.calloutSettings.Page_Size__c > 0 && returnData.totalSize > 0) {
                        this.totalPages = Math.ceil(returnData.totalSize / this.calloutSettings.Page_Size__c);
                    } else {
                        this.totalPages = 0;
                    }

                    this.total = returnData.totalSize;
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'ERROR',
                            message: 'Something went wrong and. Please contact your System Administrator.',
                            variant: 'error'
                        })
                    );
                }
            } else {
                if(data.returnData) {
                    let errorData = data.returnData;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: errorData.message,
                            message: errorData.details,
                            variant: 'error'
                        })
                    );
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'ERROR',
                            message: 'Something went wrong and. Please contact your System Administrator.',
                            variant: 'error'
                        })
                    );
                }
            }
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR',
                    message: 'Something went wrong and. Please contact your System Administrator.',
                    variant: 'error'
                })
            );
        }
    }

    handleUpdateCompanyDataWithReason() {
        this.loading = true;
        this.companyUpdateWithReasonForm = false;

        if(!this.accountNotLinked) {
            newCompanyCreditReportDE({
                connectId : this.connectId,
                accountId : this.accountId,
                reason: this.creditReportReason
            })
            .then(result => {
                this.loading = false;
                if(result) {
                    if(result.status) {
                        if(result.returnData) {
                            this.companyData = result.returnData;
                            // Display fresh data in the form
                            refreshApex(this.wiredAccount);
                            refreshApex(this.wiredCompanyDataCheck);
                        } else {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: result.status,
                                    message: result.message,
                                    variant: 'success'
                                })
                            );
                        }
                    } else {
                        if(result.returnData) {
                            let errorData = result.returnData;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: errorData.message,
                                    variant: 'error'
                                })
                            );
                        } else if(result.message) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'ERROR',
                                    message: result.message,
                                    variant: 'error'
                                })
                            );
                        } else {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'ERROR',
                                    message: 'Something went wrong and. Please contact your System Administrator.',
                                    variant: 'error'
                                })
                            );
                        }
                    }
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'ERROR',
                            message: 'Something went wrong and. Please contact your System Administrator.',
                            variant: 'error'
                        })
                    );
                }
            })
            .catch(error => {
                this.loading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
                console.debug('error', error);
            });
        }
    }

    handleUpdateCompanyData() {
        this.loading = true;

        if(!this.accountNotLinked) {
            newCompanyCreditReport({
                connectId : this.connectId,
                accountId : this.accountId
            })
            .then(result => {
                this.loading = false;
                if(result) {
                    if(result.status) {
                        if(result.returnData) {
                            this.companyData = result.returnData;
                            // Display fresh data in the form
                            refreshApex(this.wiredAccount);
                            refreshApex(this.wiredCompanyDataCheck);
                        } else {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: result.status,
                                    message: result.message,
                                    variant: 'success'
                                })
                            );
                        }
                    } else {
                        if(result.returnData) {
                            let errorData = result.returnData;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: errorData.message,
                                    variant: 'error'
                                })
                            );
                        } else if(result.message) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'ERROR',
                                    message: result.message,
                                    variant: 'error'
                                })
                            );
                        } else {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'ERROR',
                                    message: 'Something went wrong and. Please contact your System Administrator.',
                                    variant: 'error'
                                })
                            );
                        }
                    }
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'ERROR',
                            message: 'Something went wrong and. Please contact your System Administrator.',
                            variant: 'error'
                        })
                    );
                }
            })
            .catch(error => {
                this.loading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
                console.debug('error', error);
            });
        }
    }

    handleInitiateConflictCheck(event) {
        this.showConflictCheckResults = true;
        this.template.querySelector("c-conflict-check").initiateConflictCheck();
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'link':
                this.linkAccountWithConnectId(row);
                break;
            case 'show_details':
                this.showRowDetails(row);
                break;
            default:
        }
    }

    linkAccountWithConnectId(data) {
        // Show spinner
        this.loading = true;

        // Create the recordInput object
        const fields = {};
        fields[ACCOUNT_ID.fieldApiName] = this.accountId;
        fields[ACCOUNT_CONNECT_ID.fieldApiName] = data.id;
        const recordInput = { fields };

        if(data.id && this.accountId) {
            // Update Account.Connect_Id__c field on the related Account record
            updateRecord(recordInput)
            .then(() => {
                // Set result message
                let message = data.name ? 'Account successfully linked with ' + data.name : 'Account successfully linked';

                // Display result message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: message,
                        variant: 'success'
                    })
                );

                // Reset search data to hide the result table
                this.companySearchData = [];

                // Reset the page number to start from the beginning on new search
                this.page = 0;

                // Hide spinner
                this.loading = false;

                // Display fresh data in the form
                return refreshApex(this.wiredAccount);
            })
            .catch(error => {
                // Hide spinner
                this.loading = false;

                // Display result message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        }
    }

    showRowDetails(row) {
        this.companyDetails = JSON.stringify(row, null, 2);
        this.showCompanyDetails = true;
    }
    handleCloseCompanyDetails() {
        this.showCompanyDetails = false;
        this.companyDetails = '';
    }

    handleGetMoreRecords(event) {
        this.page = event.target.value;
        this.handleNewCompanySearch(event);
    }

    handleShowCompanySearchParamForm(event) {
        this.resetSearchParams();
        this.companySearchParamForm = true;
    }

    handleHideCompanySearchParamForm(event) {
        this.companySearchParamForm = false;
    }

    handleShowCompanyUpdateWithReasonForm(event) {
        this.companyUpdateWithReasonForm = true;
    }

    handleHideCompanyUpdateWithReasonForm(event) {
        this.creditsafeCreditReportReasonValue = '';
        this.companyUpdateWithReasonForm = false;
    }

    resetSearchParams() {
        //this.creditsafeCompanySearchCountry = null;
        this.companySearchData = [];
        this.companyData = [];
        this.creditsafeCompanySearchName = '';
        this.creditsafeCompanySearchPostalCode = '';
        this.creditsafeCompanyRegistrationNumber = '';
        this.total = 0;
        this.page = 1;
        this.pageSize = 0;
        this.totalPages = 0;
    }

    checkIfGermanConnectId(connectId) {
        let patt = new RegExp(/^(DE-)/gi);
        return patt.test(connectId);
    }
}