package jk.kamoru.flayon.crazy.video.service;

import java.util.List;

import jk.kamoru.flayon.crazy.video.domain.VTag;
import jk.kamoru.flayon.crazy.video.domain.Video;

public interface TagService {

	VTag getTag(Integer id);

	List<VTag> getTagList();

	List<VTag> getTagListWithVideo();

	VTag createTag(VTag tag);

	VTag updateTag(VTag tag);

	boolean deleteTag(VTag tag);

	List<Video> likeVideo(VTag tag);

}
