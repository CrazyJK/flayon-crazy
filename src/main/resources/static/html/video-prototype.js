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

	this.titleHtml   = "<span class='label label-plain' onclick=\"fnVideoDetail('" + this.opus + "')\">" + this.title + "</span>";
	this.studioHtml  = "<span class='label label-plain' onclick=\"fnViewStudioDetail('" + this.studio.name + "')\">" + this.studio.name + "</span>";
	this.opusHtml    = "<span class='label label-plain'>" + this.opus + "</span>";
	this.actressHtml = this.actressHtmlNames();
	this.releaseHtml = "<span class='label label-plain'>" + this.releaseDate + "</span>";

	this.actress = this.actressNames();

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
	return actressNames;
}

Video.prototype.play = function() {
	$("#actionIframe").attr("src", videoPath + "/" + this.opus + "/play");
} 