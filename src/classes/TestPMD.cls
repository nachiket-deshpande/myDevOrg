public with sharing class TestPMD {
    public Integer SUM (Integer a,Integer b){return a+b;}
    
    public static void main(String[] args){
        TestPMD m = new TestPMD();
        system.debug(m.SUM(5,6));
        List<Account> accountList = [Select Id,Name From Account];
        for(Account objAccount : accountList){
            List<Account> accountList1 = [Select Id,Name From Account];
            insert accountList1;
        }
    }
}