/**
 * @description       : Test data factory class
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 11-02-2021
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   12-03-2020   Bluewave | Tomasz Piechota   Initial Version
**/
@isTest
public class TestDataFactory {

    /**
    * @description Credisafe Callout Default Settings (Custom Settings)
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    * @return Credisafe_Callout_Settings__c
    **/
    public static Credisafe_Callout_Settings__c createCredisafeCalloutSettings() {
        Credisafe_Callout_Settings__c cs = new Credisafe_Callout_Settings__c(
            Name = 'Default',
            Encoding__c = 'UTF-8',
            Exact__c = false,
            Language__c = 'en',
            Page_Size_Max__c = 200,
            Page_Size__c = 10,
            Page__c = 1
        );

        return cs;
    }

    /**
    * @description Credisafe Callout Settings (Custom Settings)
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    * @param name
    * @return Credisafe_Callout_Settings__c
    **/
    public static Credisafe_Callout_Settings__c createCredisafeCalloutSettings(String name) {
        Credisafe_Callout_Settings__c cs = new Credisafe_Callout_Settings__c(
            Name = name,
            Encoding__c = 'UTF-8',
            Exact__c = false,
            Language__c = 'en',
            Page_Size_Max__c = 200,
            Page_Size__c = 10,
            Page__c = 1
        );

        return cs;
    }

    /**
    * @description Credisafe Callout Settings (Custom Settings) user defined
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    * @param name String
    * @param encoding String
    * @param exact  Boolean
    * @param lang String
    * @param pageSizeMax Decimal
    * @param pageSize Decimal
    * @param page Decimal
    * @return Credisafe_Callout_Settings__c
    **/
    public static Credisafe_Callout_Settings__c createCredisafeCalloutSettings(String name, String encoding, Boolean exact, String lang, Decimal pageSizeMax, Decimal pageSize, Decimal page) {
        Credisafe_Callout_Settings__c cs = new Credisafe_Callout_Settings__c(
            Name = name,
            Encoding__c = encoding,
            Exact__c = exact,
            Language__c = lang,
            Page_Size_Max__c = pageSizeMax,
            Page_Size__c = pageSize,
            Page__c = page
        );

        return cs;
    }

    /**
    * @description Credisafe Callout Settings (Custom Settings) user defined
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    * @param exact  Boolean
    * @return Credisafe_Callout_Settings__c
    **/
    public static Credisafe_Callout_Settings__c createCredisafeCalloutSettings(Boolean exact) {
        Credisafe_Callout_Settings__c cs = new Credisafe_Callout_Settings__c(
            Name = 'Default',
            Encoding__c = 'UTF-8',
            Exact__c = exact,
            Language__c = 'en',
            Page_Size_Max__c = 200,
            Page_Size__c = 10,
            Page__c = 1
        );

        return cs;
    }

    /**
    * @description Credisafe Credit Report Reasons Settings (Custom Settings)
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    * @param name
    * @return List<Credisafe_Credit_Report_Reasons_DE__c>
    **/
    public static List<Credisafe_Credit_Report_Reasons_DE__c> createCredisafeCreditReportReasons() {
        List<Credisafe_Credit_Report_Reasons_DE__c> reasonList = new List<Credisafe_Credit_Report_Reasons_DE__c>();
        reasonList.add(new Credisafe_Credit_Report_Reasons_DE__c(Name = '1', Value__c = '1', Description__c = 'Credit Decisioning', Key__c = 'de_reason_code', Optional__c = false));
        reasonList.add(new Credisafe_Credit_Report_Reasons_DE__c(Name = '2', Value__c = '2', Description__c = 'Credit Assessment - Future business connection (with credit risk)', Key__c = 'de_reason_code', Optional__c = false, Active__c = true));
        reasonList.add(new Credisafe_Credit_Report_Reasons_DE__c(Name = '3', Value__c = '3', Description__c = 'Credit Assessment - Existing business connection (with credit risk)', Key__c = 'de_reason_code', Optional__c = false, Active__c = true));
        reasonList.add(new Credisafe_Credit_Report_Reasons_DE__c(Name = '4', Value__c = '4', Description__c = 'Realisation check receivables collection', Key__c = 'de_reason_code', Optional__c = false));
        reasonList.add(new Credisafe_Credit_Report_Reasons_DE__c(Name = '5', Value__c = '5', Description__c = 'Purchase Contract - Intention of signature of purchase contract (with credit risk)', Key__c = 'de_reason_code', Optional__c = false));
        reasonList.add(new Credisafe_Credit_Report_Reasons_DE__c(Name = '6', Value__c = '6', Description__c = 'Goods Credit Insurance (with credit risk)', Key__c = 'de_reason_code', Optional__c = false));
        reasonList.add(new Credisafe_Credit_Report_Reasons_DE__c(Name = '7', Value__c = '7', Description__c = 'Contract - Intention of signature of leasing or rent contract (with credit risk)', Key__c = 'de_reason_code', Optional__c = false));
        reasonList.add(new Credisafe_Credit_Report_Reasons_DE__c(Name = '8', Value__c = '8', Description__c = 'Insurance Contract - Intention of signature of a insurance contract (with credit risk)', Key__c = 'de_reason_code', Optional__c = false));

        return reasonList;
    }

