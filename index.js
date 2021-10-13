const express = require('express');
const jsforce = require('jsforce');
const helper = require('./helper');
const deltaPackageCreation = require('./deltapackagecreation');
const app = express();
const bodyParser = require('body-parser');
const port = 3000;
app.set('view engine', 'ejs');
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.post('/getMetadata', async (req, res) => {
    console.log(req.body.metadataName);
    var metadataRec = await helper.getMetadata(req.body.metadataName);
    res.send(metadataRec);
});
app.post('/createDeltaPackage', (req, res) => {
    console.log(typeof req.body.selectedMetadata);
    console.log(req.body.selectedMetadata);
    deltaPackageCreation.init(req.body.selectedMetadata);
});

app.get('/', (req, res) => {
    res.render('pages/index', { helper: helper });
});

app.listen(port, () => {
    console.log(`Example app listening at http://localhost:${port}`);
});
