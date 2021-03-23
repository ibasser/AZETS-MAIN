/**
 * @description       :
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 11-02-2021
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   02-02-2021   Bluewave | Tomasz Piechota   Initial Version
**/
import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
//import OPP_ID_FIELD from '@salesforce/schema/Onboarding__c.Opportunity__r.Id';
import getProducts from '@salesforce/apex/OppProductsController.getRelatedProducts';

const COLUMNS = [
    { label: 'Product', fieldName: 'Url', type: 'url', typeAttributes: { label: { fieldName: 'ProductName' }, target: '_blank' }, initialWidth: 300, hideDefaultActions: true },
    { label: 'Assignment Type', fieldName: 'AssignmentType', hideDefaultActions: true },
    { label: 'Assignment Template', fieldName: 'AssignmentTemplate', hideDefaultActions: true },
    //{ label: 'Quantity', fieldName: 'Quantity', hideDefaultActions: true },
    //{ label: 'List Price', fieldName: 'ListPrice', type: 'currency', cellAttributes: { alignment: 'left' }, hideDefaultActions: true },
    //{ label: 'Sales Price', fieldName: 'UnitPrice', type: 'currency', cellAttributes: { alignment: 'left' }, hideDefaultActions: true },
    //{ label: 'Total Price', fieldName: 'TotalPrice', type: 'currency', cellAttributes: { alignment: 'left' }, hideDefaultActions: true },
    //{ label: 'Subtotal', fieldName: 'Subtotal', type: 'currency', hideDefaultActions: true },
    //{ label: 'Discount', fieldName: 'Discount', type: 'currency', cellAttributes: { alignment: 'left' }, hideDefaultActions: true },
    //{ label: 'Code', fieldName: 'ProductCode', hideDefaultActions: true },
    //{ label: 'Date', fieldName: 'ServiceDate', type: 'date', hideDefaultActions: true },
];

export default class OnboardingOppProducts extends NavigationMixin(LightningElement) {
    @api recordId;
    @track products = [];
    columns = COLUMNS;
    //opportunityId;

    /* @wire(getRecord, { recordId: '$recordId', fields: [OPP_ID_FIELD] }) wireOnboarding({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error getting opportunity Id',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.opportunityId = getFieldValue(data, OPP_ID_FIELD);
        }
    } */

    @wire(getProducts, { recordId: '$recordId' }) wireProducts({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error getting list of products',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.products = data;
        }
    }

    /* navigateToRelatedList(event) {
        // Stop the event's default behavior.
        // Stop the event from bubbling up in the DOM.
        event.preventDefault();
        event.stopPropagation();

        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.opportunityId,
                objectApiName: 'OpportunityLineItem',
                relationshipApiName: 'OpportunityLineItems',
                actionName: 'view'
            }
        }).then(url => { window.open(url) });
    } */

    // Getters & Setters
    get productsList() {
        return this.products;
    }

    get headerTitle() {
        return `Products (${this.products.length})`;
    }

    get productsExist() {
        return this.products.length > 0;
    }

    get pageHeaderClass() {
        return this.products.length > 0 ? 'slds-page-header slds-page-header_joined slds-page-header_bleed slds-shrink-none test-headerRegion slds-is-relative' : 'slds-page-header slds-page-header_joined slds-page-header_bleed slds-shrink-none test-headerRegion slds-is-relative slds-border-bottom_none';
    }
}