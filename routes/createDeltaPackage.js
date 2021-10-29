var express = require('express');
var router = express.Router();
const deltaPackageCreation = require('../utils/deltapackagecreation');

router.post('/', async (req, res) => {
    try {
        console.log(req.body.selectedMetadata);
        deltaPackageCreation.init(req.body.selectedMetadata)
    } catch(err){
        console.log('error while createDeltaPackage',err);
    }
})

module.exports = router;