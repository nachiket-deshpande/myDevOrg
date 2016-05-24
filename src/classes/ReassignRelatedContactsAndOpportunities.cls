public with sharing class ReassignRelatedContactsAndOpportunities {

    public void reassignRelatedContactsAndOpportunities(List<Account> accountList,Map<Id,Account> oldAccountMap){
        try {
        Set<Id> accountIds = new Set<Id>(); //set for holding the Ids of all Accounts that have been assigned to new Owners
        Map<Id, String> oldOwnerIds = new Map<Id, String>(); //map for holding the old account ownerId
        Map<Id, String> newOwnerIds = new Map<Id, String>(); //map for holding the new account ownerId
        Contact[] contactUpdates = new Contact[0]; //Contact sObject to hold OwnerId updates
        Opportunity[] opportunityUpdates = new Opportunity[0]; //Opportunity sObject to hold OwnerId updates
        
        for (Account a : accountList) { //for all records
            if (a.OwnerId != oldAccountMap.get(a.Id).OwnerId) {
                oldOwnerIds.put(a.Id, oldAccountMap.get(a.Id).OwnerId); //put the old OwnerId value in a map
                newOwnerIds.put(a.Id, a.OwnerId); //put the new OwnerId value in a map
                accountIds.add(a.Id); //add the Account Id to the set
            }
        }
        
        if (!accountIds.isEmpty()) { //if the accountIds Set is not empty
            for (Account act : [SELECT Id, (SELECT Id, OwnerId FROM Contacts), (SELECT Id, OwnerId FROM Opportunities WHERE IsClosed = False) FROM Account WHERE Id in :accountIds]) { //SOQL to get Contacts and Opportunities for updated Accounts
                String newOwnerId = newOwnerIds.get(act.Id); //get the new OwnerId value for the account
                String oldOwnerId = oldOwnerIds.get(act.Id); //get the old OwnerId value for the account
                for (Contact c : act.Contacts) { //for all contacts
                    if (c.OwnerId == oldOwnerId) { //if the contact is assigned to the old account Owner
                        Contact updatedContact = new Contact(Id = c.Id, OwnerId = newOwnerId); //create a new Contact sObject
                        contactUpdates.add(updatedContact); //add the contact to our List of updates
                    }
                }
                for (Opportunity o : act.Opportunities) { //for all opportunities
                    if (o.OwnerId == oldOwnerId) { //if the opportunity is assigned to the old account Owner
                        Opportunity updatedOpportunity = new Opportunity(Id = o.Id, OwnerId = newOwnerId); //create a new Opportunity sObject
                        opportunityUpdates.add(updatedOpportunity); //add the opportunity to our List of updates
                    }
                }
            }
            update contactUpdates; //update the Contacts
            update opportunityUpdates; //update the Opportunities
        }
    } catch(Exception e) { //catch errors
        System.Debug('reassignRelatedContactsAndOpportunities failure: '+e.getMessage()); //write error to the debug log
    }
    }
}