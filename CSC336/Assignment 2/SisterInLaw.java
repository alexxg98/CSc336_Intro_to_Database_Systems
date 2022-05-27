package assignment2;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Scanner;

public class SisterInLaw extends Person{

	public SisterInLaw(int id, String name, char gender, String dateOfBirth) {
		super(id, name, dateOfBirth, gender);
	}
	
	private static void getSisInLaws(String person) {
		Connection conn = SQLFamily.connectSQL();      
        
        try {
        	ResultSet rs = null;
        	ResultSet rs2 = null;
        	int personID = 0;
        	String getPersonId = "SELECT id FROM Persons WHERE name=?;";
        	PreparedStatement pStmt2 = conn.prepareStatement(getPersonId);
        	pStmt2.setString(1, person);
            rs2 = pStmt2.executeQuery();
            while(rs2.next()) {
                personID = rs2.getInt(1);
             }
        	
        	String sql = "SELECT name FROM Persons WHERE id IN (SELECT b FROM Husband_Wife WHERE a IN (SELECT c FROM Brothers WHERE d=?) OR a IN (SELECT e FROM Brother_Sister WHERE f=?) OR a IN (SELECT c FROM Brothers WHERE d IN (SELECT a FROM Husband_Wife WHERE b=?)) OR a in (SELECT e FROM Brother_Sister WHERE f IN (SELECT b FROM Husband_Wife WHERE a=?) UNION SELECT f FROM Brother_Sister WHERE e IN (SELECT a FROM Husband_Wife WHERE b = ?) UNION SELECT g FROM Sisters WHERE h IN (SELECT b FROM Husband_Wife WHERE a = ?)));";
            PreparedStatement pStmt = conn.prepareStatement(sql);
            pStmt.setInt(1, personID);
            pStmt.setInt(2, personID);
            pStmt.setInt(3, personID);
            pStmt.setInt(4, personID);
            pStmt.setInt(5, personID);
            pStmt.setInt(6, personID);
            rs = pStmt.executeQuery();
            
            System.out.println("QUERY SUCCESS!\n\n");
                        
            System.out.println("Sisters-in-law of " + person + ": ");
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
		System.out.print("Enter person: ");
		String personInput = scanner.nextLine();
		
		//Guy Tucker, Claire Dunphy
		//Cameron Tucker
		//Mitchell Pritchett
		getSisInLaws(personInput);
		scanner.close();
	}
}
