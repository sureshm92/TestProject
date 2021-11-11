const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const path = require('path');
require('dotenv').config();

app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');
app.use(express.static('public'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

const getMetaDataRoute = require('./routes/getMetaData');
const createDeltaPackageRoute = require('./routes/createDeltaPackage');

const helper = require('./utils/helper');

app.use('/getMetadata', getMetaDataRoute);
app.use('/createDeltaPackage', createDeltaPackageRoute);

app.get('/', (req, res) => {
    res.render('index', { helper: helper });
});

module.exports = app;
