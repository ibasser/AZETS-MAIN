/**
 * Purpose: Wrapper classes to hold AML data for Smart Search integration
 * Description:
 *  This wrapper main class contains subclasses for all the request and response JSON object
 *  used to interact with the Smart Seach API.
 * 
 * Author: PJ (Bluewave)
 * Created Date: Jan 2021
 * */
public with sharing class SmartSearchWrappers {

/****************************************************************
 * SECTION: wrapper classes for RESPONSE data objects (html body)
 */

/**
 * RESPONSE TYPE: Authorisation
 * 
 * Author: PJ (Bluewave)
 * Created Date: Jan 2021
 * */
public class AuthToken {
    public Boolean success;
    public TokenData data;
    public MetaObject meta;
    public List<ErrorObject> errors;
}

public class TokenData{
    public Integer id;
    public TokenAttributes attributes;
}

public class TokenAttributes{
    public String token_type;
    public Integer expires_in;
    public String access_token;
}

/**
 * CALL TYPE: Corporate dow jones
 * 
 * Author: PJ (Bluewave)
 * Created Date: Jan 2021
 * */
    public class DJO_Call {
        public String client_ref; // SF account Id
        public String company_name;
        public String crn;
        public String postcode;
        public String sanction_region;
        public String type;        
    }

/**
 * CALL TYPE: Individual AML
 * 
 * Author: PJ (Bluewave)
 * Created Date: Jan 4th 2021
 * */
    public class AML_UK_Call {
        public String client_ref; // SF account Id
        public Date date_of_birth;
        public SS_GBR_Documents documents;
        public SS_Name name;
        public string risk_level;
        public List<SS_Address> addresses;

    }

    public class SS_GBR_Documents {
        String nino;
    }

/**
 * CALL TYPE: Individual USA
 * 
 * Author: PJ (Bluewave)
 * Created Date: Jan 2021
 * */
    public class AML_US_Call {
        public String client_ref; // SF account Id
        public Date date_of_birth;
        public SS_USA_Documents documents;
        public SS_Name name;
        public List<SS_Address> addresses;
    }


    public class SS_USA_Documents {
        public String ssn;
    }

/**
 * CALL TYPE: Individual International
 * 
 * Author: PJ (Bluewave)
 * Created Date: Jan 2021
 * */
    public class AML_ITL_Call {
        public String client_ref; // SF account Id

    }

/***
 * CALL TYPE: Create Note
 *
 * Author: PJ (Bluewave)
 * Created Date: Jan 2021
 * */
    public class CreateNote_Call {
        public String note;
    }

/***
  * CALL TYPE: Update Due Diligence (Corporate and individual)
  * 
  * Author: PJ (Bluewave)
  * Created Date: Jan 2021   */
    public class UpdateDueDiligence_Call{
        public String your_client;
    }




/****************************************************************
 * SECTION: wrapper classes for RESPONSE data object (html body)
 */

 /**
 * RESPONSE TYPE: Corporate dow jones
 * 
 * Author: PJ (Bluewave)
 * Created Date: Jan 2021
 * */
public class DJO_Response {
    public Boolean success;
    public DJO_Data data;
    public MetaObject meta;
    public List<ErrorObject> errors;
}

public class DJO_Data{
    public Integer id;
    public DJO_Attributes attributes;
}

public class DJO_Attributes {
    public String client_ref; // SF account Id
    public String company_name;
    public String crn;
    public String postcode;
    public String run_date;
    public String ssid;
    public List<String> ssid_chain;
    public String type;    
    public DueDiligence due_diligence;   
  
}

/**
 * RESPONSE TYPE: Individual AML & USA
 * 
 * Author: PJ (Bluewave)
 * Created Date: Jan 4th 2021
 * */
public class AML_Response {
    public Boolean success;
    public AML_Data data;
    public MetaObject meta;
    public List<ErrorObject> errors;
}

public class AML_Data {
    public Integer id;
    public AML_Attributes attributes;
}

public class AML_Attributes {
    public String client_ref; // SF account Id
    public String company_name;
    public String risk_level;
    public SS_Name name;
    public Date date_of_birth;
    public List<SS_Address> addresses;
    public String name_and_address_match;
    public String ssid;
    public List<String> ssid_chain;
    public String sanction_region;
    public String result;    
    public DueDiligence due_diligence;   
  
}

/**
* RESPONSE TYPE: Individual International
* 
* Author: PJ (Bluewave)
* Created Date: Feb 2021
* */
public class AML_ITL_Response {
    public String client_ref; // SF account Id
    public AML_ITL_Data data; // SF account Id
    public MetaObject meta;
}

public class AML_ITL_Data{
    public Integer id;
    public AML_ITL_Attributes attributes;
}

public class AML_ITL_Attributes{
    public SS_Address address;
    public String client_ref; // SF account Id
    public Date date_of_birth;
    public String document_type;
    public DueDiligence due_diligence;   
    public String gender;
    public String issuing_country;
    public SS_Name name;
    public String result;    
    public List<String> result_reasons;    
    public String sanction_region;
    public String ssid;
    public String status;
    public String status_description;
    
    
    
    


}

/***
* RESPONSE TYPE: Create Note
*
* Author: PJ (Bluewave)
* Created Date: Jan 2021
* */
public class CreateNote_Response {
    public String note;
}

/***
* RESPONSE TYPE: Update Due Diligence (Corporate and individual)
* 
* Author: PJ (Bluewave)
* Created Date: Jan 2021   */
public class UpdateDueDiligence_Response{
    public String your_client;
}

/**
 *  SUBCLASS Due Diligence
 */
public class DueDiligence{
    public String sanction_region;
    public Boolean has_due_diligence;
    public Boolean has_outstanding_due_diligence;
    public Boolean has_highrisk_due_diligence;
    public String worldwide_sanctions;
    public String hm_treasury;
    public String hmt_ofacs;
    public String ofacs_sanctions;
    public String politically_exposed_person;
    public String special_interest_person;
    public String relative_close_associate;
    public String special_interest_entity;
} 

/********************* CALBACK SECTION ****************/

/*
 * 
 * Description: Wrapper class for international individual call back from SmartSearch
 * 
 * Author: PJ (Bluewave)
 * Created Date: Jan 2021   */
public class SmartSearchCallback {
    public SmartSearchCallbackData data;
}

public class SmartSearchCallbackData {
    public Integer id;
    public String type;
    public CallBackAttributes attributes;
}

public class CallbackAttributes{
    public String ssid;
    public String status;
}


/****************************************************************** 
 * Generic wrapperclasses
 * */  
    public virtual class SS_Address{
        public String building;
        public String country;
        public String flat;
        public String full;
        public String postcode;
        public String region;
        public String street_1;
        public String street_2;
        public String state;
        public String town;
        public String zip;
    }

    public class SS_Name{
        public String first;
        public String middle;
        public String last;
        public String title;
    }

    public class MetaObject{
        public String reference;
        public DateTime timestamp;
        public Double duration;
    }

    public class ErrorObject{
        String status;
        String title;
        String detail;
    }
}