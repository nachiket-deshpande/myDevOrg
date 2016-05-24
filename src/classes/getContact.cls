@RestResource(urlMapping='/v1/getContacts/*')
   global with sharing class getContact {
     @Httpget
      global static list<contact> fetchAccount(){
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        Id accId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        list<contact> lstcontact =[Select id , name,Phone,Fax,Email from contact where Accountid=:accId ];
        
        return lstcontact ;
      }
}