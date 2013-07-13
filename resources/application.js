var Shiori = {};
Shiori.callRPCRequest = function (url){
    location.href = url;
};

Shiori.purgeRepositoryName = function (string){
    for (var i = 0; i < string.length; i++) {
	if (string[i] === "/") break;
    }
    return string.slice(i+1, string.length);
};

Shiori.attachClickLineOfCodeEvent = function(){
    $(document).on("mousedown", ".line-number, .blob-line-nums span[rel]", function(e){
	var line = e.currentTarget.innerText;
	var lineOfCode = $("#LC" + line).text().trim();
	var repoAttributes = $("[itemprop=title]");
	var author = repoAttributes[0].innerText;
	var repositoryName = repoAttributes[1].innerText;
	var fileNameWithRepoName = $(".breadcrumb").text().trim().replace(/ /g, "");
	var fileName = Shiori.purgeRepositoryName(fileNameWithRepoName);
	var json = {
	    line: line,
	    line_of_code: lineOfCode,
	    file_name: fileName,
	    author: author,
	    repository_name: repositoryName,
	    url: document.URL
	};
	var encodedParams = encodeURIComponent(JSON.stringify(json));
	var message = "shiori-webview://clickLineOfCode" + encodedParams;
	Shiori.callRPCRequest(message);
    });
};

Shiori.getRepositoryName = function(){
    var repoAttributes = $("[itemprop=title]");
    var author = repoAttributes[0].innerText;
    var repositoryName = repoAttributes[1].innerText;
    return author + "/" + repositoryName;
};

Shiori.executeFinder = function(){
    var event = $.Event("keydown");
    event.hotkey = "t";
    event.target = document.body;
    $(document.body).trigger(event);    
    $("input[name=query]")[0].focus();
};

Shiori.getUserLinks = function(){
  return $("#user-links").find("a").attr("href");
};
