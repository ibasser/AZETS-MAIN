/**
 * @description       :
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 08-02-2021
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   08-02-2021   Bluewave | Tomasz Piechota   Initial Version
**/
import { LightningElement, api, track, wire } from 'lwc';
//import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import getRiskAssessmentFormConfig from '@salesforce/apex/RiskAssessmentFormController.getRiskAssessmentFormConfig';

export default class RaProgressIndicator extends LightningElement {
    // Default values
    type = 'path';
    variant = 'base';
    hasError = false;
    allDone = false;
    showLabel = false;
    activeStep = 1;
    divWapperClass = 'progress-indicator-wrapper';


    @api steps = [];
    @track wiredFormConfig;

    /* @wire(getRiskAssessmentFormConfig) formConfig({error, data}) {
        this.wiredFormConfig = data;

        if (data) {
            this.steps = data.steps;
            this.dispatchEvent(new CustomEvent('setcurrentsteplabel', {detail: this.currentStepLabel}));
        } else if (error) {
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR',
                    message: 'Couldn\'t load progress indicator configuration.',
                    variant: 'error'
                })
            );
        }
    } */

    handleActivateStep(event) {
        this.activeStep = (event.target.value != '' && event.target.value != null && typeof event.target.value != 'undefined') ? event.target.value : this.activeStep;
        //this.dispatchEvent(new CustomEvent('setcurrentsteplabel', {detail: this.currentStepLabel}));
    }

    @api
    previousHandler() {
        if(this.activeStep > 1) {
            this.handleActivateStep({target: {value: this.activeStep - 1}});
        }
        //this.activeStep = this.activeStep > 1 ? this.activeStep - 1 : this.activeStep;
    }

    @api
    nextHandler() {
        if(this.activeStep < this.steps.length) {
            this.handleActivateStep({target: {value: this.activeStep + 1}});
        }
        //this.activeStep = this.activeStep < this.steps.length ? this.activeStep + 1 : this.activeStep;
    }

    // Getters
    get currentStep() {
        return this.activeStep.toString();
    }

    get currentStepLabel() {
        if(this.steps.length > 0) {
            return this.steps[this.currentStep - 1].label;
        } else {
            return '';
        }
    }

    get wrapperClass() {
        return this.divWapperClass + '-' + this.type;
    }
}