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
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import INPUT_TEXT_TEMPLATE from './lightningInputText.html';
import INPUT_TEXTAREA_TEMPLATE from './lightningInputTextArea.html';
import INPUT_NUMBER_TEMPLATE from './lightningInputNumber.html';
import COMBOBOX_TEMPLATE from './lightningCombobox.html';
import RADIO_GROUP_TEMPLATE from './lightningRadioGroup.html';
import DEFAULT_TEMPLATE from './defaultTemplate.html';
import DUAL_LISTBOX_TEMPLATE from './lightningDualListbox.html';

export default class RaFormComponent extends LightningElement {
    @api debugMode = false;
    @api inputType;
    @api questionPackage;
    @api questionDefinition;

    // lightning field configs
    placeholder = '';
    fieldLevelHelp;
    type;
    name;
    label = '';
    value = '';
    formatter;
    step;
    checked;
    max;
    min;
    maxLength;
    minLength;
    readOnly;
    variant;
    required = false;
    disabled = false;
    dropdownAlignment;
    spinnerActive;
    setParam = '';
    options = [];


    detailFieldValue;
    fieldValue;
    dualListfieldValue = [];
    dualListDetailfieldValue = [];

    // field
    _selected = [];
    answer;
    childQuestionPackage;
    childQuestionPackages = [];
    showChildQuestionField = false;

    // dynamic variables
    counerpartiesExist = false;

    // Add details field params
    addDetailsFieldName = '';
    showAddDetailsField = false;
    _selectedDetail = [];

    //Child questions
    @api isUpdateReload = false;

    render() {
        try {
            let inputType = this.inputType.toLowerCase();
            console.log(inputType);
            switch(inputType) {
                case 'number':
                    this.fieldSetup(this.questionDefinition, false);
                    return INPUT_NUMBER_TEMPLATE;

                case 'text':
                    this.fieldSetup(this.questionDefinition, false);
                    return INPUT_TEXT_TEMPLATE;

                case 'textarea':
                    this.fieldSetup(this.questionDefinition, false);
                    return INPUT_TEXTAREA_TEMPLATE;

                case 'combobox':
                    this.fieldSetup(this.questionDefinition, true);
                    return COMBOBOX_TEMPLATE;

                case 'dual-listbox':
                    this.fieldSetup(this.questionDefinition, true);
                    return DUAL_LISTBOX_TEMPLATE;

                case 'radio-button':
                    this.type = 'button';
                    this.fieldSetup(this.questionDefinition, true);
                    return RADIO_GROUP_TEMPLATE;

                default:
                    return DEFAULT_TEMPLATE;
            }
        } catch (e) {
            console.error("An error occurred when rendering the Input field templates.");
            console.error('e.name => ' + e.name );
            console.error('e.message => ' + e.message );
            console.error('e.stack => ' + e.stack );
        }
    }

    fieldSetup(q, setOptions) {
        console.log('FIELD SETUP START: ' + q.Field_Question_No__c);
        JSON.stringify(JSON.stringify(q, null, 2));

        //this.placeholder;
        this.fieldLevelHelp = q.Field_Help_Text__c;
        this.name = q.Id;
        this.type = !this.type ? q.Field_Type__c : this.type;
        this.formatter = q.Field_Formatter__c;
        this.label = q.Field_Question__c;
        this.disabled = q.Field_Disabled__c;
        //this.setParam = q.Set_Param__c;

        if(q.Detail_Field_Active__c) {
            this.setupAddDetailsField(q);
        }

        if(setOptions) {
            this.options = this.setQuestionOptions(q.Field_Options__c);
        }

        this.fieldValueSetup(this.questionPackage, q.Field_Type__c);
    }

