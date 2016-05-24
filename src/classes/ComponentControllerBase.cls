public with sharing virtual class ComponentControllerBase {

    // This gets set in the leadConvertCoreComponent's attribute
    public PageControllerBase pageController { get;

        set {
          if (value != null) {
            pageController = value;
            pageController.setComponentController(this);
          }
        }
    }
    
    // This gets set in the leadConvertTaskInfoComponent's attribute
    public PageControllerBase pageControllerTask { get;

        set {
    
          if (value != null) {
    
            pageControllerTask = value;
        
            pageControllerTask.setTaskComponentController(this);
          
    
          }
    
        }

    }

    // This gets set in the leadConvertTaskDescComponent's attribute
    public PageControllerBase pageControllerDescription{ get;

        set {
    
          if (value != null) {
    
            pageControllerDescription = value;
        
            pageControllerDescription.setDescriptionComponentController(this);
          
    
          }

        }   
    }

    // This gets set in the leadConvertTaskRemindComponent's attribute    
    public PageControllerBase pageControllerReminder{ get;

        set {

            if (value != null) {

            pageControllerReminder = value;
        
            pageControllerReminder.setReminderComponentController(this);
          
    
          }
    
        }

    }
}