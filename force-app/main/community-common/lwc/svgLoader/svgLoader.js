/**
 * Created by Igor Malyuta on 08.02.2020.
 */
const STATE_NOT_INITIALIZED = 'Not initialized';
const STATE_COMPLETED = 'Completed';
const STATE_IN_PROGRESS = 'In progress';

const callbackQueue = [];
const symbolMap = {};

let uploadState = STATE_NOT_INITIALIZED;

export default class SvgLoader {

    getIconBody(resourceUrl, iconName, callback) {
        if(uploadState === STATE_NOT_INITIALIZED) {
            this.parseXML(resourceUrl, function () {
                uploadState = STATE_COMPLETED;
                callback(symbolMap[iconName]);

                callbackQueue.forEach(function (queueItem) {
                    queueItem(symbolMap[iconName]);
                })
            });
        } else if(uploadState === STATE_IN_PROGRESS) {
            callbackQueue.push(callback);
        } else {
            callback(symbolMap[iconName]);
        }
    }

    parseXML(resourceUrl, callback) {
        let request = new XMLHttpRequest();
        request.open('GET', resourceUrl, true);

        request.onreadystatechange = function () {
            if (request.readyState === 4 && request.status === 200) {
                let doc = new DOMParser().parseFromString(request.response, 'text/xml');
                if (doc) {
                    let symbols = doc.getElementsByTagName('symbol');
                    symbols.forEach(function (symbol) {
                        symbolMap[symbol.id] = symbol;
                    });
                }
                callback();
            }
        };
        request.send();
    }
}