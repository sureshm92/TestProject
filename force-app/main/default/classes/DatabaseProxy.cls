public with sharing class DatabaseProxy {

	public List<SObject> query(String query) {
		return Database.query(query);
	}
}