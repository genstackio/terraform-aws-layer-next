module.exports = () => ({
    custom: (...args) => {
        console.log(JSON.stringify(args, null, 4));
        return undefined;
    }
})