/**
 * Created by Denis Z on 16-Jul-19.
 */

public without sharing class Batch_CreateParticipants implements Database.Batchable<ImportPatientsCSV.Patient>{

    public List<ImportPatientsCSV.Patient> patients {get;set;}

    public Batch_CreateParticipants(List<ImportPatientsCSV.Patient> patients){
        this.patients = patients;
    }

    public Iterable<ImportPatientsCSV.Patient> start(Database.BatchableContext bc){
        return patients;
    }

    public void execute(Database.BatchableContext bc, List<ImportPatientsCSV.Patient> scope){
        if(!scope.isEmpty()){
            ParticipantEnrollmentFactory.createParticipantEnrollmentRecords(scope[0].protocolId, scope[0].siteNumber, scope[0].screeningId);
        }
    }

    public void finish(Database.BatchableContext bc){
    }

    public static void run(List<ImportPatientsCSV.Patient> patients){
        Database.executeBatch(new Batch_CreateParticipants(patients), 1);
    }
}