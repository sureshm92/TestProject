/**
 * Created by Yehor Dobrovolskyi
 */
global interface BatchHandler {

    void handle(List<SObject> scope);
    void processResult();
    void processScopeResult();
}