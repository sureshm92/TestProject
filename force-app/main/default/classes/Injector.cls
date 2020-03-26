/**
 * Created by Dmytro Pokutnii
 */
public inherited sharing class Injector {

    @AuraEnabled
    public static String getComponentName(String componentName) {
        return ((AuraInjector) ClassFactory.newInstance(AuraInjector.class)).getComponentName(componentName);
    }

    public static Map<String, Injector_Binding__mdt> getBindingsByNames(String bindingType) {
        String bindingsQuery = 'SELECT Label, ' +
                ' Injected_Unit_Name__c ' +
                ' FROM Injector_Binding__mdt ' +
                (String.isBlank(bindingType) ? '' : ' WHERE Binding_Type__c = \'' + bindingType + '\'');
        List<Injector_Binding__mdt> bindings = ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(bindingsQuery, true);
        Map<String, Injector_Binding__mdt> result = new Map<String, Injector_Binding__mdt>();
        for (Injector_Binding__mdt singleBinding : bindings) {
            result.put(singleBinding.Label, singleBinding);
        }
        return result;
    }

    private inherited sharing class AuraInjector {

        Map<String, Injector_Binding__mdt> bindingsByNames;

        public AuraInjector() {
            this.bindingsByNames = Injector.getBindingsByNames('Aura');
        }

        private String getComponentName(String componentName) {
            return bindingsByNames.get(componentName).Injected_Unit_Name__c;
        }
    }
}