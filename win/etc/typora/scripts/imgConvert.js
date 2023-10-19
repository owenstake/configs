

var XMLHttpRequest = require('xmlhttprequest').XMLHttpRequest;

const makeRequest = (method, url, data = {}) => {
  const xhr = new XMLHttpRequest();
  return new Promise(resolve => {
    xhr.open(method, url, true);
    xhr.onload = () => resolve({
      status: xhr.status,
      response: xhr.responseText
    });
    xhr.onerror = () => resolve({
      status: xhr.status,
      response: xhr.responseText
    });
    if (method != 'GET') xhr.setRequestHeader('Content-Type', 'application/json');
    data != {} ? xhr.send(JSON.stringify(data)) : xhr.send();
  })
}

async function toDataURL1(url, callback) {
    let request = await makeRequest(url);
    var reader = new FileReader();
    reader.readAsDataURL(request.response);
    console.log("toDataURL1")
}

// img convert to data base64
async function toDataURL(imgNode, callback) {
    var url = imgNode.src
    var xhr = new XMLHttpRequest();
    xhr.onload = function() {
        var reader = new FileReader();
        reader.onloadend = function() {
            dataUrl = reader.result
            callback(imgNode, dataUrl);
        }
        reader.readAsDataURL(xhr.response);
    };
    xhr.open('GET', url);
    xhr.responseType = 'blob';
    xhr.send();
}

// toDataURL(document.querySelector('img').src, function(reader) {
// const imgCallback = function(imgNode, dataUrl) {
function imgCallback(imgNode, dataUrl) {
    imgNode.src = dataUrl
    console.log('RESULT:', dataUrl)
}

// var imgNode = document.querySelector('img')
// toDataURL(imgNode, imgCallback)

var path = process.argv.slice(2)[0];
console.log(path)

var fs = require("fs");
var content = fs.readFileSync(path);

const jsdom = require("jsdom")
const { JSDOM } = jsdom
global.DOMParser = new JSDOM().window.DOMParser
const parser = new DOMParser();
const virtualDoc = parser.parseFromString(content, 'text/html')

var imgs = virtualDoc.querySelectorAll('img')

function imgForEachCallback(imgNode) {
    toDataURL(imgNode, imgCallback)
}

imgs.forEach(imgForEachCallback);

fs.writeFileSync(path,content);

