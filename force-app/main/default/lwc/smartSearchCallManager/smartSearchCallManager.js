import { LightningElement, api,wire} from 'lwc';
import Utils from 'c/utils';
import getAccount from '@salesforce/apex/SmartSearchCallManagerController.getAccount';
import getCompanyData from '@salesforce/apex/SmartSearchCallManagerController.getCompanyData';
import runDjoApx from '@salesforce/apex/SmartSearchCallManagerController.runDjo';
import runAMLApx from '@salesforce/apex/SmartSearchCallManagerController.runAMLApx';
import retrieveDjoApx from '@salesforce/apex/SmartSearchCallManagerController.retrieveDjoApx';
import retrieveAMLApx from '@salesforce/apex/SmartSearchCallManagerController.retrieveAMLApx';
import listDueDiligenceApx from '@salesforce/apex/SmartSearchCallManagerController.listDueDiligence';
import updateDueDiligence from '@salesforce/apex/SmartSearchCallManagerController.updateDueDiligence';
import getDueDiligenceLink from '@salesforce/apex/SmartSearchCallManagerController.getDueDiligenceLink';
import saveAMLApx from '@salesforce/apex/SmartSearchCallManagerController.saveAMLApx';


export default class SmartSearchCallManager extends LightningElement {
    @api recordId;
    @api sObjectName;
    account;
    amlAttributes;
    amlDueDiligenceNull = true;
    cannotRunAML = true;
    country;
    personData;
    djoString;
    djo = [];
    dueDiligence ={};
    hasDueDiligence = true;
    dataIsReady;
    isPerson=false;
    isCompany=false;
    isAccount=false;
    ssid;
    ssidNull = true;
    ddid = [];
    dueDiligenceList = [];
    dueDiligenceHasRun=false;
    highRiskAllowed=false;
    riskLevel='normal';
    yourClientOptions =[];
    yourClientSelected = false;
    spinnerOn = false;
    spinnerText = 'Waiting for response from SmartSearch';
    isUkCitizen = false;
    sanctionListPotentialMatch = 'Pass';

    dataAvailable;
    
    page = 1;
    numPages=4;

    waiting = true;
    closeLabel='';

    constructor(){
        super();
        this.yourClientOptions.push({value: 'yes',label: 'yes'});
        this.yourClientOptions.push({value: 'no',label: 'no'});
        this.yourClientOptions.push({value: 'unworked',label: '?'});
    }

    @wire(getAccount, {id: '$recordId'}) wiredAccount({ error, data }){
        if ( this.sObjectName == 'Account'){
            if (data){
                console.log(data);
                this.account=data;
                this.dataAvailable=true;
                this.isAccount=true;
                this.isCompany=true;

                this.ssid=data.SSID__c;
                if (data.SSID__c == null) {
                    this.ssidNull=true;
                } else {
                    this.ssidNull = false;
                }

            }  else if (error){
                console.log(error);
            }
        }

    };

    @wire(getCompanyData, {id: '$recordId'}) wiredCompanyData({ error, data}){
        if (this.sObjectName == 'Company_Data__c'){
            if (data){
                this.ssid=data.SSID__c;
                if (data.SSID__c == null) {
                    this.ssidNull=true;
                } else {
                    this.ssidNull = false;
                }

                if (data.Entity_Type__c == 'Person'){
                    this.isPerson=true;
                    this.personData=data;
                    if (data.Country__c == 'GBR') {
                        this.highRiskAllowed = true;
                        this.cannotRunAML = false;
                        this.isUkCitizen = true;
                    } else {
                        let variant = 'info'
                        if (this.ssidNull) {variant = 'error';}
                        Utils.showToast(this,'Unable to run  international checks','Please perform check on the Smart Search site and manually update the SSID on this record.' , variant);
                        if (this.ssidNull) {
                            this.handleClose();
                            return;
                        }
                    }
                } else if (data.Entity_Type__c == 'Company'){
                    this.isCompany=true;
                    this.companyData = data;
                } else {
                    Utils.showToast(this,'Unable to run check','Please select the correct Entity Type and corresponding Record Type' , 'pester');
                    this.handleClose();
                }
                this.country=data.Country__c;

                if (!this.cannotRunAML) {
                    if (!this.checkRequiredFields(data)){
                        this.handleClose();
                        return;
                    }
                }
                this.dataAvailable=true;

    
            }  else if (error){
                console.log(error);
            }
        }

    }

