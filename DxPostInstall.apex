UserRole role = [SELECT Id FROM UserRole WHERE Name = 'View All'];
User currentUser = new User(Id = UserInfo.getUserId(), UserRoleId = role.Id,Country = 'Ukraine');
System.debug('currentUser'+ UserInfo.getUserName());
update currentUser;