/**
 * @description       :
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 03-03-2021
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   08-02-2021   Bluewave | Tomasz Piechota   Initial Version
**/
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import riskAssessmentStyle from '@salesforce/resourceUrl/RiskAssessmentStyle';
import getRiskAssessmentFormConfig from '@salesforce/apex/RiskAssessmentFormController.getRiskAssessmentFormConfig';
import getFormConfig from '@salesforce/apex/RiskAssessmentFormController.getFormConfig';
import saveRiskAssessmentProgress from '@salesforce/apex/RiskAssessmentFormController.saveRiskAssessmentProgress';

export default class RaForm extends NavigationMixin(LightningElement) {

    @api debugMode = false;
    @api recordId; //sObjectId
    @api action;
    @api initData;
    @api ra;
    @api raId;

    // Default values
    type = 'path';
    variant = 'base';
    hasError = false;
    allDone = false;
    showLabel = true;
    activeStep = 1;
    divWapperClass = 'progress-indicator-wrapper';
    isSaving = false;

//????????????????????
    counerpartiesExist = false;
    isUpdateReload = false;


    @track data = [];
    @track steps = [];
    @track questions = [];
    @track wiredFormConfig;
    @track parsedInitData = {};

    connectedCallback() {
        Promise.all([
            loadStyle(this, riskAssessmentStyle)
        ])
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Something went wrong and custom CSS copuldn\'t be loaded.',
                    variant: 'error'
                })
            );
            console.debug('error', error);
        });

        this.parsedInitData = JSON.parse(this.initData);

        console.log(typeof this.initData)
        console.log(this.initData)
        console.log(this.action);
    }

    @wire(getFormConfig, { initData: '$initData', action: '$action' }) formConfig({error, data}) {
        this.wiredFormConfig = {error, data};
        //console.log(JSON.stringify(data, null, 2));

        if (data) {
            //console.log(JSON.stringify(data, null, 2));
            this.data = data;
            this.steps = data.steps;
            console.log('getRiskAssessmentFormConfig');
            console.log(data.questions);
            if(this.currentStepLabel) {
                this.questions = this.currentQuestionSet;
            }
            console.log('this.currentStepLabel: ' + this.currentStepLabel);
            this.dispatchEvent(
                new CustomEvent('setcurrentsteplabel', {
                    detail: this.currentStepLabel
                })
            );
        } else if (error) {
            console.log(JSON.stringify(error, null, 2));
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'ERROR',
                    message: 'Couldn\'t load progress indicator configuration.',
                    variant: 'error'
                })
            );
        }
    }

    setParam(event) {
        //console.log('Master got the setParam event ' + event.detail)
        //console.log(this[event.detail.label])
        if(event.detail.label && event.detail.value) {
            //console.log(event.detail.name + '|' + event.detail.value)
            this[event.detail.label] = event.detail.value;
        }
    }

    handlePrevious() {
        this.template.querySelector('c-ra-progress-indicator').previousHandler();
        if(this.activeStep > 1) {
            this.handleActivateStep({target: {value: this.activeStep - 1}});
            this.questions = this.currentQuestionSet;
        }
    }

    handleNext() {
        this.template.querySelector('c-ra-progress-indicator').nextHandler();
        if(this.activeStep <= this.steps.length) {
            this.handleSaveProgress();
            this.handleActivateStep({target: {value: this.activeStep + 1}});
            this.questions = this.currentQuestionSet;
        }
    }

    handleActivateStep(event) {
        this.activeStep = (event.target.value != '' && event.target.value != null && typeof event.target.value != 'undefined') ? event.target.value : this.activeStep;
    }

    handleSaveProgress() {
        //parsedInitDfata.raInProgress
        console.log(this.parsedInitData);
        var _this = this;
        if(this.parsedInitData.raInProgress) {
            this.isSaving = true;
            //delay in case updating JSON structure takes time
            setTimeout(function() {
                _this.saveProgress(_this.parsedInitData);
            }, 500);
        }
    }

    saveProgress(parsedInitData) {
        saveRiskAssessmentProgress({
            recordId: parsedInitData.raInProgress,
            riskAssessment: JSON.stringify(this.data)
        })
        .then(result => {
            if(result) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Progress successfully saved.',
                        variant: 'success'
                    })
                );
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: result,
                        variant: 'error'
                    })
                );
            }
            this.isSaving = false;
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                })
            );
            this.isSaving = false;
            console.debug('error', error);
        });
    }

    handleFieldUpdate(event) {
        console.log('GOT AN UPDATE')
        let answerPackage = event.detail;
        let dataCopy = JSON.parse(JSON.stringify(this.data));
        console.log(JSON.stringify(answerPackage, null, 2));

        console.log(this.getObjects(dataCopy, 'id', answerPackage.id));
        this.updateObjects(dataCopy, 'id', answerPackage.id, answerPackage);
        console.log('NEW JSON');
        console.log(dataCopy);
        this.isUpdateReload = true;
        this.data = dataCopy;
        let _this = this;
        setTimeout(function() { _this.isUpdateReload = false; }, 500);

        /*  */
    }

    handleSubmit(event) {
        console.log('SUBMIT')
        let _this = this;
        this.handleSaveProgress();
        setTimeout(function() {
            _this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: _this.parsedInitData.raInProgress,
                    objectApiName: 'Risk_Assessment__c',
                    actionName: 'view'
                }
            });
        }, 500);

        /*  */
    }

    navigateToRecordPage() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: parsedInitData.raInProgress,
                objectApiName: 'Risk_Assessment__c',
                actionName: 'view'
            }
        }).then(url => { window.open(url) });
    }


    /*** JSON util ***/
    //return an array of objects according to key, value, or key and value matching
    getObjects(obj, key, val) {
        var objects = [];
        for (var i in obj) {
            if (!obj.hasOwnProperty(i)) continue;
            if (typeof obj[i] == 'object' || Array.isArray(obj[key])) {
                objects = objects.concat(this.getObjects(obj[i], key, val));
            } else
            //if key matches and value matches or if key matches and value is not passed (eliminating the case where key matches but passed value does not)
            if (i == key && obj[i] == val || i == key && val == '') { //
                objects.push(obj);
            } else if (obj[i] == val && key == ''){
                //only add if the object is not already in the array
                if (objects.lastIndexOf(obj) == -1){
                    objects.push(obj);
                }
            }
        }

        return objects;
    }

    findNested(obj, key, value, data) {
        if (obj[key] === value) {
            console.log(obj[key]);
            console.log(obj);
            console.log(data);
        }

        const objKeys = Object.keys(obj);

        objKeys.forEach(objKey => {
            let found;
            if (typeof obj[objKey] === 'object' || Array.isArray(obj[objKey])) {
                found = this.findNested(obj[objKey], key, value, data);
            }
            return found;
        });

        return null;
    }

    //update an array of objects according to key, value, or key and value matching
    updateObjects(obj, key, val, data) {
        console.log('UPDATE JSON('+key+ ','+val+')');
        var objects = [];
        for (var i in obj) {
            if (!obj.hasOwnProperty(i)) continue;
            if (typeof obj[i] == 'object' || Array.isArray(obj[key])) {
                objects = objects.concat(this.getObjects(obj[i], key, val));
            } else
            //if key matches and value matches or if key matches and value is not passed (eliminating the case where key matches but passed value does not)
            if (i == key && obj[i] == val) { //
                objects.push(obj);
            }
        }
        objects.forEach(o => {
            if(data.isDetail) {
                o.answerDetailsString = data.answerDetailsString;
                o.answerDetailsValue = data.answerDetailsValue;
            } else {
                o.answerString = data.answerString;
                o.answerValue = data.answerValue;
            }
        });

        return obj;
    }

    //return an array of values that match on a certain key
    getValues(obj, key) {
        var objects = [];
        for (var i in obj) {
            if (!obj.hasOwnProperty(i)) continue;
            if (typeof obj[i] == 'object') {
                objects = objects.concat(getValues(obj[i], key));
            } else if (i == key) {
                objects.push(obj[i]);
            }
        }
        return objects;
    }

    //return an array of keys that match on a certain value
    getKeys(obj, val) {
        var objects = [];
        for (var i in obj) {
            if (!obj.hasOwnProperty(i)) continue;
            if (typeof obj[i] == 'object') {
                objects = objects.concat(getKeys(obj[i], val));
            } else if (obj[i] == val) {
                objects.push(i);
            }
        }
        return objects;
    }

    // Getters
    get currentStep() {
        return this.activeStep.toString();
    }

    get questionlists() {
        return this.questions;
    }

    get ifCounterpartiesExist() {
        return this.counerpartiesExist;
    }

    get currentStepLabel() {
        if(this.steps.length > 0) {
            return this.steps[this.activeStep - 1].label;
        } else {
            return '';
        }
    }

    get isFirstStep() {
        return this.activeStep == 1;
    }

    get isLastStep() {
        return this.activeStep == this.steps.length;
    }

    get currentQuestionSet() {
        return this.data && this.data.questions ? this.data.questions[this.currentStepLabel] : this.questions;
    }
}