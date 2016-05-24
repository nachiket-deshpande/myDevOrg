public with sharing class GeoCoverageControllerClone {
    public List<String> billingLongitudeLatitude {get; set;}

    //controller
    public GeoCoverageControllerClone() {
        billingLongitudeLatitude = new List<String>();
        String billingLatLonStr;
        List<Account> lstAccount = new List<Account>();
        //query address from account where account type is 'NN Client' and Billing street, city, state,
        //country and postal code values should be present 
        lstAccount = [select BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, BillingLatitude, BillingLongitude, 
                        Billing_Address_Location__Longitude__s, Billing_Address_Location__Latitude__s 
                      from Account where Billing_Address_Location__Longitude__s != null AND Billing_Address_Location__Latitude__s != null];
        system.debug('lstAccount====>>>> '+lstAccount);
        system.debug('lstAccount.size()====>>>> '+lstAccount.size());
        if(!lstAccount.isEmpty()) {
            //concatenate the billing address and add it in the list
            for(Account accInst : lstAccount) {
             billingLatLonStr = '\"'+accInst.Billing_Address_Location__Latitude__s+', '+accInst.Billing_Address_Location__Longitude__s +'\"';
             billingLongitudeLatitude.add(billingLatLonStr);
            }
            system.debug('billingLongitudeLatitude Size==='+billingLongitudeLatitude);
        }
    }//end controller
}