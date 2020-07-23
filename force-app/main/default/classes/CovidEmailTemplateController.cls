public without sharing class CovidEmailTemplateController 
{
    public static final String nybcLogoDocument = 'Nybc_logo';
    public String fileName { get; set; }
    
    public String getImageUrl() 
    {
        List<Document> doc = [SELECT Id, LastModifiedDate FROM Document WHERE DeveloperName = :nybcLogoDocument Limit 1];
        if(doc == null)
        {
            return null;
        }
        else
        {
            return Url.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id='+doc[0].Id+
                '&oid='+UserInfo.getOrganizationId();
        }  
    }
}