public with sharing class ScheduleEditorController {

//    public List<LineItemAndScheduleWrapper> lstWrapper {get; set;}

    // Label for showing zero or positive value message for validation.
    private static String ZERO_OR_POSITIVE_VALUE_MESSAGE = 'Test';

    // id of current User
    private String currentUserId;
    // starting month of fiscal yearr
    public Integer fiscalYearStartMonth {get; set;}
    // maps of Opportunity to LineItem to Scheduled Month to List of Schedules
    public Map<String, Map<String, Map<String, List<OpportunityLineItemSchedule>>>> 
            mapOpportunityToMapLineItemToMapMonthToSchedules {get; set;}
    // maps Opportunity to List of LineItems to maintain order
    public Map<String, List<String>> mapOpportunityToLstLineItem {get; set;}
    // current Fiscal Year
    public Integer fiscalYear {get; set;}
    // List of months from current month to last month of current fiscal year
    public List<String> lstMonth {get; set;}
    // maps Id to Opportunity
    public Map<Id, Opportunity> mapOpportunity {get; set;}
    // maps Id to LineItem
    public Map<Id, String> mapOpportunityLineItemName {get; set;}
    // Opportunity to save child schedules
    public String opportunityId {get; set;}
    // LineItem to save child schedules
    public String lineItemId {get; set;}
    // total number of records
    public Integer totalRecords {get; set;}
    // total number of records shown on a page
    public Integer pageSize {get; set;}
    // total number of pages
    public Integer totalPages {get; set;}
    // current page number shown on page
    public Integer currentPage {get; set;}
    // boolean to show Quantity or Revenue schedules
    public Boolean showQuantityOrRevenue {get; set;}
    // boolean to show Quantity schedules
    public Boolean showQuantitySchedules {get; set;}
    // boolean to show Revenue schedules
    public Boolean showRevenueSchedules {get; set;}
    // list of LineItem Ids to be excluded in next page
    private List<String> lstLineItemId;

    /**
     * @description  Constructor for the class
     */
    public ScheduleEditorController(){
        init();
        fiscalYear = getCurrentFiscalYear();
        updateRecordCountAndMap();
    }

    /**
     * @description  Initializes class variables
     */
    public void init() {
        if (!Test.isRunningTest()) {
            currentUserId = UserInfo.getUserId();
        }
        system.debug('currentUserId = ' + currentUserId);
        mapOpportunityToMapLineItemToMapMonthToSchedules = 
            new Map<String, Map<String, Map<String, List<OpportunityLineItemSchedule>>>>();
        mapOpportunityToLstLineItem = new Map<String, List<String>>();
        mapOpportunity = new Map <Id, Opportunity>();
        mapOpportunityLineItemName = new Map <Id, String>();
        lstMonth = new List<String>();
        opportunityId = '';
        lineItemId = '';
        totalPages = 0;
        pageSize = 2;
        currentPage = 0;
        showQuantitySchedules = false;
        showRevenueSchedules = false;
        showQuantityOrRevenue = false;
    }

    /**
     * @description  Recalculates the count of records and fills the map again accordingly
     */
    public void updateRecordCountAndMap() {
        lstLineItemId = new List<String>();
        totalRecords = getCountOfRecords();
        fillMap();
    }

    /**
     * @description  Returns total Number of Line Item records for current User
     * @return  Integer Total Number of Line Item records for current User
     */
    private Integer getCountOfRecords() {
        String query = 'SELECT  Count() ' +
                       'FROM    OpportunityLineItem WHERE Id IN (   SELECT  OpportunityLineItemId ' +
                                                                  ' FROM    OpportunityLineItemSchedule ' +
                                                                  ' WHERE   FISCAL_YEAR(ScheduleDate) = :fiscalYear '// +
                                                                    /*'AND    ScheduleDate >= TODAY '*/;
        query += (showQuantityOrRevenue == true) ? 'AND Revenue != null) '
                                                 : 'AND Quantity != null) ';
        query += 'AND (NOT Opportunity.StageName LIKE \'%Closed%\') ';
        query += 'AND FISCAL_YEAR(Opportunity.CloseDate) = :fiscalYear ';
        query += (showQuantityOrRevenue == true) ? 'AND HasRevenueSchedule = true '
                                                 : 'AND HasQuantitySchedule = true ';
        query += (String.isNotBlank(currentUserId)) ? 'AND Opportunity.OwnerId = :currentUserId ' : '';
        //query +=    'AND Opportunity.OwnerId = :currentUserId ';
        system.debug('getCountOfRecords query = ' + query);
        try{
            Integer totalRecs = Database.countQuery(query);
            if (totalRecs > 0) {
                currentPage = 1;
            } else {
                currentPage = 0;
            }
            totalPages = totalRecs / pageSize;
            if (Math.mod(totalRecs, pageSize) > 0) {
                totalPages++;
            }
            return totalRecs;
        }catch(System.Exception excp){
            system.debug('query = ' + query);
            system.debug('excp = ' + excp);
            //ApexPages.addMessages(excp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, excp.getMessage() + ' in ' + query));
        }
        currentPage = 0;
        return 0;
    }

    /**
     * @description  Shows next Page of records in pagination
     */
    public void nextPage() {
        try{
            currentPage++;
            fillMap();
        } catch (System.Exception excp) {
            ApexPages.addMessages(excp);
        }
    }

    /**
     * @description  Shows previous Page of records in pagination
     */
    public void previousPage() {
        system.debug('lstLineItemId before = ' + lstLineItemId);
        Integer lstLineItemIdSize = lstLineItemId.size();
        Integer numberOfPages = lstLineItemIdSize / pageSize;
        Integer remainder = Math.mod(lstLineItemIdSize, pageSize);
        numberOfPages-=1;
        if (remainder <= 0) {
            numberOfPages-=1;
        }/* else {
            numberOfPages-=pageSize;
            
        }*/
        for (Integer i = lstLineItemIdSize-1; i >= (numberOfPages * pageSize) && i > 0; i--) {
                lstLineItemId.remove(i);
            }
            currentPage--;
        system.debug('lstLineItemId after = ' + lstLineItemId);
        fillMap();
    }

    /**
     * @description  Populates the maps to show schedule records
     */
    public void fillMap() {
        mapOpportunityToMapLineItemToMapMonthToSchedules = 
            new Map<String, Map<String, Map<String, List<OpportunityLineItemSchedule>>>>();
        mapOpportunityToLstLineItem = new Map<String, List<String>>();
        mapOpportunity = new Map <Id, Opportunity>();
        mapOpportunityLineItemName = new Map <Id, String>();
        system.debug('showQuantitySchedules = ' + showQuantitySchedules);
        system.debug('showRevenueSchedules = ' + showRevenueSchedules);
        
        String query = 'SELECT  Id, Name, OpportunityId, Opportunity.Name, Product2Id, Product2.Name, Quantity, ' + 
                                '(SELECT    Id, Quantity, Revenue, ScheduleDate FROM OpportunityLineItemSchedules ' +
                                'WHERE      FISCAL_YEAR(ScheduleDate) = :fiscalYear ';
        query += (showQuantityOrRevenue == true) ? 'AND Revenue != null '
                                                 : 'AND Quantity != null ';
        query +=                 'ORDER BY    ScheduleDate) ' +
                       'FROM    OpportunityLineItem WHERE Id IN (   SELECT  OpportunityLineItemId ' +
                                                                  ' FROM    OpportunityLineItemSchedule ' +
                                                                  ' WHERE   FISCAL_YEAR(ScheduleDate) = :fiscalYear '// + 
                                                                    /*'AND    ScheduleDate >= TODAY '*/;
        query += (showQuantityOrRevenue == true) ? 'AND Revenue != null) '
                                                 : 'AND Quantity != null) ';
        query += 'AND (NOT Opportunity.StageName LIKE \'%Closed%\') ';
        query += 'AND FISCAL_YEAR(Opportunity.CloseDate) = :fiscalYear ';
        query += (showQuantityOrRevenue == true) ? 'AND HasRevenueSchedule = true '
                                                 : 'AND HasQuantitySchedule = true ';
        query += (String.isNotBlank(currentUserId)) ? 'AND Opportunity.OwnerId = :currentUserId ' : '';
        //query +=    'AND Opportunity.OwnerId = :currentUserId ';
        query +=    'AND Id NOT IN :lstLineItemId ' +
                'ORDER BY    Opportunity.Name ASC, Product2.Name ASC, Id ASC ' +
                'LIMIT       :pageSize';
        
        system.debug('fillMap query = ' + query);
        for (OpportunityLineItem lineItem : Database.query(query)) {
            system.debug('lineItem.Opportunity.Name = ' + lineItem.Opportunity.Name);
            // Populate map to maintain order of Line Items
            List<String> lstLineItem = mapOpportunityToLstLineItem.get(lineItem.OpportunityId);
            if (lstLineItem == null) {
                lstLineItem = new List<String>{lineItem.Id};
            } else {
                lstLineItem.add(lineItem.Id);
            }
            mapOpportunityToLstLineItem.put(lineItem.OpportunityId, lstLineItem);

            // Populate the main map and link Opportunity to LineItem to Schedules
            for (OpportunityLineItemSchedule lineSchedule : lineItem.OpportunityLineItemSchedules) {
                Map<String, Map<String, List<OpportunityLineItemSchedule>>> mapLineItemToMapMonthToSchedules =
                mapOpportunityToMapLineItemToMapMonthToSchedules.get(lineItem.OpportunityId);
                if (mapLineItemToMapMonthToSchedules == null) {
                    mapLineItemToMapMonthToSchedules = new Map<String, Map<String, List<OpportunityLineItemSchedule>>>();
                    Map<String, List<OpportunityLineItemSchedule>> mapMonthToSchedules = 
                        new Map<String, List<OpportunityLineItemSchedule>>();
                    mapMonthToSchedules.put(month(lineSchedule.ScheduleDate.month()), 
                                            new List<OpportunityLineItemSchedule> {lineSchedule});
                    mapLineItemToMapMonthToSchedules.put(lineItem.Id, mapMonthToSchedules);
                    mapOpportunityToMapLineItemToMapMonthToSchedules.put(lineItem.OpportunityId,
                                                                        mapLineItemToMapMonthToSchedules);
                } else {
                    Map<String, List<OpportunityLineItemSchedule>> mapMonthToSchedules = 
                        mapLineItemToMapMonthToSchedules.get(lineItem.Id);
                    if (mapMonthToSchedules == null) {
                        mapMonthToSchedules = new Map<String, List<OpportunityLineItemSchedule>>();
                        mapMonthToSchedules.put(month(lineSchedule.ScheduleDate.month()), 
                                                new List<OpportunityLineItemSchedule> {lineSchedule});
                        mapLineItemToMapMonthToSchedules.put(lineItem.Id, mapMonthToSchedules);
                        mapOpportunityToMapLineItemToMapMonthToSchedules.put(lineItem.OpportunityId,
                                                                        mapLineItemToMapMonthToSchedules);
                    } else {
                        List<OpportunityLineItemSchedule> lstSchedule = 
                            mapMonthToSchedules.get(month(lineSchedule.ScheduleDate.month()));
                        if (lstSchedule == null) {
                            lstSchedule = new List<OpportunityLineItemSchedule>{lineSchedule};
                        } else {
                            lstSchedule.add(lineSchedule);
                        }
                        mapMonthToSchedules.put(month(lineSchedule.ScheduleDate.month()), lstSchedule);
                        mapLineItemToMapMonthToSchedules.put(lineItem.Id, mapMonthToSchedules);
                        mapOpportunityToMapLineItemToMapMonthToSchedules.put(lineItem.OpportunityId,
                                                                        mapLineItemToMapMonthToSchedules);
                    }
                }
            }
            mapOpportunityLineItemName.put(lineItem.Id, lineItem.Product2.Name);
            mapOpportunity.put(lineItem.OpportunityId, new Opportunity( Id = lineItem.OpportunityId,
                                                                        Name = lineItem.Opportunity.Name));
            lstLineItemId.add(lineItem.Id);
        }
        system.debug('mapOpportunityToMapLineItemToMapMonthToSchedules = ' + 
            mapOpportunityToMapLineItemToMapMonthToSchedules);
        system.debug('mapOpportunityToLstLineItem = ' + mapOpportunityToLstLineItem);
    }

    /**
     * @description  Saves the Schedule records
     */
    public void saveSchedules() {
        system.debug('opportunityId = ' + opportunityId);
        system.debug('lineItemId = ' + lineItemId);

        List<OpportunityLineItemSchedule> lstSchedule = new List<OpportunityLineItemSchedule>();
        if (String.isNotBlank(opportunityId)) { // If particular Opportunity is selected
            Map<String, Map<String, List<OpportunityLineItemSchedule>>> mapLineItemToMapMonthToSchedules = 
                mapOpportunityToMapLineItemToMapMonthToSchedules.get(opportunityId);
            if (mapLineItemToMapMonthToSchedules != null) {
                // If particular LineItem is selected
                if (mapOpportunityToMapLineItemToMapMonthToSchedules != null && String.isNotBlank(lineItemId)) {
                    Map<String, List<OpportunityLineItemSchedule>> mapMonthToSchedules = 
                        mapLineItemToMapMonthToSchedules.get(lineItemId);
                    if (mapMonthToSchedules != null) {
                        for (String month : mapMonthToSchedules.keySet()) {
                            for (OpportunityLineItemSchedule schedule : mapMonthToSchedules.get(month)) {
                                if (showQuantityOrRevenue) {
                                    if (schedule.Revenue == null || schedule.Revenue < 0) {
                                        ApexPages.addMessage(
                                            new ApexPages.Message(ApexPages.Severity.FATAL, ZERO_OR_POSITIVE_VALUE_MESSAGE)
                                        );
                                    }else{
                                        lstSchedule.add(schedule);
                                    }
                                }else{
                                    if (schedule.Quantity == null || schedule.Quantity < 0) {
                                        ApexPages.addMessage(
                                            new ApexPages.Message(ApexPages.Severity.FATAL, ZERO_OR_POSITIVE_VALUE_MESSAGE)
                                        );
                                    }else{
                                        lstSchedule.add(schedule);
                                    }
                                }
                            }
                        }
                    }
                } else {    // Save Schedules for all Line Items of selected Opportunity
                    for (String instLineItemId : mapLineItemToMapMonthToSchedules.keySet()) {
                        Map<String, List<OpportunityLineItemSchedule>> mapMonthToSchedules =
                            mapLineItemToMapMonthToSchedules.get(instLineItemId);
                        if (mapMonthToSchedules != null) {
                            for (String month : mapMonthToSchedules.keySet()) {
                                for (OpportunityLineItemSchedule schedule : mapMonthToSchedules.get(month)) {
                                    if (showQuantityOrRevenue) {
                                        if (schedule.Revenue == null || schedule.Revenue < 0) {
                                            ApexPages.addMessage(new ApexPages.Message(
                                                ApexPages.Severity.FATAL, ZERO_OR_POSITIVE_VALUE_MESSAGE
                                            ));
                                        }else{
                                            lstSchedule.add(schedule);
                                        }
                                    }else{
                                        if (schedule.Quantity == null || schedule.Quantity < 0) {
                                            ApexPages.addMessage(new ApexPages.Message(
                                                ApexPages.Severity.FATAL, ZERO_OR_POSITIVE_VALUE_MESSAGE
                                            ));
                                        }else{
                                            lstSchedule.add(schedule);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        } else {    // Save Schedules for all Line Items for all Opportunities
            for (String instOpportunityId : mapOpportunityToMapLineItemToMapMonthToSchedules.keySet()) {
                Map<String, Map<String, List<OpportunityLineItemSchedule>>> mapLineItemToMapMonthToSchedules = 
                        mapOpportunityToMapLineItemToMapMonthToSchedules.get(instOpportunityId);
                if (mapLineItemToMapMonthToSchedules != null) {
                    for (String instLineItemId : mapLineItemToMapMonthToSchedules.keySet()) {
                        Map<String, List<OpportunityLineItemSchedule>> mapMonthToSchedules =
                            mapLineItemToMapMonthToSchedules.get(instLineItemId);
                        if (mapMonthToSchedules != null) {
                            for (String month : mapMonthToSchedules.keySet()) {
                                for (OpportunityLineItemSchedule schedule : mapMonthToSchedules.get(month)) {
                                    if (showQuantityOrRevenue) {
                                        if (schedule.Revenue == null || schedule.Revenue < 0) {
                                            ApexPages.addMessage(new ApexPages.Message(
                                                ApexPages.Severity.FATAL, ZERO_OR_POSITIVE_VALUE_MESSAGE
                                            ));
                                        }else{
                                            lstSchedule.add(schedule);
                                        }
                                    }else{
                                        if (schedule.Quantity == null || schedule.Quantity < 0) {
                                            ApexPages.addMessage(new ApexPages.Message(
                                                ApexPages.Severity.FATAL, ZERO_OR_POSITIVE_VALUE_MESSAGE
                                            ));
                                        }else{
                                            lstSchedule.add(schedule);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        system.debug('lstSchedule size = ' + lstSchedule.size());
        system.debug('lstSchedule = ' + lstSchedule);
        try{
            update lstSchedule;
        }catch (System.DMLException dmlExcp) {
            ApexPages.addMessages(dmlExcp);
        }catch (System.Exception excp) {
            ApexPages.addMessages(excp);
        }
    }

    /**
     * @description  Calculates the current fiscal year and also sets the starting month for fiscal year
     * @return  Integer Current fiscal year 
     */
    private Integer getCurrentFiscalYear() {
        /*String currentFiscalYear = [SELECT  FiscalYearSettings.Name 
                                    FROM    Period 
                                    WHERE   Type = 'Year' 
                                        AND StartDate <= TODAY 
                                        AND EndDate >= TODAY].FiscalYearSettings.Name;*/
        String currentFiscalYear = '2017';
        system.debug('***currentFiscalYear***'+currentFiscalYear);
        Date today = Date.today();
        Organization organization = [   SELECT  FiscalYearStartMonth, 
                                                UsesStartDateAsFiscalYearName
                                        FROM    Organization LIMIT 1];
        Integer fiscalYearStartMonth = organization.FiscalYearStartMonth;
        lstMonth = getListOfMonthsFromMonth(fiscalYearStartMonth);
        Integer fiscalYear;
         if (today.month() < fiscalYearStartMonth
          || fiscalYearStartMonth == 1 ){
             fiscalYear = today.year();
         } else {
             fiscalYear = today.year()+1;
         }
         if (organization.UsesStartDateAsFiscalYearName) {
             fiscalYear--;
         }
         return fiscalYear;
    }

    /**
     * @description  Creates list of months from current month to ending month of fiscal year
     * @return  List<String> list of fiscal months from current month
     */
    private static List<String> getListOfMonthsFromMonth(Integer pFiscalYearStartMonth) {
        List<String> lstMonth = new List<String>();
        // add months from current to the end of calendar year
        for (Integer i = pFiscalYearStartMonth; i <=12; i++) {
            lstMonth.add(month(i));
        }
        // add months from the start of calendar year to current month
        for (Integer i = 1; i <pFiscalYearStartMonth; i++) {
            lstMonth.add(month(i));
        }
        system.debug('lstMonth = ' + lstMonth);
        return lstMonth;
    }

    /**
     * @description  Creates list of months from current month to ending month of fiscal year
     * @return  List<String> list of fiscal months from current month
     */
    public static String month(Integer pMonth) {
        if (pMonth == 1) {
            return 'JANUARY';
        } else if (pMonth == 2) {
            return 'FEBRUARY';
        } else if (pMonth == 3) {
            return 'MARCH';
        } else if (pMonth == 4) {
            return 'APRIL';
        } else if (pMonth == 5) {
            return 'MAY';
        } else if (pMonth == 6) {
            return 'JUNE';
        } else if (pMonth == 7) {
            return 'JULY';
        } else if (pMonth == 8) {
            return 'AUGUST';
        } else if (pMonth == 9) {
            return 'SEPTEMBER';
        } else if (pMonth == 10) {
            return 'OCTOBER';
        } else if (pMonth == 11) {
            return 'NOVEMBER';
        } else if (pMonth == 12) {
            return 'DECEMBER';
        } else {
            return '';
        }
    }
}