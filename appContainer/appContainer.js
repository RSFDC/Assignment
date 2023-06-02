import { LightningElement, track } from 'lwc';

export default class AppContainer extends LightningElement {
    @track currentPage;
    @track showDirections;

    handleNavigation(event) {
        const page = event.detail.page;
        if (page === 'directions') {
            this.showDirections = true;
        } else {
            this.showDirections = false;
        }
        this.currentPage = page;
    }
}
