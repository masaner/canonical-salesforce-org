import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLeads from '@salesforce/apex/Foobar.getLeads';
import sendPostRequest from '@salesforce/apex/Foobar.sendPostRequest';
import LightningConfirm from 'lightning/confirm';

export default class DataTableForLeads extends LightningElement {
    @api leads = [];
    @track selectedRows = [];
    @track initialRecords = [];
    @track searchTerm = '';
    @track salesRepName = '';
    @track relatedJobId = '';
    @track lastSalesRepTest = '';

    selectedIds = [];

    columns = [
        { label: 'First Name', fieldName: 'firstname', type: 'text' },
        { label: 'Last Name', fieldName: 'lastname', type: 'text' },
        { label: 'Email', fieldName: 'email', type: 'text' },
        { label: 'Company', fieldName: 'company', type: 'text' }
    ];

    @wire(getLeads)
    wiredLeads({ data, error }) {
        if (data) {
            this.leads = JSON.parse(data);
            this.initialRecords = JSON.parse(data);
        } else if (error) {
            console.error('Error fetching leads:', error);
        }
    }

    handleSearchBar(event) {
        this.searchTerm = event.target.value.toUpperCase();
        if (this.searchTerm) {
            if (this.leads) {
                let searchRecords = [];
                for (let record of this.leads) {
                    let valuesArray = Object.values(record);
                    for (let val of valuesArray) {
                        let strVal = String(val);
                        if (strVal) {
                            if (strVal.toUpperCase().includes(this.searchTerm.toUpperCase())) {
                                searchRecords.push(record);
                                break;
                            }
                        }
                    }
                }
                console.log('Matched Accounts are ' + JSON.stringify(searchRecords));
                this.leads = searchRecords;
            }
        } else {
            this.leads = this.initialRecords;
        }
    }

    async importLeads() {
        let result = false;
        if(this.relatedJobId && this.lastSalesRepTest == this.salesRepName){
            result = await LightningConfirm.open({
                message: 'There seems to be an already existing reference id from your previous imports, would you like to link these leads to the previous import?',
                variant: 'header',
                label: 'Link To Previous Import?',
                theme: 'success'
            });
        }
        
        console.log(result);

        if (this.selectedRows.length > 0) {
            const salesRepName = this.salesRepName;
            const selectedIds = this.selectedRows.map(row => row.id).join(',');
    
            if (result) {
                this.joinLeadsWithExistingJob(this.relatedJobId, selectedIds, salesRepName);
            } else {
                this.sendNewRequest(selectedIds, salesRepName);
            }
        this.lastSalesRepTest = salesRepName;
        } else {
            this.showToast('Error', 'No leads selected.', 'error');
        }
    }
    
    sendNewRequest(selectedIds, salesRepName) {
        sendPostRequest({  undefined, selectedIds, salesRepName })
            .then(result => {
                console.log('POST Response:', result);
                const parsedResult = JSON.parse(result); // Parse the JSON string received from Apex
                console.log(parsedResult);
                const jobId = parsedResult.jobId; // Access jobId from the parsed result
                const referenceId = parsedResult.referenceId; 
                if (jobId) {
                    this.relatedJobId = referenceId;
                    this.showToast('Success', 'POST request sent successfully.', 'success');
                } else {
                    this.showToast('Success', 'POST request sent successfully, but we didn\'t get a Job Id from the Response!', 'error');
                }
            })
            .catch(error => {
                console.error('Error sending POST request:', error);
                this.showToast('Error', 'Failed to send POST request.', 'error');
            });
    }
    
    joinLeadsWithExistingJob(relatedJobId, selectedIds, salesRepName) {
        sendPostRequest({ relatedJobId, selectedIds, salesRepName })
            .then(result => {
                console.log('POST Response:', result);
                this.showToast('Success', 'POST request sent successfully.', 'success');
            })
            .catch(error => {
                console.error('Error sending POST request:', error);
                this.showToast('Error', 'Failed to send POST request.', 'error');
            });
    }
    
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    onRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    handleSaleRepNameChange(event) {
        this.salesRepName = event.detail.value;
    }
}