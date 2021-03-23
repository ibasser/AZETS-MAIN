/**
 * @description       :
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 14-01-2021
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   14-01-2021   Bluewave | Tomasz Piechota   Initial Version
**/
({
    closeMethodInAuraController : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})