@IsTest
public with sharing class Test_HumanAPIcontroller {
  @IsTest
  public static void getReportListTest() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new HumanAPIcontrollerMock());
    HumanAPIcontroller.ReportListWrapper wrap = new HumanAPIcontroller.ReportListWrapper();
    wrap = HumanAPIcontroller.getReportList('humanid');
    system.assertEquals('test_token', wrap.accessToken);
    Test.stopTest();
  }
}