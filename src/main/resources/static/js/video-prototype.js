/**
 * Video Prototype
 */
function Video(data) {
	this.studio = data.studio;
	this.opus = data.opus;
	this.title = data.title;
	this.actressList = data.actressList;
	this.releaseDate = data.releaseDate;
	this.fullname = data.fullname;
	this.coverURL = "/video/" + this.opus + "/cover";
	this.score = data.score;
	this.rank = data.rank;
	this.existVideoFileList = data.existVideoFileList;
	this.existSubtitlesFileList = data.existSubtitlesFileList;
	this.favorite = data.favorite;
	this.torrents = data.torrents;
	this.existTorrents = data.torrents.length > 0;
	this.videoCandidates = data.videoCandidates;
	this.existCandidates = data.videoCandidates.length > 0;
	
	this.fullnameHtml   = "<span class='label label-plain' onclick=\"fnVideoDetail('" + this.opus + "')\">" + this.fullname + "</span>";
	this.titleHtml   = "<span class='label label-plain' onclick=\"fnVideoDetail('" + this.opus + "')\">" + this.title + "</span>";
	this.studioHtml  = "<span class='label label-plain' onclick=\"fnViewStudioDetail('" + this.studio.name + "')\">" + this.studio.name + "</span>";
	this.opusHtml    = "<span class='label label-plain'>" + this.opus + "</span>";
	this.actressHtml = this.actressHtmlNames();
	this.releaseHtml = "<span class='label label-plain'>" + this.releaseDate + "</span>";
	this.scoreHtml = "<span class='label label-plain'>" + this.score + "</span>";
	this.rankHtml = "<span class='label label-plain'>R " + this.rank + "</span>";
	this.existVideoHtml = "<span class='label label-plain " + (this.existVideoFileList ? "exist" : "nonExist") + "' onclick=\"fnPlay('" + this.opus + "')\">Video</span>";
	this.existSubtitlesHtml = "<span class='label label-plain " + (this.existSubtitlesFileList ? "exist" : "nonExist") + "'>Sub</span>";

	this.actress = this.actressNames();

	this.torrentsHtml = this.torrentNames();
	this.torrentFindBtn = "<button class='btn btn-xs btn-info' onclick=\"goTorrentSearch('" + this.opus + "');\">Find</button>";
	this.favoriteHtml = this.favorite ? '<span class="label label-success">Fav</span>' : '';

	this.videoCandidatesHtml = this.candidatesNames();
}



Video.prototype.candidatesNames = function() {
	var html = "";
	for (var i=0; i<this.videoCandidates.length; i++) {
		if (i > 0)
			html += "&nbsp;";
		html += '<form method="post" target="ifrm" action="/video/' + this.opus + '/confirmCandidate" style="display: inline-block;">';
		html += '<input type="hidden" name="path" value="' + this.videoCandidates[i] + '"/>';
		html += '<button type="submit" class="btn btn-xs btn-primary" onclick="fnSelectCandidateVideo(this)">' + getFilename(this.videoCandidates[i]) + '</span>';
		html += '</form>';
	}
	return html + "&nbsp;";
}

Video.prototype.torrentNames = function() {
	var html = "";
	for (var i=0; i<this.torrents.length; i++) {
		if (i > 0)
			html += "&nbsp;";
		html += "<span class='label label-warning' onclick=\"goTorrentMove('" + this.opus + "')\">" + getFilename(this.torrents[i]) + "</span>";
	}
	return html + "&nbsp;";
}

Video.prototype.actressNames = function() {
	var actressNames = "";
	for (var i=0; i<this.actressList.length; i++) {
		var actress = this.actressList[i];
		if (i > 0)
			actressNames += ", ";
		actressNames += actress.name;
	}
	return actressNames;
}

Video.prototype.actressHtmlNames = function() {
	var actressNames = "";
	for (var i=0; i<this.actressList.length; i++) {
		var actress = this.actressList[i];
		if (i > 0)
			actressNames += " ";
		actressNames += "<span class='label label-plain' onclick=\"fnViewActressDetail('" + actress.name + "')\">" + actress.name + "</span>";
	}
	return actressNames + "&nbsp;";
}

Video.prototype.play = function() {
	$("#actionIframe").attr("src", videoPath + "/" + this.opus + "/play");
} 

Video.prototype.contains = function(query) {
	return this.studio.name.toLowerCase().indexOf(query.toLowerCase()) > -1
		|| this.opus.toLowerCase().indexOf(query.toLowerCase()) > -1
		|| this.title.toLowerCase().indexOf(query.toLowerCase()) > -1
		|| this.actress.toLowerCase().indexOf(query.toLowerCase()) > -1
		|| this.releaseDate.toLowerCase().indexOf(query.toLowerCase()) > -1
		|| (query.toLowerCase().indexOf('fav') > -1 ? this.favorite : false);
}

function getFilename(file) {
	var lastIndex = file.lastIndexOf("\\");
	return file.substring(lastIndex + 1, file.length);
}


