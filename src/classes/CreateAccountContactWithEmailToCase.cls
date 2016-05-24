public class CreateAccountContactWithEmailToCase {
    //Variable Declarattion.
    List<String> emailAddressList = new List<String>();

    public void createAccountContactOnBeforeInsert(List<Case> caseList){
        for(Case objCase : caseList){
            if(objCase.ContactId == null && objCase.SuppliedEmail <> null){
                emailAddressList.add(objCase.SuppliedEmail);
            }//if
        }//for

        //if(emailAddressList.isEmpty() == false) return;
        List<Contact> conttactList = [Select Id,Email From Contact Where Email in :emailAddressList];
        system.debug('***conttactList***'+conttactList);
        for(Contact objContact : Database.query('Select Id,Email From Contact Where Email in :emailAddressList')){
            system.debug('***objContact***'+objContact);
        }
    }//createAccountContactOnBeforeInsert
}//CreateAccountContactWithEmailToCase