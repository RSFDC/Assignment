import { LightningElement, track } from 'lwc';
import getDirections from '@salesforce/apex/DirectionsController.getDirections';

export default class DirectionsForm extends LightningElement {
    @track originAddress;
    @track destinationAddress;
    @track directionsResult;
    @track errorMessage;

    handleOriginChange(event) {
        this.originAddress = event.target.value;
    }

    handleDestinationChange(event) {
        this.destinationAddress = event.target.value;
    }

    async getDirections() {
        try {
            const result = await getDirections({ originAddress: this.originAddress, destinationAddress: this.destinationAddress });
            this.directionsResult = result;
            this.errorMessage = null; // Reset the error message if the call is successful
        } catch (error) {
            this.directionsResult = null; // Reset the result if there's an error
            this.errorMessage = 'Error retrieving directions. Please try again.'; // Set the error message
        }
    }
}
