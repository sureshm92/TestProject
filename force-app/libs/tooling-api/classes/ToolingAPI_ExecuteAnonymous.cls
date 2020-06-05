/**
 * Created by Leonid Bartenev
 */

public without sharing class ToolingAPI_ExecuteAnonymous extends ToolingAPIAbstract{
    
    public static final String ENDPOINT_ANONYMOUS_EXECUTION = '/services/data/v39.0/tooling/executeAnonymous/?anonymousBody=';
    
    public class ExecutionResult{
        public Integer line;
        public Integer column;
        public Boolean compiled;
        public Boolean success;
        public String compileProblem;
        public String exceptionStackTrace;
        public String exceptionMessage;
    }
    
    
    public ToolingAPI_ExecuteAnonymous(String code){
        this.endPointURL = ENDPOINT_ANONYMOUS_EXECUTION + EncodingUtil.urlEncode(code, 'UTF-8');
    }
    
    protected override String buildRequestBody() {
        return null;
    }
    
    protected override Object parseResponse(String responseBody) {
        ExecutionResult execResult = (ExecutionResult)JSON.deserialize(responseBody, ExecutionResult.class);
        if(!execResult.compiled){
            throw new ToolingAPIServiceException('Can not compile (line '+ execResult.line + ', column ' + execResult.column + '): '
                    + execResult.compileProblem);
        }else if(!execResult.success){
            throw new ToolingAPIServiceException('Execution error(line '+ execResult.line + ', column ' + execResult.column + '): '
                
                    + execResult.exceptionMessage + '; \n' + execResult.exceptionStackTrace);
        }
        return execResult;
    }
}