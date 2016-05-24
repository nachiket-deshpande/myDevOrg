@RestResource(urlMapping='/v1/getAccounts/*')
global class GetAccount {
    @Httpget
    global static list<Account> fetchAccount(){
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        Id accId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        list<Account> accountList =[Select id,name,Phone,Fax from Account where Id =:accId ];

        return accountList ;
    }
}