    get canNotSaveAML(){

        if ( this.dueDiligenceHasRun == true) {
            let noUnworkedCLient = false;
            for (let i=0; i < this.dueDiligenceList.length; i++){
                console.log('Due diligence: ' + JSON.stringify(this.dueDiligenceList[i]));
                console.log('Your client = ' + this.dueDiligenceList[i].your_client);
                if (this.dueDiligenceList[i].your_client == 'unworked' ){
                    noUnworkedCLient = true;
                }
                return noUnworkedCLient;
            }
        } else {
            return true;
        }
    }

    get sanctionListPotentialMatch(){
        return this.sanctionListPotentialMatch;
    }; 


    get checkType(){
        if (this.isCompany){
            return 'Dow Jones';
        } else if (this.isPerson) {
            return 'AML';
        }
    }

    get dueDiligenceCheck(){
        return this.hasDueDiligence;
    }; 

    get page1(){
        if (this.page ==1 ) {
            return true; }
        else {
            return false;}
    };
    get page2(){
        if (this.page == 2 ) {
            return true; }
        else {
            return false;}
    };
    get page3(){
        if (this.page == 3 ) {
            return true; }
        else {
            return false;}
    };
    get page4(){
        if (this.page == 4 ) {
            return true; }
        else {
            return false;}
    };   


    runDJO(){
        this.spinnerOn = true;
        this.nextPage();
        runDjoApx({account: this.account, companyData:this.companyData, isAccount:this.isAccount})
        .then(result => {this.updateDjo(result);
            this.spinnerOn = false;
        })
        .catch(error => {
            // console.log('Error ' + JSON.stringify(error));
            // console.log('Error ' + error.body.message);
            Utils.showToast(this,'Error creating record', error.body.message, 'pester');
            this.handleClose();
        });        
        //.then( ()=> {})
    }

    updateDjo(result){
        try {
            if (result){
                console.log('Result returned from djo' + result );
                this.djoString=result;
                this.djo = JSON.parse(this.djoString);
                if (this.djo.data.attributes){
                    this.dueDiligence = this.djo.data.attributes.due_diligence;
                    this.ssid = this.djo.data.attributes.ssid;
                    if (this.dueDiligence != null){
                        this.amlDueDiligenceNull = false;

                        let worldwideSanction = this.dueDiligence.worldwide_sanctions;
                        let hmtOfacs = this.dueDiligence.hmt_ofacs;
                        let hmtTreasury = this.dueDiligence.hm_treasury;
                        let ofacsSanctions = this.dueDiligence.ofacs_sanctions;
                        if((worldwideSanction != null && worldwideSanction != '' && worldwideSanction != 'undefined' && worldwideSanction == 'fail') || 
                        (hmtOfacs != null && hmtOfacs != '' && hmtOfacs != 'undefined' && hmtOfacs == 'fail') || 
                        (hmtTreasury != null && hmtTreasury != '' && hmtTreasury != 'undefined' && hmtTreasury == 'fail') || 
                        (ofacsSanctions != null && ofacsSanctions != '' && ofacsSanctions != 'undefined' && ofacsSanctions == 'fail'))
                        {
                            this.sanctionListPotentialMatch = 'Refer';
                        }
                        this.translateDueDiligence();

                    } else {
                        Utils.showToast(this, 'Not Due diligenge found' ,'SmartSearch dd not return a due diligence' , 'info');
                    }
                }

                this.dataIsReady = true;
            } else {
                console.log('No result returned from runDJO');
            }
        } catch (error) {
            console.error(error);
            Utils.showToast(this, 'Error dunning Dow Jones' ,error , 'error');
        }
    }

    runAML(){
        this.nextPage();
        runAMLApx({companyData: this.personData, country:this.country, riskLevel: this.riskLevel})
        .then(result => {this.updateAML(result);
            
        })
    }

