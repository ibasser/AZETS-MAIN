/**
 * @description       : Credit Report wrapper class
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 08-02-2021
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   11-13-2020   Bluewave | Tomasz Piechota   Initial Version
**/
public class CreditsafeCreditReportWrapper {
	public String correlationId {get;set;}
	public String orderId {get;set;}
	public String companyId {get;set;}
	public String dateOfOrder {get;set;}
	public String language {get;set;}
	public String userId {get;set;}
	public String chargeReference {get;set;}
	public Report report {get;set;}
	public List<Message> messages {get;set;}
	public List<String> failedSections {get;set;}

	public CreditsafeCreditReportWrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'correlationId') {
						correlationId = parser.getText();
					} else if (text == 'orderId') {
						orderId = parser.getText();
					} else if (text == 'companyId') {
						companyId = parser.getText();
					} else if (text == 'dateOfOrder') {
						dateOfOrder = parser.getText();
					} else if (text == 'language') {
						language = parser.getText();
					} else if (text == 'userId') {
						userId = parser.getText();
					} else if (text == 'report') {
						report = new Report(parser);
					} else if (text == 'chargeReference') {
						chargeReference = parser.getText();
					} else if (text == 'messages') {
						messages = arrayOfMessage(parser);
					} else if (text == 'failedSections') {
						failedSections = arrayOfString(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'CreditsafeCreditReportWrapper consuming unrecognized property: ' + text);
						consumeObject(parser);
					}
				}
			}
		}
	}

	public class ActivityClassification {
		public String classification {get;set;}
		public List<Activity> activities {get;set;}

		public ActivityClassification(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'classification') {
							classification = parser.getText();
						} else if (text == 'activities') {
							activities = arrayOfActivity(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'ActivityClassification consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Activity {
		public String code {get;set;}
		public String industrySector {get;set;}
		public String description {get;set;}
		public String classification {get;set;}

		public Activity(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'code') {
							code = parser.getText();
						} else if (text == 'industrySector') {
							industrySector = parser.getText();
						} else if (text == 'description') {
							description = parser.getText();
						} else if (text == 'classification') {
							classification = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Activity consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class GroupStructure {
		public Parent ultimateParent {get;set;}
		public Parent immediateParent {get;set;}
		public List<Parent> subsidiaryCompanies {get;set;}
		public List<Parent> affiliatedCompanies {get;set;}

		public GroupStructure(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'ultimateParent') {
							ultimateParent = new Parent(parser);
						} else if (text == 'immediateParent') {
							immediateParent = new Parent(parser);
						} else if (text == 'subsidiaryCompanies') {
							subsidiaryCompanies = arrayOfParent(parser);
						} else if (text == 'affiliatedCompanies') {
							affiliatedCompanies = arrayOfParent(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'GroupStructure consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Directors {
		public List<Director> currentDirectors {get;set;}
		public List<Director> previousDirectors {get;set;}

		public Directors(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'currentDirectors') {
							currentDirectors = arrayOfDirector(parser);
						} else if (text == 'previousDirectors') {
							previousDirectors = arrayOfDirector(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Directors consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class CreditScore {
		public CreditRating currentCreditRating {get;set;}
		public Figure currentContractLimit {get;set;}
		public CreditRating previousCreditRating {get;set;}
		public String latestRatingChangeDate {get;set;}

		public CreditScore(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'currentCreditRating') {
							currentCreditRating = new CreditRating(parser);
						} else if (text == 'currentContractLimit') {
							currentContractLimit = new Figure(parser);
						} else if (text == 'previousCreditRating') {
							previousCreditRating = new CreditRating(parser);
						} else if (text == 'latestRatingChangeDate') {
							latestRatingChangeDate = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'CreditScore consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class LegalForm {
		public String commonCode {get;set;}
		public String providerCode {get;set;}
		public String description {get;set;}
		public String dateChanged {get;set;}
		public LegalForm legalForm {get;set;}

		public LegalForm(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'commonCode') {
							commonCode = parser.getText();
						} else if (text == 'providerCode') {
							providerCode = parser.getText();
						} else if (text == 'description') {
							description = parser.getText();
						} else if (text == 'dateChanged') {
							dateChanged = parser.getText();
						} else if (text == 'legalForm') {
							legalForm = new LegalForm(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'LegalForm consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Address {
		public String simpleValue {get;set;}
		public String street {get;set;}
		public String houseNumber {get;set;}
		public String city {get;set;}
		public String postalCode {get;set;}
		public String province {get;set;}
		public String telephone {get;set;}
		public Boolean directMarketingOptOut {get;set;}
		public Boolean directMarketingOptIn {get;set;}
		public String country {get;set;}
		public String addressType {get;set;}

		public Address(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'simpleValue') {
							simpleValue = parser.getText();
						} else if (text == 'street') {
							street = parser.getText();
						} else if (text == 'houseNumber') {
							houseNumber = parser.getText();
						} else if (text == 'city') {
							city = parser.getText();
						} else if (text == 'postalCode') {
							postalCode = parser.getText();
						} else if (text == 'province') {
							province = parser.getText();
						} else if (text == 'telephone') {
							telephone = parser.getText();
						} else if (text == 'directMarketingOptOut') {
							directMarketingOptOut = parser.getBooleanValue();
						} else if (text == 'directMarketingOptIn') {
							directMarketingOptIn = parser.getBooleanValue();
						} else if (text == 'country') {
							country = parser.getText();
						} else if (text == 'type') {
							addressType = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Address consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Director {
		public String id {get;set;}
		public String idType {get;set;}
		public String name {get;set;}
		public String title {get;set;}
		public String firstNames {get;set;}
		public String firstName {get;set;}
		public String middleName {get;set;}
		public String surname {get;set;}
		public String gender {get;set;}
		public String birthName {get;set;}
		public String dateOfBirth {get;set;}
		public String placeOfBirth {get;set;}
		public String nationality {get;set;}
		public String countryOfResidence {get;set;}
		public String country {get;set;}
		public String directorType {get;set;}
		public Boolean hasNegativeInfo {get;set;}
		public Boolean signingAuthority {get;set;}
		public String resignationDate {get;set;}
		public String registrationNumber {get;set;}
		public Address address {get;set;}

		public Director(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'idType') {
							idType = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'title') {
							title = parser.getText();
						} else if (text == 'firstNames') {
							firstNames = parser.getText();
						} else if (text == 'firstName') {
							firstName = parser.getText();
						} else if (text == 'middleName') {
							middleName = parser.getText();
						} else if (text == 'surname') {
							surname = parser.getText();
						} else if (text == 'address') {
							address = new Address(parser);
						} else if (text == 'gender') {
							gender = parser.getText();
						} else if (text == 'birthName') {
							birthName = parser.getText();
						} else if (text == 'dateOfBirth') {
							dateOfBirth = parser.getText();
						} else if (text == 'placeOfBirth') {
							placeOfBirth = parser.getText();
						} else if (text == 'nationality') {
							nationality = parser.getText();
						} else if (text == 'countryOfResidence') {
							countryOfResidence = parser.getText();
						} else if (text == 'country') {
							country = parser.getText();
						} else if (text == 'directorType') {
							directorType = parser.getText();
						} else if (text == 'hasNegativeInfo') {
							hasNegativeInfo = parser.getBooleanValue();
						} else if (text == 'signingAuthority') {
							signingAuthority = parser.getBooleanValue();
						} else if (text == 'resignationDate') {
							resignationDate = parser.getText();
						} else if (text == 'registrationNumber') {
							registrationNumber = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Director consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class ShareCapitalStructure {
		public String shareCapitalCurrency {get;set;}
		public Long numberOfSharesIssued {get;set;}
		public Figure nominalShareCapital {get;set;}
		public Figure issuedShareCapital {get;set;}
		public List<ShareHolder> shareHolders {get;set;}

		public ShareCapitalStructure(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'shareCapitalCurrency') {
							shareCapitalCurrency = parser.getText();
						} else if (text == 'numberOfSharesIssued') {
							numberOfSharesIssued = parser.getLongValue();
						} else if (text == 'nominalShareCapital') {
							nominalShareCapital = new Figure(parser);
						} else if (text == 'issuedShareCapital') {
							issuedShareCapital = new Figure(parser);
						} else if (text == 'shareHolders') {
							shareHolders = arrayOfShareHolder(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'ShareCapitalStructure consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Message {
		public String code {get;set;}
		public String text {get;set;}

		public Message(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String parserText = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (parserText == 'code') {
							code = parser.getText();
						} else if (parserText == 'text') {
							text = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Message consuming unrecognized property: ' + parserText);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class CreditRating {
		public String commonValue {get;set;}
		public String commonDescription {get;set;}
		public String providerDescription {get;set;}
		public Decimal pod {get;set;}
		public String assessment {get;set;}
		public CreditLimit creditLimit {get;set;}
		public ProviderValue providerValue {get;set;}

		public CreditRating(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'commonValue') {
							commonValue = parser.getText();
						} else if (text == 'commonDescription') {
							commonDescription = parser.getText();
						} else if (text == 'providerDescription') {
							providerDescription = parser.getText();
						} else if (text == 'pod') {
							pod = parser.getDecimalValue();
						} else if (text == 'assessment') {
							assessment = parser.getText();
						} else if (text == 'creditLimit') {
							creditLimit = new CreditLimit(parser);
						} else if (text == 'providerValue') {
							providerValue = new ProviderValue(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'CreditRating consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Report {
		public String companyId {get;set;}
		public String language {get;set;}
		public CompanySummary companySummary {get;set;}
		public CompanyIdentification companyIdentification {get;set;}
		public CreditScore creditScore {get;set;}
		public ContactInformation contactInformation {get;set;}
		public Directors directors {get;set;}
		public ShareCapitalStructure shareCapitalStructure {get;set;}
		public GroupStructure groupStructure {get;set;}
		public AdditionalInformation additionalInformation {get;set;}

		public Report(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'companyId') {
							companyId = parser.getText();
						} else if (text == 'language') {
							language = parser.getText();
						} else if (text == 'companySummary') {
							companySummary = new CompanySummary(parser);
						} else if (text == 'companyIdentification') {
							companyIdentification = new CompanyIdentification(parser);
						} else if (text == 'creditScore') {
							creditScore = new CreditScore(parser);
						} else if (text == 'contactInformation') {
							contactInformation = new ContactInformation(parser);
						} else if (text == 'directors') {
							directors = new Directors(parser);
						} else if (text == 'shareCapitalStructure') {
							shareCapitalStructure = new ShareCapitalStructure(parser);
						} else if (text == 'groupStructure') {
							groupStructure = new GroupStructure(parser);
						} else if (text == 'additionalInformation') {
							additionalInformation = new AdditionalInformation(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Report consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class CreditLimit {
		public String currencyCode {get;set;}
		public String value {get;set;}

		public CreditLimit(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'currency') {
							currencyCode = parser.getText();
						} else if (text == 'value') {
							value = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'CreditLimit consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Figure {
		public String currencyCode {get;set;}
		public Decimal value {get;set;}

		public Figure(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'currency') {
							currencyCode = parser.getText();
						} else if (text == 'value') {
							value = parser.getDecimalValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Figure consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class CompanyStatus {
		public String status {get;set;}
		public String description {get;set;}

		public CompanyStatus(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'status') {
							status = parser.getText();
						} else if (text == 'description') {
							description = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'CompanyStatus consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Parent {
		public String country {get;set;}
		public String id {get;set;}
		public String safeNumber {get;set;}
		public String idType {get;set;}
		public String name {get;set;}
		public String officeType {get;set;}
		public String status {get;set;}
		public String registrationNumber {get;set;}
		public String vatNumber {get;set;}
		public String legalForm {get;set;}
		public String parentType {get;set;}
		public Address address {get;set;}

		public Parent(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'country') {
							country = parser.getText();
						} else if (text == 'id') {
							id = parser.getText();
						} else if (text == 'safeNumber') {
							safeNumber = parser.getText();
						} else if (text == 'idType') {
							idType = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'officeType') {
							officeType = parser.getText();
						} else if (text == 'status') {
							status = parser.getText();
						} else if (text == 'registrationNumber') {
							registrationNumber = parser.getText();
						} else if (text == 'vatNumber') {
							vatNumber = parser.getText();
						} else if (text == 'legalForm') {
							legalForm = parser.getText();
						} else if (text == 'type') {
							parentType = parser.getText();
						} else if (text == 'address') {
							address = new Address(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Parent consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class AdditionalInformation {
		public PersonsWithSignificantControl personsWithSignificantControl {get;set;}

		public AdditionalInformation(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'personsWithSignificantControl') {
							personsWithSignificantControl = new PersonsWithSignificantControl(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'AdditionalInformation consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class PersonsWithSignificantControl {
		public List<ActivePSC> activePSC {get;set;}

		public PersonsWithSignificantControl(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'activePSC') {
							activePSC = arrayOfActivePSC(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'PersonsWithSignificantControl consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class ActivePSC {
		public String name {get;set;}
		public String title {get;set;}
		public String firstName {get;set;}
		public String middleName {get;set;}
		public String surname {get;set;}
		public String personType {get;set;}
		public String country {get;set;}
		public String kind {get;set;}
		public String countryOfRegistration {get;set;}
		public String countryOfResidence {get;set;}
		public String placeRegistered {get;set;}
		public String natureOfControl {get;set;}
		public String notifiedOn {get;set;}
		public String governingLaw {get;set;}
		public String legalForm {get;set;}
		public String registrationNumber {get;set;}
		public String insertDate {get;set;}
		public String nationality {get;set;}
		public String dateOfBirth {get;set;}
		public Address address {get;set;}

		public ActivePSC(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'name') {
							name = parser.getText();
						} else if (text == 'title') {
							title = parser.getText();
						} else if (text == 'firstName') {
							firstName = parser.getText();
						} else if (text == 'middleName') {
							middleName = parser.getText();
						} else if (text == 'surname') {
							surname = parser.getText();
						} else if (text == 'personType') {
							personType = parser.getText();
						} else if (text == 'country') {
							country = parser.getText();
						} else if (text == 'kind') {
							kind = parser.getText();
						} else if (text == 'countryOfRegistration') {
							countryOfRegistration = parser.getText();
						} else if (text == 'countryOfResidence') {
							countryOfResidence = parser.getText();
						} else if (text == 'placeRegistered') {
							placeRegistered = parser.getText();
						} else if (text == 'natureOfControl') {
							natureOfControl = parser.getText();
						} else if (text == 'notifiedOn') {
							notifiedOn = parser.getText();
						} else if (text == 'governingLaw') {
							governingLaw = parser.getText();
						} else if (text == 'legalForm') {
							legalForm = parser.getText();
						} else if (text == 'registrationNumber') {
							registrationNumber = parser.getText();
						} else if (text == 'insertDate') {
							insertDate = parser.getText();
						} else if (text == 'nationality') {
							nationality = parser.getText();
						} else if (text == 'dateOfBirth') {
							dateOfBirth = parser.getText();
						} else if (text == 'address') {
							address = new Address(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'ActivePSC consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class BasicInformation {
		public String businessName {get;set;}
		public String registeredCompanyName {get;set;}
		public String vatRegistrationNumber {get;set;}
		public String companyRegistrationNumber {get;set;}
		public String companyRegistrationDate {get;set;}
		public String country {get;set;}
		public String ownershipType {get;set;}
		public CompanyStatus companyStatus {get;set;}
		public LegalForm legalForm {get;set;}
		public Activity principalActivity {get;set;}
		public Address contactAddress {get;set;}

		public BasicInformation(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'businessName') {
							businessName = parser.getText();
						} else if (text == 'registeredCompanyName') {
							registeredCompanyName = parser.getText();
						} else if (text == 'vatRegistrationNumber') {
							vatRegistrationNumber = parser.getText();
						} else if (text == 'companyRegistrationNumber') {
							companyRegistrationNumber = parser.getText();
						} else if (text == 'companyRegistrationDate') {
							companyRegistrationDate = parser.getText();
						} else if (text == 'country') {
							country = parser.getText();
						} else if (text == 'ownershipType') {
							ownershipType = parser.getText();
						} else if (text == 'legalForm') {
							legalForm = new LegalForm(parser);
						} else if (text == 'companyStatus') {
							companyStatus = new CompanyStatus(parser);
						} else if (text == 'principalActivity') {
							principalActivity = new Activity(parser);
						} else if (text == 'contactAddress') {
							contactAddress = new Address(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'BasicInformation consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class ContactInformation {
		public Address mainAddress {get;set;}
		public List<Address> otherAddresses {get;set;}
		public List<Address> previousAddresses {get;set;}
		public List<String> emailAddresses {get;set;}
		public List<String> websites {get;set;}

		public ContactInformation(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'mainAddress') {
							mainAddress = new Address(parser);
						} else if (text == 'otherAddresses') {
							otherAddresses = arrayOfAddress(parser);
						} else if (text == 'previousAddresses') {
							previousAddresses = arrayOfAddress(parser);
						} else if (text == 'emailAddresses') {
							emailAddresses = arrayOfString(parser);
						} else if (text == 'websites') {
							websites = arrayOfString(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'ContactInformation consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class Name {
		public String dateChanged {get;set;}
		public String name {get;set;}

		public Name(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'dateChanged') {
							dateChanged = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Name consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class ShareHolder {
		public String id {get;set;}
		public String idType {get;set;}
		public String name {get;set;}
		public String title {get;set;}
		public String firstNames {get;set;}
		public String firstName {get;set;}
		public String middleName {get;set;}
		public String surname {get;set;}
		public String shareholderType {get;set;}
		public String shareType {get;set;}
		public Long totalNumberOfSharesOwned {get;set;}
		public Decimal totalValueOfSharesOwned {get;set;}
		public Decimal percentSharesHeld {get;set;}
		public String startDate {get;set;}
		public String endDate {get;set;}
		public String currencyCode {get;set;}
		public Boolean hasNegativeInfo {get;set;}
		public Address address {get;set;}

		public ShareHolder(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'idType') {
							idType = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'title') {
							title = parser.getText();
						} else if (text == 'firstNames') {
							firstNames = parser.getText();
						} else if (text == 'firstName') {
							firstName = parser.getText();
						} else if (text == 'middleName') {
							middleName = parser.getText();
						} else if (text == 'surname') {
							surname = parser.getText();
						} else if (text == 'shareholderType') {
							shareholderType = parser.getText();
						} else if (text == 'shareType') {
							shareType = parser.getText();
						} else if (text == 'totalNumberOfSharesOwned') {
							totalNumberOfSharesOwned = parser.getLongValue();
						} else if (text == 'totalValueOfSharesOwned') {
							totalValueOfSharesOwned = parser.getDecimalValue();
						} else if (text == 'percentSharesHeld') {
							percentSharesHeld = parser.getDecimalValue();
						} else if (text == 'startDate') {
							startDate = parser.getText();
						} else if (text == 'endDate') {
							endDate = parser.getText();
						} else if (text == 'currency') {
							currencyCode = parser.getText();
						} else if (text == 'hasNegativeInfo') {
							hasNegativeInfo = parser.getBooleanValue();
						} else if (text == 'address') {
							address = new Address(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'ShareHolder consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class CompanyIdentification {
		public BasicInformation basicInformation {get;set;}
		public List<ActivityClassification> activityClassifications {get;set;}
		public List<Name> previousNames {get;set;}
		public List<LegalForm> previousLegalForms {get;set;}

		public CompanyIdentification(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'basicInformation') {
							basicInformation = new BasicInformation(parser);
						} else if (text == 'activityClassifications') {
							activityClassifications = arrayOfActivityClassification(parser);
						} else if (text == 'previousNames') {
							previousNames = arrayOfName(parser);
						} else if (text == 'previousLegalForms') {
							previousLegalForms = arrayOfLegalForm(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'CompanyIdentification consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class ProviderValue {
		public String maxValue {get;set;}
		public String minValue {get;set;}
		public String value {get;set;}

		public ProviderValue(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'maxValue') {
							maxValue = parser.getText();
						} else if (text == 'minValue') {
							minValue = parser.getText();
						} else if (text == 'value') {
							value = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'ProviderValue consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public class CompanySummary {
		public String businessName {get;set;}
		public String country {get;set;}
		public String companyNumber {get;set;}
		public String companyRegistrationNumber {get;set;}
		public CompanyStatus companyStatus {get;set;}
		public Figure latestTurnoverFigure {get;set;}
		public Figure latestShareholdersEquityFigure {get;set;}
		public CreditRating creditRating {get;set;}

		public CompanySummary(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'businessName') {
							businessName = parser.getText();
						} else if (text == 'country') {
							country = parser.getText();
						} else if (text == 'companyNumber') {
							companyNumber = parser.getText();
						} else if (text == 'companyRegistrationNumber') {
							companyRegistrationNumber = parser.getText();
						} else if (text == 'companyStatus') {
							companyStatus = new CompanyStatus(parser);
						} else if (text == 'latestTurnoverFigure') {
							latestTurnoverFigure = new Figure(parser);
						} else if (text == 'latestShareholdersEquityFigure') {
							latestShareholdersEquityFigure = new Figure(parser);
						} else if (text == 'creditRating') {
							creditRating = new CreditRating(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'CompanySummary consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT ||
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}

	private static List<Activity> arrayOfActivity(System.JSONParser p) {
        List<Activity> res = new List<Activity>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Activity(p));
        }
        return res;
    }

	private static List<Parent> arrayOfParent(System.JSONParser p) {
        List<Parent> res = new List<Parent>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Parent(p));
        }
        return res;
    }

	private static List<Director> arrayOfDirector(System.JSONParser p) {
        List<Director> res = new List<Director>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Director(p));
        }
        return res;
    }

	private static List<ShareHolder> arrayOfShareHolder(System.JSONParser p) {
        List<ShareHolder> res = new List<ShareHolder>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new ShareHolder(p));
        }
        return res;
    }

	private static List<ActivePSC> arrayOfActivePSC(System.JSONParser p) {
        List<ActivePSC> res = new List<ActivePSC>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new ActivePSC(p));
        }
        return res;
    }

	private static List<Address> arrayOfAddress(System.JSONParser p) {
        List<Address> res = new List<Address>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Address(p));
        }
        return res;
	}

	private static List<String> arrayOfString(System.JSONParser p) {
        List<String> res = new List<String>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getText());
        }
        return res;
	}

	private static List<ActivityClassification> arrayOfActivityClassification(System.JSONParser p) {
        List<ActivityClassification> res = new List<ActivityClassification>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new ActivityClassification(p));
        }
        return res;
	}

	private static List<Name> arrayOfName(System.JSONParser p) {
        List<Name> res = new List<Name>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Name(p));
        }
        return res;
	}

	private static List<LegalForm> arrayOfLegalForm(System.JSONParser p) {
        List<LegalForm> res = new List<LegalForm>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new LegalForm(p));
        }
        return res;
	}

	private static List<Message> arrayOfMessage(System.JSONParser p) {
        List<Message> res = new List<Message>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Message(p));
        }
        return res;
	}

	public static CreditsafeCreditReportWrapper parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new CreditsafeCreditReportWrapper(parser);
	}
}