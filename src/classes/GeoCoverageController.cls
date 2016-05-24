public class GeoCoverageController {
    public List<String> listOfAddresses {get; set;}

    //controller
    public GeoCoverageController() {
        listOfAddresses = new List<String>();
        string strAddress;
        List<Account> lstAccount = new List<Account>();
        //query address from account where account type is 'NN Client' and Billing street, city, state,
        //country and postal code values should be present 
        lstAccount = [select BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode 
                      from Account where  BillingStreet != null 
                      AND BillingCity != null AND BillingState != null AND BillingCountry != null 
                      AND BillingPostalCode != null];
        if(!lstAccount.isEmpty()) {
            //concatenate the billing address and add it in the list
            for(Account accInst : lstAccount) {
                strAddress = '\"'+accInst.BillingStreet+', '+accInst.BillingCity+', '
                                +accInst.BillingState+' '+accInst.BillingPostalCode+', '
                                +accInst.BillingCountry+'\"';
                listOfAddresses.add(strAddress);
            }
            system.debug('listOfAddresses==='+listOfAddresses);
            system.debug('listOfAddresses Size==='+listOfAddresses.size());
        }
    }//end controller
}//end GeoCoverageController