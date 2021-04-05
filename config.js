module.exports = () => ({
    custom: ({cfEvent}) => {
        console.log(JSON.stringify(cfEvent, null, 4));
        return cfEvent.request;
    }
})