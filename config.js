module.exports = {
    custom: ({cfEvent: {request: {uri, origin}}}) => {
        // statics assets hosted by S3
        if (origin.custom.customHeaders['x-cloudfront-edge-next-statics']) {
            if ('/_next/image/' === uri.slice(0, 13)) return {uri: `/.${uri.slice(2)}`};
            if ('/_next/statics/' === uri.slice(0, 15)) return {uri: `/.${uri.slice(2)}`};
        }
        // `api` lambda process all /api/* requests
        if (origin.custom.customHeaders['x-cloudfront-edge-next-api-dns']) {
            if ('/api/' === uri.slice(0, 5)) return {
                origin: {
                    custom: {
                        customHeaders: origin.custom.customHeaders,
                        domainName: origin.custom.customHeaders['x-cloudfront-edge-next-api-dns'][0].value,
                        keepaliveTimeout: 5,
                        path: '',
                        port: 443,
                        protocol: 'https',
                        readTimeout: 30,
                        sslProtocols: ['TLSv1.2'],
                    }
                }
            };
        }
        // fallback to `dynamics` lambda
        if (origin.custom.customHeaders['x-cloudfront-edge-next-dynamics-dns']) return {
            origin: {
                custom: {
                    customHeaders: origin.custom.customHeaders,
                    domainName: origin.custom.customHeaders['x-cloudfront-edge-next-dynamics-dns'][0].value,
                    keepaliveTimeout: 5,
                    path: '',
                    port: 443,
                    protocol: 'https',
                    readTimeout: 30,
                    sslProtocols: ['TLSv1.2'],
                }
            }
        };
        // nothing dynamic is enabled, fallback to default origin
        return undefined;
    }
}