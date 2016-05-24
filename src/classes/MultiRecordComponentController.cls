public with sharing class MultiRecordComponentController {
    public Boolean AllowAdd {get; set;}
    public Boolean AllowEdit {get; set;}
    public Boolean AllowDelete {get; set;}
    public String ParentRecId {get; set;}
    public String RelationField {get; set;}
    public String OrderByField {get; set;}
    public list<String> FieldList {get; set;}
    public String sObjectType {get; set;}
    public list<String> LabelOverrideFieldList {get; set;}
    public list<String> LabelOverrideTextList {get; set;}
    private map<String, String> LabelOverrideMap;
    public list<String> DefaultValueFieldList {get; set;}
    public list<String> DefaultValueTextList {get; set;}
    private map<String, String> DefaultValueMap;
    public Boolean DisableSave {get; set;}
    public Boolean DisableCancel {get; set;}
    public String ActionId {get; set;}
    public list<ObjectWrapper> ObjectList {get; set;}
    private list<ColumnWrapper> ColumnWrapList;
    public String ActionRowNumber {get; set;}
    private Integer AddedRowCount;
    
    public MultiRecordComponentController() {
        DisableSave = true;
        DisableCancel = true;
        AddedRowCount = 0;
    }

    /***
    * ColumnList - get/set methods. get initializes columns and list entries on first load
    ***/
    public list<ColumnWrapper> ColumnList {
        get {
            if (ColumnWrapList == null) {
                InitValues();
                // load fields for table columns
                ColumnWrapList = LoadColumnList(sObjectType, FieldList, LabelOverrideMap);
                // load records in the table
                ObjectList = LoadObjectList(ParentRecId, sObjectType, FieldList, RelationField, OrderByField);
            }
            return ColumnWrapList;
        }
        set;
    }

    /***
    * InitValues - initialize maps with list data
    ***/
    public void InitValues() {
        // convert field label override lists to a map for easier lookup
        // Salesforce apex:attribute of type map doesn't current work properly.
        // this can updated to a map when/if SF fixes the attribute for maps
        LabelOverrideMap = new map<String, String>();
        if (LabelOverrideFieldList != null && LabelOverrideTextList != null) {
            system.debug(LabelOverrideFieldList + ':::' + LabelOverrideTextList);
            for (Integer i=0; i < LabelOverrideFieldList.size(); i++) {
                if (i < LabelOverrideTextList.size()) {
                    LabelOverrideMap.put(LabelOverrideFieldList[i], LabelOverrideTextList[i]);
                }
            }
        }
        system.debug('LabelOverrideMap' + LabelOverrideMap);
        
        DefaultValueMap = new map<String, String>();
        if (DefaultValueFieldList != null && DefaultValueTextList != null) {
            system.debug(DefaultValueFieldList + ':::' + DefaultValueTextList);
            for (Integer i=0; i < DefaultValueFieldList.size(); i++) {
                if (i < DefaultValueTextList.size()) {
                    DefaultValueMap.put(DefaultValueFieldList[i], DefaultValueTextList[i]);
                }
            }
        }
        system.debug('DefaultValueMap' + DefaultValueMap);
    }
    
    /***
    * DoAdd - add a record to the list
    ***/
    public void DoAdd() {
        DisableSave = false;
        DisableCancel = false;
        ObjectWrapper TmpObjWrap = new ObjectWrapper(Schema.getGlobalDescribe().get(sObjectType).newSObject(), true);
        TmpObjWrap.obj.put(RelationField, ParentRecId);
        for (String s : DefaultValueMap.keySet()) {
            TmpObjWrap.obj.put(s, DefaultValueMap.get(s));
        }
        AddedRowCount += 1;
        TmpObjWrap.AddedRowNumber = String.valueOf(AddedRowCount);
        ObjectList.add( TmpObjWrap );
    }

    /***
    * DoCancel - remove added lines and change lines back to display mode
    ***/
    public void DoCancel() {
        DisableSave = true;
        DisableCancel = true;
        for (Integer i=0; i < ObjectList.size(); i++) {
            // remove added lines that were not saved
            if (ObjectList[i].obj.Id == null) {
                ObjectList.remove(i);
                i--;
                continue;
            }
            // change to display mode
            ObjectList[i].IsEditMode = false;
        }
    }
    
    /***
    * DoSave - Save edited and added records. then refresh/requery the list
    ***/
    public void DoSave() {
        DisableSave = true;
        DisableCancel = true;
        list<sObject> UpdateList = new list<sObject>();
        list<sObject> InsertList = new list<sObject>();
        for (ObjectWrapper o : ObjectList) {
            if (o.IsEditMode == true) {
                if (o.obj.Id == null) {
                    InsertList.add(o.obj);
                } else {
                    UpdateList.add(o.obj);
                }
            }
        }
        System.Savepoint sp1 = Database.setSavepoint();
        try {
            system.debug('UpdateList: ' + UpdateList);
            system.debug('InsertList: ' + InsertList);
            if (UpdateList.size() > 0) {
                update UpdateList;
            }
            if (InsertList.size() > 0) {
                insert InsertList;
            }
        } catch (System.DmlException e) {
            system.debug('error: ' + e);
            Database.rollback(sp1);
            for (Integer i=0; i < e.getNumDml(); i++) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getDmlMessage(i)));
            }
            return;
        } catch (exception e) {
            system.debug('error: ' + e);
            Database.rollback(sp1);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An error updating the records: ' + e.getMessage()));
            return;
        }
        // requery in case field list contains fields referencing related objects
        if (UpdateList.size() > 0 || InsertList.size() > 0) {
            ObjectList.clear();
            ObjectList = LoadObjectList(ParentRecId, sObjectType, FieldList, RelationField, OrderByField);
        }
    }
    
    /***
    * DoDelete - delete the selected record
    ***/
    public void DoDelete() {
        if (ActionId == null || ActionId.trim().length() == 0) {
            return;
        }
        try {
            database.delete(ActionId);
            for (Integer i=0; i < ObjectList.size(); i++) {
                if (ActionId == ObjectList[i].obj.Id) {
                    ObjectList.remove(i);
                    break;
                }
            }
        } catch (exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        }
        ActionId = null;
        return;
    }

    /***
    * DoRemove - remove usaved added rows of the list
    ***/
    public void DoRemove() {
        if (ActionRowNumber == null || ActionRowNumber.trim().length() == 0) {
            return;
        }
        for (Integer i=0; i < ObjectList.size(); i++) {
            if (ActionRowNumber == ObjectList[i].AddedRowNumber) {
                ObjectList.remove(i);
                break;
            }
        }
        ActionRowNumber = null;
        return;
    }
    
    /***
    * DoEdit - dispaly a record with editable fields
    ***/
    public void DoEdit() {
        if (ActionId == null || ActionId.trim().length() == 0) {
            return;
        }
        DisableSave = false;
        DisableCancel = false;
        for (ObjectWrapper o : ObjectList) {
            if (o.obj.Id != null && ActionId == o.obj.Id) {
                o.IsEditMode = true;
                break;
            }
        }
        ActionId = null;
        return;
    }
    
    /***
    * LoadObjectList - query the object, and load results into the object wrapper list
    ***/
    public static list<ObjectWrapper> LoadObjectList(String InitRecId, String InitSObj, list<String> InitFieldList, String InitRelField, String InitOrderByField) {
        list<ObjectWrapper> ObjWrapList = new list<ObjectWrapper>();
        list<String> QueryFieldList = new list<String>();
        set<String> QueryFieldSet = new set<String>();
        
        // add id to field
        QueryFieldList.addAll(InitFieldList);
        QueryFieldSet.addAll(InitFieldList);
        if (QueryFieldSet.contains('id')) {
            QueryFieldList.add('id');
        }
        
        if (InitOrderByField == null || InitOrderByField.trim().length() == 0) {
            InitOrderByField = 'CreatedDate';
        }
        String TmpQuery;
        TmpQuery = 'Select ' + String.escapeSingleQuotes( String.join(QueryFieldList,', ') )+ 
                    ' From ' + String.escapeSingleQuotes( InitSObj ) + 
                    ' Where ' + String.escapeSingleQuotes( InitRelField ) + '=\'' + String.escapeSingleQuotes( InitRecId ) + '\'' + 
                    ' Order by ' + String.escapeSingleQuotes( InitOrderByField ) +
                    ' limit 1000';
        system.debug('Query: ' + TmpQuery);
                
        list<sObject> TmpObjectList = database.query(TmpQuery);
        for (sObject o : TmpObjectList) {
            ObjWrapList.add(new ObjectWrapper(o, false));
        }
        return ObjWrapList;
    }
    
    /***
    * LoadColumnList - load properties for columns to display into a list
    ***/
    public static list<ColumnWrapper> LoadColumnList(String InitSObj, list<String> InitFieldList, map<String, String> LabelOverrideMap) {
        list<ColumnWrapper> TmpColumnList = new list<ColumnWrapper>();
        system.debug('sObj:' + InitSObj);
        // map of fields for the object
        map<String, Schema.sObjectField> FieldMap = Schema.getGlobalDescribe().get(InitSObj).getDescribe().fields.getMap();
        
        for (String s : InitFieldList) {
            Schema.sObjectField FieldObj;
            Schema.DescribeFieldResult DescField;
            String TmpLabel;
            Boolean TmpIsEditable;
            Boolean TmpIsObjField;
            
            // check override label
            
            // check read only ************************************************************ 
            // defaults
            TmpIsEditable = false;
            TmpIsObjField = false;
            TmpLabel = s;

            // fields of the object retrieve label and permissions, related object fields do not
            FieldObj = FieldMap.get(s);
            if (FieldObj != null) {
                DescField = FieldObj.getDescribe();
                if (DescField != null) {
                    if (DescField.isAccessible() == false) {
                        system.debug('Field: ' + s + ' is not accessable for the user. Field ignored.');
                        continue;
                    }
                
                    if (DescField.isUpdateable() == true && DescField.isCreateable() == true) {
                        TmpIsEditable = true;
                    }
                    TmpLabel = FieldObj.getDescribe().getLabel();
                    TmpIsObjField = true;
                }
            }
            
            // use override label when found
            if (LabelOverrideMap.containsKey(s) == true) {
                    TmpLabel = LabelOverrideMap.get(s);
            }
                
            TmpColumnList.add(new ColumnWrapper(s, TmpLabel, TmpIsEditable, TmpIsObjField));
        }
        system.debug('ColumnList: ' + TmpColumnList);
        return TmpColumnList;
    }
    
    /***
    * ColumnWrapper - subclass for field properties of columns that will be displayed in the list
    ***/
    public class ColumnWrapper { 
        public String FieldName {get; set;}
        public String FieldLabel {get; set;}
        public Boolean IsEditable {get; set;}
        public Boolean IsObjField {get; set;}
        
        public ColumnWrapper(String FieldName, String FieldLabel, Boolean IsEditable, Boolean IsObjField) {
            this.FieldName = FieldName; 
            this.FieldLabel = FieldLabel;
            this.IsEditable = IsEditable;
            this.IsObjField = IsObjField;
        }
    }
    
    /***
    * ObjectWrapper - subclass for the sObject record with additional properties
    ***/
    public class ObjectWrapper { 
        public sObject obj {get; set;}
        public Boolean IsEditMode {get; set;}
        public String AddedRowNumber {get; set;}
        
        public ObjectWrapper(sObject obj, Boolean IsEditMode) {
            this.obj = obj;
            this.IsEditMode = IsEditMode;
        }
    }
}