public inherited sharing class DatabaseProxy {

	public List<SObject> query(String query) {
		return Database.query(query);
	}

	public void upsertRecord(SObject record) {
		upsert record;
	}

	public void upsertRecords(List<SObject> records) {
		upsert records;
	}
}