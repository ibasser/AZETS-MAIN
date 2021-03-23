({

	doInit : function(component, event, helper) {

		var action = component.get("c.getOppAmount");

        action.setParams({
          "oppId" : component.get("v.recordId")
        });

        action.setCallback(this, function(a) {
            
        var response = a.getReturnValue();
        component.set("v.amount", response);
         
        	
        });
      	$A.enqueueAction(action);

		
	},
	
	save : function(component, event, helper) {

		component.set("v.showError", false);

		var amount = component.get("v.amount");
		var month = component.get("v.month");
		var frequency = component.get("v.frequency");
		var noOfPayments = component.get("v.noOfPayments");
		var probability = component.get("v.probability");

		if(amount === null || amount === "" || month === null || month === "" || frequency === null || frequency === "" || noOfPayments === null || noOfPayments === "" || probability === null || probability === ""){

			component.set("v.showError", true);
			component.set("v.errorMessage", "Please complete all fields.")

		} else {

			var action = component.get("c.createSchedules");

	        action.setParams({
	          "oppId" : component.get("v.recordId"),
	          "amount" : amount,
	          "month" : month,
	          "frequency" : frequency,
	          "noOfPayments" : noOfPayments,
	          "probability" : probability
	        });

	        action.setCallback(this, function(a) {
	            var response = a.getReturnValue();
	            if(JSON.stringify(response) !== '"Success"') {
	        		component.set('v.showError', true);
	        		component.set('v.errorMessage', response);
	        	} else {
	        		component.set('v.showError', false);
	        		component.set('v.showSuccess', true);
	        		$A.get('e.force:refreshView').fire();
	                
	        	}
	        });
	      	$A.enqueueAction(action);

	    }



	}, 

	cancel : function(component, event, helper) {

		$A.get("e.force:closeQuickAction").fire();
	}
})