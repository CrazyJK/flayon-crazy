package jk.kamoru.flayon.crazy.video;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import jk.kamoru.flayon.crazy.video.domain.VTag;
import jk.kamoru.flayon.crazy.video.service.TagService;
import jk.kamoru.flayon.crazy.video.service.VideoService;

@RestController
@RequestMapping("/rest/tag")
public class TagRestController {

	@Autowired TagService tagService;
	@Autowired VideoService videoService;

	@RequestMapping(value="/{tagId}", method=RequestMethod.GET)
	public VTag viewTag(@PathVariable Integer tagId) {
		return tagService.getTag(tagId);
	}

	@RequestMapping(method=RequestMethod.GET)
	public List<VTag> tagList() {
		return tagService.getTagList();
	}

	@RequestMapping(method=RequestMethod.PUT)
	public VTag updateTag(@ModelAttribute VTag tag) {
		return tagService.updateTag(tag);
	}
	
	@RequestMapping(method=RequestMethod.DELETE)
	public Boolean deleteTag(@ModelAttribute VTag tag) {
		return tagService.deleteTag(tag);
	}
	
	@RequestMapping(method=RequestMethod.POST)
	@ResponseStatus(HttpStatus.CREATED)
	public VTag saveTag(@ModelAttribute VTag tag, @RequestParam(value="opus", required=false, defaultValue="") String opus) {
		VTag createTag = tagService.createTag(tag);
		if (opus.length() > 0)
			videoService.toggleTag(createTag, opus);
		return createTag;
	}

}
