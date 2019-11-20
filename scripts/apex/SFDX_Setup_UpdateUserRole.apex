UserRole userRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'View_All'];
User user = [SELECT Id FROM User WHERE Name = 'User User'];
user.UserRoleId = userRole.Id;
update user;