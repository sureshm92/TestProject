var express = require('express');
var router = express.Router();
const helper = require('../utils/helper');

router.post('/', async (req, res) => {
    try {
        var metadataRec = await helper.getMetadata(req.body.metadataName);
        res.send(metadataRec);
    } catch (err) {
        console.log('Error occured while fetching Metadata', err)
        res.send([])
    }
})

module.exports = router;