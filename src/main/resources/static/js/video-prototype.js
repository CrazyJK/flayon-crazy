/**
 * Video Prototype
 */
function Video(idx, data) {
	this.idx = idx;
	this.studio       = data.studio;      // studio object
	this.opus         = data.opus;
	this.title        = data.title;
	this.actressList  = data.actressList; // actress object list
	this.releaseDate  = data.releaseDate;
	this.etcInfo      = data.etcInfo;
	this.info         = data.info;        // info object
	this.tags         = data.tags;        // tag object list
	this.archive      = data.archive;
	this.favorite     = data.favorite;
	this.overviewText = data.overviewText;
	this.videoDate    = data.videoDate;
	this.playCount    = data.playCount;
	this.rank         = data.rank;
	this.fullname     = data.fullname;
	this.actressName  = data.actressName;
	this.score        = data.score;
	this.scoreDesc    = data.scoreDesc;
	this.fileLength   = data.length; 
	this.coverURL     = "/video/" + data.opus + "/cover";
	// files
	this.videoFileList     = data.videoFileList;     // array
	this.subtitlesFileList = data.subtitlesFileList; // array
	this.coverFile         = data.coverFile;
	this.infoFile          = data.infoFile;
	this.etcFileList       = data.etcFileList;       // array
	this.videoCandidates   = data.videoCandidates;   // array
	this.torrents          = data.torrents;          // array
	this.fileAll           = data.fileAll;           // array

	this.existVideoFileList     = data.videoFileList.length > 0;
	this.existSubtitlesFileList = data.subtitlesFileList.length > 0;
	this.existCoverFile         = data.coverFile != 'null';
	this.existInfoFile          = data.infoFile != 'null';
	this.existEtcFileList       = data.etcFileList.length > 0;
	this.existCandidates        = data.videoCandidates.length > 0;
	this.existTorrents          = data.torrents.length > 0;
	this.existOverview          = data.overviewText != '';
	
	// html
	this.html_fullname        = wrapLabel(this.fullname, this.fullname, "fnVideoDetail('" + this.opus + "')");
	this.html_title           = wrapLabel(this.title, this.title, "fnVideoDetail('" + this.opus + "')");
	this.html_studio          = wrapLabel(this.studio.name, '', "fnViewStudioDetail('" + this.studio.name + "')");
	this.html_opus            = wrapLabel(this.opus);
	this.html_actress         = this.actressHtmlNames();
	this.html_release         = wrapLabel(this.releaseDate);
	this.html_score           = wrapLabel('S ' + this.score, this.scoreDesc);
	this.html_rank            = wrapLabel("R " + this.rank);
	this.html_video           = wrapLabel("Video", '', this.existVideoFileList ? "fnPlay('" + this.opus + "')" : "", this.existVideoFileList ? "exist" : "nonExist");
	this.html_subtitles       = wrapLabel("Sub", '', this.existVideoFileList ? "fnEditSubtitles('" + this.opus + "')" : "", this.existSubtitlesFileList ? "exist" : "nonExist");
	this.html_videoCandidates = this.candidatesNames();
	this.html_torrents        = this.torrentNames();
	this.html_torrentFindBtn  = '<button class="btn btn-xs btn-default" title="Torrent search" onclick="goTorrentSearch(\'' + this.opus + '\',' + this.idx + ');">Find</button>';
	this.html_favorite        = this.favorite ? wrapLabel("Fav", "", "", "label-success") : "";

}

Video.prototype.candidatesNames = function() {
	var html = "";
	for (var i=0; i<this.videoCandidates.length; i++) {
		if (i > 0)
			html += "&nbsp;";
		html += '<form method="post" target="ifrm" action="/video/' + this.opus + '/confirmCandidate" style="display: inline-block;">';
		html += '<input type="hidden" name="path" value="' + this.videoCandidates[i] + '"/>';
		html += '<button type="submit" style="max-width:200px;" class="nowrap btn btn-xs btn-primary" onclick="fnSelectCandidateVideo(\'' + this.opus + '\',' + this.idx + ')" title="' + this.videoCandidates[i] + '">' + getFilename(this.videoCandidates[i]) + '</span>';
		html += '</form>';
	}
	return html + "&nbsp;";
}

