/**
 * @description       : Independent component to create Conflict Checks and display results to the user
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 29-01-2021
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   14-01-2021   Bluewave | Tomasz Piechota   Initial Version
**/
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import customCssStyles from '@salesforce/resourceUrl/ConflictCheckStyle';
import checkIfCompanyDataExists from '@salesforce/apex/ConflictCheckController.checkIfCompanyDataExists';
import initiateConflictCheck from '@salesforce/apex/ConflictCheckController.initiateConflictCheck';

export default class ConflictCheck extends NavigationMixin(LightningElement) {
    @api recordId;      // Current context record Id
    @api sObjectName;   // Current context object API name, ie: Account, Onboarding__c
    @api objectApiName;
    @api manualRetrieve = false;
    @api showConflictCheck = false;
    @track wiredCompanyData;
    @track wiredConflictCheckData;
    @track conflictCheckData = [];
    companyDataRecordsExist = false;
    loadingCD = true;
    loadingCC = true;
    debugMode = false;

    connectedCallback() {
        Promise.all([
            loadStyle(this, customCssStyles)
        ])
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading 1',
                    message: 'Something went wrong and custom CSS copuldn\'t be loaded.',
                    variant: 'error'
                })
            );
            console.debug('error', error);
        });
    }

    @wire(checkIfCompanyDataExists, { recordId: '$recordId'}) wireCompanyDataCheck({ error, data }) {
        if (data) {
            if(data.status) {
                this.companyDataRecordsExist = data.returnData;
                if(!this.manualRetrieve) {
                    this.createConflictChecks(this.companyDataRecordsExist);
                }
            }
            this.loadingCD = false;
        } else if (error) {
            this.loadingCD = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error,
                    variant: 'error'
                })
            );
            console.debug('error', error);
        }
    }

    createConflictChecks(runConflictCheck) {
        if(runConflictCheck) {
            initiateConflictCheck({
                recordId: this.recordId
            })
            .then(result => {
                if(result.status) {
                    this.conflictCheckData = result.returnData;
                    this.loadingCC = false;
                } else {
                    this.loadingCC = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: result,
                            variant: 'error'
                        })
                    );
                }
            })
            .catch(error => {
                this.loadingCC = false;
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

    navigateToRelatedList(event) {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: event.target.dataset.id,
                objectApiName: 'Conflict_Check__c',
                relationshipApiName: 'Conflict_Checks__r',
                actionName: 'view'
            }
        }).then(url => { window.open(url) });
    }

    navigateToRecordPage(event) {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                objectApiName: 'Company_Data__c',
                actionName: 'view'
            }
        }).then(url => { window.open(url) });
    }

    // Close quick action modal. Dispatch event to Aura component and close quick action.
    handleCancel() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    @api
    initiateConflictCheck() {
        this.createConflictChecks(this.companyDataRecordsExist);
    }

    // Getters
    get conflictCheckRetrieved() { return this.conflictCheckData.length > 0; }
    get conflictCheckRecords() { return this.conflictCheckData; }
    get oName() { return this.objectApiName; }
    get isLoadingCD() { return this.loadingCD; }
    get isLoadingCC() { return this.loadingCC; }
    get companyDataExist() { return this.companyDataRecordsExist; }
    get isDebugMode() { return this.debugMode; }
    get accountId() { return this.recordId; }
}