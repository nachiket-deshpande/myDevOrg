public with sharing virtual class PageControllerBase {

    //this is the controller for leadConvertCoreComponentController
    private ComponentControllerBase myComponentController;
    
    //this is the controller for leadConvertTaskInfoComponentController
    private ComponentControllerBase myTaskComponentController;
    
    //this is the controller for leadConvertRemindComponentController
    private ComponentControllerBase myReminderComponentController;
    
    //this is the controller for leadConvertTaskDescComponentController
    private ComponentControllerBase myDescriptionComponentController;

    // this method will return the leadConvertCoreComponentController. It is overridden in the LeadConverController class
    public virtual ComponentControllerBase getMyComponentController() {
        return myComponentController;
    }

    // this method will return the leadConvertTaskInfoComponentController. It is overridden in the LeadConverController class
    public virtual ComponentControllerBase getmyTaskComponentController() {
        return myTaskComponentController;
    }
  
    // this method will return the leadConvertRemindComponentController. It is overridden in the LeadConverController class
    public virtual ComponentControllerBase getmyReminderComponentController() {
        return myReminderComponentController;
    }
    
    // this method will return the leadConvertTaskDescComponentController. It is overridden in the LeadConverController class
    public virtual ComponentControllerBase getmyDescriptionComponentController() {

        return myDescriptionComponentController;
 
    }

    // this method will return the leadConvertTaskInfoComponentController. It is overridden in the LeadConverController class
    public virtual void setTaskComponentController(ComponentControllerBase compController) {
        myTaskComponentController = compController;
    }

    // this method will set the leadConvertCoreComponentController. It is overridden in the LeadConverController class
    public virtual void setComponentController(ComponentControllerBase compController) {
        myComponentController = compController;
    }
    
    // this method will set the leadConvertRemindComponentController. It is overridden in the LeadConverController class
    public virtual void setReminderComponentController(ComponentControllerBase compController) {
        myReminderComponentController = compController;
    }
    
    // this method will set the leadConvertTaskDescComponentController. It is overridden in the LeadConverController class
    public virtual void setDescriptionComponentController(ComponentControllerBase compController) {
        myDescriptionComponentController = compController;
    }

    // return the instance of this class
    public PageControllerBase getThis() {
        return this;
    }
}