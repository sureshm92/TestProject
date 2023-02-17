/**
 * Created by Leonid Bartenev
 */

public without sharing class ParametrizedMessageService {
    public class ParametrizedMessage {
        private String sourceMessage;
        private String paramProviderName;
        private Id whatId;
        private String language;
        private String resultMessage;
        private SObject sobj;

        public ParametrizedMessage(
            String sourceMessage,
            Id whatId,
            String paramProviderName,
            String language
        ) {
            this.sourceMessage = TranslateHelper.getLabelValue(sourceMessage, language);
            this.whatId = whatId;
            this.paramProviderName = paramProviderName;
            this.language = language;
        }

        public String getMessage() {
            if (resultMessage == null)
                resultMessage = sourceMessage;
            return resultMessage;
        }

        public void setSObject(SObject sobj) {
            resultMessage = null;
            list<User> userObj;
            if (sobj == null)
                return;
            if (sourceMessage == null)
                return;
            ParametersProviderService.Parameters parameters = ParametersProviderService.getParamsMap(
                paramProviderName
            );
            Map<String, String> paramsMap = parameters.parametersMap;
            Map<String, String> alternateParamsMap = parameters.parametersAlternateSourceMap;
            Map<String, String> valuesMap = new Map<String, String>();

            if (paramsMap.get('ContactID') != null) {
                Object contactIdValue = SObjectHelper.getSObjectFieldValue(
                    sobj,
                    paramsMap.get('ContactID')
                );
                if (contactIdValue != null) {
                    userObj = [
                        SELECT Id, LocaleSidKey, TimeZoneSidKey
                        FROM User
                        WHERE ContactId = :contactIdValue + ''
                    ];
                }
            }

            for (String paramName : paramsMap.keySet()) {
                String fieldPath = paramsMap.get(paramName);
                Object value = SObjectHelper.getSObjectFieldValue(sobj, fieldPath);
                String valueStr;
                if (value instanceof Date) {
                    valueStr = UserService.formatDate((Date) value, language);
                } else if (value instanceof Datetime) {
                    if (userObj == null || userObj.size() == 0) {
                        valueStr = UserService.formatDateTime((Datetime) value, language);
                    } else {
                        valueStr = UserService.formatDateTimebyZone(
                            (Datetime) value,
                            userObj[0].LocaleSidKey,
                            userObj[0].TimeZoneSidKey
                        );
                    }
                } else {
                    valueStr = (value != null ? value : '') + '';
                }
                if (paramName == 'Taskdate') {
                    if (valueStr == '') {
                        valueStr = System.Label.Not_Available;
                    }
                }
                /**PEH-9758*/
                if (paramName == 'TaskOnlydate') {
                    if (valueStr == '') {
                        valueStr = System.Label.Not_Available;
                    } else {
                        if (value instanceof Datetime) {
                            DateTime tempDateTime = (DateTime) value;
                            valueStr = UserService.formatDatebyLocale(
                                tempDateTime.date(),
                                language
                            );
                        } else if (value instanceof Date) {
                            valueStr = UserService.formatDatebyLocale((Date) value, language);
                        }
                    }
                }
                /**PEH-8622*/
                if (paramName == 'expirationOnlyDate') {
                    if (valueStr == '') {
                        valueStr = System.Label.Not_Available;
                    } else {
                        if (value instanceof Datetime) {
                            DateTime tempDateTime = (DateTime) value;
                            valueStr = UserService.formatDatebyLocale(
                                tempDateTime.date(),
                                language
                            );
                        } else if (value instanceof Date) {
                            valueStr = UserService.formatDatebyLocale((Date) value, language);
                        }
                    }
                }

                /**PEH-11453*/
                if (paramName == 'SMSTaskdate') {
                    if (valueStr == '') {
                        valueStr = System.Label.Not_Available;
                    } else {
                        //get originator field values
                        String originatorField = paramsMap.get('Originator');
                        Object originatorFieldValue = SObjectHelper.getSObjectFieldValue(
                            sobj,
                            originatorField
                        );
                        //check originator if MCP show convert datetime to date
                        if (
                            (String) originatorFieldValue != 'Participant' &&
                            (String) originatorFieldValue != 'Delegate'
                        ) {
                            if (value instanceof Datetime) {
                                DateTime tempDateTime = (DateTime) value;
                                valueStr = UserService.formatDatebyLocale(
                                    tempDateTime.date(),
                                    language
                                );
                            } else if (value instanceof Date) {
                                valueStr = UserService.formatDatebyLocale((Date) value, language);
                            }
                        }
                    }
                }

                if (paramName == 'SMSexpirationDate') {
                    if (valueStr == '') {
                        valueStr = System.Label.Not_Available;
                    } else {
                        //get endDateVisible field values
                        String endDateVisibleField = paramsMap.get('endDateVisible');
                        Object endDateVisibleFieldValue = SObjectHelper.getSObjectFieldValue(
                            sobj,
                            endDateVisibleField
                        );
                        //check originator if MCP show convert datetime to date
                        if (!(Boolean) endDateVisibleFieldValue) {
                            if (value instanceof Datetime) {
                                DateTime tempDateTime = (DateTime) value;
                                valueStr = UserService.formatDatebyLocale(
                                    tempDateTime.date(),
                                    language
                                );
                            } else if (value instanceof Date) {
                                valueStr = UserService.formatDatebyLocale((Date) value, language);
                            }
                        }
                    }
                }

                if (paramName == 'STUDYorPROGRAM') {
                    if (valueStr == 'true') {
                        valueStr = System.Label.Program_SMS_PP;
                    } else {
                        valueStr = System.Label.Study_SMS_PP;
                    }
                }
                if (paramName == 'isStudyorProgram') {
                    if (valueStr == 'true') {
                        valueStr = System.Label.Program_Header_PP;
                    } else {
                        valueStr = System.Label.Study_PP;
                    }
                }
                if (paramName == 'isEventorVisit') {
                    if (valueStr == 'true') {
                        valueStr = System.Label.Event_PP;
                    } else {
                        valueStr = System.Label.Visit_PP;
                    }
                }

                valuesMap.put(paramName, valueStr);
            }
            resultMessage = sourceMessage;
            if (valuesMap.get('ShortTaskName') != null) {
                valuesMap.put('ShortTaskName', valuesMap.get('ShortTaskName').abbreviate(12));
            }
            for (String parameterName : valuesMap.keySet()) {
                resultMessage = resultMessage.replace(
                    '##' + parameterName,
                    valuesMap.get(parameterName)
                );
            }
        }
    }

    private Map<String, ParametrizedMessage> messagesMap = new Map<String, ParametrizedMessage>();
    private Map<Id, SObject> allSObjects = new Map<Id, SObject>();

    public void addMessage(
        String key,
        String sourceMessage,
        Id whatId,
        String paramProviderName,
        String language
    ) {
        messagesMap.put(
            key,
            new ParametrizedMessage(sourceMessage, whatId, paramProviderName, language)
        );
    }

    public void processMessages() {
        //group by provider name
        Map<String, List<Id>> idsByProviderMap = new Map<String, List<Id>>();
        for (ParametrizedMessage pm : messagesMap.values()) {
            if (pm.paramProviderName == null || pm.whatId == null)
                continue;
            List<Id> whatIds = idsByProviderMap.get(pm.paramProviderName);
            if (whatIds == null)
                whatIds = new List<Id>();
            whatIds.add(pm.whatId);
            idsByProviderMap.put(pm.paramProviderName, whatIds);
        }
        //query records for all grouped whatIds
        for (String providerName : idsByProviderMap.keySet()) {
            List<Id> whatIds = idsByProviderMap.get(providerName);
            List<SObject> records = ParametersProviderService.queryRecords(whatIds, providerName);
            for (SObject sobj : records)
                allSObjects.put(sobj.Id, sobj);
        }
        //group whatIds by language
        Map<String, List<SObject>> sObjectsByLanguageMap = new Map<String, List<SObject>>();
        for (ParametrizedMessage pm : messagesMap.values()) {
            if (pm.whatId == null || pm.language == null)
                continue;
            List<SObject> sObjectList = sObjectsByLanguageMap.get(pm.whatId);
            if (sObjectList == null)
                sObjectList = new List<SObject>();
            SObject sObj = allSObjects.get(pm.whatId);
            if (sObj != null)
                sObjectList.add(sObj);
            sObjectsByLanguageMap.put(pm.language, sObjectList);
        }
        //translate sObjects
        for (String language : sObjectsByLanguageMap.keySet()) {
            List<SObject> sObjects = sObjectsByLanguageMap.get(language);
            TranslateHelper.translate(sObjects, language);
        }
        //update messages
        for (ParametrizedMessage pm : messagesMap.values()) {
            SObject sobj = allSObjects.get(pm.whatId);
            pm.setSObject(sobj);
        }
    }

    public String getMessage(String key) {
        ParametrizedMessage pm = messagesMap.get(key);
        if (pm == null)
            return null;
        return pm.getMessage();
    }
}