    /**
    * @description Create the list of countries  (Custom Settings)
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    * @return List<Countries__c>
    **/
    public static List<Countries__c> createCountryListSettings() {
        List<Countries__c> cl = new List<Countries__c>();
        cl.add(new Countries__c(Name = 'Albania', Country_ISO2_Code__c = 'AL'));
        cl.add(new Countries__c(Name = 'Andorra', Country_ISO2_Code__c = 'AD'));
        cl.add(new Countries__c(Name = 'Australia', Country_ISO2_Code__c = 'AU'));
        cl.add(new Countries__c(Name = 'Austria', Country_ISO2_Code__c = 'AT'));
        cl.add(new Countries__c(Name = 'Belarus', Country_ISO2_Code__c = 'BY'));
        cl.add(new Countries__c(Name = 'Belgium', Country_ISO2_Code__c = 'BE'));
        cl.add(new Countries__c(Name = 'Bosnia and Herzegovina', Country_ISO2_Code__c = 'BA'));
        cl.add(new Countries__c(Name = 'Bulgaria', Country_ISO2_Code__c = 'BG'));
        cl.add(new Countries__c(Name = 'Canada', Country_ISO2_Code__c = 'CA'));
        cl.add(new Countries__c(Name = 'China', Country_ISO2_Code__c = 'CN'));
        cl.add(new Countries__c(Name = 'Croatia', Country_ISO2_Code__c = 'HR'));
        cl.add(new Countries__c(Name = 'Czechia - Czech Republic', Country_ISO2_Code__c = 'CZ'));
        cl.add(new Countries__c(Name = 'Denmark', Country_ISO2_Code__c = 'DK'));
        cl.add(new Countries__c(Name = 'Estonia', Country_ISO2_Code__c = 'EE'));
        cl.add(new Countries__c(Name = 'Faroe Islands', Country_ISO2_Code__c = 'FO'));
        cl.add(new Countries__c(Name = 'Finland', Country_ISO2_Code__c = 'FI'));
        cl.add(new Countries__c(Name = 'France', Country_ISO2_Code__c = 'FR'));
        cl.add(new Countries__c(Name = 'Germany', Country_ISO2_Code__c = 'DE', Priority_Country__c = true, Priority_Order__c = 3));
        cl.add(new Countries__c(Name = 'Gibraltar', Country_ISO2_Code__c = 'GI'));
        cl.add(new Countries__c(Name = 'Greece', Country_ISO2_Code__c = 'GR'));
        cl.add(new Countries__c(Name = 'Guernsey', Country_ISO2_Code__c = 'GG'));
        cl.add(new Countries__c(Name = 'Hungary', Country_ISO2_Code__c = 'HU'));
        cl.add(new Countries__c(Name = 'Iceland', Country_ISO2_Code__c = 'IS'));
        cl.add(new Countries__c(Name = 'India', Country_ISO2_Code__c = 'IN'));
        cl.add(new Countries__c(Name = 'Ireland', Country_ISO2_Code__c = 'IE', Priority_Country__c = true, Priority_Order__c = 2));
        cl.add(new Countries__c(Name = 'Isle of Man', Country_ISO2_Code__c = 'IM'));
        cl.add(new Countries__c(Name = 'Israel', Country_ISO2_Code__c = 'IL'));
        cl.add(new Countries__c(Name = 'Italy', Country_ISO2_Code__c = 'IT'));
        cl.add(new Countries__c(Name = 'Japan', Country_ISO2_Code__c = 'JP'));
        cl.add(new Countries__c(Name = 'Jersey', Country_ISO2_Code__c = 'JE'));
        cl.add(new Countries__c(Name = 'Latvia', Country_ISO2_Code__c = 'LV'));
        cl.add(new Countries__c(Name = 'Liechtenstein', Country_ISO2_Code__c = 'LI', Priority_Country__c = true));
        cl.add(new Countries__c(Name = 'Lithuania', Country_ISO2_Code__c = 'LT'));
        cl.add(new Countries__c(Name = 'Luxembourg', Country_ISO2_Code__c = 'LU'));
        cl.add(new Countries__c(Name = 'Malta', Country_ISO2_Code__c = 'MT'));
        cl.add(new Countries__c(Name = 'Moldova', Country_ISO2_Code__c = 'MD'));
        cl.add(new Countries__c(Name = 'Monaco', Country_ISO2_Code__c = 'MC'));
        cl.add(new Countries__c(Name = 'Montenegro', Country_ISO2_Code__c = 'ME'));
        cl.add(new Countries__c(Name = 'Netherlands', Country_ISO2_Code__c = 'NL'));
        cl.add(new Countries__c(Name = 'Norway', Country_ISO2_Code__c = 'NO'));
        cl.add(new Countries__c(Name = 'Poland', Country_ISO2_Code__c = 'PL', Priority_Country__c = true, Priority_Order__c = 4));
        cl.add(new Countries__c(Name = 'Portugal', Country_ISO2_Code__c = 'PT'));
        cl.add(new Countries__c(Name = 'Romania', Country_ISO2_Code__c = 'RO'));
        cl.add(new Countries__c(Name = 'Russia', Country_ISO2_Code__c = 'RU'));
        cl.add(new Countries__c(Name = 'San Marino', Country_ISO2_Code__c = 'SM'));
        cl.add(new Countries__c(Name = 'Serbia', Country_ISO2_Code__c = 'RS'));
        cl.add(new Countries__c(Name = 'Slovakia', Country_ISO2_Code__c = 'SK'));
        cl.add(new Countries__c(Name = 'Slovenia', Country_ISO2_Code__c = 'SI'));
        cl.add(new Countries__c(Name = 'Spain', Country_ISO2_Code__c = 'ES'));
        cl.add(new Countries__c(Name = 'Svalbard', Country_ISO2_Code__c = 'SJ'));
        cl.add(new Countries__c(Name = 'Sweden', Country_ISO2_Code__c = 'SE'));
        cl.add(new Countries__c(Name = 'Switzerland', Country_ISO2_Code__c = 'CH'));
        cl.add(new Countries__c(Name = 'Ukraine', Country_ISO2_Code__c = 'UA'));
        cl.add(new Countries__c(Name = 'United Kingdom', Country_ISO2_Code__c = 'GB', Priority_Country__c = true, Priority_Order__c = 1));
        cl.add(new Countries__c(Name = 'United States', Country_ISO2_Code__c = 'US'));
        cl.add(new Countries__c(Name = 'Vatican City', Country_ISO2_Code__c = 'VA'));

        return cl;
    }

