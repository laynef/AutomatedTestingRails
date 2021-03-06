path = __dir__ + '/routes.rb'
outpath = __dir__ + '/../app/assets/javascripts/docs.js'
textArray = []
File.open(path).each_line do |line|
    textArray.push(line)
end
textArray.shift
textArray.shift
textArray.pop

allRoutes = []
textArray.each do |line|
    newLine = line
    newLine = newLine.split(' ')
    method = newLine[0].upcase
    routePath = newLine[1].split('')
    routePath.shift
    routePath.pop
    route = routePath.join('')
    allRoutes.push({ method: method, route: route })
end

javascriptString = ''
allRoutes.each do |route| 
    camelCased = ''
    camelCased += route[:method].downcase
    
    tempRoute = route[:route]

    tempRoute.split('/').each do |line|
        cap = line[0]
        if cap == ':'
            line[0] = ''
            camelCased += line.capitalize + 'Param'
        else
            camelCased += line.capitalize       
        end
    end

    javascriptString += "window.#{camelCased} = function() {
var allData = {
    method: '#{route[:method]}',
    route: '#{route[:route]}',
};
var paramList = document.getElementById('#{camelCased}ParamsForm') && document.getElementById('#{camelCased}ParamsForm').elements ? document.getElementById('#{camelCased}ParamsForm').elements : [];

var csrfToken = document.querySelector('meta[name=\"csrf-token\"]').getAttribute('content');
var csrfHeader = { headers: { 'X-CSRF-Token': null } };
csrfHeader.headers['X-CSRF-Token'] = csrfToken;
var jsonWebToken = document.getElementById('#{camelCased}AuthorizationToken');
if (jsonWebToken && jsonWebToken.value) csrfHeader.headers['Authorization'] = jsonWebToken.value;

var paramObject = {};
var tempParamKey = null;
for (var i = 0; i < paramList.length; i++) {
var eleParam = paramList[i].value;
if (i % 2 !== 0) {
    paramObject[':' + tempParamKey] = eleParam;
    tempParamKey = null;
} else {
    tempParamKey = eleParam;
}
}

var routeName = allData.route.split('/').map(e => paramObject[e] ? paramObject[e] : e).join('/');

if (allData.method !== 'GET' || allData.method !== 'DELETE') {
var bodyDataType = document.getElementById('#{camelCased}DataType') && document.getElementById('#{camelCased}DataType').value ? document.getElementById('#{camelCased}DataType').value : false;
var formBoolean = bodyDataType === 'Form Data';

var bodyElements = [];
var bodyRawElements = document.getElementById('#{camelCased}BodyForm') && document.getElementById('#{camelCased}BodyForm').elements ? document.getElementById('#{camelCased}BodyForm').elements : [];
for (var i = 0; i < bodyRawElements.length; i++) {
    var eleParam = bodyRawElements[i].value || null;
    bodyElements.push(eleParam);
}

bodyElements = bodyElements.filter(e => !!e);

var bodyObject = bodyDataType === 'Form Data' ? new FormData() : {};
var tempBodyKey = null;
bodyElements.forEach((e, i) => {
    if (i % 2 !== 0) {
        if (formBoolean) {
            bodyObject.append(tempBodyKey, e);
            tempBodyKey = null;
        } else {
            bodyObject[tempBodyKey] = e;
            tempBodyKey = null;
        }
    } else {
        if (formBoolean) {
            tempBodyKey = e;
        } else {
            bodyObject[e] = null;
            tempBodyKey = e;
        }
    }
});
}

var qsElements = [];
var qsRawElements = document.getElementById('#{camelCased}QSForm') && document.getElementById('#{camelCased}QSForm').elements ? document.getElementById('#{camelCased}QSForm').elements : [];
for (var i = 0; i < qsRawElements.length; i++) {
var eleParam = qsRawElements[i].value || null;
qsElements.push(eleParam);
}

qsElements = qsElements.filter(e => !!e);

var qsObject = {};
var tempQSKey = null;
qsElements.forEach((e, i) => {
if (i % 2 !== 0) {
    qsObject[tempQSKey] = e;
    tempQSKey = null;
} else {
    qsObject[e] = null;
    tempQSKey = e;
}
});

var qsLength = Object.keys(qsObject).length;
var querystring = qsLength > 0 ? '?' : '';
var qsCount = 0;
if (querystring === '?') {
for (var qs in qsObject) {
    if (qsLength - 1 === qsCount) {
        querystring += qs + '=' + qsObject[qs];
    } else {
        querystring += qs + '=' + qsObject[qs] + '&';
    }
}
}

var args = allData.method === 'GET' || allData.method === 'DELETE' ? [routeName + querystring, csrfHeader] : [routeName + querystring, bodyObject, csrfHeader];
var resultElement = document.getElementById('#{camelCased}-results');

axios[allData.method.toLowerCase()](...args)
.then((resp) => {
    if (resp.status <= 300) {
        resultElement.innerText = JSON.stringify(resp.data, null, 4);
    } else {
        resultElement.innerText = JSON.stringify(resp.data, null, 4);
    }
})
.catch((err) => {
    resultElement.innerText = JSON.stringify(err.data, null, 4);
});
};
"

    javascriptString += "window.#{camelCased}NewBody = function() {
var ele = document.getElementById('#{camelCased}BodyForm');
ele.innerHTML += '<div class=\"d-flex f-row\"><input class=\"w-100 m-1 form-control\" type=\"text\" placeholder=\"Enter key\"><input class=\"w-100 m-1 form-control\" type=\"text\" placeholder=\"Enter value\"></div>';
};

"

    javascriptString += "window.#{camelCased}NewBodyFile = function() {
var ele = document.getElementById('#{camelCased}BodyForm');
ele.innerHTML += '<div class=\"d-flex f-row\"><input class=\"w-100 m-1 form-control\" type=\"text\" placeholder=\"Enter key\"><input class=\"w-100 m-1 form-control\" type=\"file\" placeholder=\"Enter value\"></div>';
};

"

    javascriptString += "window.#{camelCased}NewQS = function() {
var ele = document.getElementById('#{camelCased}QSForm');
ele.innerHTML += '<div class=\"d-flex f-row\"><input class=\"w-100 m-1 form-control\" type=\"text\" placeholder=\"Enter key\"><input class=\"w-100 m-1 form-control\" type=\"text\" placeholder=\"Enter value\"></div>';
};
"
end

File.open(outpath, "w+") do |f|
    f.write(javascriptString)
end