/**
 * Created by Leonid Bartenev
 */

public class AuraHelper {

    public static Object throwException(Exception e){
        String errorMessage = e.getMessage() + '\n' + e.getStackTraceString();
        System.debug('THROW EXCEPTION: ' + errorMessage);
        Exception auraException = new AuraHandledException(errorMessage);
        auraException.setMessage(errorMessage);
        throw auraException;
    }

}