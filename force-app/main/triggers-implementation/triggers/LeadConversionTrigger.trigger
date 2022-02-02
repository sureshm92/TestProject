trigger LeadConversionTrigger on Lead(after update) {
  Profile p = [
    SELECT Name
    FROM Profile
    WHERE Id = :userinfo.getProfileid()
    LIMIT 1
  ];
  String pname = p.name;
  if (
    Trigger.isAfter &&
    Trigger.isUpdate &&
    pname != 'IQVIA Referral Hub Profile'
  ) {
    LeadConversionHelper.afterLeadsUpdate(
      Trigger.new,
      Trigger.oldMap,
      Trigger.newMap 
    ); 
  }
}
