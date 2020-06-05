## Tooling API 


1) Tooling API can be used in current context if sessionId available (communication between user and server). 
    For this case you don't need an additional setup, and you can execute only with method executeInCurrentSession().
    
    Example execution of code in anonymous with a current session:
    
    ```java
    String code = 'System.debug(\'Hello world!\');'
    new ToolingAPI_ExecuteAnonymous().executeInCurrentSession(code);
    
    ```

2) If sessionId not available in current context (any async execution like batches, schedule, future, queueable)
    For these cases you need first setup named credential fot connect Salesforce to itself. Setup will be described below. 
    And you can use only method execute(), method executeInCurrentSession() not available in these cases.
    
    Example execution of code in anonymous in async context:
    
    ```java
    String code = 'System.debug(\'Hello world!\');'
    new ToolingAPI_ExecuteAnonymous().execute(code);

    ```
   

### Setup named credential for use Tooling API without current sessionId:

#### 1. Create Connected App in Salesforce:
 - In setup open 'App Manager' > New Connected App button > enter below fields:
 - Connected App Name: 
 - API Name:
 - Contact Email: any email for contact
 - enable a checkbox 'Enable OAuth Settings'
 - Callback URL: https://dummy.com
 - Selected OAuth Scopes: select all and move to right
 - press Save

#### 2. Create Authentication Provider:
 - In setup open in a new tab 'Auth. Providers' > New >  enter below fields:
 - Provider Type: Salesforce
 - Name: SF AP
 - URL Suffix: SF_AP
 - Consumer Key: copy value from created Connected App before
 - Consumer Secret: copy value from created Connected App before
 - Default Scopes: full refresh_token offline_access
 - Registration Handler: click on 'Automatically create a registration handler template'
 - click save
 - copy Callback URL to the clipboard 

#### 3. Update Callback URL in Connected APP:
 - return to your Authentication Provider, press enter and paste to Callback URL field value from clipboard
 - click save and wait 10 minutes

#### 4. Create Named Credential:
 - In setup open 'Named Credentials' > new
 - Label: Salesforce Credential
 - Name: Salesforce_Credential
 - URL: in setup search enter 'domains'and open in a new tab > find my domain and copy url to clipboard, 
   return to a named credential and paste url, add 'https://' before url value
 - Identity Type: Named Principal
 - Authentication Protocol OAuth 2.0
 - Authentication Provider: SF AP
 - Scope: full refresh_token offline_access
 - Start Authentication Flow on Save: checked
 - click Save
 - you will be redirected to login page, login to this org and press 'Allow' button
 - after save Authentication Status must be: Authenticated as yourUser@email.com 
 - NamedCredential setup complete


## Extend functionality

Now implemented only several functions.
You can implement new one. 
Every function - new class with prefix 'ToolingApi_' and then name of function you want to add from Tooling API. 
This class must be extended from ToolingAPIAbstract which contains base functionality for send data and parse response.
In the constructor of your new class must be defined httpMethod and endPointURL:   

```java
this.httpMethod = 'GET or POST method depends on your case...' 
this.endPointURL = 'Some endpoint of tooling api service';
```

You must implement methods for building request and parsing response. Build request method must create JSON with data, 
structure of this JSON described for concrete endpoint in Tooling API docs. If used GET method then buildResponse must return null!
Method parserResponse must parse server response if needed, or you can leave  it empty and just return null:


```java
protected override String buildRequestBody() {
    return JSON.serialize(someObjectWithData);
}
  
protected override Object parseResponse(String responseBody) {
    //do nothing
    return null;
}
```