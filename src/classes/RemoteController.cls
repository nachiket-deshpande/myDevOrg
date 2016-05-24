public class RemoteController{

	public static Integer IPAGE_SIZE {get;set;}
	public static Integer lastRowIndex = 0;
	public static Integer iTotalNoOfStudent { get; set; }
	public Integer iCurrentPageNo { get; set; }
	
	public RemoteController(){
	   iTotalNoOfStudent = [select count() from Contact]; // Total NNumber Of Record
	}

	@RemoteAction
	public static String studentDetails(Integer iCurrentPageNo,Integer limitSize )
	{
		String studentDetails='';
		Integer iOff_Set =((iCurrentPageNo)* limitSize );
		List<Contact> lstStudent;
		List<studentWrapper> lstStudentWrapper;
		try
		{
			lstStudent = new List<Contact>();
			lstStudentWrapper = new List<studentWrapper>();
			lstStudent = [select FirstName,LastName from Contact order by LastModifiedDate limit :limitSize OFFSET: iOff_Set ];
			++lastRowIndex ;
		if(lstStudent.size()>0)
		{
			for(Contact student : lstStudent)
			{
			     lstStudentWrapper.add(new studentWrapper(++iOff_Set,student));
			}
		}
		StudentDetails = JSON.serialize(lstStudentWrapper);
		return StudentDetails ;
		}
		catch(exception ex)
		{
			system.debug('Exception :'+ex);
			return studentDetails;
		}
	}

	public class studentWrapper
	{
	public String studentName {get; set;}
	public String className {get; set;}
	public Integer rowIndex {get;set;}
	public studentWrapper (Integer RowIndex,Contact student)
	{
	this.studentName = student.FirstName;
	this.className = student.LastName;
	this.rowIndex = RowIndex;
	}
	}
}