public class PaginationController{
    private integer totalRecs = 0;     
    private integer index = 0;
    private integer blockSize = 5;         
    
    public PaginationController()
    {
        totalRecs = [select count() from Contact];        
    }    
    
    public List<Contact> getMemb() 
    {
        List<Contact> membs = Database.Query('SELECT Id, LastName FROM Contact  LIMIT :blockSize OFFSET :index');
        System.debug('Values are ' + membs);
        return membs;
    }    
    
    public void beginning()
    {
        index = 0;
    }
    
    public void previous()
    {
        index = index - blockSize;
    }
    
    public void next()
    {
        index = index + blockSize;
    }

    public void end()
    {
        index = totalrecs - math.mod(totalRecs,blockSize);
    }        
    
    public boolean getprev()
    {
        if(index == 0)
        return true;
        else
        return false;
    }  
    
    public boolean getnxt()
    {
        if((index + blockSize) > totalRecs)
        return true;
        else
        return false;
    }         
}