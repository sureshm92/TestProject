public inherited sharing class DatabaseProxy {

    public List<SObject> query(String query) {
        return Database.query(query);
    }

    public List<SObject> query(String query, Boolean withoutSharing) {
        if (withoutSharing) {
            return ((DatabaseProxyWithoutSharing) ClassFactory.newInstance(DatabaseProxyWithoutSharing.class)).query(query);
        } else {
            return this.query(query);
        }
    }

    public void upsertRecord(SObject record) {
        upsert record;
    }

    public void upsertRecords(List<SObject> records) {
        upsert records;
    }

    public without sharing class DatabaseProxyWithoutSharing {

        public List<SObject> query(String query) {
            return Database.query(query);
        }
    }
}