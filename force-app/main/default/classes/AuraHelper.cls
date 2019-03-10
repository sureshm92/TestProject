/**
 * Created by Leonid Bartenev
 */

public class AuraHelper {
    
    public static void throwException(Exception e){
        throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
    } 

}