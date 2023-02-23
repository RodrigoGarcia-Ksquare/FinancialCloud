import { LightningElement, wire, api, track } from 'lwc';
import getLeads from '@salesforce/apex/HomeController.getLeads';
import assignUser from '@salesforce/apex/HomeController.assignUser';
import getAdminUsers from '@salesforce/apex/HomeController.getAdminUsers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

const actions = [
    { label: 'Assign', name: 'assign' }
];

const COLS = [
    { label: 'Name', fieldName: 'FirstName'},
    { label: 'Last Name', fieldName: 'LastName'},
    { label: 'Email', fieldName: 'Email', type: 'email'},
    { label: 'City', fieldName: 'City'},
    { label: 'State', fieldName: 'State'},
    { label: 'Status', fieldName: 'Status'},
    { label: 'Sales Representative', fieldName: 'RecordOwner', type: 'text'},
    { label: 'Assign', type: 'action', 
        typeAttributes: 
        { 
            rowActions: actions, 
            menuAlignment: 'right'
        }
    }
];

export default class LeadSummary extends LightningElement {

    @api recordId
    @track record
    allLeads = []
    columns = COLS;
    isAssignModalOpen = false;
    userSelected;
    userVal;

    handleUserChange(event){
        this.userSelected = event.detail.value;
    }

    users(){
        getAdminUsers()
        .then((result) => {
            this.allAdminUsers = result;
            this.userVal = [];
            for(var i = 0; i < result.length; i++){
                let labelLine = result[i].Name;
                let valueLine = result[i].Id;
                let option = {label : labelLine, value : valueLine};
                this.userVal.push(option);
            }
        });
    }

    closeModal(){
        this.isAssignModalOpen = false;
    }

    @wire(getLeads)
    leads({error, data}){
        if(data){
            this.allLeads = data.map((acc) => {
                const leadOwner = {...acc}
                leadOwner.RecordOwner = acc.Owner.Name;
                return leadOwner;
            })
        } else if(error){
            this.error = error;
        }
        console.log(data);
    }

    handleRowAction(event){
        let action = event.detail.action.name;
        this.record = event.detail.row;

        this.recordId = this.record.Id;

        console.log(JSON.stringify(this.record));
            this.users();
            this.isAssignModalOpen = true;
    }

    assignLead(){
        this.isAssignModalOpen = false;
        assignUser({recordId : this.recordId, userId : this.userSelected})
        .then(() => {
            let found = this.userVal.find(element => element.value == this.userSelected);
            this.message = 'This lead have been assigned to ' + found.label;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: this.message,
                    variant: 'success'
                })
            );
            refreshApex(this.allLeads);
        })
    }

}