public with sharing class InlineEditPageController {
    public Boolean MyAllowAdd {get; set;}
    public Boolean MyAllowEdit {get; set;}
    public Boolean MyAllowDelete {get; set;}
    public String MysObj {get; set;}
    public String MyRecId {get; set;}
    public String MyRelationField {get; set;}
    public list<String> MyFieldList {get; set;}
    public list<String> MyLabelOverrideFieldList {get; set;}
    public list<String> MyLabelOverrideTextList {get; set;}
    public list<String> MyDefaultValueFieldList {get; set;}
    public list<String> MyDefaultValueTextList {get; set;}
    public String MyBlockTitle {get; set;}
    
    public InlineEditPageController() {
        MyAllowAdd = true;
        MyAllowEdit = true;
        MyAllowDelete = true;
        MyBlockTitle = 'In-line Editing of Contacts';
        MysObj = 'Contact';
        MyRecId = '001i000000JqJAa';  // fill in your record Id here
        MyRelationField = 'AccountId';
        MyFieldList = new list<String> {'FirstName',
                                        'LastName',
                                        'Email',
                                        'Phone',
                                        'Account.Name'};
        MyLabelOverrideFieldList = new list<String> { 'Account.Name'};
        MyLabelOverrideTextList = new list<String> {'Account Name'};
        MyDefaultValueFieldList = new list<String> {'FirstName'};
        MyDefaultValueTextList = new list<String> {'<default value>'};
    }
}