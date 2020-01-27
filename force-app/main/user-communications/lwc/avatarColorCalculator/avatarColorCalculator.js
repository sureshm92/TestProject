/**
 * Created by Igor Malyuta on 24.12.2019.
 */
const colors = [
    '#297DFD',
    '#10558A',
    '#DF216D',
    '#00C221',
    '#FF9300',
    '#9E54B0'
];

export default class AvatarColorCalculator {

    getColorFromString(str) {
        let codesString = str
            .split('')
            .map(function(char){return  char.charCodeAt(0)})
            .join('');

        return colors[parseInt(codesString, 10) % colors.length];
    }
}