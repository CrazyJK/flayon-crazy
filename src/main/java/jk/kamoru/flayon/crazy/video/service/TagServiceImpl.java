package jk.kamoru.flayon.crazy.video.service;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jk.kamoru.flayon.crazy.video.dao.TagDao;
import jk.kamoru.flayon.crazy.video.dao.VideoDao;
import jk.kamoru.flayon.crazy.video.domain.VTag;
import jk.kamoru.flayon.crazy.video.domain.Video;

@Service
public class TagServiceImpl implements TagService {

	@Autowired TagDao tagDao;
	@Autowired VideoDao videoDao;

	@Override
	public VTag getTag(Integer id) {
		VTag vTag = tagDao.findById(id);
		vTag.getVideoList().clear();
		for (Video video : sortByReleaseReverse(videoDao.getVideoList(true, false))) {
			if (video.getTags() == null)
				continue;
			if (video.getTags().contains(vTag)) {
				vTag.addVideo(video);
			}
		}
		return vTag;
	}

	@Override
	public List<VTag> getTagList() {
		return tagDao.findAll();
	}

	@Override
	public List<VTag> getTagListWithVideo() {
		List<VTag> allTags = tagDao.findAll();
		List<Video> videoList = videoDao.getVideoList(true, false);
		for (VTag vTag : allTags) {
			vTag.getVideoList().clear();
			for (Video video : videoList) {
				if (video.getTags() == null)
					continue;
				if (video.getTags().contains(vTag)) {
					vTag.addVideo(video);
				}
			}
		}
		return allTags;
	}

	@Override
	public VTag createTag(VTag tag) {
		return tagDao.persist(tag);
	}

	@Override
	public VTag updateTag(VTag tag) {
		VTag updatedTag = tagDao.merge(tag);
		for (Video video : videoDao.getVideoList(true, false)) {
			if (video.getInfo().getTags() == null)
				continue;
			if (video.getInfo().getTags().contains(updatedTag)) {
				video.updateTag(updatedTag);
			}
		}
		return updatedTag;
	}

	@Override
	public boolean deleteTag(VTag tag) {
		boolean deleted = tagDao.remove(tag);
		if (deleted)
			for (Video video : videoDao.getVideoList(true, false)) {
				if (video.getInfo().getTags() == null)
					continue;
				if (video.getInfo().getTags().contains(tag)) {
					video.toggleTag(tag);
				}
			}
		return deleted;
	}

	private List<Video> sortByReleaseReverse(List<Video> videoList) {
		return videoList.stream().sorted((Comparator.comparing(Video::getReleaseDate).reversed())).collect(Collectors.toList());
	}
}
