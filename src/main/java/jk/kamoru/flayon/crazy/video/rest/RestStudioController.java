package jk.kamoru.flayon.crazy.video.rest;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jk.kamoru.flayon.crazy.video.domain.Studio;
import jk.kamoru.flayon.crazy.video.service.VideoService;

@RestController
@RequestMapping("/rest/studio")
public class RestStudioController {

	@Autowired VideoService videoService;

	@RequestMapping(method=RequestMethod.GET)
	public List<Studio> list(
			@RequestParam(value="i", required=false, defaultValue="true") boolean instance,
			@RequestParam(value="a", required=false, defaultValue="false") boolean archive) {
		return videoService.getStudioList(instance, archive);
	}

	@RequestMapping(value="/{name}", method=RequestMethod.GET)
	public Studio studio(@PathVariable String name) {
		return videoService.getStudio(name);
	}

	@RequestMapping(method=RequestMethod.PUT)
	public Studio saveStudioInfo(@RequestParam Map<String, String> params) {
		return videoService.saveStudioInfo(params);
	}

}
