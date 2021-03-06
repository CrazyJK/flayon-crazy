package jk.kamoru.flayon.crazy.video;

import java.io.File;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import jk.kamoru.flayon.crazy.CrazyConfig;
import jk.kamoru.flayon.crazy.video.daemon.VideoBatch;
import jk.kamoru.flayon.crazy.video.domain.History;
import jk.kamoru.flayon.crazy.video.domain.HistoryData;
import jk.kamoru.flayon.crazy.video.domain.Sort;
import jk.kamoru.flayon.crazy.video.domain.TistoryGraviaItem;
import jk.kamoru.flayon.crazy.video.domain.VTag;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.service.HistoryService;
import jk.kamoru.flayon.crazy.video.service.VideoService;

@RestController
@RequestMapping("/rest/video")
public class VideoRestController {

	@Autowired VideoService videoService;
	@Autowired VideoBatch videoBatch;
	@Autowired HistoryService historyService;
	@Autowired CrazyConfig config;

	@RequestMapping(method=RequestMethod.GET)
	public List<Video> videoList(
			@RequestParam(value="i", required=false, defaultValue="true") boolean instance,
			@RequestParam(value="a", required=false, defaultValue="false") boolean archive,
			@RequestParam(value="o", required=false) Sort sort,
			@RequestParam(value="r", required=false, defaultValue="true") boolean reverse,
			@RequestParam(value="t", required=false, defaultValue="false") Boolean withCandidate,
			@RequestParam(value="v", required=false, defaultValue="false") Boolean existVideo,
			@RequestParam(value="p", required=false, defaultValue="1") Integer page,
			@RequestParam(value="s", required=false, defaultValue="10") Integer size) {
		return paging(videoService.getVideoList(instance, archive, sort, reverse, withCandidate, existVideo), page, size);
	}

	<T> List<T> paging(List<T> list, int page, int size) {
		if (page == 0)
			return list;
		
		int total = list.size();
		int from = Math.min((page - 1) * size, total);
		int to   = Math.min(from + size, total);		
		return list.subList(from, to);
	}
	
	@RequestMapping(value="/{opus}", method=RequestMethod.GET)
	public Video video(@PathVariable String opus) {
		return videoService.getVideo(opus);
	}

	@RequestMapping(value="/{opus}", method=RequestMethod.DELETE)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void deleteVideo(@PathVariable("opus") String opus) {
		videoService.removeVideo(opus);
	}

	@RequestMapping(value="/{opus}/exec/play", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void execVideoPlayer(@PathVariable String opus) {
		videoService.playVideo(opus);
	}

	@RequestMapping(value="/{opus}/exec/subtitles", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void execSubtitlesEditor(@PathVariable String opus) {
		videoService.editVideoSubtitles(opus);
	}

	@RequestMapping(value="/{opus}/rank/{rank}", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void putVideoRank(@PathVariable String opus, @PathVariable int rank) {
		videoService.rankVideo(opus, rank);
	}

	@RequestMapping(value="/{opus}/reset", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void videoReset(@PathVariable String opus) {
		videoService.resetVideoScore(opus);
	}

	@RequestMapping(value="/{opus}/wrong", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void videoWrong(@PathVariable String opus) {
		videoService.resetWrongVideo(opus);
	}

	@RequestMapping(value="/{opus}/tag", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void toggleTag(@ModelAttribute VTag tag, @PathVariable String opus) {
		videoService.toggleTag(tag, opus);
	}

	@RequestMapping(value="/{opus}/moveTorrentToSeed", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void moveTorrentToSeed(@PathVariable String opus) {
		videoService.moveTorrentToSeed(opus);
	}

	@RequestMapping(value="/{opus}/confirmCandidate", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void confirmCandidate(@PathVariable String opus, @RequestParam("path") String path, @RequestParam("type") char type) {
		videoService.confirmCandidate(opus, path, type);
	}

	@RequestMapping(value="/{opus}/saveCover", method=RequestMethod.POST)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void saveCover(@PathVariable String opus, @RequestParam String title) {
		videoService.saveCover(opus, title);
	}
	
	@RequestMapping(value="/{opus}/overview", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void opusOverviewPost(@PathVariable("opus") String opus, @RequestParam("overview") String overview) {
		videoService.saveVideoOverview(opus, overview);
	}

	@RequestMapping(value="/{opus}/rename", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void rename(@PathVariable("opus") String opus, @RequestParam("newname") String newName) {
		videoService.rename(opus, newName);
	}

	@RequestMapping(value="/{opus}/moveToInstance", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void moveToInstance(@PathVariable String opus) {
		videoService.moveToInstance(opus);
	}

	@RequestMapping("/search/{query}")
	public Map<String, List<Map<String, String>>> searchJson(@PathVariable String query) {
		Map<String, List<Map<String, String>>> data = new HashMap<>();
		data.put("videoResult",    videoService.findVideoList(query));
		data.put("historyResult",  videoService.findHistory(query));
		data.put("torrentResult",  videoService.findTorrent(query));
		data.put("studioResult",   videoService.findStudio(query));
		return data;
	}
	
	@RequestMapping(value="/batch/option", method=RequestMethod.PUT)
	public Boolean setBatchOption(@RequestParam("k") VideoBatch.Option option, @RequestParam("v") boolean setValue) {
		return videoBatch.setBatchOption(option, setValue);
	}
	
	@RequestMapping(value="/batch/start", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void startVideoBatch(@RequestParam("t") VideoBatch.Type type) {
		videoBatch.startBatch(type);
	}

	@RequestMapping(value="/reload", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void reload() {
		videoService.reload(null);
	}
	
	@RequestMapping(value="/torrent/get", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void torrentGet(@RequestParam("opus") String[] opusArr) {
		videoService.downloadTorrents(opusArr);
	}
	
	@RequestMapping(value="/torrent/seed/move", method=RequestMethod.PUT)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void torrentMove(@RequestParam("seed") File seed) {
		videoService.moveTorrentToSeed(seed);
	}
	
	@RequestMapping(value="/gravia", method=RequestMethod.POST)
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void graviainterviewSaveCover(@RequestParam(value="title", required=true) List<String> titles) {
		videoService.saveCover(titles);
	}

	@RequestMapping("/gravia")
	public List<TistoryGraviaItem> graviainterviewData() {
		return videoService.getTistoryItem();
	}

	@RequestMapping("/history/{pattern}")
	public Collection<HistoryData> historyData(@PathVariable String pattern) {
		return historyService.getGraphData(pattern);
	}

	@RequestMapping("/opus")
	public List<String> opusList() {
		return videoService.getOpusList();
	}

	@RequestMapping("/historyOnDB")
	public List<History> historyOnDB() {
		return historyService.findOnDB();
	}

	@RequestMapping("/history")
	public List<History> history() {
		return historyService.getAll();
	}

}
