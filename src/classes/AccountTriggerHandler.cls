public with sharing class AccountTriggerHandler {

    public void onAfterInsert(){

    }

    public void onAfterUpdate(){
        new ReassignRelatedContactsAndOpportunities().reassignRelatedContactsAndOpportunities((List<Account>) trigger.new,
                                                                                               (Map<Id,Account>) trigger.oldMap);
    }
}