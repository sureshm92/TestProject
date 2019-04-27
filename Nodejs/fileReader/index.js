var fs = require('fs');

exports.readFiles = function (dirname, onFileContentLoad, onError) {
    fs.readdir(dirname, (err, files) => {
        if (err) {
            console.log('filed read error', err);
        }
        files.forEach(filename => {
            fs.readFile(dirname + '/' + filename, 'utf-8', function (err, content) {
                if (err) {
                   console.log('err',err);
                    return;
                }
                onFileContentLoad(content,filename);
            });

        });
    });
};
exports.module = fs;