    /**
    * @description Create Account
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    * @return Account
    **/
    public static Account createAccount(String Name) {
        Account a = new Account(
            Name = Name,
            Type = 'Client',
            Industry = 'Automotive',
            Region__c = 'Westeros',
            Local_Office__c = 'UK'
        );

        return a;
    }

    /**
    * @description Create Account
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    * @return Account
    **/
    public static Account createAccountAndInsert(String Name) {
        Account a = new Account(
            Name = Name,
            Type = 'Client',
            Industry = 'Automotive',
            Region__c = 'Westeros',
            Local_Office__c = 'UK'
        );
        insert a;

        return a;
    }

    /**
    * @description Create Account with Connect Id
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    * @return Account
    **/
    public static Account createAccountAndInsert(String Name, String connectId) {
        Account a = new Account(
            Name = Name,
            Type = 'Client',
            Industry = 'Automotive',
            Region__c = 'Westeros',
            Local_Office__c = 'UK',
            Connect_Id__c = connectId
        );
        insert a;

        return a;
    }

    /**
    * @description Create Account with defined Connect Id
    * @author Bluewave | Tomasz Piechota | 12-03-2020
    * @param connectId
    * @return Account
    **/
    public static Account createAccount(String Name, String connectId) {
        Account a = new Account(
            Name = Name,
            Type = 'Client',
            Industry = 'Automotive',
            Region__c = 'Westeros',
            Local_Office__c = 'UK',
            Connect_Id__c = connectId
        );

        return a;
    }

