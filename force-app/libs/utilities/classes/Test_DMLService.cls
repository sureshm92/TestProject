/**
 * Created by Leonid Bartenev
 */

@IsTest
private class Test_DMLService {
    
    @IsTest
    static void testDMLBufferOff() {
        Account acc = new Account(Name = 'Test');
        DMLService.insertRecord(acc);
        System.assert([SELECT Id FROM Account WHERE Name = 'Test'].size() == 1);
    
        acc.Name = 'TestUpdate';
        DMLService.updateRecord(acc);
        System.assert([SELECT Id FROM Account WHERE Name = 'TestUpdate'].size() == 1);
    
        DMLService.deleteRecord(acc);
        System.assert([SELECT Id FROM Account WHERE Name = 'TestUpdate'].size() == 0);
    }
    
    @IsTest
    static void testDMLBufferOn() {
        DMLService.useDMLBuffer(true);
        Account acc = new Account(Name = 'Test');
        DMLService.insertRecord(acc);
        System.assert(acc.Id == null);
        
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Some', CloseDate = Date.today().addDays(30));
        DMLService.setLookup(opp, 'AccountId', acc);
        DMLService.insertRecord(opp);
        
        DMLService.pushDMLBuffer();
        System.assert([SELECT Id FROM Account WHERE Name = 'Test'].size() == 1);
        Opportunity checkOpp = [SELECT Id, AccountId FROM Opportunity WHERE Name = 'Test Opp'];
        System.assert(checkOpp.AccountId == acc.Id);
        
        acc.Phone = '123';
        DMLService.updateRecord(acc);
        DMLService.pushDMLBuffer();
        System.assert([SELECT Id, Phone FROM Account WHERE Name = 'Test'].Phone == '123');
        
        DMLService.deleteRecord(acc);
        DMLService.pushDMLBuffer();
        System.assert([SELECT Id FROM Account WHERE Name = 'Test'].size() == 0);

    }
}