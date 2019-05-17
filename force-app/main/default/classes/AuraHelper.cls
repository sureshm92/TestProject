/**
 * Created by Leonid Bartenev
 */

public class AuraHelper {
    
    public static Object throwException(Exception e){
        System.debug('THROW EXCEPTION: ' + e.getMessage() + '\n' + e.getStackTraceString());
        throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
    }
}