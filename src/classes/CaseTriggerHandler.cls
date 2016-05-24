public class CaseTriggerHandler {

    public void onBeforeInsert(){
        new CreateAccountContactWithEmailToCase().createAccountContactOnBeforeInsert((List<Case>)trigger.new);
    }
}