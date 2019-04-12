/**
 * Created by Leonid Bartenev
 */

public class DatabaseService {
    
    private static DatabaseService instance;
    
    public static DatabaseService getInstance(){
        if(instance == null) instance = new DatabaseService();
        return instance;
    }
    
    public static void setMock(StubProvider stubProvider){
        instance = (DatabaseService) Test.createStub(DatabaseService.class, stubProvider);
    }
    
    public List<SObject> query(String query) {
        return Database.query(query);
    }
    
}