    fieldValueSetup(q, inputType) {
        console.log('FIELD VALUE SETUP: ' + q.answerString + ' | ' + q.answerValue + ' ' + (typeof q.answerString != 'undefined' && q.answerString != '' && q.answerString != null));

        if(typeof q.answerString != 'undefined' && q.answerString != '' && q.answerString != null) {
            switch(inputType) {
                case 'radio-button':
                    console.debug('setting up radio-button value');
                    if(!this.fieldValue) { this.fieldValue = q.answerString; }
                    if(!this._selected.length) { this._selected = q.answerString;}
                    this.showDetailField(JSON.parse(this._selected));
                    this.showHideChildQuestionField(JSON.parse(this._selected));
                    break;

                case 'dual-listbox':
                    console.log('setting up dual-listbox value');
                    if(q.answerString) {
                        /* let str1 = this.decodeBase64(q.answerString);
                        let str2 = this.dualListboxFieldValueHelper(str1); */
                        let str1 = this.decodeBase64(q.answerString);
                        let str2 = this.dualListboxFieldValueHelper(str1);
                        if(!this._selected.length) {
                            //this._selected = [];
                            //this._selected.push(...str2);
                            this.dualListfieldValue=[];
                            this.dualListfieldValue.push(...str2);

                        }
                        if(!this.dualListfieldValue.length) {
                        }
                        /*  else {
                            this.dualListfieldValue.push(...str2);

                        } */
                    }
                    this.showDualListboxDetailField(this.dualListfieldValue);
                    this.showHideDualListboxChildQuestionField(this.dualListfieldValue);
                    break;

                case 'combobox':
                    console.log('setting up combobox value');
                    if(q.answerString) {
                        if(!this.fieldValue) { this.fieldValue = q.answerString; }
                        if(!this._selected.length) { this._selected = q.answerString;}
                    }
                    this.showDetailField(JSON.parse(this._selected));
                    this.showHideChildQuestionField(JSON.parse(this._selected));
                    break;
                case 'textarea':
                    console.debug('setting up textarea value');
                    /* this.fieldValue = q.answerString;
                    this.showDetailField(q.answerString);
                    this.showHideChildQuestionField(q.answerString); */
                    if(q.answerString) {
                        if(!this.fieldValue) { this.fieldValue = q.answerString; }
                        if(!this._selected.length) { this._selected = q.answerString;}
                    }
                    this.showDetailField(this._selected);
                    this.showHideChildQuestionField(this._selected);
                    break;
                case 'text':
                    console.debug('setting up text value');
                    /* this.fieldValue = q.answerString;
                    this.showDetailField(q.answerString);
                    this.showHideChildQuestionField(q.answerString); */
                    if(q.answerString) {
                        if(!this.fieldValue) { this.fieldValue = q.answerString; }
                        if(!this._selected.length) { this._selected = q.answerString;}
                    }
                    this.showDetailField(this._selected);
                    this.showHideChildQuestionField(this._selected);
                    break;
                case 'number':
                    console.debug('setting up number value');
                    /* try {
                        this.fieldValue =  parseFloat(q.answerString);
                        this._selected =  parseFloat(q.answerString);
                    } catch(e) {
                        console.debug(e);
                    }
                    this.showDetailField(q.answerString);
                    this.showHideChildQuestionField(q.answerString); */
                    try {
                        if(!this.fieldValue) { this.fieldValue = parseFloat(q.answerString); }
                        if(!this._selected.length) { this._selected = parseFloat(q.answerString);}
                    } catch(e) {
                        console.debug(e);
                    }

                    this.showDetailField(this._selected);
                    this.showHideChildQuestionField(this._selected);
                    break;
            }
        }
    }

