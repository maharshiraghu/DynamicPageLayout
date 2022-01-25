@isTest
public class CTRL_PSMEngagementDetailsTest {
	@isTest
    public static void doTest(){
        List<PSM_Engagement_Request__c> lstEngagementRequestRecords = new List<PSM_Engagement_Request__c>();
        lstEngagementRequestRecords.add(new PSM_Engagement_Request__c(File_Name__c='Testing', Status__c = 'Dealer Report Card generated'));
        
        insert lstEngagementRequestRecords;
        CTRL_PSMEngagementDetails.PageLayoutDetails clsRecord = CTRL_PSMEngagementDetails.getPageLayoutDetails(lstEngagementRequestRecords[0].Id);
        System.assertNotEquals(0, clsRecord.lstPageLayoutSections.size()); 
    }
}