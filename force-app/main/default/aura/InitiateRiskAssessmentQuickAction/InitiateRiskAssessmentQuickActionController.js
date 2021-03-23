/**
 * @description       :
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 25-02-2021
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   22-02-2021   Bluewave | Tomasz Piechota   Initial Version
**/
({
    doInit : function(component, event, helper) {
        let action = component.get("c.initializeRiskAssessment");

        action.setParams({
            recordId : component.get('v.recordId')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                console.log('INIT:');
                console.log(JSON.stringify(result, null,  2));
                component.set("v.initData", result);
                component.set("v.sObjectId", result.sObjectId);
                component.set("v.sObjectType", result.sObjectType);
                component.set("v.raExist", !$A.util.isUndefinedOrNull(result.raExist) && result.raExist > 0);
                component.set("v.raInProgress", result.raInProgress);
                component.set("v.raInProgressExist", !$A.util.isUndefinedOrNull(result.raInProgress));
                component.set("v.raPendingApproval", result.raPendingApproval);
                component.set("v.raPendingApprovalExist", !$A.util.isUndefinedOrNull(result.raPendingApproval));

/*                 if(!$A.util.isUndefinedOrNull(result.raExist) && parseInt(result.raExist) == 0) {
                    // createNew - create new Risk_Assessment__c and create new JSON
                    helper.navigatoToLwc(component, helper, 'createNew');
                } */

                if($A.util.isUndefinedOrNull(result.raInProgress)) {
                    // createNew - create new Risk_Assessment__c and create new JSON
                    //helper.navigatoToLwc(component, 'createNew');
                    console.log('go to helper.handleCreateNew')
                    helper.handleCreateNew(component, event, helper);
                }
            }
            else if (state === "INCOMPLETE") {
                console.log("Unknown error");

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    handleLoad: function(component, event, helper) {
        // updateLoad - load existing assessmentprogress JSON
        console.log('handleLoad');

        let action = "updateLoad";
        helper.navigatoToLwc(component, helper, action);
    },

    handleNew: function(component, event, helper) {
        console.log('handleNew');
        // createNew - discard existing and create new JSON
        let action = component.get("c.getFormConfigWithDML");

        action.setParams({
            recordId: component.get("v.sObjectId"),
            initData: JSON.stringify(component.get("v.initData")),
            action : 'updateNew'
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                component.set("v.initData", result);
                //if($A.util.isUndefinedOrNull(result.raInProgress)) {
                    // updateLoad - load existing new assessmentprogress JSON
                    helper.navigatoToLwc(component, helper, 'updateLoad');
                //}
            }
            else if (state === "INCOMPLETE") {
                console.log("Unknown error");

            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    }
})