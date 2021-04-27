function buildDefaultResponse() {
    return {
        status: '404',
        statusDescription: 'Not Found',
        headers: {
            'cache-control': [{
                key: 'Cache-Control',
                value: 'no-cache'
            }],
            'content-type': [{
                key: 'Content-Type',
                value: 'text/plain'
            }]
        },
        body: 'Not Found',
    };
}

function isHostMatching(a, b) {
    return !a ? false : (('string' === typeof a) ? (a === b) : !!b.match(a));
}
function isUriMatching(a, b) {
    return !a ? false : (('string' === typeof a) ? (a === b) : !!b.match(a));
}
function applyTest(a, b) {
    return !a ? false : (('function' === typeof a) ? !!a(b) : false);
}
function isCountryMatching(a, b) {
    return !a ? false : (Array.isArray(a) ? a.includes(b) : (a === b));
}

function matchRuleAndOptionallyUpdateRule(rule, context) {
    let r = undefined;
    // noinspection PointlessBooleanExpressionJS
    rule.host && (r = ((undefined !== r) ? r : true) && isHostMatching(rule.host, context.host));
    rule.uri && (r = ((undefined !== r) ? r : true) && isUriMatching(rule.uri, context.uri));
    rule.country && (r = ((undefined !== r) ? r : true) && isCountryMatching(rule.country, context.country));
    if (rule.test) {
        r = ((undefined !== r) ? r : true);
        const testResult = applyTest(rule.test, context);
        if (!!testResult && ('string' === typeof testResult)) {
            rule.location = testResult;
        }
        r = r && !!testResult;
    }
    return r;
}

function getHeaderFromRequest(request, name, defaultValue = undefined) {
    const headers = getHeadersFromRequest(request);
    const value = ((headers[name] || headers[(name || '').toLowerCase()] || [])[0] || {}).value;
    return (undefined === value) ? defaultValue : value;
}

function getHeadersFromRequest(request) {
    return request.headers || [];
}

function getUriFromRequest(request, {refererMode = false} = {}) {
    if (!refererMode) return request.uri;
    let host = getHeaderFromRequest(request, 'Host');
    let referer = getHeaderFromRequest(request, 'Referer');
    if (host && referer) return referer.split(host)[1];
    return request.uri;
}

async function getRedirectResponseIfExistFromConfig(request, config) {
    const context = {
        host: getHeaderFromRequest(request, 'Host'),
        uri: getUriFromRequest(request, config),
        country: getHeaderFromRequest(request, 'CloudFront-Viewer-Country'),
        headers: getHeadersFromRequest(request),
    };
    return ((config || {}).redirects || []).find(
        rule => matchRuleAndOptionallyUpdateRule(rule, context, request)
    );
}

async function getRedirectResponseIfExistForRequest(request, config) {
    const rule = await getRedirectResponseIfExistFromConfig(request, config);
    return !rule ? undefined : {
        status: rule.status || '302',
        statusDescription: 'Found',
        headers: {
            ...(rule.headers || {}),
            location: [{
                key: 'Location',
                value: rule.location,
            }],
        },
    };
}
async function getRegionalS3OriginRequestIfNeededForRequest(request, config) {
    if (!request || !request.origin || !request.origin.s3) return undefined;
    const buckets = JSON.parse(request.headers['x-next-buckets'] || "{}");
    // @todo do a better selection
    const bucket = Object.values(buckets);
    request.origin = {
        s3: {
            domainName: bucket.domain,
            region: '',
            authMethod: 'none',
            path: request.origin.s3.path,
            customHeaders: {}
        }
    }
    request.headers['host'] = [{ key: 'host', value: bucket.domain}]
    return request;
}
async function getRegionalApiGatewayOriginRequestIfNeededForRequest(request, config) {
    if (!request || !request.origin || !request.origin.custom) return undefined;
    const apps = JSON.parse(request.headers['x-next-apps'] || "{}");
    // @todo do a better selection
    const app = Object.values(apps);
    request.origin = {
        custom: {
            domainName: app.domain,
            port: 443,
            protocol: 'https',
            path: request.origin.path,
            sslProtocols: ['TLSv1', 'TLSv1.1', 'TLSv1.2'],
            readTimeout: 5,
            keepaliveTimeout: 5,
            customHeaders: {},
        }
    }
    request.headers['host'] = [{ key: 'host', value: app.domain}]
    return request;
}

async function processRequest(request) {
    let config = require('./config');
    if ('function' === typeof config) config = config(request);
    let result = await getRedirectResponseIfExistForRequest(request, config);
    result = result || await getRegionalS3OriginRequestIfNeededForRequest(request, config);
    result = result || await getRegionalApiGatewayOriginRequestIfNeededForRequest(request, config);
    return result || request;
}

module.exports = {
    buildDefaultResponse,
    processRequest,
}