import { api, wire, LightningElement } from 'lwc';
import { getRecord, getFieldValue, createRecord, updateRecord } from "lightning/uiRecordApi";
import getPageLayoutDetails from '@salesforce/apex/CTRL_PSMEngagementDetails.getPageLayoutDetails';


const fields = ['PSM_Engagement_Request__c.PSM_Engagement__c', 'PSM_Engagement_Request__c.Name','PSM_Engagement_Request__c.Dealer__c'];
export default class PsmEngagementDetails extends LightningElement {
    @api recordId;
    recordDetailsLoaded = false;
    psmRecordFound = false;
    psmRecordId;

    isLoaded = false;
    pageLayoutSections = [];
    activeSections = '';
    isShowEdit = true;
    isViewOnly = false;
    isShowNew = true;
    isShowModal = false;
    /*
    @wire(getPageLayoutDetails, { recordId: '$recordId' })
    wiredGetPageLayoutDetails(response) {
        let data = response.data;
        let error = response.error;
        if (data) {
            console.log(data);
            this.pageLayoutSections = data.lstPageLayoutSections;
            this.activeSections = data.lstActiveSections;
            this.isLoaded = true;
            this.isShowEdit = data.bIsShowEdit;
            this.isShowNew = data.bIsShowNew;
            this.psmRecordId = data.sPSMRecordId;
            if(this.psmRecordId == null && !this.isShowNew){
                this.isLoaded = false;
            }
        }
        else if (error) {
        console.log('error ' + error);
        }
    }
    */
    handleEditClick(){
        this.isViewOnly = false;
    }
    handleCancel(){
        this.isViewOnly = true;
    }
    handleSuccess(){
        console.log('handleSuccess');
        this.isViewOnly = true;
    }
    /*
    @wire(getRecord, {
        recordId: "$recordId",
        fields
    })wiredRecord({ error, data }) {
        if (data) {
            this.recordDetailsLoaded = true;
            console.log('getRecord');
            //console.log(data);
            //console.log(data.fields.PSM_Engagement__c);
            //console.log(data.fields.PSM_Engagement__c.value);
           // console.log('updated');
            
            if(data.fields.PSM_Engagement__c != undefined && data.fields.PSM_Engagement__c.value != null){
                this.psmRecordFound = true;
                this.psmRecordId = data.fields.PSM_Engagement__c.value;
            }else{
            var today = new Date();
            var dd = today.getDate();
            var mm = today.getMonth()+1; 
            var yyyy = today.getFullYear();
            if(dd<10) 
            {
                dd='0'+dd;
            } 

            if(mm<10) 
            {
                mm='0'+mm;
            } 
            var todayDate = yyyy+'-'+mm+'-'+dd;
                let engagementRecordData = { apiName: 'PSM_Engagements__c',fields : {"Status__c":"Created", "Notes__c" : "  ", "Engagement_Date__c" : todayDate, "PSM_Engagement_Request__c":this.recordId,"Dealer_Name__c":data.fields.Dealer__c.value}};
                console.log(engagementRecordData);
                createRecord(engagementRecordData)
                .then((engagementRecord) => {
                    console.log('yes success');
                    console.log(engagementRecord);
                    const fields = {};
                    fields["Id"] = this.recordId;
                    fields["PSM_Engagement__c"] =  engagementRecord.Id;
                    const recordInput = { fields };
                    updateRecord(recordInput)
                    .then(() => {
                        
                    })
                    .catch(error => {
                        console.log(error);
                    });
                })
                .catch((error) => {
                    console.log(error);
                });
            }
        } else if (error) {
            console.log(error);
        }
    });
    */
    connectedCallback() {
        console.log('connectedCallback');
        console.log(this.recordId);
        getPageLayoutDetails({recordId:this.recordId}).then((data) => {
            console.log(data);
            this.pageLayoutSections = data.lstPageLayoutSections;
            this.activeSections = data.lstActiveSections;
            this.isLoaded = true;
            this.isShowEdit = data.bIsShowEdit;
            this.isShowNew = data.bIsShowNew;
            this.psmRecordId = data.sPSMRecordId;
            if(this.psmRecordId == null && !this.isShowNew){
                this.isLoaded = false;
            }
        }).catch(error => {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
                mode:'dismissable'
            });
            this.dispatchEvent(evt);
        });
    }
    createNewPSMEngagement(){

    }
    createNewContact(){
        
    }
    handleEditClick(){
       this.isShowNew = true; 
    }
    handleSuccess(event){
        this.psmRecordId = event.detail.id;
        this.isShowNew = false; 
    }
    handleCancel(){
        this.isShowNew = false; 
    }
    handleCreateEngagementContact(){
        this.isShowModal = true;
    }
    closeMoadal(){
        this.isShowModal = false;
    }
}