    /**
    * @description Create Onboarding__c with Opportunity with opportunity products (opportunity line items) and all dependencies
    * @author Bluewave | Tomasz Piechota | 03-02-2021
    * @return Opportunity
    **/
    public static Onboarding__c createOnboardingWithOppAndOppLineItems() {
        Account acc = createAccount('Test Account');
        insert acc;

        Product2 prod2 = new Product2(
            Name = 'Test Product',
            Description = 'Test Product',
            ProductCode = 'TP',
            IsActive = true
        );
        insert prod2;

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            product2Id = prod2.Id,
            IsActive = true,
            UnitPrice = 1000
        );
        insert pbEntry;

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

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.id,
            PricebookEntryId = pbEntry.id,
            Product2Id = prod2.id,
            Description = 'Test Product',
            TotalPrice = 10000,
            Quantity = 10,
            Status__c = 'Service Won'
        );
        insert oli;

        Onboarding__c ob = createOnboarding(opp.AccountId, opp.Id);
        insert ob;

        return ob;
    }

    /**
    * @description Create Opportunity with opportunity products (opportunity line items) and all dependencies
    * @author Bluewave | Tomasz Piechota | 03-02-2021
    * @return Opportunity
    **/
    public static Opportunity createOppAndOppLineItems() {
        Account acc = createAccount('Test Account');
        insert acc;

        Product2 prod2 = new Product2(
            Name = 'Test Product',
            Description = 'Test Product',
            ProductCode = 'TP',
            IsActive = true
        );
        insert prod2;

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            product2Id = prod2.Id,
            IsActive = true,
            UnitPrice = 1000
        );
        insert pbEntry;

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

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.id,
            PricebookEntryId = pbEntry.id,
            Product2Id = prod2.id,
            Description = 'Test Product',
            TotalPrice = 10000,
            Quantity = 10
        );
        insert oli;

        return opp;
    }

    public static Onboarding__c createOnboarding(Id accId, Id oppId) {
        Onboarding__c o = new Onboarding__c(
            Account__c = accId,
            Opportunity__c = oppId
        );

        return o;
    }

    public static Onboarding__c createOnboardingAndInsert(Id accId, Id oppId) {
        Onboarding__c o = new Onboarding__c(
            Account__c = accId,
            Opportunity__c = oppId
        );
        insert o;

        return o;
    }

    public static Opportunity createOpportunityAndInsert(Id accId) {
        Staff_List__c s = new Staff_List__c(Name = 'Test Staff');
        insert s;

        Opportunity opp = new Opportunity(
			AccountId = accId,
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

        return opp;
    }

    /**
    * @description Create Company_Data__c records and insert all
    * @author Bluewave | Tomasz Piechota | 04-02-2021
    * @param Id accId
    * @param Integer count
    * @return List<Company_Data__c>
    **/
    public static List<Company_Data__c> createCompanyDataAndInsert(Id accId, Integer count) {
        List<Company_Data__c> cdl = new List<Company_Data__c>();

        for(Integer i = 0; i < count; i++) {
            cdl.add(new Company_Data__c(
                Account__c = accId
            ));
        }
		insert cdl;

        return cdl;
    }

    /**
    * @description Create Company_Data__c records and insert all
    * @author Bluewave | Tomasz Piechota | 04-02-2021
    * @param Id accId
    * @param Integer count
    * @return List<Company_Data__c>
    **/
    public static List<Company_Data__c> createCompanyDataAndInsert(Id accId, Integer count, String entityType, String personName, String companyName, Id rtId) {
        List<Company_Data__c> cdl = new List<Company_Data__c>();
        String name = personName == null ? companyName == null ? null : companyName : personName;
        for(Integer i = 0; i < count; i++) {
            cdl.add(new Company_Data__c(
                Account__c = accId,
                Entity_Type__c = entityType,
                Person_Name__c = personName,
                Company_Name__c = companyName,
                CC_Name__c = name,
                RecordTypeId = rtId
            ));
        }
		insert cdl;

        return cdl;
    }
}