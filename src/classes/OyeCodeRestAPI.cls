@RestResource(urlMapping='/OyeCode/*')
global class OyeCodeRestAPI {
    
    //**************************************************
    //Private methods 
    //**************************************************
    
    //Check if Object is NULL or Blank
    global static boolean isNotNullOrEmpty(string str)
    {
        return str!=null || !String.isBlank(str); 
    }
    
    // Create a Contact 
    public static Contact createContact(String firstName, String lastName, String email,String Phone)
    {
        //check if the fields provided on not empty
        if(isNotNullOrEmpty(firstName) && isNotNullOrEmpty(lastName) && isNotNullOrEmpty(email) && isNotNullOrEmpty(Phone))
        {
            Contact newContact = new Contact();
            newContact.FirstName = firstName;
            newContact.LastName = lastName;
            newContact.Email = email;
            newContact.Phone=phone;
            return newContact;         
        }
        else 
        {
            System.Debug('Required field values are not provided here');
            return null;
        }
    }
    
    
    //====================================================================================
    // *** REST POST *** : Require field should not be empty, method to post a new Contact
    //====================================================================================
    @HttpPost
    global static ResponseHandler post(String firstname, String  lastname, String email, String Phone)
    {
        Contact  newContact =  createContact(firstName, lastName, email, Phone);
        ResponseHandler response = new ResponseHandler();
        try
        {
            insert newContact;
            List<sObject> thesObjectList = new List<sObject>();
            thesObjectList.add((sObject)newContact);
            response.Data = thesObjectList;
            response.Status = 'Success';
            response.ErrorCode = null;
            response.Message = null;
        } 
        catch(DmlException e) 
        {
            //Add custom error code when you could not insert a record
            response.ErrorCode = 'Oyecode - 0001';
            response.Status = 'error';
            response.Message = e.getMessage();
        }
        return response;   
    }
    
    
    //==============================================================================================
    // *** REST GET *** :  Requires the id of Contact and reutrn results as Response Type
    //===============================================================================================
    @HttpGet 
    global static ResponseHandler GET()
    {
        ResponseHandler response = new ResponseHandler();
        Contact  returnContact = getContact();
        
        if(returnContact!=null)
        {
            response.Status = 'Success';
            response.ErrorCode = '';
            List<sObject> thesObjectList = new List<sObject>();
            thesObjectList.add((sObject)returnContact);
            response.Data = thesObjectList;
            response.Message = 'Success : Found Contact';
        }
        
        else
        {
            response.ErrorCode = 'OyeCode-0002';
            response.Status = 'error';
            response.Message = 'Fail : Ahh, Contact Not Found';
            
        }
        
        return response;
    }
    
    //Adding custom Exception sub-class 
    public class NoRecordMatchException extends Exception {}
    
    public static Contact getContact()
    {
        //Read the Request from the URL
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String ContactId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1); 
        Contact result;
        try{
            result = [SELECT Id, lastname, firstName, phone, email FROM Contact WHERE Id = :ContactId];
        }
        Catch(System.QueryException e)
        {
            //Add custom exception dynamically to the ErrorMap
            throw new NoRecordMatchException('Unable to find the record maching Id : '+ContactId);
        }
        return result;
    }
    
}