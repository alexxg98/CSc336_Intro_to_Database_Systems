package assignment2;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.Statement;

public interface SQLFamily {
	public static Connection connectSQL() {
		Connection conn = null;
        try{
     	   Class.forName("com.mysql.cj.jdbc.Driver");
            String userName = "root";
            String password = "cscD@t@Bas3";
            String url = "jdbc:MySQL://localhost/assignment2";        
            conn = DriverManager.getConnection (url, userName, password);
            System.out.println("\nDatabase Connection Established...\n");
        }
       catch (Exception ex){
		       System.err.println ("Cannot connect to database server");
			   ex.printStackTrace();
        }
        return conn;
	}
	
	public void setPerson();
	
	public static void setFamily(int person, int father, int mother) {
		Connection conn = connectSQL();
		try {
			String sql = "INSERT INTO Family VALUES (?, ?, ?);";
	        PreparedStatement pStmt = conn.prepareStatement(sql);
	        pStmt.setInt(1, person);
	        pStmt.setInt(2, father);
	        pStmt.setInt(3, mother);
	        pStmt.executeUpdate();

	        System.out.println("QUERY SUCCESS!\n");
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
	public static void setHusband_Wife(int husband, int wife) {
		Connection conn = connectSQL();
		try {
			String sql = "INSERT INTO Family VALUES (?, ?);";
	        PreparedStatement pStmt = conn.prepareStatement(sql);
	        pStmt.setInt(1, husband);
	        pStmt.setInt(2, wife);
	        pStmt.executeUpdate();

	        System.out.println("QUERY SUCCESS!\n");
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
	public static void setBrothers() {
		Connection conn = connectSQL();
		try {
        	String sql = "INSERT INTO Brothers SELECT f1.person AS 'c', f2.person AS 'd' FROM (SELECT * FROM Family WHERE person IN (SELECT id FROM Persons WHERE gender = 'M')) f1, (SELECT * FROM Family WHERE person IN (SELECT id FROM Persons WHERE gender = 'M')) f2 WHERE f1.father=f2.father AND f1.mother=f2.mother AND NOT f1.person=f2.person;";
        	Statement stmt  = conn.createStatement();
            stmt.executeUpdate(sql);

            System.out.println("QUERY SUCCESS!\n");
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
	public static void setSisters() {
		Connection conn = connectSQL();
		try {
        	String sql = "INSERT INTO Sisters SELECT f1.person AS 'g', f2.person AS 'h' FROM (SELECT * FROM Family WHERE person IN (SELECT id FROM Persons WHERE gender = 'F')) f1, (SELECT * FROM Family WHERE person IN (SELECT id FROM Persons WHERE gender = 'F')) f2 WHERE f1.father=f2.father AND f1.mother=f2.mother AND NOT f1.person=f2.person;";
        	Statement stmt  = conn.createStatement();
            stmt.executeUpdate(sql);

            System.out.println("QUERY SUCCESS!\n");
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
	public static void setBrother_Sister() {
		Connection conn = connectSQL();
		try {
        	String sql = "INSERT INTO Brother_Sister SELECT f1.person AS 'e', f2.person AS 'f' FROM (SELECT * FROM Family WHERE person IN (SELECT id FROM Persons WHERE gender = 'M')) f1, (SELECT * FROM Family WHERE person IN (SELECT id FROM Persons WHERE gender = 'F')) f2 WHERE f1.father=f2.father AND f1.mother=f2.mother AND NOT f1.person=f2.person;";
        	Statement stmt  = conn.createStatement();
            stmt.executeUpdate(sql);

            System.out.println("QUERY SUCCESS!\n");
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
}
