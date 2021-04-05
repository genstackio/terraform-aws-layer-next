module.exports = () => ({
    custom: (...args) => {
        console.log(args);
        return undefined;
    }
})