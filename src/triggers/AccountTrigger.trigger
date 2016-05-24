trigger AccountTrigger on Account (after insert, after update) {
    if(trigger.isAfter){
        if(trigger.isInsert){
            new AccountTriggerHandler().onAfterInsert();
        }
        if(trigger.isUpdate){
            new AccountTriggerHandler().onAfterUpdate();
        }
    }
}