    updateAML(result){
        try {
            if (result){
                console.log('Result returned from djo' +  result);
                this.amlString=result;
                this.aml = JSON.parse(this.amlString);
                if (this.aml.errors) {
                    console.log('Error');
                } else {
                    if (this.aml.data.attributes){
                        this.dueDiligence = this.aml.data.attributes.due_diligence;
                        if (this.dueDiligence != null) {
                            this.amlDueDiligenceNull = false;

                        let worldwideSanction = this.dueDiligence.worldwide_sanctions;
                        let hmtOfacs = this.dueDiligence.hmt_ofacs;
                        let hmtTreasury = this.dueDiligence.hm_treasury;
                        let ofacsSanctions = this.dueDiligence.ofacs_sanctions;
                        if(worldwideSanction == 'fail' || hmtOfacs == 'fail' || hmtTreasury == 'fail' || ofacsSanctions == 'fail')
                        {
                            this.sanctionListPotentialMatch = 'Refer';
                        }

                        }
                        console.log('amlDueDiligenceNull '+this.amlDueDiligenceNull);
                        this.ssid = this.aml.data.attributes.ssid;
                        this.amlAttributes = this.aml.data.attributes;
                        this.translateAMLAttributes();
                        this.translateDueDiligence();
                    }

                    this.dataIsReady = true;
                }
            } else {
                    console.log('No result returned from runAML');
            }
        } catch (error) {
            console.error(error);
        }
    }

    listDueDiligence(){
        this.nextPage();
        listDueDiligenceApx({ssid : this.ssid})
        .then(result => {
            if (result){
                var JSONresult = JSON.parse(result);
                if (JSONresult.data){
                    this.dueDiligenceList = [];
                    for (let i = 0; i<JSONresult.data.length; i++){
                        this.dueDiligenceList.push(JSONresult.data[i].attributes);
                    } 
                }
            } else {
                console.log('no result returned from list due diligence');
            }
            this.dueDiligenceHasRun = true;
            
            if(this.dueDiligenceList.length == 0)
            {
                this.hasDueDiligence = false;
            } else {
                this.hasDueDiligence = true;
            }
        })
    }
    /**
     * 
     * @param {yourClient, index} event 
     * DESCRIPTION: This method triggers the call to Smart Search to update the due diligence your_client value
     *  If success it will update the value locally so result can be saved
     * 
     * Author: PJ (Bluewave)
     * Created Date: Jan 2021
     */
    updateClient(event){
        let yourClient = event.target.value;
        let index = event.target.dataset.index;
        updateDueDiligence({ssid:this.ssid, ddid:event.target.dataset.ddid, yourClient:event.target.value})
        .then(result => { 
            var JSONresult = JSON.parse(result);
            if ((JSONresult.data.attributes.your_client) && (yourClient = JSONresult.data.attributes.your_client)){
                    this.dueDiligenceList[index].your_client=yourClient;                             
            } else {
                console.log('Unable to update client');
            }
        })
    }

    displayDDID(event){
        let checkType;
        if (this.isPerson) {
            checkType='aml';
        } else if (this.isCompany) {
            checkType = 'djo';
        }

        getDueDiligenceLink({ssid:this.ssid, ddid:event.target.dataset.ddid, checkType:checkType})
            .then(result => {
            var url = result;
            if(url != null && url != '' && url != 'undefined')
            {
                window.open(url, '_blank');
            }
            else
            {  
                Utils.showToast(this, 'Not Found!' ,'Smart search link for due diligence not set in custom setting!' , 'info');
            }
            })  
    }

    retrieveSearch(){
        if (this.isCompany) {
            this.retrieveDjo();
        } else if (this.isPerson) {
            this.retrieveAML();
        }
    }

    retrieveAML(){
        retrieveAMLApx({ssid : this.ssid, country:this.country})
        .then(result => {
            if(result=='Not Found')
            {
                console.log('Not Found');
                this.page = 2;
                Utils.showToast(this, 'Not Found!' ,'No results found for ssid: '+ this.ssid , 'info');
            }
            else{
                this.page = 2;
                this.updateAML(result)
            }
        })
    }

    retrieveDjo(){
        retrieveDjoApx({ssid : this.ssid})
        .then(result => {
            this.page = 2;
            this.updateDjo(result)
        })
    }

