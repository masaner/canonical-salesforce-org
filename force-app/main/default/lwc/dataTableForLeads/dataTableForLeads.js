// import { LightningElement, api, wire } from 'lwc';
// import getLeads from '@salesforce/apex/Foobar.getLeads';


// export default class DataTableForLeads extends LightningElement {
//   @api leads = [];
//   searchTerm = '';
//   selectedIds = [];

//   columns = [
//     { label: 'Name', fieldName: 'name', type: 'text' },
//     { label: 'Email', fieldName: 'email', type: 'text' },
//     { label: 'Company', fieldName: 'company', type: 'text' },
//     {
//       type: 'action',
//       typeAttributes: { label: 'Select', fieldName: 'id' },
//       contentActions: [
//         { label: 'Select', name: 'select', type: 'checkbox' },
//       ],
//     },
//   ];

//   @wire(getLeads)
//   wiredLeads({ data, error }) {
//     if (data) {
//       this.leads = JSON.parse(data);
//     } else if (error) {
//       console.error('Error fetching leads:', error);
//     }
//   }


//   handleSearch(event) {
//     this.searchTerm = event.detail.value.toLowerCase();
//     this.updateLeads();
//   }

//   handleSelectAll(event) {
//     const isChecked = event.detail.checked;
//     this.selectedIds = isChecked ? this.leads.map(lead => lead.id) : [];
//   }

//   handleCheckboxSelect(event) {
//     const isChecked = event.detail.checked;
//     const leadId = event.target.dataset.id;
//     if (isChecked) {
//       this.selectedIds.push(leadId);
//     } else {
//       this.selectedIds = this.selectedIds.filter(id => id !== leadId);
//     }
//   }

//   updateLeads() {
//     this.leads = this.template.data.leads.filter(lead => {
//       const searchTerm = this.searchTerm;
//       return (
//         lead.name.toLowerCase().includes(searchTerm) ||
//         lead.email.toLowerCase().includes(searchTerm) ||
//         lead.company.toLowerCase().includes(searchTerm)
//       );
//     });
//   }

// }
import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLeads from '@salesforce/apex/Foobar.getLeads';
import sendPostRequest from '@salesforce/apex/Foobar.sendPostRequest';


export default class DataTableForLeads extends LightningElement {
    @api leads = [];
    @track selectedRows = [];
    @track initialRecords = [];
    @track searchTerm = '';
    selectedIds = [];

    columns = [
        { label: 'Name', fieldName: 'name', type: 'text' },
        { label: 'Email', fieldName: 'email', type: 'text' },
        { label: 'Company', fieldName: 'company', type: 'text' },
        {
            type: 'action',
            typeAttributes: { label: 'Select', fieldName: 'id' },
            contentActions: [
                { label: 'Select', name: 'select', type: 'checkbox' },
            ],
        },
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

    handleButtonClick() {
        if (this.selectedRows.length > 0) {
            const selectedIds = this.selectedRows.map(row => row.id).join(',');
            sendPostRequest({ selectedIds })
                .then(result => {
                    console.log('POST Response:', result);
                    this.showToast('Success', 'POST request sent successfully.', 'success');
                })
                .catch(error => {
                    console.error('Error sending POST request:', error);
                    this.showToast('Error', 'Failed to send POST request.', 'error');
                });
        } else {
            this.showToast('Error', 'No leads selected.', 'error');
        }
    }
    
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    handleSelectAll(event) {
        const isChecked = event.target.checked;
        this.selectedIds = isChecked ? this.leads.map(lead => lead.id) : [];
    }

    onRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
        console.log(
            'selectedRows are ',
            JSON.stringify( this.selectedRows )
        );
    }

}
