/**
 * @description       :
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 25-02-2021
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   23-02-2021   Bluewave | Tomasz Piechota   Initial Version
**/
({
    navigatoToLwc : function(component, helper, action) {
        console.log('navigatoToLwc');
        console.log(component.get("v.initData"))
        var navService = component.find("navService");
        var compDefinition = {
            componentDef: "c:raForm",
            attributes: {
                recordId: component.get("v.sObjectId"),
                initData: JSON.stringify(component.get("v.initData")),
                action: action
            }
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));

        var pageReference = {
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        }

        navService.navigate(pageReference);
    },

    handleCreateNew: function(component, event, helper) {
        // createNew - discard existing and create new JSON
        let action = component.get("c.getFormConfigWithDML");

        action.setParams({
            recordId: component.get("v.sObjectId"),
            initData: JSON.stringify(component.get("v.initData")),
            action : 'createNew'
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                component.set("v.initData", result);
                console.log(result)
                // updateLoad - load existing new assessmentprogress JSON
                helper.navigatoToLwc(component, helper, 'updateLoad');
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