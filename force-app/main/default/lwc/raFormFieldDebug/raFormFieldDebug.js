/**
 * @description       :
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 18-02-2021
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   18-02-2021   Bluewave | Tomasz Piechota   Initial Version
**/
import { LightningElement, api } from 'lwc';

export default class RaFormFieldDebug extends LightningElement {
    @api selected;
    @api hasChildren;
    @api showChildField;
}