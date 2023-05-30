//https://stackoverflow.com/questions/41285434/how-to-find-out-the-stream-length-for-createblockblobfromstream-method
//https://stackoverflow.com/questions/68631266/how-to-find-length-of-a-stream-in-nodejs
module.exports = async function (context, stream) {
    context.log("JavaScript blob trigger function processed stream '" + context.bindingData.blobTrigger + "' of type '" + stream.constructor.name + "'.");
};