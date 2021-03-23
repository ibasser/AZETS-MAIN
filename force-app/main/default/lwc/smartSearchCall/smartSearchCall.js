import { LightningElement } from 'lwc';

export default class SmartSearchCall extends LightningElement {
    page = 1;
    waiting = true;
    dueDiligenceList=[];
    closeLabel='';
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
    get page5(){
        if (this.page == 5 ) {
            return true; }
        else {
            return false;}
    };
    

    constructor(){
        super();
        this.dueDiligenceList=[
            {DDID:1, name:'Martin Johnes'},
            {DDID:2, name:'Martina Jansen'},
            {DDID:3, name:'Juan Martinez'},
        ]
    }

    connectedCallback() {
        setTimeout(() => {this.waiting==false;},1500 );
    }

    nextPage(){
        this.page ++;
    }

    displayDDID(){
        alert('This would make a call to Smart Search ansd show the due diligence details.');
    }


}