    handleClose(){
        const evt = new CustomEvent('closemodal');
        this.dispatchEvent(evt);    
    }
    
    nextPage(){
        this.page ++;
    }

    saveAML(){
        console.log('In save ' +this.sObjectName);
        let jsonString;
        if (this.isCompany){
            jsonString = this.djoString;
        } else if (this.isPerson){
            jsonString = this.amlString;
        }
         
        saveAMLApx({jsonString: jsonString, id:this.recordId, sObjectType:this.sObjectName, country:this.country})
        .then(result => {
            if(result){
                Utils.showToast(this,'Success', 'Succesfully created AML record', 'success');
            } else {
                Utils.showToast(this,'Unable to save AML record','' , 'pester');
            }
        })
        .then( () => {this.handleClose();})

    }

    setRiskLevel(event){
        if(event.target.checked){
            this.riskLevel = 'high';
        } else {
            this.riskLevel = 'normal';
        }
    }

    checkRequiredFields(companyData){

        let misssingFields=[];
        // Fields required for AML call
        if (this.isPerson) {
            if (companyData.Address_Building__c == null) {
                misssingFields.push('Building');
            } 

            if (companyData.Address_Street_1__c == null){
                misssingFields.push('Street 1');
                }
            if  (companyData.Address_Town__c == null) {
                misssingFields.push('Town');
            }        
            if  (companyData.Country__c == null) {
                misssingFields.push('Country');
            }
            if (this.country == 'USA' && companyData.NINO_SSN__c == null){
                misssingFields.push('Social Security Number');
            }
        }

        // Fields required for both AML and DJO
        if (companyData.Address_Postcode__c == null){
            misssingFields.push('Postcode');
        }

        if (misssingFields.length > 0 ) {
            Utils.showToast(this,'Missing fields', 'Please complete the following fields: ' + misssingFields.toString(), 'error');

            return false
        }

        return true;
    }

    translateDueDiligence(){
        this.dueDiligence.has_due_diligence = this.translateYesNo(this.dueDiligence.has_due_diligence);
        this.dueDiligence.has_outstanding_due_diligence = this.translateYesNo(this.dueDiligence.has_outstanding_due_diligence);
        this.dueDiligence.has_highrisk_due_diligence = this.translateYesNo(this.dueDiligence.has_highrisk_due_diligence);
        this.dueDiligence.politically_exposed_person = this.translateFailRefer(this.dueDiligence.politically_exposed_person);
        this.dueDiligence.special_interest_person = this.translateFailRefer(this.dueDiligence.special_interest_person);
        this.dueDiligence.relative_close_associate = this.translateFailRefer(this.dueDiligence.relative_close_associate);
        this.dueDiligence.special_interest_entity = this.translateFailRefer(this.dueDiligence.special_interest_entity);
    }

    translateAMLAttributes(){
        //UK Attributes
        this.amlAttributes.result = this.translateFailRefer(this.amlAttributes.result);
        this.amlAttributes.name_and_address_match = this.translateFailRefer(this.amlAttributes.name_and_address_match);
        this.amlAttributes.identity_confirmation_level = this.translateFailRefer(this.amlAttributes.identity_confirmation_level);
        this.amlAttributes.paf_confirmation = this.translateFailRefer(this.amlAttributes.paf_confirmation);
        this.amlAttributes.deceased_check = this.translateFailRefer(this.amlAttributes.deceased_check);
        this.amlAttributes.potential_fraud_alert = this.translateFailRefer(this.amlAttributes.potential_fraud_alert);

        //International Attributes
        this.amlAttributes.result = this.translateFailRefer(this.amlAttributes.result);

    }

    translateFailRefer(input){
        let returnValue = input;
        
        if (input == 'Pass' || input == 'pass'){
            returnValue = 'Pass';
        } else if (input == 'Fail' || input == 'fail' || input == 'refer') {
            returnValue = 'Refer';
        }

        return returnValue;
    }

    translateYesNo(input){
        let returnValue = input;

        if (input){
            returnValue = 'Yes';
        } else if (input == false) {
            returnValue =  'No';
        }
        return returnValue;
    }
    

}