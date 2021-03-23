/**
 * @description       : Object that ie: is sent back to Aura or LWC and contains
 * data (any obj type), status (true if success and false if error), and message if needed (ie: error message)
 * @author            : Bluewave | Tomasz Piechota
 * @last modified on  : 11-13-2020
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   11-13-2020   Bluewave | Tomasz Piechota   Initial Version
**/
public class ResponseData {
    @AuraEnabled public Boolean status;
    @AuraEnabled public String message;
    @AuraEnabled public Object returnData;

    public ResponseData(Boolean status) {
        this.status = status;
        this.message = null;
        this.returnData = null;
    }

    public ResponseData(Boolean status, String message) {
        this.status = status;
        this.message = message;
    }

    public ResponseData(Boolean status, Object returnData) {
        this.status = status;
        this.returnData = returnData;
    }
}