trigger ServiceAppointmentTrigger on ServiceAppointment(Before Insert) {
    System.debug('Test Trigger');
    
    List<ServiceAppointment> lst = [SELECT id,subject FROM ServiceAppointment WHERE id=: trigger.new];
    System.debug(lst);
    
}