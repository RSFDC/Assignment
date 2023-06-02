import { LightningElement, api } from 'lwc';

export default class Home extends LightningElement {
    @api
    navigateToDirections() {
        const navigateEvent = new CustomEvent('navigate', {
            detail: {
                page: 'directions',
            },
        });
        this.dispatchEvent(navigateEvent);
    }
}
