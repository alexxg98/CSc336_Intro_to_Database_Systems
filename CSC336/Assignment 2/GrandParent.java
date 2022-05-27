package assignment2;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Scanner;

public class GrandParent extends Person{

	public GrandParent(int id, String name, char gender, String dateOfBirth) {
		super(id, name, dateOfBirth, gender);
	}
	
	private static void getGrandparents(String grandchildName) {
		Connection conn = SQLFamily.connectSQL();    
        
        try {
        	ResultSet rs = null;
        	String sql = "SELECT (SELECT name FROM Persons WHERE id = p.person) AS 'Person', (SELECT name FROM Persons WHERE id = m.mother) AS 'Maternal Grandmother', (SELECT name FROM Persons WHERE id = m.father) AS 'Maternal Grandfather', (SELECT name FROM Persons WHERE id = f.mother) AS 'Paternal Grandmother', (SELECT name FROM Persons WHERE id = f.father) AS 'Paternal Grandfather' FROM (FAMILY p INNER JOIN Family m ON p.mother = m.person INNER JOIN Family f ON p.father = f.person) WHERE p.person IN (SELECT id FROM Persons WHERE name = ?); ";
            PreparedStatement pStmt = conn.prepareStatement(sql);
            pStmt.setString(1, grandchildName);
            rs = pStmt.executeQuery();
            
            System.out.println("QUERY SUCCESS!\n\n");
            
            System.out.println("Grandparents of " + grandchildName + ": ");
            System.out.println("Maternal Grandmother \tMaternal Grandfather \tPaternal Grandmother \tPaternal Grandfather");
            while(rs.next()) {
                System.out.print(rs.getString(2));
                System.out.print("\t" + rs.getString(3));
                System.out.print("\t\t" + rs.getString(4));
                System.out.print("\t\t" + rs.getString(5));
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
		System.out.print("Enter grandchild: ");
		String gcInput = scanner.nextLine();
		
		//Alex Dunphy
		getGrandparents(gcInput);
		scanner.close();
	}

}
