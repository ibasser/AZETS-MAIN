/**
 * @description       :
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 12-11-2020
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   12-08-2020   Bluewave | Tomasz Piechota   Initial Version
**/
@isTest
private class createPaymentSchedule_Controller_TEST {

	@isTest
	static void T01_createPaymentSchedule_Monthly() {

		Account acc = new Account(
			Name = 'Test Acc'
		);
		insert acc;

		Staff_List__c s = new Staff_List__c(Name = 'Test Staff');
		insert s;

		Opportunity opp = new Opportunity(
			AccountId = acc.Id,
			Name = 'Test Opp',
			StageName = 'New',
			CloseDate = Date.today().addYears(1),
			Department__c = 'Payroll',
			Region__c = 'The North',
            Sub_Region__c = 'North West',
			Local_Office__c = 'Bolton',
			Product__c = 'Payroll',
			Opportunity_Type__c = 'New Client',
			Opportunity_assigned_to__c = s.Id
		);
		insert opp;

		Test.startTest();
		createPaymentSchedule_Controller.createSchedules(opp.Id, 100, 1, 'Monthly', 10, '50');
		Test.stopTest();

		list<Payment_Schedule__c> psList = [select Id, Payment_Date__c from Payment_Schedule__c order by Payment_Date__c];
		system.assertEquals(10, psList.size());

		Date firstPayment = psList[0].Payment_Date__c;
		Date lastPayment = psList[9].Payment_Date__c;

		Integer months = firstPayment.monthsBetween(lastPayment);

		system.assertEquals(9, months);

	}


	@isTest
	static void T02_createPaymentSchedule_Quarterly() {

		Account acc = new Account(
			Name = 'Test Acc'
		);
		insert acc;

		Staff_List__c s = new Staff_List__c(Name = 'Test Staff');
		insert s;

		Opportunity opp = new Opportunity(
			AccountId = acc.Id,
			Name = 'Test Opp',
			StageName = 'New',
			CloseDate = Date.today().addYears(1),
			Department__c = 'Payroll',
			Region__c = 'The North',
            Sub_Region__c = 'North West',
			Local_Office__c = 'Bolton',
			Product__c = 'Payroll',
			Opportunity_Type__c = 'New Client',
			Opportunity_assigned_to__c = s.Id
		);
		insert opp;

		Test.startTest();
		createPaymentSchedule_Controller.createSchedules(opp.Id, 100, 1, 'Quarterly', 10, '50');
		Test.stopTest();

		list<Payment_Schedule__c> psList = [select Id, Payment_Date__c from Payment_Schedule__c order by Payment_Date__c];
		system.assertEquals(10, psList.size());

		Date firstPayment = psList[0].Payment_Date__c;
		Date lastPayment = psList[9].Payment_Date__c;

		Integer months = firstPayment.monthsBetween(lastPayment);

		system.assertEquals(27, months);

	}


	@isTest
	static void T03_createPaymentSchedule_ERROR() {

		Account acc = new Account(
			Name = 'Test Acc'
		);
		insert acc;

		Staff_List__c s = new Staff_List__c(Name = 'Test Staff');
		insert s;

		Opportunity opp = new Opportunity(
			AccountId = acc.Id,
			Name = 'Test Opp',
			StageName = 'New',
			CloseDate = Date.today().addYears(1),
			Department__c = 'Payroll',
			Region__c = 'The North',
            Sub_Region__c = 'North West',
			Local_Office__c = 'Bolton',
			Product__c = 'Payroll',
			Opportunity_Type__c = 'New Client',
			Opportunity_assigned_to__c = s.Id
		);
		insert opp;

		delete opp;

		Test.startTest();
		createPaymentSchedule_Controller.createSchedules(opp.Id, 100, 1, 'Monthly', 10, '50');
		Test.stopTest();


		system.assertEquals(0, [select count() from Payment_Schedule__c]);

	}

	@isTest
	static void T04_getOppAmount() {

		Account acc = new Account(
			Name = 'Test Acc'
		);
		insert acc;

		Staff_List__c s = new Staff_List__c(Name = 'Test Staff');
		insert s;

		Opportunity opp = new Opportunity(
			AccountId = acc.Id,
			Name = 'Test Opp',
			StageName = 'New',
			CloseDate = Date.today().addYears(1),
			Department__c = 'Payroll',
			Region__c = 'The North',
            Sub_Region__c = 'North West',
			Local_Office__c = 'Bolton',
			Product__c = 'Payroll',
			Opportunity_Type__c = 'New Client',
			Opportunity_assigned_to__c = s.Id,
			Amount = 100
		);
		insert opp;

		Test.startTest();
		Decimal amount = createPaymentSchedule_Controller.getOppAmount(opp.Id);
		Test.stopTest();

		system.assertEquals(100, amount);

	}
}