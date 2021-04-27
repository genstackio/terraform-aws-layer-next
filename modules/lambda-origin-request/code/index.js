const {buildDefaultResponse, processRequest} = require('./utils');

const handler = async event => {
    const records = ((event || {})['Records'] || []);
    if (!records.length) return buildDefaultResponse();
    const request = ((records[0] || {})['cf'] || {})['request'];
    if (!request) return buildDefaultResponse();

    return processRequest(request);
};

module.exports = {handler}