    detailFieldValueSetup(q, inputType) {
        console.log('DETAIL FIELD '+ inputType + ' VALUE SETUP: ' + q.answerDetailsString + ' | ' + q.answerDetailsValue + ' ' + (typeof q.answerDetailsString != 'undefined' && q.answerDetailsString != '' && q.answerDetailsString != null));

        if(typeof q.answerDetailsString != 'undefined' && q.answerDetailsString != '' && q.answerDetailsString != null) {
            switch(inputType) {
                case 'radio-button':
                    console.debug('setting up DETAIL radio-button value: ' + q.answerDetailsString + ' | ' + q.answerDetailsValue);
                    this.detailFieldValue = q.answerDetailsString;
                    this._selectedDetail = q.answerDetailsString;
                    break;
                case 'dual-listbox':
                    console.log('setting up dual-listbox detail value');
                    console.log(this._selectedDetail);
                    console.log(this.dualListDetailfieldValue);
                    if(q.answerDetailsString) {
                        let str1 = this.decodeBase64(q.answerDetailsString);
                        let str2 = this.dualListboxFieldValueHelper(str1);
                        if(!this._selectedDetail.length) {
                            //this._selectedDetail = [];
                            //this._selected.push(...str2);
                            this.dualListDetailfieldValue=[];
                            this.dualListDetailfieldValue.push(...str2);

                        }
                        /* if(this.dualListDetailfieldValue.length) {
                        } else {
                            this.dualListDetailfieldValue.push(...str2);

                        } */
                    }
                    break;
                case 'combobox':
                    console.log('setting up DETAIL combobox value: ' + q.answerDetailsString + ' | ' + q.answerDetailsValue);
                    this.detailFieldValue = q.answerDetailsString;
                    this._selectedDetail = q.answerDetailsString;
                    break;
                case 'textarea':
                    console.debug('setting up DETAIL textarea value: ' + q.answerDetailsString + ' | ' + q.answerDetailsValue);
                    this.detailFieldValue = q.answerDetailsString;
                    break;
                case 'text':
                    console.debug('setting up DETAIL text value: ' + q.answerDetailsString + ' | ' + q.answerDetailsValue);
                    this.detailFieldValue = q.answerDetailsString;
                    break;
                case 'number':
                    console.debug('setting up DETAIL number value: ' + q.answerDetailsString + ' | ' + q.answerDetailsValue);
                    this.detailFieldValue = q.answerDetailsString;
                    break;
            }
        }
    }

    setQuestionOptions(jsonStr) {
        console.log('<<< SET QUESTION OPTIONS >>>')
        let options = [];
        let jsonObj = jsonStr && typeof jsonStr == 'string' ? JSON.parse(jsonStr) : jsonStr;
        let isArray = Array.isArray(jsonObj);
        let inputType = this.inputType.toLowerCase();

        switch(inputType) {
            case 'radio-button':
                if(isArray) {
                    if(jsonObj.length > 0) {
                        jsonObj.forEach(e => {
                            options.push({ label: e.label, value: JSON.stringify(e) });
                        });
                    }
                }
                break;
            case 'combobox':
                if(isArray) {
                    if(jsonObj.length > 0) {
                        jsonObj.forEach(e => {
                            options.push({ label: e.label, value: JSON.stringify(e) });
                        });
                    }
                }
                break;
            case 'dual-listbox':
                console.log(jsonObj);
                console.log(jsonObj[0]);
                console.log(JSON.stringify(jsonObj[0]));
                if(isArray) {
                    let tempOptions = []
                    if(jsonObj.length > 0) {
                        jsonObj.forEach(e => {
                            tempOptions.push({ label: e.label, value: JSON.stringify(e) });
                        });
                    }
                    options.push(...tempOptions);
                }
                break;
        }

        return options;
    }

    setDetailQuestionOptions(jsonStr) {
        console.log('<<< SET DETAIL QUESTION OPTIONS >>>')
        let detailOptions = [];
        let jsonObj = jsonStr && typeof jsonStr == 'string' ? JSON.parse(jsonStr) : jsonStr;
        let isArray = Array.isArray(jsonObj);
        let inputType = this.questionDefinition.Detail_Field_Type__c ? this.questionDefinition.Detail_Field_Type__c.toLowerCase() : null;

        switch(inputType) {
            case 'radio-button':
                if(isArray) {
                    if(jsonObj.length > 0) {
                        jsonObj.forEach(e => {
                            detailOptions.push({ label: e.label, value: JSON.stringify(e) });
                        });
                    }
                }
                break;
            case 'combobox':
                if(isArray) {
                    if(jsonObj.length > 0) {
                        jsonObj.forEach(e => {
                            detailOptions.push({ label: e.label, value: JSON.stringify(e) });
                        });
                    }
                }
                break;
            case 'dual-listbox':
                if(isArray) {
                    let tempOptions = []
                    if(jsonObj.length > 0) {
                        jsonObj.forEach(e => {
                            tempOptions.push({ label: e.label, value: JSON.stringify(e) });
                        });
                    }
                    detailOptions.push(...tempOptions);
                }
                break;
        }

        return detailOptions;
    }

