UserRole userRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'View_All'];
User user = [SELECT Id FROM User WHERE Name = 'User User'];
user.UserRoleId = userRole.Id;
user.CountryCode = 'US';
user.StateCode = 'CA';
update user;