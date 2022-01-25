public class CTRL_PSMEngagementDetails {
    @AuraEnabled
    public static PageLayoutDetails getPageLayoutDetails(String recordId){
        PSM_Engagement_Request__c engagementRequest = [Select Id, Dealer__c, Status__c from PSM_Engagement_Request__c Where Id = :recordId];
        List<PSM_Engagements__c> lstEngagementsRecords = [Select Id From PSM_Engagements__c Where PSM_Engagement_Request__c =:recordId];
        List<Dealer_Report_card__c> lstdealerReportCards = [Select Id, Dealer_Score__c From Dealer_Report_card__c where PSM_Engagement_Request__c =:recordId];
        PageLayoutDetails pageLayoutDetails = new PageLayoutDetails();
        String sPageLayoutName = 'PSM_Engagements__c-PSM Engagement Layout';
        
        List<PageLayoutSection> lstPageLayoutSections = new List<PageLayoutSection>();
        List<Metadata.Metadata> lstLayouts = 
        Metadata.Operations.retrieve(Metadata.MetadataType.Layout, 
                                     new List<String> {sPageLayoutName});

        Metadata.Layout layoutMd = (Metadata.Layout)lstLayouts.get(0);
        Integer iIndex = 0;
        Integer iColumnIndex = 0;
        List<String> lstActiveSections = new List<String>();
        for (Metadata.LayoutSection section : layoutMd.layoutSections) {
            System.debug('Section'+section.label);
            PageLayoutSection pageLayoutSectionObj = new PageLayoutSection();
            pageLayoutSectionObj.sLabel = section.label;
            pageLayoutSectionObj.sName = String.valueOf(iIndex);
            lstActiveSections.add(String.valueOf(iIndex));
            iIndex++;
            for (Metadata.LayoutColumn column : section.layoutColumns) {
                if (column.layoutItems != null) {
                    PageLayoutColumn pageLayoutColumn = new PageLayoutColumn();
                    pageLayoutColumn.iColumnIndex = iColumnIndex;
                    iColumnIndex++;
                    for (Metadata.LayoutItem item : column.layoutItems) {
                        Boolean bIsReadOnly = false;
                        Boolean bIsRequired = false;
                        String slsyFieldstyle = '';
                        if(String.valueOf(item.behavior) == 'Readonly'){
                            bIsReadOnly = true;
                        }
                        if(String.valueOf(item.behavior) == 'Required'){
                            bIsRequired = true;
                        }
                        String sFieldValue = '';
                        pageLayoutColumn.lstFields.add(new PageLayoutField(item.field, bIsReadOnly,slsyFieldstyle, sFieldValue, bIsRequired));
                    }
                    pageLayoutSectionObj.lstColumns.add(pageLayoutColumn);
                }
            }
            if(pageLayoutSectionObj.sLabel != 'Custom Links'){
            	lstPageLayoutSections.add(pageLayoutSectionObj);
            }
        }
        pageLayoutDetails.lstPageLayoutSections = lstPageLayoutSections;
        pageLayoutDetails.lstActiveSections = lstActiveSections;
        pageLayoutDetails.bIsShowNew = lstEngagementsRecords.size() == 0;
        if(lstEngagementsRecords.size() > 0){
            pageLayoutDetails.sPSMRecordId = lstEngagementsRecords[0].Id;
            pageLayoutDetails.bIsShowNew = false;
        }else{
            if(engagementRequest.Status__c == 'Dealer Report Card generated'){
            	pageLayoutDetails.bIsShowNew = true;
                PSM_Engagements__c engagementsRecord = new PSM_Engagements__c();
                engagementsRecord.PSM_Engagement_Request__c = recordId;
                engagementsRecord.Dealer_Name__c = engagementRequest.Dealer__c;
                if(lstdealerReportCards.size() > 0){
                	engagementsRecord.Engagement_Score__c = lstdealerReportCards[0].Dealer_Score__c;
                }
                insert engagementsRecord;
                pageLayoutDetails.sPSMRecordId = engagementsRecord.Id;
            }else{
                pageLayoutDetails.bIsShowNew = false;
            }
        }
        return pageLayoutDetails;
    }
    public class PageLayoutDetails{
        @AuraEnabled public List<PageLayoutSection> lstPageLayoutSections;
        @AuraEnabled public List<String> lstActiveSections;
        @AuraEnabled public Boolean bIsShowEdit;
        @AuraEnabled public Boolean bIsShowNew;
        @AuraEnabled public String sPSMRecordId;
        public PageLayoutDetails(){
            lstPageLayoutSections = new List<PageLayoutSection>();
        }
    }
    public class PageLayoutSection{
        @AuraEnabled public String sName;
        @AuraEnabled public String sLabel;
        @AuraEnabled public List<PageLayoutColumn> lstColumns;
        public PageLayoutSection(){
            lstColumns = new List<PageLayoutColumn>();
        }
    }
    public class PageLayoutColumn{
        @AuraEnabled public List<PageLayoutField> lstFields;
        @AuraEnabled public Integer iColumnIndex;
        public PageLayoutColumn(){
            lstFields = new List<PageLayoutField>();
        }
    }
    public class PageLayoutField{
        @AuraEnabled public String sFieldName;
        @AuraEnabled public String sFieldValue;
        @AuraEnabled public Boolean bIsReadOnly;
        @AuraEnabled public Boolean bIsRequired;
        @AuraEnabled public Boolean bIsShowDefaultValue;
        @AuraEnabled public String sFieldstyle;
        public PageLayoutField(String sFieldName, Boolean bIsReadOnly, String slsyFieldstyle,String sFieldValue, Boolean bIsRequired){
            this.sFieldName = sFieldName;
            this.bIsReadOnly = bIsReadOnly;
            this.sFieldstyle = sFieldstyle;
            this.sFieldValue = sFieldValue;
            this.bIsRequired = bIsRequired;
            if(sFieldValue == ''){
                this.bIsShowDefaultValue = false;
            }else{
                this.bIsShowDefaultValue = true;
            }
        }
    }
}