    handleInputRadioGroupChange(event) {
        console.log('CHANGE - RADIO-GROUP');
        let answer = event.detail.value;
        let isDetailField =  event.target.dataset.isDetailField;
        let answerObj = [];
        let answerPackage = [];

        try {
            answerObj = JSON.parse(answer);
        } catch(e) {
            console.log(e); // error in the above string (in this case, yes)!
        }

        // Set the selected value
        if(isDetailField) {
            this._selectedDetail = answer;
        } else {
            this._selected = answer;
            // Show/Hide detail field
            this.showDetailField(answerObj);
            // Show/Hide child field
            this.showHideChildQuestionField(answerObj);
        }

        answerPackage = this.prepareFieldChangeData(isDetailField);
        this.dispatchEvent(new CustomEvent('fieldupdate', {detail: answerPackage}));

        console.log('PACKAGE:')
        console.log(answerPackage)
        console.log('=======================================');
    }

    handleInputDualListChange(event) {
        console.log('DUAL-LISTBOX CHANGE');
        let isDetailField =  event.target.dataset.isDetailField;
        let answerPackage = [];
        let answerObject = event.detail.value;

        /* if(isDetailField) {
            this._selectedDetail = event.detail.value;
            this.dualListDetailfieldValue = event.detail.value;
        } else { */
            this._selected = answerObject;
            this.dualListfieldValue = answerObject;
            // Show/Hide detail field
            this.showDualListboxDetailField(answerObject);
            // Show/Hide child field
            this.showHideDualListboxChildQuestionField(answerObject);
        //}

        answerPackage = this.prepareFieldChangeData(isDetailField);
        console.log('PACKAGE:')
        console.log(JSON.stringify(answerPackage, null, 2))
        this.dispatchEvent(new CustomEvent('fieldupdate', {detail: answerPackage}));
    }

    handleInputDetailDualListChange(event) {
        console.log('DUAL-LISTBOX DETAIL CHANGE');
        let isDetailField =  event.target.dataset.isDetailField;
        let answerPackage = [];
        let answerObject = event.detail.value;

        this._selectedDetail = answerObject;
        this.dualListDetailfieldValue = answerObject;

        answerPackage = this.prepareFieldChangeData(isDetailField);
        console.log('PACKAGE:')
        console.log(JSON.stringify(answerPackage, null, 2))
        this.dispatchEvent(new CustomEvent('fieldupdate', {detail: answerPackage}));
    }

    handleInputComboboxChange(event) {
        console.log('COMBOBOX CHANGE');
        let isDetailField =  event.target.dataset.isDetailField;

        if(isDetailField) {
            this._selectedDetail = event.detail.value;
        } else {
            this._selected = event.detail.value;
            // Show/Hide detail field
            this.showDetailField(event.detail.value);
            // Show/Hide child field
            this.showHideChildQuestionField(event.detail.value);
        }

        let answerPackage = this.prepareFieldChangeData(isDetailField);

        console.log('PACKAGE:')
        console.log(JSON.stringify(answerPackage, null, 2))
        this.dispatchEvent(new CustomEvent('fieldupdate', {detail: answerPackage}));
    }

    handleTextFieldChange(event) {
        console.log('TEXT CHANGE');
        let isDetailField =  event.target.dataset.isDetailField;
        if(event.target.value) {
            if(isDetailField) {
                this._selectedDetail = event.target.value;
            } else {
                this._selected = event.target.value;
            }

            let answerPackage = this.prepareFieldChangeData(isDetailField);
            console.log('PACKAGE:')
            console.log(JSON.stringify(answerPackage, null, 2))
            this.dispatchEvent(new CustomEvent('fieldupdate', {detail: answerPackage}));
        }
    }

    handleNumberFieldChange(event) {
        console.log('TEXT CHANGE');
        let isDetailField =  event.target.dataset.isDetailField;
        if(event.target.value) {
            if(isDetailField) {
                this._selectedDetail = event.target.value;
            } else {
                this._selected = event.target.value;
            }

            let answerPackage = this.prepareFieldChangeData(isDetailField);
            console.log('PACKAGE:')
            console.log(JSON.stringify(answerPackage, null, 2))
            this.dispatchEvent(new CustomEvent('fieldupdate', {detail: answerPackage}));
        }
    }

