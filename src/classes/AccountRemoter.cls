global with sharing class AccountRemoter {

    public String accountName { get; set; }
    public static Contact contact { get; set; }
    public Contact objCon { get; set; }
    
    public AccountRemoter() {
        objCon = new Contact();
        wasd w = new wasd();
    }
    
    
    
    public class wasd {
        String wasd;
        
        public wasd(String str) {
            
        }
        public wasd() {
            
        }
    }
    
    @RemoteAction
    global static Sobject getAccount(String accountName) {
        contact = [SELECT Id, Name, AccountId 
                   FROM Contact WHERE Name = :accountName];
        return contact;
    }
}