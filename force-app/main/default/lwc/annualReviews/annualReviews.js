import { LightningElement, api,wire, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getScheduledReviews from '@salesforce/apex/AnnualReviewsController.getAnnualReviews';
import { refreshApex } from '@salesforce/apex';

export default class AnnualReviews extends NavigationMixin(LightningElement) {
    page = 1;
    editRecordId = null;
    totalReviews;
    buttonType;
    submitButtonDisabled = true;
    @track error;
    @track annualReviewsList = [];
    @track wiredResults = [];

    //method run on initialisation to get scheduled annual review records
    @wire(getScheduledReviews) wiredReviews(result) {
        this.wiredResults = result;
        if (result.data){
            this.annualReviewsList = result.data;
            this.totalReviews = this.annualReviewsList.length;
        } else if (result.error){
            this.error = result.error;
        }
    };

////////////////////////////////////////////////////////////////////////////////////////////////
    //attributes used in the HTML 
    get totalReviews(){
        return this.totalReviews; 
    };

    get submitDisabled(){
        return this.submitButtonDisabled; 
    };

    get page1(){
        if (this.page ==1 ) 
        {
            return true; 
        }
        else 
        {
            return false;
        }
    };
    get page2(){
        if (this.page == 2 ) 
        {
            return true; 
        }
        else {

            return false;
        }
    };

    get annualReviewRecordId(){
        return this.editRecordId; 
    };
////////////////////////////////////////////////////////////////////////////////////////////////

//navigates to the annual review record in a new tab on click of the 'Go To Record' button on page 1
    viewRecord(event){
    this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                actionName: 'view',
            },
        }).then(url => {
            window.open(url, '_blank');
        });
    };

    //navigates to the page 2 which is the edit form on click of the 'Review' button on page 1
    editDetails(event){
    console.log(event.target.dataset.id);
    this.editRecordId = event.target.dataset.id;
    this.page++;
    };

    // sets the variable 'buttonType' when the 'save' or 'complete' buttons are clicked on page 2
    // this variable is then used in the handle save operation
    setButtonType(event){
        console.log(event.target.dataset.id);
        this.buttonType = event.target.dataset.id;
    };

    // goes back to page 1 when the 'back' button is pressed on page 2.
    toPage1(event){
        this.page = 1;   
    };

    // sets the 'submitButtonDisabled' variable when the "No_changes_to_record__c" checkbox is toggled
    // OR when "Changes_to_record_and_checks_re_run__c" is toggled and whether all fields are populated
    // this enables/disables the 'complete review' button

    handleChange(event) {
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        let allPopulated = true;
        let noChangeCheckbox = false;
        let changeCheckbox = false;

        if (inputFields) {
            inputFields.forEach(field => {
                console.log('field: ' + JSON.stringify(field) + ' ' + JSON.stringify(field.Id) + ' name:  ' + JSON.stringify(field.name) + JSON.stringify(field.value));
                if(field.value === null || field.value === '')
                {
                    allPopulated = false;
                }

                if(field.name == 'question6' && field.value === true)
                {
                    noChangeCheckbox = true;
                }
                else if(field.name == 'question7' && field.value === true)
                {
                    changeCheckbox = true;
                }   
            });
        }
        
        //let checked = event.detail.checked;
        //console.log('checked: ' + checked);
        if(allPopulated && changeCheckbox)
        {
            this.submitButtonDisabled = false;
        }
        else if(noChangeCheckbox)
        {
            this.submitButtonDisabled = false;
        }
        else
        {
            this.submitButtonDisabled = true;
        }
        
    };

    // when the record edit form is initially loaded
    //sets the 'submitButtonDisabled' variable based on the value of "No_changes_to_record__c" field on the record 
    // this enables/disables the 'complete review' button
    handleLoad(event) {
        let record = event.detail.records;
        let inputFields = record[this.editRecordId].fields;

        if(inputFields.No_changes_to_record__c.value ||
            (inputFields.Changes_to_record_and_checks_re_run__c.value && inputFields.Is_this_still_an_active_client__c.value != null && inputFields.Contacted_Client_in_the_last_12_months__c.value != null
                && inputFields.Any_new_services_for__c.value != null && inputFields.Changes_in_AML_last_12_months__c.value != null && inputFields.Any_changes_to_client_due_diligence__c.value != null))
        {
            this.submitButtonDisabled = false;
        }
        else
        {
            this.submitButtonDisabled = true;
        } 
    };

    // override method for saving the record once edited
    // if all text fields are filled in and "Changes_to_record_and_checks_re_run__c" is checked
    // OR the 'complete review' button was clicked
    // then sets status to 'Reviewed' and updates the record
    // otherwise just updates the records leaving the status as 'Scheduled'
    handleSave(event){
        
        event.preventDefault();       // stop the form from submitting

        const fields = event.detail.fields;
        if(this.buttonType === 'complete')
        {
            console.log('reviewed!');
            fields.Status__c = 'Reviewed';
        }
        this.template.querySelector('lightning-record-edit-form').submit(fields); 
    };

    //resets the fields in the record edit form on page 2
    handleReset(event) {
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    };

    // on success of the annual review record being updated in SF:
    // 1 - a success toast is presented
    // 2 - the list of scheduled annual review records id refreshed 
    // 3 - navigate back to page 1
    handleSuccess(event){
        const evt = new ShowToastEvent({
            title: 'Success!',
            message: 'Annual Review Record Successfully Saved',
            variant: 'success'
        });
        this.dispatchEvent(evt);
        
        refreshApex(this.wiredResults);
        this.page = 1;
    };

    // Error handling. Display errors in a toast
    handleError(event)
    {
        const evt = new ShowToastEvent({
            title: 'Error!',
            message: JSON.stringify(event.error),
            variant: 'error'
        });
        this.dispatchEvent(evt);

    }

}