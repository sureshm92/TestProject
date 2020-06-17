/**
 * Created by Igor Malyuta on 15.06.2020.
 */
global without sharing class TemplateLinkController {

    global String linkLabelValue { get; set; }
    global String urlValue {
        get {
            String resultUrl = urlValue;
            if(String.isNotEmpty(urlValue) && urlValue.startsWith('##')) {
                resultUrl = EmailTemplateProviderService.getProvider().getParameters().get(resultUrl.substring(2));
            }
            return resultUrl;
        }
        set;
    }
}