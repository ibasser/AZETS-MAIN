/**
 * Purpose: Handle SmartSearch Callback
 * 
 * Description: When users do an AML or dow jones search on the Smart search portal
 *      they can insert a callback URL which Smart Search will ping with the result
 *      of the ping once the check completed.
 * 
 * Author: PJ (Bluewave)
 * Created Date: Jan 2021
 */
@RestResource (urlMapping='/SmartSearch/*')
global class SmartSearchWebservice {

    /**
     * Purpose: Handle SmartSearch POST
     * 
     * Description: The callback body is casted into a wrapper class SmartSearchCallBack.  
     *      The ssid and result are pased to notifyDoccheckComplete() which in turn sends an email 
     *      to the user in charge
     * 
     * Author: PJ (Bluewave)
     * Created Date: Jan 2021
     */
    @HttpPost 
    global static string doPost(){
        String ssid;
        String status;
        String bodyStr;
        bodyStr=RestContext.request.requestBody.toString();
        Type callbackType = Type.forName('SmartSearchWrappers.SmartSearchCallBack');
        SmartSearchWrappers.SmartSearchCallBack callback = (SmartSearchWrappers.SmartSearchCallBack)JSON.deserialize(bodyStr, callbackType);
        ssid=callback.data.attributes.ssid;
        status=callback.data.attributes.status;
        
        Boolean success = notifyDoccheckComplete(ssid,status);
       if (success){ 
           return 'Success';}
       else {
           return 'Unable to process entity';
        }
    }

/**
 * Purpose: Get user data and prepare message contents
 * 
 * Description: Using the SSID we retrieve the object for which the check was made
 *      In this method we get all the parameters for the email notfication and pass them 
 *      to sendEmailNotification()
 * 
 * Author: PJ (Bluewave)
 * Created Date: Jan 2021
 */
    public static Boolean notifyDoccheckComplete(String ssid, String status){
        System.debug('SSID in Handler  ' + ssid);

        List<List<SObject>> results = [FIND :ssid RETURNING Account(id,Name,OwnerId,Owner.email,SSID__C), 
                                                            Company_Data__c(id,Company_Name__c, Person_Name__c,Account__r.Owner.email,SSID__c)];  
        String entityName;
        String userEmail;
        List<Account> accounts = results[0];
        List<Company_Data__c> companyData = results[1];

        //Check if SSID is in account or CompanyData Record
        // Note SSID is unique and we cannot find more than one recrodcannot
        if (accounts.size()>0) {
            for (Account a : accounts){
                if (a.SSID__c == ssid){
                    userEmail=a.owner.Email;
                    entityName = a.name;
                }
            }
        }

        if (companyData.size()>0) {
            for (Company_Data__c cd : companyData){
                if (cd.SSID__c == ssid){
                    userEmail=cd.Account__r.owner.Email;

                    if (cd.Company_Name__c != null) {
                        entityName = cd.Company_Name__c;
                    } 
                    if (cd.Person_Name__c != null) {
                        entityName = cd.Person_Name__c;
                    }

                }
            }
        }

        try {
            sendEmailNotification(userEmail, ssid, entityName, status);
            return true;
        } catch( Exception e){
            System.debug('Unable to send emai to user');
            return false;
        }


        
    }

/**
 * Purpose: Send Email
 * 
 * Description: send email notification. We are not using a tmeplate.
 * 
 * Author: PJ (Bluewave)
 * Created Date: Jan 2021
 */
    public static void sendEmailNotification(String toAddress, String ssid, String nameString, String status) {
        
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {toAddress};
        mail.setToAddresses(toAddresses);

        // Specify the name used as the display name.
        mail.setSenderDisplayName('Azets Smart Search Notification Agent');

        // Specify the subject line for your email address.
        mail.setSubject('o International check ' + status + ' for ' + nameString +' ('+ssid+')' );

        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);

        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);

        // Specify the text content of the email.
        mail.setPlainTextBody('International check ' + status + ' for ' + nameString +' ('+ssid+')' );

        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}