    // Update feom child field
    handleFieldUpdate(event) {
        console.log('GOT AN UPDATE FROM CHILD: passing to raForm')
        let answerPackage = event.detail;
        this.dispatchEvent(new CustomEvent('fieldupdate', {detail: answerPackage}));
    }

    showDualListboxDetailField(data) {
        console.log('SHOW - DUAL-LISTBOX - DETAIL FIELD')
        try {
            if(Array.isArray(data) && data.length > 0) {
                let dlbData = JSON.parse(data[0]);
                // If it's an array then only check first value
                if(this.questionDefinition.Detail_Field_Active__c &&
                    this.questionDefinition.Detail_Field_Trigger_Answer__c &&
                    dlbData.value &&
                    this.questionDefinition.Detail_Field_Trigger_Answer__c.toString().toLowerCase() == dlbData.value.toString().toLowerCase()) {

                    // Show detail field
                    this.showAddDetailsField = true;
                } else {
                    // Hide detail field
                    this.showAddDetailsField = false;
                }
            }
            /*  else {
                let dlbData = JSON.parse(data);
                if(this.questionDefinition.Detail_Field_Active__c &&
                    this.questionDefinition.Detail_Field_Trigger_Answer__c &&
                    dlbData.value &&
                    this.questionDefinition.Detail_Field_Trigger_Answer__c.toString().toLowerCase() == dlbData.value.toString().toLowerCase()) {
                    // Show detail field
                    this.showAddDetailsField = true;
                } else {
                    // Hide detail field
                    this.showAddDetailsField = false;
                }
            } */

            if(this.showAddDetailsField) {
                this.detailFieldValueSetup(this.questionPackage, this.questionDefinition.Detail_Field_Type__c);
            }
        } catch (error) {
            console.debug(error);
        }
    }

    showHideDualListboxChildQuestionField(data) {
        console.log('showHideChildQuestionField');
        let items = this.hasChildQuestions ? this.questionPackage.items : [];
        try {
            if(Array.isArray(data) && data.length > 0) {
                let dlbData = JSON.parse(data[0]);
                if(dlbData.value) {
                    //this.childQuestionPackage = this.getFirstMatchingChildPackage(items, dlbData.value);
                    this.childQuestionPackages = this.getAllMatchingChildPackages(items, dlbData.value);
                    if(this.childQuestionPackages) {
                        // Show child question
                        this.showChildQuestionField = true;
                    } else {
                        // Hide child question
                        this.showChildQuestionField = false;
                    }
                } else {
                    // Hide child question
                    this.showChildQuestionField = false;
                }
            }
            /*  else {
                let dlbData = JSON.parse(data);
                if(this.questionDefinition.Detail_Field_Active__c &&
                    this.questionDefinition.Detail_Field_Trigger_Answer__c &&
                    dlbData.value &&
                    this.questionDefinition.Detail_Field_Trigger_Answer__c.toString().toLowerCase() == dlbData.value.toString().toLowerCase()) {
                    // Show detail field
                    this.showAddDetailsField = true;
                } else {
                    // Hide detail field
                    this.showAddDetailsField = false;
                }
            } */
        } catch (error) {
            console.debug(error);
        }
    }

