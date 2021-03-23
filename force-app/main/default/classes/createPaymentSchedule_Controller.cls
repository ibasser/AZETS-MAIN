public with sharing class createPaymentSchedule_Controller {

	@AuraEnabled
    public static Decimal getOppAmount(String oppId) {

    	Decimal amount = 0;

    	Opportunity opp = [select Id, Amount from Opportunity where Id = : oppId];

    	amount = opp.Amount;

    	return amount;


    }


	@AuraEnabled
    public static String createSchedules(String oppId, Decimal amount, Integer month, String frequency, Decimal noOfPayments, String probability) {

    	String result = '';

    	Decimal paymentAmount = amount/noOfPayments;
    	Integer increment = (frequency == 'Monthly' ? 1 : 3);
    	Date firstDate = date.newinstance(Date.Today().Year(), month, 01);

    	Date paymentDate = (firstDate.month() < Date.Today().month() ? firstDate.addYears(1) : firstDate);
    	
    	list<Payment_Schedule__c> paymentSchedulesToInsert = new list<Payment_Schedule__c>();

    	for(Integer i = 0; i < noOfPayments; i++){

    		Payment_Schedule__c ps = new Payment_Schedule__c(

    			Opportunity_Name__c = oppId,
    			Payment_Amount__c = paymentAmount,
    			Payment_Date__c = paymentDate,
                Probability__c = probability
    		);

    		paymentSchedulesToInsert.add(ps);

    		paymentDate = paymentDate.addMonths(increment);


    	}

    	try {

    		insert paymentSchedulesToInsert;
    		result = 'Success';

    	} catch(Exception ex){

    		system.debug(ex.getMessage());
            result = ex.getMessage();

        }

    	return result;

    }
	

}