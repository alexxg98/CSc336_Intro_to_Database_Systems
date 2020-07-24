package assignment2;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class Person implements SQLFamily{
	protected int id;
	protected String name;
	protected char gender;
	protected String dateOfBirth;
	
	public Person(int id, String name, String dateOfBirth, char gender) {
		this.id = id;
		this.name= name;
		this.dateOfBirth = dateOfBirth;
		this.gender = gender;
	}
	
	public void setPerson() {
		Connection conn = SQLFamily.connectSQL();
        
        try {
        	String sql = "INSERT INTO Persons VALUES (?, ?, ?, ?);";
            PreparedStatement pStmt = conn.prepareStatement(sql);
            pStmt.setInt(1, id);
            pStmt.setString(2, name);
            pStmt.setString(3, dateOfBirth);
            pStmt.setString(4, String.valueOf(gender));
            pStmt.executeUpdate();
            
            System.out.println("QUERY SUCCESS!\n\n");
        }
        catch (Exception e) {
     	   System.err.println ("Cannot execute query");
			   e.printStackTrace();
        }
		   
		   finally{
            if (conn != null){
                try{
					conn.close();					   
                    System.out.println("\nDatabase connection terminated...\n");
                }
                catch(Exception ex){
				   System.out.println ("Error in connection termination!");
				}
            }
        }
	}
	
	public int getIdPerson() {
		return id;
	}
	public String getNamePerson() {
		return name;
	}
	public char getGenderPerson() {
		return gender;
	}
	public String getDobPerson() {
		return dateOfBirth;
	}
	
	@Override
	public String toString() {
		return String.format("%d %s %s %s", id, name, dateOfBirth, gender);
	}
	
	public static void main(String[] args) {
		Person newPerson = new Person(26, "Example", "1111-11-11", 'M');
		newPerson.setPerson();
		System.out.print(newPerson.toString());
		//SQLFamily.setBrother_Sister();
	}
}
