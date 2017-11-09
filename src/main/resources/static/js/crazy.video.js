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
	this.coverURL     = PATH + "/video/" + data.opus + "/cover";
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
	this.label_fullname        = VideoUtils.wrapLabel(this.fullname,    this.fullname, "fnVideoDetail('" + this.opus + "')");
	this.label_title           = VideoUtils.wrapLabel(this.title,       this.title,    "fnVideoDetail('" + this.opus + "')",            '', {fontSize: '85%'});
	this.label_studio          = VideoUtils.wrapLabel(this.studio.name, '',            "fnViewStudioDetail('" + this.studio.name + "')");
	this.label_opus            = VideoUtils.wrapLabel(this.opus,        '',            "fnVideoDetail('" + this.opus + "')");
	this.label_release         = VideoUtils.wrapLabel(this.releaseDate);
	this.label_modified        = VideoUtils.wrapLabel(this.videoDate);
	this.label_score           = VideoUtils.wrapLabel('S ' + this.score);
	this.label_rank            = VideoUtils.wrapLabel("R " + this.rank);
	this.label_video           = VideoUtils.wrapLabel("Video", '', this.existVideoFileList     ? "fnPlay('" + this.opus + "')" : "",          this.existVideoFileList ? "exist" : "nonExist");
	this.label_subtitles       = VideoUtils.wrapLabel("Sub",   '', this.existSubtitlesFileList ? "fnEditSubtitles('" + this.opus + "')" : "", this.existSubtitlesFileList ? "exist" : "nonExist");
	this.label_overview		   = VideoUtils.wrapLabel(this.overviewText, '', '', '', {color: 'rgba(250,0,230,.5)'});
	this.label_favorite        = this.favorite ? VideoUtils.wrapLabel("Fav", "", "", "label-success") : "";
	this.label_actress         = function() {
		var elements = [];
		$.each(data.actressList, function(index, actress) {
			index > 0 && elements.push("&nbsp;");
			elements.push(VideoUtils.wrapLabel(actress.name, '', "fnViewActressDetail('" + actress.name + "')", actress.favorite ? "favorite" : ""));
		});
		return elements;
	};
	this.label_videoCandidates = function() {
		var elements = [];
		$.each(data.videoCandidates, function(index, candidate) {
			index > 0 && elements.push("&nbsp;");
			elements.push(
					$("<span>", {
						opus: data.opus, title: candidate, "class": "nowrap btn btn-xs btn-primary"
					}).css({maxWidth: 200, color: "#fff"}).html(VideoUtils.getFilename(candidate)).data("path", candidate).on("click", function() {
						var $self = $(this);
						var opus = $self.attr("opus");
						var candidate = $self.data("path");
						restCall(PATH + "/rest/video/" + opus + "/confirmCandidate", {method: "PUT", data: {path: candidate}, showLoading: false}, function() {
							showSnackbar("accept file " + opus);
							$self.off().hide();
						});
						$("#check-" + opus).addClass("found");
					})
			);
		});
		return elements;
	};
	this.label_torrentSeed = function() {
		var elements = [];
		$.each(data.torrents, function(index, torrent) {
			index > 0 && elements.push("&nbsp;");
			elements.push(
					$("<span>", {
						opus: data.opus, title: torrent, "class": "nowrap btn btn-xs btn-warning"
					}).css({maxWidth: 200, color: "#fff"}).html(VideoUtils.getFilename(torrent)).on("click", function() {
						var opus = $(this).attr("opus");
						restCall(PATH + "/rest/video/" + opus + "/moveTorrentToSeed", {method: "PUT", showLoading: false});
						showSnackbar("move torrent " + opus);
						$("#check-" + opus).addClass("moved");
						$(this).off().hide();
					})
			);
		});
		return elements;
	};
	this.label_seedFindBtn = function() {
		return $("<span>").addClass("label label-info pointer").attr({title: "Search torrent"}).data("opus", data.opus).html("Find").on("click", function() {
			var opus = $(this).data("opus");
			$("#check-" + opus).addClass("found");
			fnSearchTorrent(opus);
//			popup(PATH + '/video/' + opus + '/cover/title', 'SearchTorrentCover', 800, 600);
		})
	};
}

var VideoUtils = {
		getFilename: function(file) {
			var lastIndex = file.lastIndexOf("\\");
			lastIndex < 0 && (lastIndex = file.lastIndexOf("/"));
			return file.substring(lastIndex + 1, file.length);
		},
		wrapLabel: function(html, title, onclick, extClass, extCss, extAttr) {
			var $span = $("<span>").addClass("label label-plain").html(html);
			title    &&    title != '' && $span.attr("title", title);
			onclick  &&  onclick != '' && $span.attr("onclick", onclick);
			extClass && extClass != '' && $span.addClass(extClass);
			extCss   &&   extCss != '' && $span.css(extCss);
			extAttr  &&  extAttr != '' && $span.attr(extAttr);
			return $span.clone().wrapAll("<div/>").parent().html();
		}
};
