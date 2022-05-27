package assignment2;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Scanner;

public class Child extends Person{

	public Child(int id, String name, char gender, String dateOfBirth) {
		super(id, name, dateOfBirth, gender);
	}
	
	private static void getChildren(String parentName) {
		Connection conn = SQLFamily.connectSQL();     
        
        try {
        	ResultSet rs = null;
        	String sql = "SELECT name AS 'Child' FROM Persons INNER JOIN Family ON Persons.id=Family.person WHERE father = (SELECT id FROM Persons WHERE name = ?) OR mother = (SELECT id FROM Persons WHERE name = ?);";
            PreparedStatement pStmt = conn.prepareStatement(sql);
            pStmt.setString(1, parentName);
            pStmt.setString(2, parentName);
            rs = pStmt.executeQuery();
            
            System.out.println("QUERY SUCCESS!\n\n");
            
            System.out.println("Children of " + parentName + ": ");
            while(rs.next()) {
                System.out.print(rs.getString(1));
                System.out.println();
             }
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
	
	public static void main(String[] args) {
		Scanner scanner = new Scanner(System.in);
		System.out.print("Enter parent: ");
		String parentInput = scanner.nextLine();
		
		//Phil Dunphy
		getChildren(parentInput);
		scanner.close();
	}

}
