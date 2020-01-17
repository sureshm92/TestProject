/**
 * Created by Kryvolap on 21.08.2019.
 */

public without sharing class SearchService{

    public final static String QUERY_TYPE_SOQL = 'SOQL';
    public final static String QUERY_TYPE_SOSL = 'SOSL';

    private static SearchService instance;

    public static SearchService getInstance(){
        if(instance == null) instance = new SearchService();
        return instance;
    }

    public static void setMock(StubProvider stubProvider){
        instance = (SearchService) Test.createStub(SearchService.class, stubProvider);
    }
    
    public List<SObject> searchImpl(SearchFilter filter, PaginationData paginationData){
        paginationData.setRecordsCount(countRecords(filter));
        return queryRecords(filter, paginationData);
    }
    
    public List<SObject> searchImpl(SearchFilter filter){
        return queryRecords(filter);
    }
    
    private Integer countRecords(SearchFilter filter){
        if(filter.getQueryType() == QUERY_TYPE_SOQL){
            return DatabaseService.countQuery(filter.getSObjectType(), filter.getFilterString());
        }
        else{
            return 0;
        }
    }
    
    private List<SObject> queryRecords(SearchFilter filter, PaginationData paginationData){
        if(filter.getQueryType() == QUERY_TYPE_SOQL){
            return  DatabaseService.query(filter.getFields(), filter.getSObjectType(),
                    filter.getFilterString(), filter.getOrderBy(), paginationData.pageRecordsCount, paginationData.offset);
        } else{
            //TODO
            return null;
        }
    }
    
    private List<SObject> queryRecords(SearchFilter filter){
        if(filter.getQueryType() == QUERY_TYPE_SOQL){
            return  DatabaseService.query(filter.getFields(), filter.getSObjectType(), filter.getFilterString(),filter.getOrderBy(),null,null);
        } else{
            //TODO
            return null;
        }
    }
    
    // Static facade: --------------------------------------------------------------------------------------------------
    public static List<SObject> search(SearchFilter filter, PaginationData paginationData){
        return getInstance().searchImpl(filter, paginationData);
    }
    
    public static List<SObject> search(SearchFilter filter){
        return getInstance().searchImpl(filter);
    }
}