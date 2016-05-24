public with sharing class OpportunityController {
    public integer counter = 0;
    public integer listSize = 5;
    public integer totalListSize = 0;
    public String searchString {get;set;}
    public String Id1{get;set;}
    public String selectedUser {get;set;}
    public integer pageSize{get;set;}
    public boolean showPanel1{get;set;}
    public boolean showPanel2{get;set;}
    public Set<Id> checkedOpportunityIdSet{get;set;}
    public List<opportunityWrapper> opportunityWrapperList{get;set;}
    public List<Task> taskList{get;set;}
    public List<Opportunity> opportunityTaskList{get;set;}
    public List<User> users{get;set;}
    public List<selectOption> options{get;set;}
    public Boolean displayPopup {get;set;}
    
    public void showPopup(){
        displayPopup = true;
    }

    public void closePopup() {
        displayPopup = false;
    }

    //create a wrapper class for opp with checkbox
    public class opportunityWrapper {
        public Opportunity oppInstance{get;set;}
        public boolean checked{get;set;}
        public opportunityWrapper(Opportunity opportunity) {
            oppInstance = opportunity;
            checked = false;
        }
    }//opportunityWrapper

    //get count of opportunities in org in constructor
    public OpportunityController() {
        showPanel1 = true;
        //options = new List<SelectOption>();
        taskList = new List<Task>();
        checkedOpportunityIdSet = new Set<Id>();
        totalListSize = [
            SELECT count()
            FROM Opportunity
        ];
        getOpportunityWrapperList1();
    }//DisplayOpportunityController

    //get opportunityList in wrapperList
    public List<opportunityWrapper> getOpportunityWrapperList1() {
        showPanel1 = true;
            opportunityWrapperList = new List<opportunityWrapper>();
            for(Opportunity opportunity : [SELECT Id, Name, CloseDate, StageName
                                           FROM Opportunity
                                           LIMIT : listSize
                                           offset :counter
            ]) {
                opportunityWrapperList.add(new opportunityWrapper(opportunity));
            }//for
            for(opportunityWrapper oppWrapper : opportunityWrapperList) {
                if(checkedOpportunityIdSet.contains(oppWrapper.oppInstance.Id)) {
                    oppWrapper.checked = true;
                }//if
            }//for
            
            return opportunityWrapperList;
    }//getOpportunityWrapperList1

    public void selectedOpportunity() {
        for(opportunityWrapper instance : opportunityWrapperList) {
            if(instance.checked == true) {
                checkedOpportunityIdSet.add(instance.oppInstance.Id);
            }//if
            if(instance.checked == false && checkedOpportunityIdSet.contains(instance.oppInstance.Id)) {
                checkedOpportunityIdSet.remove(instance.oppInstance.Id);
            }//if
        }//for
        return;
    }//selectedOpportunity

    //method to search opportunity entered in serchbox
    public void searchOpportunity() {
        showPanel1 = true;
        showPanel2 = false;
        if(searchString.length() < 3) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Enter at least 3 characters to search'));
        }//if
        else{
            String searchbox = '%'+searchString + '%';
            opportunityWrapperList = new List<opportunityWrapper>();
            for(Opportunity opportunity : [SELECT Id, Name, CloseDate, StageName
                                           FROM Opportunity 
                                           WHERE Name LIKE : searchbox
                                           LIMIT : listSize
                                           offset :counter
            ]) {
            opportunityWrapperList.add(new opportunityWrapper(opportunity));
            }//for
            if(opportunityWrapperList.isEmpty() == true) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Soryy, No results found!!'));
                showPanel2 = false;
                showPanel1 = false;
            }
        }//if
    }//searchOpportunity

    public pageReference createFollowupTask() {
        showPanel1 = false;
        showPanel2 = true;
        selectedOpportunity();
        if(checkedOpportunityIdSet.isEmpty()) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'No opportunities selected !'));
        }
        else {
            for(opportunityWrapper wrapperInstance : opportunityWrapperList) {
                if(wrapperInstance.checked == true) {
                    Task task = new task();
                    task.WhatId = wrapperInstance.oppInstance.Id;
                    task.Subject = 'FollowUp Task';
                    task.Status = 'Not Started';
                    task.Priority = 'Normal';
                    taskList.add(task);
                }
            }
            insert taskList;
            opportunityTaskList = new List<Opportunity>();
            for(Opportunity instance : [SELECT Id, Name,
                                   (SELECT Id, Priority,Subject FROM Tasks LIMIT 2)
                                    FROM Opportunity
                                    WHERE Id IN: checkedOpportunityIdSet
            ]) {
                opportunityTaskList.add(instance);
            }//for
        }
        return null;
    }

    //method to save opportunity on editing
    public void saveOpporunity() {
        List<Opportunity> oppList = new List<Opportunity>();
        for(opportunityWrapper wrapInstance : opportunityWrapperList) {
            oppList.add(wrapInstance.oppInstance);
        }//for
        update oppList;
    }//saveOpporunity

    public List<SelectOption> getNumber() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('5','5'));
        options.add(new SelectOption('10','10'));
        options.add(new SelectOption('15','15'));
        return options;
    }

    //on 'first' button
    public PageReference Beginning() {
        selectedOpportunity();
        counter = 0;
        getOpportunityWrapperList1();
        return null;
    }//Beginning

    //on 'previous' button click
    public PageReference Previous() {
        selectedOpportunity();
        counter = counter - listSize;
        getOpportunityWrapperList1();
        return null;
    }//Previous

    //on 'next' button click
    public PageReference Next() {
        selectedOpportunity();
        counter = counter + listSize;
        getOpportunityWrapperList1();
        return null;
    }//Next

    //on 'last' button click
    public PageReference End() {
        selectedOpportunity();
        counter = totalListSize - (math.mod(totalListSize,listSize));
        getOpportunityWrapperList1();
        return null;
    }

    //disable 'previous' button
    public boolean getDisablePrevious() {
        if(counter > 0)
            return false;
        else
            return true;
    }//getDisablePrevious

    //disble 'next' button
    public boolean getDisableNext() {
        if(counter + listSize < totalListSize)
            return false;
        else
            return true;
    }//getDisableNext

    //get current pagenumber
    public Integer getPageNumber() {
      return counter/listSize + 1;
   }//getPageNumber

    //get the total number of pages for records
     public Integer getTotalPages() {
      if (math.mod(totalListSize, listSize) > 0) {
         return totalListSize/listSize + 1;
      } else {
         return (totalListSize/listSize);
      }
   }//getTotalPages

    public Pagereference showinfo(){
        PageReference redirect = new PageReference('/' + Id1);
        return redirect;
    }

    public List<SelectOption> getOrgUsers() {
        system.debug('**Inside get Users****');
        options = new List<SelectOption>();
        for(User user :[SELECT Id, Name, isActive FROM User WHERE isActive = true]) {
            options.add(new SelectOption(user.Name,user.Name));
        }
        system.debug('-------------------'+options.size());
        system.debug('-------------------aaaaaaa'+options);
        return options;
    }

    public pageReference assignUserToTask() {
        system.debug('>>>>>user'+selectedUser);
        Id userId = [select Id from user where name=: selectedUser].Id;
        for(Task task : taskList) {
            task.ownerId = userId;
        }
        update taskList;
        return null;
    }
}