import { api, LightningElement} from 'lwc';
import PPInvitationStatusTitle from '@salesforce/label/c.Site_DB_Patient_Portal_Invitation_Status';
import PPInvited from '@salesforce/label/c.Site_DB_Invited';
import PPNotYetInvited from '@salesforce/label/c.Site_DB_Not_Yet_Invited';
import CountParticipants from '@salesforce/label/c.Site_DB_Participants';
import SendInvitestoNotYetInvited from '@salesforce/label/c.Site_DB_Send_Invites_to_Not_Yet_Invited';
import getParticipantCount from '@salesforce/apex/DashboardParticipantCount.participantInvitationDashboard';
 
export default class PpinvitationstatusdashboardLWC extends LightningElement {
    @api selectedCTP;
    @api selectedPI;
   
    participantsCountResponse;
    error;
    loading = false;
    invitedCount = 0;
    notYetInvitedCount = 0;

    label = {
        PPInvitationStatusTitle,
        PPInvited,
        PPNotYetInvited,
        CountParticipants,
        SendInvitestoNotYetInvited
    };
	chartConfiguration;   
 
    connectedCallback() {
        this.fetchDashboardValues();                   
    }

    @api
    fetchDashboardValues() {
        if(this.selectedCTP && this.selectedPI) {
            this.loading = true;
            this.chartConfiguration = undefined;
            getParticipantCount({ pIid: this.selectedPI,ctpId: this.selectedCTP })
            .then(result => {
                console.log('result:'+JSON.stringify(result));
                let chartAmtData = [];                
                if(result) {
                    chartAmtData.push(result.Invited);
                    chartAmtData.push(result.NotYetInvited);
                    this.invitedCount = result.Invited;
                    this.notYetInvitedCount = result.NotYetInvited;                  
                    
                } else {
                    chartAmtData.push('0');
                    chartAmtData.push('0');
                }
                this.loading = false;
                this.prepareChartConfig(chartAmtData);
                
            })
            .catch(error => {
                let chartAmtData = [];            
                this.error = error;
                chartAmtData.push('0');
                chartAmtData.push('0');
                this.loading = false;
                this.prepareChartConfig(chartAmtData);
            });
        }

    }

    prepareChartConfig(chartAmtData) {
        let chartLabel = [PPInvited,PPNotYetInvited];        
        this.chartConfiguration = {
            type: 'horizontalBar',
            data: {
                axis:'y',
                datasets: [
                    {backgroundColor: ["#D8EBF7","#83C7F4"],data: chartAmtData}
                ],
                labels: chartLabel
            },   
            options: {
                scales: {
                    xAxes: [{
                        ticks: {
                            beginAtZero: true
                        },
                        gridLines: {
                            color: "rgba(0, 0, 0, 0)",
                        },
                        display: false,
                        minBarLength:2
                    }],
                    yAxes: [{                                
                        gridLines: {
                            color: "rgba(0, 0, 0, 0)",
                        },
                        ticks:{
                            fontColor: 'black',
                            fontSize: 14,                            
                        },
                    }]
                },
                legend: {
                    display: false,
                    position : 'top',
                    labels: {
                        display: true,
                        
                    }
                },
                tooltips: {
                    enabled: false
                },
            }
        };

    }
}