Video.prototype.torrentNames = function() {
	var html = "";
	for (var i=0; i<this.torrents.length; i++) {
		if (i > 0)
			html += "&nbsp;";
		html += '<span class="label label-warning" onclick="goTorrentMove(\'' + this.opus + '\',' + this.idx + ')">' + getFilename(this.torrents[i]) + '</span>';
	}
	return html + "&nbsp;";
}

Video.prototype.actressHtmlNames = function() {
	var actressNames = "<div class='nowrap'  title='" + this.actressName + "'>";
	for (var i=0; i<this.actressList.length; i++) {
		var actress = this.actressList[i];
		if (i > 0)
			actressNames += " ";
		actressNames += "<span class='label label-plain " + (actress.favorite ? "favorite" : "") + "' onclick=\"fnViewActressDetail('" + actress.name + "')\">" + actress.name + "</span>";
	}
	return actressNames + "</div>";
}

Video.prototype.play = function() {
	$("#actionIframe").attr("src", videoPath + "/" + this.opus + "/play");
} 

Video.prototype.contains = function(query, isCheckedFavorite) {
	return (isCheckedFavorite === 'true' ? this.favorite : true) 
		&& (this.studio.name.toLowerCase().indexOf(query.toLowerCase()) > -1
		|| this.opus.toLowerCase().indexOf(query.toLowerCase()) > -1
		|| this.title.toLowerCase().indexOf(query.toLowerCase()) > -1
		|| this.actressName.toLowerCase().indexOf(query.toLowerCase()) > -1
		|| this.releaseDate.toLowerCase().indexOf(query.toLowerCase()) > -1);
}

function getFilename(file) {
	var lastIndex = file.lastIndexOf("\\");
	if (lastIndex < 0)
		lastIndex = file.lastIndexOf("/");
	return file.substring(lastIndex + 1, file.length);
}

function videoSort(list, sort, reverse) {
	
	list.sort(function(video1, video2) {
		switch(sort) {
		case 'S':
			return compareTo(video1.studio.name, video2.studio.name, reverse); 
		case 'O':
			return compareTo(video1.opus, video2.opus, reverse); 
		case 'T':
			return compareTo(video1.title, video2.title, reverse); 
		case 'A':
			return compareTo(video1.actress, video2.actress, reverse); 
		case 'D':
			return compareTo(video1.releaseDate, video2.releaseDate, reverse); 
		case 'R':
			return compareTo(video1.rank, video2.rank, reverse); 
		case 'SC':
			return compareTo(video1.score, video2.score, reverse); 
		case 'T':
			return compareTo(video1.torrents.length, video2.torrents.length, reverse); 
		case 'F':
			return compareTo(video1.favorite, video2.favorite, reverse); 
		case 'C':
			var result = compareTo(video1.existCandidates, video2.existCandidates, reverse);
			if (result == 0)
				result = compareTo(video1.favorite, video2.favorite, reverse);
			if (result == 0)
				result = compareTo(video1.existTorrents, video2.existTorrents, reverse);
			if (result == 0)
				result = compareTo(video1.opus, video2.opus, reverse); 
			return result; 
		default:
			return video1.title > video2.title ? 1 : -1;
		}
	});

}

function compareTo(data1, data2, reverse) {
	var result = 0;
	if (typeof data1 === 'number') {
		result = data1 - data2;
	} else if (typeof data1 === 'string') {
		result = data1.toLowerCase() > data2.toLowerCase() ? 1 : -1;
	} else if (typeof data1 === 'boolean') {
		result = data1 ? 1 : (data2 ? -1 : 0);
	} else {
		result = data1 > data2 ? 1 : -1;
	}
	return result * (reverse ? -1 : 1);
}

function wrapLabel(html, title, onclick, extClass) {
	var span = $("<span>").addClass("label label-plain");
	span.html(html);
	if (title != '')
		span.attr("title", title);
	if (onclick != '')
		span.attr("onclick", onclick);
	if (extClass != '')
		span.addClass(extClass);
	return span.clone().wrapAll("<div/>").parent().html();
}


