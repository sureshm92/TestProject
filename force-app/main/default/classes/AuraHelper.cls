/**
 * Created by Leonid Bartenev
 */

public class AuraHelper {
    
    public static Object throwException(Exception e){
        System.debug('THROW EXCEPTION: ' + e.getMessage() + '\n' + e.getStackTraceString());
        String errorMessage = e.getMessage() + '\n' + e.getStackTraceString();
        Exception newException = new AuraHandledException(errorMessage);
        newException.setMessage(errorMessage);
        throw newException;
    }
}