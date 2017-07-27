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
//	this.info         = data.info;        // info object
	this.tags         = data.tags;        // tag object list
	this.archive      = data.archive;
	this.favorite     = data.favorite;
	this.overviewText = data.overviewText;
	this.videoDate    = data.videoDate;
	this.playCount    = data.playCount;
	this.rank         = data.rank;
	this.fullname     = "[" + data.studio.name + "][" + data.opus + "][" + data.title + "][" + data.actressName + "][" + data.releaseDate + "]";
	this.actressName  = data.actressName;
	this.score        = data.score;
//	this.scoreDesc    = data.scoreDesc;
	this.fileLength   = data.length; 
	this.coverURL     = videoPath + "/" + data.opus + "/cover";
	// files
//	this.videoFileList     = data.videoFileList;     // array
//	this.subtitlesFileList = data.subtitlesFileList; // array
//	this.coverFile         = data.coverFile;
//	this.infoFile          = data.infoFile;
	this.etcFileList       = data.etcFileList;       // array
	this.videoCandidates   = data.videoCandidates;   // array
	this.torrents          = data.torrents;          // array
	this.fileAll           = data.fileAll;           // array

	this.existVideoFileList     = data.existVideoFileList;     //data.videoFileList.length > 0;
	this.existSubtitlesFileList = data.existSubtitlesFileList; //data.subtitlesFileList.length > 0;
	this.existCoverFile         = data.existCoverFile;         //data.coverFile != 'null';
	this.existInfoFile          = data.existInfoFile;
	this.existEtcFileList       = data.etcFileList.length > 0;
	this.existCandidates        = data.videoCandidates.length > 0;
	this.existTorrents          = data.torrents.length > 0;
	this.existOverview          = data.overviewText != '';
	
	// html
	this.html_fullname        = wrapLabel(this.fullname, this.fullname, "fnVideoDetail('" + this.opus + "')");
	this.html_title           = wrapLabel(this.title, this.title, "fnVideoDetail('" + this.opus + "')", '', {fontSize: '85%'});
	this.html_studio          = wrapLabel(this.studio.name, '', "fnViewStudioDetail('" + this.studio.name + "')");
	this.html_opus            = wrapLabel(this.opus);
	this.html_actress         = this.actressHtmlNames();
	this.html_release         = wrapLabel(this.releaseDate);
	this.html_modified        = wrapLabel(this.videoDate);
	this.html_score           = wrapLabel('S ' + this.score);
	this.html_rank            = wrapLabel("R " + this.rank);
	this.html_video           = wrapLabel("Video", '', this.existVideoFileList ? "fnPlay('" + this.opus + "')" : "", this.existVideoFileList ? "exist" : "nonExist");
	this.html_subtitles       = wrapLabel("Sub", '', this.existSubtitlesFileList ? "fnEditSubtitles('" + this.opus + "')" : "", this.existSubtitlesFileList ? "exist" : "nonExist");
	this.html_videoCandidates = this.candidatesNames();
	this.html_torrents        = this.torrentNames();
	this.html_torrentFindBtn  = '<span class="label label-info" title="Torrent search" onclick="goTorrentSearch(\'' + this.opus + '\',' + this.idx + ');">Find</span>';
	this.html_favorite        = this.favorite ? wrapLabel("Fav", "", "", "label-success") : "";
	this.html_overview		  = wrapLabel(this.overviewText, '', '', '', {color: 'rgba(250,0,230,.5)'});
}

Video.prototype.candidatesNames = function() {
	var html = '';
	for (var i=0; i<this.videoCandidates.length; i++) {
		if (i > 0)
			html += "&nbsp;";
		html += '<form method="post" target="ifrm" action="' + videoPath + '/' + this.opus + '/confirmCandidate" style="display: inline-block;" data-candidate="' + this.opus + '-' + i + '">';
		html += '<input type="hidden" name="path" value="' + this.videoCandidates[i] + '"/>';
		html += '<button type="submit" style="max-width:200px;" class="nowrap btn btn-xs btn-primary" onclick="fnSelectCandidateVideo(\'' + this.opus + '\',' + this.idx  + ',' + i + ')" title="' + this.videoCandidates[i] + '">' + getFilename(this.videoCandidates[i]) + '</button>';
		html += '</form>';
	}
	return html;
}

Video.prototype.torrentNames = function() {
	var html = "";
	for (var i=0; i<this.torrents.length; i++) {
		if (i > 0)
			html += "&nbsp;";
		html += '<span class="label label-warning" data-torrent="' + this.opus + '-' + i + '" onclick="goTorrentMove(\'' + this.opus + '\',' + this.idx  + ',' + i + ')">' + getFilename(this.torrents[i]) + '</span>';
	}
	return html;
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

Video.prototype.contains = function(query, isCheckedFavorite, isCheckedNoVideo, isCheckedTags) {
	return (this.fullname.toLowerCase().indexOf(query.toLowerCase()) > -1 || this.overviewText.toLowerCase().indexOf(query.toLowerCase()) > -1)
		&& (isCheckedFavorite ?  this.favorite             : true)
		&& (isCheckedNoVideo  ? !this.existVideoFileList   : true)
		&& (isCheckedTags     ? containsTag(this) : true);
}

function containsTag(video) {
	if (video.tags.length > 0)
		return true;
	for (var i=0; i<tagList.length; i++) {
		var tag = tagList[i];
		if (video.fullname.toLowerCase().indexOf(tag.name.toLowerCase()) > -1) {
			return true;
		}
	}
	return false;
}

function getFilename(file) {
	var lastIndex = file.lastIndexOf("\\");
	if (lastIndex < 0)
		lastIndex = file.lastIndexOf("/");
	return file.substring(lastIndex + 1, file.length);
}

/**
 * wrap span tag
 * @param html
 * @param title
 * @param onclick
 * @param extClass
 * @param extCss
 * @returns
 */
function wrapLabel(html, title, onclick, extClass, extCss) {
	var span = $("<span>").addClass("label label-plain");
	span.html(html);
	if (title && title != '')
		span.attr("title", title);
	if (onclick && onclick != '')
		span.attr("onclick", onclick);
	if (extClass && extClass != '')
		span.addClass(extClass);
	if (extCss && extCss != '')
		span.css(extCss);
	return span.clone().wrapAll("<div/>").parent().html();
}