    showDetailField(data) {
        console.log('SHOW DETAIL FIELD')
        if(Array.isArray(data) && data.length > 0) {
            console.log('A')
            // If it's an array then only check first value
            if(this.questionDefinition.Detail_Field_Active__c &&
                this.questionDefinition.Detail_Field_Trigger_Answer__c &&
                data[0].value &&
                this.questionDefinition.Detail_Field_Trigger_Answer__c.toString().toLowerCase() == data[0].value.toString().toLowerCase()) {

                // Show detail field
                this.showAddDetailsField = true;
                //this.detailFieldValueSetup(this.questionPackage, this.questionDefinition.Detail_Field_Type__c);
                console.log('SOWING DETAIL')
            } else {
                // Hide detail field
                this.showAddDetailsField = false;
                console.log('NOT SOWING DETAIL')
            }
        } else {
            console.log('B')
            if(this.questionDefinition.Field_Type__c == 'textarea' || this.questionDefinition.Field_Type__c == 'text' || this.questionDefinition.Field_Type__c == 'number') {
                if(this.questionDefinition.Detail_Field_Active__c &&
                    this.questionDefinition.Detail_Field_Trigger_Answer__c &&
                    data &&
                    this.questionDefinition.Detail_Field_Trigger_Answer__c.toString().toLowerCase() == data.toString().toLowerCase()) {
                    // Show detail field
                    this.showAddDetailsField = true;
                    //this.detailFieldValueSetup(this.questionPackage, this.questionDefinition.Detail_Field_Type__c);
                    console.log('SOWING DETAIL')
                } else {
                    // Hide detail field
                    this.showAddDetailsField = false;
                    console.log('NOT SOWING DETAIL')
                }
            } else{
                if(this.questionDefinition.Detail_Field_Active__c &&
                    this.questionDefinition.Detail_Field_Trigger_Answer__c &&
                    data.value &&
                    this.questionDefinition.Detail_Field_Trigger_Answer__c.toString().toLowerCase() == data.value.toString().toLowerCase()) {
                    // Show detail field
                    this.showAddDetailsField = true;
                    //this.detailFieldValueSetup(this.questionPackage, this.questionDefinition.Detail_Field_Type__c);
                    console.log('SOWING DETAIL')
                } else {
                    // Hide detail field
                    this.showAddDetailsField = false;
                    console.log('NOT SOWING DETAIL')
                }
            }
        }

        if(this.showAddDetailsField) {
            this.detailFieldValueSetup(this.questionPackage, this.questionDefinition.Detail_Field_Type__c);
        }
    }

    showHideChildQuestionField(data) {
        console.log('showHideChildQuestionField');
        let items = this.hasChildQuestions ? this.questionPackage.items : [];

        console.log(data)
        if(Array.isArray(data) && data.length > 0) {
            let dlbData = JSON.parse(data[0]);
            console.log(dlbData.value)
            if(dlbData.value) {
                //this.childQuestionPackage = this.getFirstMatchingChildPackage(items, data[0].value);
                this.childQuestionPackages = this.getAllMatchingChildPackages(items, dlbData.value);
                if(this.childQuestionPackages) {
                    // Show child question
                    this.showChildQuestionField = true;
                } else {
                    // Hide child questio
                    this.showChildQuestionField = false;
                }
            } else {
                // Hide child question
                this.showChildQuestionField = false;
            }
        } else {
            if(this.questionDefinition.Field_Type__c == 'textarea' || this.questionDefinition.Field_Type__c == 'text' || this.questionDefinition.Field_Type__c == 'number') {
                if(data) {
                    //this.childQuestionPackage = this.getFirstMatchingChildPackage(items, data);
                    this.childQuestionPackages = this.getAllMatchingChildPackages(items, data);
                    if(this.childQuestionPackages) {
                        // Show child question
                        this.showChildQuestionField = true;
                    } else {
                        // Hide child question
                        this.showChildQuestionField = false;
                    }
                } else {
                    // Hide child question
                    this.showChildQuestionField = false;
                }
            } else{
                let objData = JSON.parse(data);
            console.log(objData.value)
                if(objData.value) {
                    //this.childQuestionPackage = this.getFirstMatchingChildPackage(items, data.value);
                    this.childQuestionPackages = this.getAllMatchingChildPackages(items, objData.value);
                    if(this.childQuestionPackages) {
                        // Show child question
                        this.showChildQuestionField = true;
                    } else {
                        // Hide child question
                        this.showChildQuestionField = false;
                    }
                } else {
                    // Hide child question
                    this.showChildQuestionField = false;
                }
            }
        }
    }

    getFirstMatchingChildPackage(items, value) {
        if(items) {
            return items.find(q => q && q.definition && q.definition.Parent_Trigger_Answer__c && q.definition.Parent_Trigger_Answer__c.toString().toLowerCase() == value.toString().toLowerCase());
        } else {
            return null;
        }
    }

