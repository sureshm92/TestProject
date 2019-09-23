/**
 * Created by Slav on 21.08.2019.
 */

@IsTest
public class Test_DeploymentContext {
    
    @IsTest
    public static void runTest () {
        DeploymentContext.onInstall();
        DeploymentContext.getHandlers();
    }

}