/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class TherapeuticAreaService {

    public Set<String> getTANamesOnResource(Resource__c resource) {
        Set<String> tANames = new Set<String>();
        if(!String.isBlank(resource.Therapeutic_Areas__c)) {
            tANames.addAll(resource.Therapeutic_Areas__c.split(';'));
        }
        return tANames;
    }

    public Map<String, Therapeutic_Area__c> getTherapeuticAreasByNames(List<Therapeutic_Area__c> therapeuticAreas) {
        Map<String, Therapeutic_Area__c> tAsByNames = new Map<String, Therapeutic_Area__c>();
        for (Therapeutic_Area__c singleTA : therapeuticAreas) {
            tAsByNames.put(singleTA.Name, singleTA);
        }
        return tAsByNames;
    }

    public List<Therapeutic_Area__c> createTherapeuticAreas(Set<String> therapeuticAreaNames) {
        List<Therapeutic_Area__c> therapeuticAreas = new List<Therapeutic_Area__c>();
        for (String singleTAName : therapeuticAreaNames) {
            therapeuticAreas.add(new Therapeutic_Area__c(Name = singleTAName));
        }
        insert therapeuticAreas;
        return therapeuticAreas;
    }

    public List<Therapeutic_Area__c> getTherapeuticAreas(Set<String> tANames, Boolean createIfNotExist) {

        List<Therapeutic_Area__c> therapeuticAreas = [SELECT Id, Name FROM Therapeutic_Area__c WHERE Name IN :tANames];
        if(!createIfNotExist) {
            return therapeuticAreas;
        }
        Set<String> existingTANames = new Set<String>();
        for (Therapeutic_Area__c singleTA : therapeuticAreas) {
            existingTANames.add(singleTA.Name);
        }
        tANames.removeAll(existingTANames);
        if (!tANames.isEmpty()) {
            therapeuticAreas.addAll(this.createTherapeuticAreas(tANames));
        }
        return therapeuticAreas;
    }
}