    getAllMatchingChildPackages(items, value) {
        console.log('getAllMatchingChildPackages');

        if(items) {
            let filteredItems = items.filter(q => q && q.definition && q.definition.Parent_Trigger_Answer__c && q.definition.Parent_Trigger_Answer__c.toString().toLowerCase() == value.toString().toLowerCase());
            return filteredItems;
        } else {
            return null;
        }
    }

    prepareFieldChangeData(isDetailField) {
        console.log('prepareFieldChangeData')
        let answer = {
            answerDetailsString: isDetailField ? this.prepareFieldChangeDataStringHelper(this.selectedDetail, this.questionDefinition.Detail_Field_Type__c) : this.questionPackage.answerDetailsString ? this.questionPackage.answerDetailsString : '',
            answerDetailsValue: isDetailField ? this.prepareFieldChangeDataValueHelper(this.selectedDetail, this.questionDefinition.Detail_Field_Type__c) : this.questionPackage.answerDetailsValue ? this.questionPackage.answerDetailsValue : '',
            answerString: !isDetailField ? this.prepareFieldChangeDataStringHelper(this.selected, this.questionDefinition.Field_Type__c) : this.questionPackage.answerString ? this.questionPackage.answerString : '',
            answerValue: !isDetailField ? this.prepareFieldChangeDataValueHelper(this.selected, this.questionDefinition.Field_Type__c) : this.questionPackage.answerValue ? this.questionPackage.answerValue : '',
            isDetail: isDetailField,
            id: this.questionPackage.id,
            questionNo: this.questionPackage.questionNo,
            riskArea: this.questionPackage.riskArea
        }

        return answer;
    }

    prepareFieldChangeDataStringHelper(data, fieldType) {
        console.log('prepareFieldChangeDataStringHelper: ' + fieldType);
        if(data) {
            if(fieldType && fieldType.toLowerCase() == 'dual-listbox') {
                return this.encodeBase64(data);
            } else {
                return data;
            }
        } else {
            return '';
        }
    }

    prepareFieldChangeDataValueHelper(data, fieldType) {
        console.log('prepareFieldChangeDataValueHelper: ' + fieldType);
        if(data) {
            if(fieldType && fieldType.toLowerCase() == 'dual-listbox') {
                if(Array.isArray(data)) {
                    return JSON.parse(data[0]).value;
                } else {
                    return JSON.parse(data).value;
                }
            }
            if(fieldType && fieldType.toLowerCase() == 'combobox') {
                if(Array.isArray(data)) {
                    return JSON.parse(data[0]).value;
                } else {
                    return JSON.parse(data).value;
                }
            }
            if(fieldType && fieldType.toLowerCase() == 'radio-button') {
                if(Array.isArray(data)) {
                    return JSON.parse(data[0]).value;
                } else {
                    return JSON.parse(data).value;
                }
            }
            if(fieldType && (fieldType.toLowerCase() == 'text' || fieldType.toLowerCase() == 'textarea')) {
                return data ? data : '';
            }

            if(fieldType && (fieldType.toLowerCase() == 'number')) {
                if(this.questionDefinition.Field_Fee_Value_Logic_Active__c && this.questionDefinition.Field_Fee_Value_Logic__c && this.questionDefinition.Field_Fee_Value_Threshold__c) {
                    return eval(data + this.questionDefinition.Field_Fee_Value_Logic__c + this.questionDefinition.Field_Fee_Value_Threshold__c) ? 'yes' : 'no';
                } else {
                    return data;

                }
            }
        } else {
            return '';
        }
    }

    encodeBase64(btoaValue) {
        return btoa(btoaValue);
    }

    decodeBase64(atobValue) {
        return atob(atobValue);
    }

    dualListboxFieldValueHelper(answerString) {
        let str1 = answerString.replace(/,(?=((?!\})*\{))/, '&|&');
        return str1.split('&|&');
    }

    setParamEventPayload(value, label) {
        return {
            value: value,
            label: label
        };
    }

    setupAddDetailsField(q) {
        this.addDetailsFieldName = [q.Id, q.Field_Question_No__c, 'detailfield'].join('-');
    }

    /*** Get question definition & question info ***/
    get q() { return this.questionDefinition; }
    // Get non-detail question selected value
    get selected() { return this._selected.length ? this._selected : JSON.stringify({"label":"None", "value":"no"}); }
    // Get detail question selected value
    get selectedDetail() { return this._selectedDetail.length ? this._selectedDetail : JSON.stringify({"label":"None", "value":"no"}); }
    // Check if a question has risk sub area defined
    get hasRiskSubArea() { return this.questionDefinition.Field_Risk_Sub_Area__c ? true : false; }
    // Get question risk sub area name
    get riskSubArea() { return this.questionDefinition.Field_Risk_Sub_Area__c; }
    // Check if a question has help text
    get hasFieldLevelHelp() { return this.fieldLevelHelp ? true : false; }
    // Get question class (depends on whether there is a help text and sub area defined)
    get raQuestionClass() { return this.fieldLevelHelp ? this.hasRiskSubArea ? 'ra-question has-badge_sub-area has-helptext' : 'ra-question has-helptext' : this.hasRiskSubArea ? 'ra-question has-badge_sub-area' : 'ra-question'; }
    // Check if question has child questions
    get hasChildQuestions() { return this.questionPackage.items ? this.questionPackage.items.length > 0 : false; }
    // Tell the DOM to hide or show child question
    get showChildQuestion() { return this.showChildQuestionField; }

    /*** Details field getter section ***/
    // Check whether to show detaild field or not
    get showAddDetails() { return this.showAddDetailsField; }
    // Check if detail field has help text defined
    get hasDetailFieldLevelHelp() { return this.questionDefinition.Detail_Field_Helptext__c ? true : false; }
    // Get detail field name set in setupAddDetailsField()
    get fieldPlaceholder() { return this.questionDefinition.Field_Placeholder__c; }
    get fieldStep() { return this.questionDefinition.Field_Formatter__c ? 0.01 : null; }
    get detailFieldName() { return this.addDetailsFieldName; }
    get detailFieldType() { return this.questionDefinition.Detail_Field_Type__c.toLowerCase(); }
    get detailFieldLabel() { return this.questionDefinition.Detail_Field_Label__c; }
    get detailQuestionClass() { return this.questionDefinition.Detail_Field_Helptext__c ? 'detail-question has-helptext' : 'detail-question'; }
    get detailFieldHelptext() { return this.questionDefinition.Detail_Field_Helptext__c; }
    get detailFieldPlaceholder() { return this.questionDefinition.Detail_Field_Placeholder__c; }
    get detailFieldFormatter() { return this.questionDefinition.Detail_Field_Formatter__c; }
    get detailFieldStep() { return this.questionDefinition.Detail_Field_Formatter__c ? 0.01 : null; }
    get detailFieldOptions() { return (this.questionDefinition && this.questionDefinition.Detail_Field_Options__c) ? this.setDetailQuestionOptions(this.questionDefinition.Detail_Field_Options__c) : []; }
    get isDetailFieldRequired() { return this.questionDefinition.Detail_Field_Required__c; }
    get isDetailFieldText() { return this.questionDefinition.Detail_Field_Type__c.toLowerCase() == 'text'; }
    get isDetailFieldFile() { return this.questionDefinition.Detail_Field_Type__c.toLowerCase() == 'file'; }
    get isDetailFieldNumber() { return this.questionDefinition.Detail_Field_Type__c.toLowerCase() == 'number'; }
    get isDetailFieldTextArea() { return this.questionDefinition.Detail_Field_Type__c.toLowerCase() == 'textarea'; }
    get isDetailFieldCheckbox() { return this.questionDefinition.Detail_Field_Type__c.toLowerCase() == 'checkbox'; }
    get isDetailFieldCombobox() { return this.questionDefinition.Detail_Field_Type__c.toLowerCase() == 'combobox'; }
    get isDetailFieldRadioButton() { return this.questionDefinition.Detail_Field_Type__c.toLowerCase() == 'radio-button'; }
    get isDetailFieldDualListbox() { return this.questionDefinition.Detail_Field_Type__c.toLowerCase() == 'dual-listbox'; }

}