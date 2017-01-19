package jk.kamoru.flayon.crazy.video.domain;

import java.io.File;
import java.io.IOException;
import java.io.Serializable;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.regex.Pattern;

import org.apache.commons.io.FileExistsException;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.time.DateFormatUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.databind.ObjectMapper;

import jk.kamoru.flayon.crazy.CRAZY;
import jk.kamoru.flayon.crazy.CrazyProperties;
import jk.kamoru.flayon.crazy.Utils;
import jk.kamoru.flayon.crazy.video.VIDEO;
import jk.kamoru.flayon.crazy.video.VideoException;
import jk.kamoru.flayon.crazy.video.util.VideoUtils;

/**
 * AV Bean class<br>
 * include studio, opus, title, overview info and video, cover, subtitles, log file<br>
 * action play, random play, editing subtitles and overview  
 * @author kamoru
 *
 */
@Component
@Scope("prototype")
public class Video extends CrazyProperties implements Comparable<Video>, Serializable, CRAZY {

	private static final long serialVersionUID = VIDEO.SERIAL_VERSION_UID;

	private static final Logger logger = LoggerFactory.getLogger(Video.class);
	
	private Sort sortMethod = VIDEO.DEFAULT_SORTMETHOD;
	
	// files
	private List<File> videoFileList;
	private List<File> subtitlesFileList;
	private File coverFile;
	private File infoFile; // json file
	private List<File> etcFileList;
	private List<File> videoCandidates;
	private List<File> torrents;

	// info
	private Studio studio;
	private String opus;
	private String title;
	private String overview; // overview text
	private String etcInfo;
	private String releaseDate;
	private List<Actress> actressList;
	private Integer playCount;
	private int rank;
	private Info info;
	
	private boolean isArchive;


	public Video() {
		videoFileList 		= new ArrayList<File>();
		subtitlesFileList 	= new ArrayList<File>();
		etcFileList 		= new ArrayList<File>();
		videoCandidates		= new ArrayList<File>();
		torrents			= new ArrayList<>();
		
		actressList = new ArrayList<Actress>();

		playCount 	= 0;
		rank 		= 0;
		overview 	= "";
		
		info = new Info();
	}
	
	/** 
	 * 파일 위치 정렬<br>
	 * 비디오 파일이 있고, {@link #STAGE} 폴더에 위치해 있거나<br>
	 * 커버 파일만 있고, {@link #COVER} 폴더에 위치해 있거나<br>
	 * 아카이브 비디오면, 월별로 구분해 이동
	 */
	public void arrange() {
		logger.trace(opus);

		if (StringUtils.isEmpty(studio.getName()) 
				|| StringUtils.isEmpty(opus)
				|| StringUtils.isEmpty(title)
				|| StringUtils.isEmpty(releaseDate)
				|| !Pattern.matches(REGEX_DATE, releaseDate)
				) {
			logger.warn("Check video : [{}] [{}] archive={} [{}]", opus, releaseDate, isArchive, getDelegatePath());
		}
		else {
			if (isArchive) {
				if (StringUtils.endsWith(this.getDelegatePath(), ARCHIVE))
					move(VideoUtils.makeSubPathByReleaseDate(this));
			}
			else {
				if (this.isExistVideoFileList()) {
					if (StringUtils.endsWith(this.getDelegatePath(), STAGE))
						move(VideoUtils.makeSubPathByReleaseDate(this));
					else
						move(this.getDelegatePath());
				}
				else if (this.isExistCoverFile()) {
					if (StringUtils.endsWith(this.getDelegatePath(), COVER))
						move(VideoUtils.makeSubPathByReleaseDate(this));
					else
						move(this.getDelegatePath());
				}
				else {
					move(this.getDelegatePath());
				}
			}
		}
	}

	@Override
	public int compareTo(Video comp) {
		switch(sortMethod) {
		case S:
			return Utils.compareTo(this.getStudio().getName(), comp.getStudio().getName());
		case O:
			return Utils.compareTo(this.getOpus(), comp.getOpus());
		case T:
			return Utils.compareTo(this.getTitle(), comp.getTitle());
		case A:
			return Utils.compareTo(this.getActressName(), comp.getActressName());
		case D:
			return Utils.compareTo(this.getReleaseDate(), comp.getReleaseDate());
		case M:
			return Utils.compareTo(this.getDelegateFile().lastModified(), comp.getDelegateFile().lastModified());
		case P:
			return Utils.compareTo(this.getPlayCount(), comp.getPlayCount());
		case R:
			return Utils.compareTo(this.getRank(), comp.getRank());
		case L:
			return Utils.compareTo(this.getLength(), comp.getLength());
		case SC:
			return Utils.compareTo(this.getScore(), comp.getScore());
		case VC:
			if (this.videoCandidates.size() > 0) {
				if (comp.videoCandidates.size() == 0) {
					return -1;
				}
			}
			else {
				if (comp.videoCandidates.size() > 0) {
					return 1;
				}
			}
			return Utils.compareTo(this.getStudio().getName(), comp.getStudio().getName());
		default:
			return Utils.compareTo(this, comp);
		}
	}
	
	/**
	 * actress 이름이 있는지 확인. 
	 * @param actressName
	 * @return 같거나 포함되어 있으면 {@code true}
	 */
	public boolean containsActress(String actressName) {
//		return actressList.stream().allMatch(a -> VideoUtils.containsActress(a.getName(), actressName));
		return actressList.stream().anyMatch(a -> VideoUtils.containsActress(a.getName(), actressName));
	}
	
	/**
	 * 전체 배우 이름을 컴마(,)로 구분한 문자로 반환
	 * @return 배우이름 문자열
	 */
	public String getActressName() {
		List<String> list = new ArrayList<String>();
		for(Actress actress : actressList) {
			list.add(actress.getName());
		}
		return VideoUtils.listToSimpleString(list);
	}

	/**
	 * @return actress list
	 */
	public List<Actress> getActressList() {
		return actressList;
	}
	
	/**
	 * cover file의 byte[] 반환
	 * @return 없거나 에러이면 null 반환
	 */
	@JsonIgnore
	public byte[] getCoverByteArray() {
		if (coverFile == null)
			return null;
		try {
			return FileUtils.readFileToByteArray(coverFile);
		} catch (IOException e) {
			logger.error("read cover file error", e);
			return null;
		}
	}
	
	/**
	 * 커버 파일 반환
	 * @return 커버 파일
	 */
	public File getCoverFile() {
		return coverFile;
	}

	/**
	 * cover 파일 절대 경로
	 * @return 없으면 공백
	 */
	@JsonIgnore
	public String getCoverFilePath() {
		if(isExistCoverFile())
			return getCoverFile().getAbsolutePath();
		return "";
	}
	
	/**
	 * video 대표 파일
	 * @return 대표 파일
	 */
	private File getDelegateFile() {
		if (this.isExistVideoFileList()) 
			return this.getVideoFileList().get(0);
		else if (this.isExistCoverFile()) 
			return this.getCoverFile();
		else if (this.isExistSubtitlesFileList()) 
			return this.getSubtitlesFileList().get(0);
		else if (this.isExistEtcFileList()) 
			return this.getEtcFileList().get(0);
		else if (this.infoFile != null) 
			return this.infoFile;
		else 
			throw new VideoException(this, "No delegate video file : " + this.opus + " " + this.toString());
	}

	/**
	 * video 대표 파일 이름. 확장자를 뺀 대표이름
	 * @return 대표 이름
	 */
	private String getDelegateFilenameWithoutSuffix() {
		return Utils.getNameExceptExtension(getDelegateFile());
	}
	
	/**
	 * video 대표 폴더 경로. video > cover > overview > subtitles > etc 순으로 찾는다.
	 * @return 대표 경로
	 */
	@JsonIgnore
	public String getDelegatePath() {
		return this.getDelegateFile().getParent();
	}
	
	/**
	 * video 대표 폴더 경로. video > cover > overview > subtitles > etc 순으로 찾는다.
	 * @return 대표 경로 file
	 */
	@JsonIgnore
	public File getDelegatePathFile() {
		return this.getDelegateFile().getParentFile();
	}

	/**
	 * 기타 파일 
	 * @return etc file list
	 */
	public List<File> getEtcFileList() {
		return etcFileList;
	}
	
	/**
	 * 기타 파일 경로
	 * @return string of etc file list
	 */
	@JsonIgnore
	public String getEtcFileListPath() {
		if(isExistEtcFileList())
			return Utils.toStringComma(getEtcFileList());
		return "";
	}
	
	/**기타 정보. 날짜
	 * @return etc info
	 */
	public String getEtcInfo() {
		return etcInfo;
	}

	/**
	 * 모든 파일 list.
	 * @return all file
	 */
	public List<File> getFileAll() {
		List<File> list = new ArrayList<File>();
		for (File file : getVideoFileList())
			if (file != null)
				list.add(file);
		for (File file : getSubtitlesFileList())
			if (file != null)
				list.add(file);
		for (File file : getEtcFileList())
			if (file != null)
				list.add(file);
		if (coverFile != null)
			list.add(this.coverFile);
		if (infoFile != null)
			list.add(this.infoFile);
		return list;
	}

	@JsonIgnore
	public List<File> getFileWithoutVideo() {
		List<File> list = new ArrayList<File>();
		list.addAll(getSubtitlesFileList());
		list.addAll(getEtcFileList());
		list.add(this.coverFile);
		list.add(this.infoFile);
		return list;
	}

	/**
	 * info 파일 반환. 없으면 대표경로에 만듬.
	 * @return info
	 */
	public File getInfoFile() {
		if(infoFile == null) {
			infoFile = new File(this.getDelegatePath(), this.getDelegateFilenameWithoutSuffix() + "." + VIDEO.EXT_INFO);
			try {
				infoFile.createNewFile();
			} catch (IOException e) {
				logger.error("fail to create info file", e);
			}
		}
		return infoFile;
	}

	/**
	 * info 파일 경로
	 * @return info path
	 */
	@JsonIgnore
	public String getInfoFilePath() {
		return getInfoFile().getAbsolutePath();
	}

	/**
	 * @return 품번
	 */
	public String getOpus() {
		return opus;
	}

	/**
	 * overview
	 * @return overvire text
	 */
	public String getOverviewText() {
		return overview;
	}

	/**
	 * play count
	 * @return count of play
	 */
	public Integer getPlayCount() {
		return playCount;
	}

	/**
	 * rank point
	 * @return rank
	 */
	public int getRank() {
		return rank;
	}

	/**
	 * studio
	 * @return studio class
	 */
	public Studio getStudio() {
		return studio;
	}

	/**
	 * subtitles file list
	 * @return list of subtitles file
	 */
	public List<File> getSubtitlesFileList() {
		return subtitlesFileList;
	}

	/**
	 * subtitles file list path
	 * @return string of sutitles path
	 */
	@JsonIgnore
	public String getSubtitlesFileListPath() {
		if(isExistSubtitlesFileList())
			return Utils.toStringComma(getSubtitlesFileList());
		return "";
	}

	/**
	 * 자막 파일 위치를 배열로 반환, 외부 에디터로 자막 수정시 사용 
	 * @return array of subtitles oath
	 */
	@JsonIgnore
	public String[] getSubtitlesFileListPathArray() {
		if(isExistSubtitlesFileList()) {
			String[] filePathes = new String[this.subtitlesFileList.size()];
			for(int i=0; i<this.subtitlesFileList.size(); i++)
				filePathes[i] = this.subtitlesFileList.get(i).getAbsolutePath();
			return filePathes;
		}
		return null;
	}
	
	/**
	 * video title
	 * @return title
	 */
	public String getTitle() {
		return title;
	}

	/**
	 * video의 대표 날자. video > cover > overview > subtitles > etc 순으로 찾는다.
	 * @return date of video
	 */
	public String getVideoDate() {
		return DateFormatUtils.format(this.getDelegateFile().lastModified(), VIDEO.DATE_PATTERN);
	}

	/**
	 * video file list
	 * @return list of video file
	 */
	public List<File> getVideoFileList() {
		return videoFileList;
	}

	/**
	 * video file list path
	 * @return string of video path
	 */
	@JsonIgnore
	public String getVideoFileListPath() {
		if(isExistVideoFileList()) 
			return Utils.toStringComma(getVideoFileList()); 
		return "";
	}
	
	/**
	 * 비디오 파일 목록 배열. 플레이어 구동시 사용
	 * @return array of video path
	 */
	@JsonIgnore
	public String[] getVideoFileListPathArray() {
		if(isExistVideoFileList()) {
			String[] filePathes = new String[getVideoFileList().size()];
			for(int i=0; i<filePathes.length; i++)
				filePathes[i] = getVideoFileList().get(i).getAbsolutePath();
			return filePathes;
		}
		return null;
	}

	/**비디오 상대 경로 형식의 URL객체
	 * @return url of video
	 */
	@JsonIgnore
	public URL getVideoURL() {
		if (videoFileList == null || videoFileList.size() == 0) {
			return null;
		}
		else {
			File vfile = videoFileList.get(0);
			String pname = vfile.getParentFile().getName();
			
			try {
				return new URL("/" + pname + "/" + vfile.getName());
			} catch (MalformedURLException e) {
//				logger.warn("Error: {}", e.getMessage());
			}
			return null;
		}
	}
	
	/**
	 * play count 증가
	 */
	public void increasePlayCount() {
		this.playCount++;
		this.saveInfo();
	}

	/**
	 * 커버 파일이 존재하는지
	 * @return {@code true} if exist
	 */
	@JsonIgnore
	public boolean isExistCoverFile() {
		return this.coverFile != null;
	}

	/**
	 * 기타 파일이 존재하는지
	 * @return {@code true} if exist
	 */
	@JsonIgnore
	public boolean isExistEtcFileList() {
		return this.etcFileList != null && this.etcFileList.size() > 0;
	}

	/**
	 * overview가 있는지
	 * @return {@code true} if exist
	 */
	@JsonIgnore
	public boolean isExistOverview() {
		return this.overview != null && this.overview.trim().length() > 0;
	}

	/**
	 * 자막 파일이 존재하는지
	 * @return {@code true} if exist
	 */
	@JsonIgnore
	public boolean isExistSubtitlesFileList() {
		return this.subtitlesFileList != null && this.subtitlesFileList.size() > 0;
	}

	/**
	 * 비디오 파일이 존재하는지
	 * @return {@code true} if exist
	 */
	@JsonIgnore
	public boolean isExistVideoFileList() {
		return this.videoFileList != null && this.videoFileList.size() > 0;  
	}

	/**
	 * destDir 폴더로 전체 파일 이동
	 * @param destDir
	 */
	public synchronized void move(String destDir) {
		File destDirFile = new File(destDir);
		if (!destDirFile.exists()) 
			throw new VideoException(this, "directory(" + destDir + ") is not exist!");
		move(destDirFile);
	}

	public synchronized void move(File destDir) {
		for (File file : getFileAll()) {
			if (file != null && file.exists() && !file.getParent().equals(destDir.getAbsolutePath())) {
				if (!Utils.getRootDirectory(file).equals(Utils.getRootDirectory(destDir)) &&
						destDir.getFreeSpace() < file.length()) {
					logger.warn("{} -> {} is small. {}mb > {}mb",file, destDir, file.length() / FileUtils.ONE_MB, destDir.getFreeSpace() / FileUtils.ONE_MB);
					break;
				}
				try {
					FileUtils.moveFileToDirectory(file, destDir, false);
					logger.debug("file moved from [{}] to [{}]", file.getAbsolutePath(), destDir.getAbsolutePath());
				} catch (FileExistsException fe) {
					logger.warn("File exist, then delete", fe);
					FileUtils.deleteQuietly(file);
				} catch (IOException e) {
					logger.error("Fail move file", e);
				}
			}
		}
	}
	
	/**
	 * actress를 추가한다. 기존actress가 발견되면 ref를 갱신.
	 * @param actress
	 */
	public void addActress(Actress actress) {
		boolean notFound = true;
		for (Actress actressInList : this.actressList) {
			if (actressInList.contains(actress.getName())) {
				notFound = false;
				actressInList = actress;
				break;
			}
		}
		if (notFound)
			this.actressList.add(actress);
	}

	/**  
	 * 삭제 처리. 비디오 파일은 지우고 나머지는 archive로 이동
	 */
	public void removeVideo() {
		saveInfo();
		// video delete
		if (videoFileList != null)
			for (File file : videoFileList)
				if(FileUtils.deleteQuietly(file))
					logger.debug(file.getAbsolutePath());
				else
					logger.error("delete fail : {}", file.getAbsolutePath());
		// the others move
		File archiveDir = new File(ARCHIVE_PATH);
		for (File file : getFileWithoutVideo())
			if (file != null)
				try {
					FileUtils.moveFileToDirectory(file, archiveDir, false);
				} catch (FileExistsException e) {
					logger.warn("file exists in archive dir : {}", e.getMessage());
					FileUtils.deleteQuietly(file);
				} catch (IOException e) {
					logger.error("move fail", e);
				}
	}
	
	/**
	 * 싹다 지운다
	 */
	public void deleteVideo() {
		for (File file : getFileAll())
			if (file != null)
				if(FileUtils.deleteQuietly(file))
					logger.debug(file.getAbsolutePath());
				else
					logger.error("delete fail : {}", file.getAbsolutePath());
	}
	
	/**
	 * info 내용 저장
	 */
	private void saveInfo() {
		if (logger.isDebugEnabled())
			logger.debug("saveInfo start");
		
		ObjectMapper mapper = new ObjectMapper();

		info.setOpus(opus);
		info.setPlayCount(playCount);
		info.setRank(rank);
		info.setOverview(overview);
		info.setLastAccess(new Date());

		try {
			mapper.writeValue(getInfoFile(), info);
			if (logger.isDebugEnabled())
				logger.debug("saveInfo {}", info);
		} catch (IOException e) {
			throw new VideoException(this, "fail to write info", e);
		}
	}

	/**
	 * info file 읽어서 필요 데이터(rank, overview, history, playcount) 설정
	 * @param file info file
	 */
	public void setInfoFile(File file) {
		this.infoFile = file;
		
		ObjectMapper mapper = new ObjectMapper();
		
		try {
			info = mapper.readValue(infoFile, Info.class);
			rank = info.getRank();
			playCount = info.getPlayCount();
			overview = info.getOverview();

			if (!this.opus.equalsIgnoreCase(info.getOpus())) 
				throw new VideoException(this, "invalid info file. " + this.opus + " != " + opus);

		} catch (IOException e) {
			info = new Info(opus);
			rank = 0;
			playCount = 0;
			overview = "";
		}
		
	}

	public void setTags(List<VTag> newTags) {
		info.setTags(newTags);
		saveInfo();
	}
	
	public List<VTag> getTags() {
		return info.getTags();
	}
	
	public Info getInfo() {
		return info;
	}
	/**
	 * overview 내용 저장
	 * @param overViewText
	 */
	public void saveOverView(String overViewText) {
		logger.trace("{} [{}]", opus, overViewText);
		this.overview = overViewText;
		this.saveInfo();
	}
	
	/**
	 * actress list
	 * @param actressList
	 */
	public void setActressList(List<Actress> actressList) {
		this.actressList = actressList;
	}

	/**
	 * cover file
	 * @param coverFile
	 */
	public void setCoverFile(File coverFile) {
		this.coverFile = coverFile;
	}

	/**
	 * etc file
	 * @param file
	 */
	public void addEtcFile(File file) {
		this.etcFileList.add(file);		
	}
	
	/**
	 * etc file list
	 * @param etcFileList
	 */
	public void setEtcFileList(List<File> etcFileList) {
		this.etcFileList = etcFileList;
	}
	
	/**
	 * etc info
	 * @param etcInfo
	 */
	public void setEtcInfo(String etcInfo) {
		this.etcInfo = etcInfo;
	}
	
	/**
	 * opus
	 * @param opus
	 */
	public void setOpus(String opus) {
		this.opus = opus;
	}

	/**
	 * play count
	 * @param playCount
	 */
	public void setPlayCount(Integer playCount) {
		this.playCount = playCount;
		this.saveInfo();
	}

	/**
	 * rank. info 파일에 저장
	 * @param rank
	 */
	public void setRank(int rank) {
		logger.trace("{} rank is {}", opus, rank);
		this.rank = rank;
		this.saveInfo();
	}

	/**
	 * sort method. 정렬 방식 
	 * @param sortMethod
	 */
	public Video setSortMethod(Sort sortMethod) {
		this.sortMethod = sortMethod;
		return this;
	}

	/**
	 * studio
	 * @param studio
	 */
	public void setStudio(Studio studio) {
		this.studio = studio;
	}

	/**
	 * add subtitles file
	 * @param file
	 */
	public void addSubtitlesFile(File file) {
		this.subtitlesFileList.add(file);
	}
	
	/**
	 * subtitles file list
	 * @param subtitlesFileList
	 */
	public void setSubtitlesFileList(List<File> subtitlesFileList) {
		this.subtitlesFileList = subtitlesFileList;
	}
	
	/**
	 * title
	 * @param title
	 */
	public void setTitle(String title) {
		this.title = title;
	}

	/**
	 * add video file
	 * @param file
	 */
	public void addVideoFile(File file) {
		this.videoFileList.add(file);
	}

	/**
	 * video file list
	 * @param videoFileList
	 */
	public void setVideoFileList(List<File> videoFileList) {
		this.videoFileList = videoFileList;
	}
	
	public String getReleaseDate() {
		return releaseDate;
	}

	public void setReleaseDate(String releaseDate) {
		this.releaseDate = releaseDate;
	}

	/**
	 * video의 모든 파일 크기
	 * @return entire length of video
	 */
	public long getLength() {
		long length = 0l;
		for (File file : this.getFileAll()) {
			if (file != null)
				length += file.length();
		}
		return length;
	}
	
	/**video full name
	 * @return [studio][opus][title][actress][date]
	 */
	public String getFullname() {
		return String.format("[%s][%s][%s][%s][%s]", studio.getName(), opus, title, getActressName(), StringUtils.isEmpty(releaseDate) ? getVideoDate() : releaseDate);
	}
	
	/**비디오 점수<br>
	 * rank, playCount, actress video count, subtitles count
	 * @return score
	 */
	public int getScore() {
		if (getPlayCount() == 0)
			return 0;
		else
			return getRankScore() + getPlayScore() + getActressScore() + getSubtitlesScore();
	}

	/**자세한 비디오 점수
	 * @return 비디오 점수 설명 
	 */
	public String getScoreDesc() {
		return String.format("Rank[%s]*%s + Play[%s]*%s/10 + Actress[%s]*%s/10 + Subtitles[%s]*%s = %s", 
				getRank(), RANK_RATIO,
				getPlayCount(), PLAY_RATIO,
				getActressScoreDesc(), ACTRESS_RATIO,
				isExistSubtitlesFileList() ? 1 : 0, SUBTITLES_RATIO,
				getScore());
	}
	
	@JsonIgnore
	public String getScoreRatio() {
		return String.format("Score ratio {Rank[%s] Play[%s] Actress[%s] Subtitles[%s]}", RANK_RATIO, PLAY_RATIO, ACTRESS_RATIO, SUBTITLES_RATIO);
	}
	
	/**환산된 랭킹 점수
	 * @return score of rank
	 */
	@JsonIgnore
	public int getRankScore() {
		return getRank() * RANK_RATIO;
	}

	/**환산된 플레이 점수
	 * @return score of play count
	 */
	@JsonIgnore
	public int getPlayScore() {
		return Math.round(getPlayCount() * PLAY_RATIO / 10);
	}

	/**환산된 배우 점수
	 * @return score of actress
	 */
	@JsonIgnore
	public int getActressScore() {
		int actressVideoScore = 0;
		for (Actress actress : getActressList()) {
			actressVideoScore += Math.round(actress.getVideoList().size() * ACTRESS_RATIO / 10);
		}
		return actressVideoScore;
	}
	/**여배우 점수 설명
	 * @return description of actress score
	 */
	@JsonIgnore
	public String getActressScoreDesc() {
		String desc = "";
		boolean first = true;
		for (Actress actress : getActressList()) {
			desc += (first ? "" : "+") + actress.getVideoList().size();
			first = false;
		}
		return desc;
	}
	/**환산된 자막 점수
	 * @return score of subtitles
	 */
	@JsonIgnore
	public int getSubtitlesScore() {
		return (isExistSubtitlesFileList() ? 1 : 0) * SUBTITLES_RATIO;
	}

	/**비디오 파일 후보 추가
	 * @param file
	 */
	public void addVideoCandidates(File file) {
		videoCandidates.add(file);
	}

	/**비디오 파일 후보 getter
	 * @return list of the videoCandidates
	 */
	public List<File> getVideoCandidates() {
		return videoCandidates;
	}

	/**비디오 파일 후보 setter
	 * @param videoCandidates the videoCandidates to set
	 */
	public void setVideoCandidates(List<File> videoCandidates) {
		this.videoCandidates = videoCandidates;
	}

	/**
	 * 비디오 파일 후보 list clear
	 */
	public void resetVideoCandidates() {
		this.videoCandidates.clear();
	}

	public void rename(String newName) {
		logger.debug("rename {} -> {}", getFullname(), newName);
		int count = 1;
		// video
		List<File> videoFileList = new ArrayList<>();
		int videoCount = getVideoFileList().size();
		for (File file : VideoUtils.sortFile(getVideoFileList())) {
			if (videoCount == 1) {
				videoFileList.add(Utils.renameFile(file, newName));
			}
			else {
				videoFileList.add(Utils.renameFile(file, newName + count++));
			}
		}
		setVideoFileList(videoFileList);
		
		// cover
		
		if (coverFile != null && coverFile.exists())
			setCoverFile(Utils.renameFile(coverFile, newName));

		// subtitles, if exist
		count = 1;
		List<File> subtitlesFileList = new ArrayList<>();
		int subtitlesCount = getSubtitlesFileList().size();
		for (File file : VideoUtils.sortFile(getSubtitlesFileList())) {
			if (subtitlesCount == 1) {
				subtitlesFileList.add(Utils.renameFile(file, newName));
			}
			else {
				subtitlesFileList.add(Utils.renameFile(file, newName + count++));
			}
		}
		setSubtitlesFileList(subtitlesFileList);
		
		// info file
		if (infoFile != null && infoFile.exists())
			setInfoFile(Utils.renameFile(infoFile, newName));
			
		// etc file
		List<File> etcFileList = new ArrayList<>();
		for (File file : this.getEtcFileList()) {
			etcFileList.add(Utils.renameFile(file, newName));
		}
		setEtcFileList(etcFileList);
	}

	public void renameOfActress(String oldName, String newName) {
		String actressNames = this.getActressName().replace(oldName, newName);
		String newVideoName = String.format("[%s][%s][%s][%s][%s]", studio.getName(), opus, title, actressNames, StringUtils.isEmpty(releaseDate) ? getVideoDate() : releaseDate);
		rename(newVideoName);
	}

	public void renameOfStudio(String newName) {
		rename(String.format("[%s][%s][%s][%s][%s]", newName, opus, title, getActressName(), StringUtils.isEmpty(releaseDate) ? getVideoDate() : releaseDate));
	}


	public void delete() {
		removeVideo();
	}
	
	/**대표 파일의 확장자
	 * @return
	 */
	@JsonIgnore
	public String getExt() {
		return Utils.getExtension(getDelegateFile());
	}

	@Override
	public String toString() {
		return String
				.format("Video [videoFileList=%s, subtitlesFileList=%s, coverFile=%s, infoFile=%s, etcFileList=%s, studio=%s, opus=%s, title=%s, overview=%s, etcInfo=%s, releaseDate=%s, actressList=%s, playCount=%s, rank=%s]",
						videoFileList, subtitlesFileList, coverFile, infoFile,
						etcFileList, studio.getName(), opus, title, overview, etcInfo,
						releaseDate, getActressName(), playCount, rank);
	}

	/**
	 * @return the isArchive
	 */
	public boolean isArchive() {
		return isArchive;
	}

	/**
	 * @param isArchive the isArchive to set
	 * @return this video
	 */
	public void setArchive(boolean isArchive) {
		this.isArchive = isArchive;
	}

	@JsonIgnore
	public int getSize() {
		if (isExistVideoFileList()) {
			return getVideoFileList().size();
		}
		else 
			return 0;
	}

	public void resetScore() {
		this.rank = 0;
		this.playCount = 0;
		this.saveInfo();
	}

	/**
	 * 비디오 파일을 최상위 루트로 이동
	 */
	public void moveOutside() {
		if (this.isExistVideoFileList()) {
			File root = Utils.getRootDirectory(this.getDelegateFile());
			for (File file : this.getVideoFileList()) {
				try {
					FileUtils.moveFileToDirectory(file, root, false);
				} catch (FileExistsException e) {
					logger.warn("file exists in root dir[{}] : {}", root.getAbsolutePath(), e.getMessage());
					FileUtils.deleteQuietly(file);
				} catch (IOException e) {
					logger.error("move fail", e);
				}
			}
			videoFileList = new ArrayList<>();
		}
		resetScore();
	}

	public void toggleTag(VTag tag) {
		if (logger.isDebugEnabled())
			logger.debug("toggleTag {}", tag);
		if (info.getTags().contains(tag)) {
			info.getTags().remove(tag);
			if (logger.isDebugEnabled())
				logger.debug("toggleTag remove");
		}
		else {
			info.getTags().add(tag);
			if (logger.isDebugEnabled())
				logger.debug("toggleTag add");
		}
		saveInfo();
	}

	public void updateTag(VTag tag) {
		if (info.getTags().contains(tag)) {
			info.getTags().remove(tag);
			info.getTags().add(tag);
			saveInfo();
		}		
	}
	
	public boolean match(VideoSearch search) {
		if ((matchStudio(search.getSearchText()) || 
			 matchOpus(search.getSearchText()) || 
			 matchTitle(search.getSearchText()) || 
			 matchActress(search.getSearchText()) ||
			 matchRelease(search.getSearchText())
			) 
			&& matchExist(search.isExistVideo(), search.isExistSubtitles(), search.isExistCover())
			&& matchFavorite(search.isFavorite())
			&& matchStudioList(search.getSelectedStudio())
			&& matchActressList(search.getSelectedActress())
			&& matchRank(search.getRankRange())
			&& matchPlay(search.getPlayCount())
			&& matchTag(search.getSelectedTag())
			) {
			setSortMethod(search.getSortMethod());
			return true;
		}
		return false;
	}

	private boolean matchFavorite(boolean favorite) {
		if (favorite) {
			for (Actress actress : actressList) {
				if (actress.getFavorite())
					return true;
			}
			return false;
		}
		else 
			return true;
	}

	public boolean matchArchive(VideoSearch search) {
		if ((matchStudio(search.getSearchText()) 
				|| matchOpus(search.getSearchText()) 
				|| matchTitle(search.getSearchText()) 
				|| matchActress(search.getSearchText())
				|| matchRelease(search.getSearchText())) 
			&& matchStudioList(search.getSelectedStudio())
			&& matchActressList(search.getSelectedActress())
			&& matchTag(search.getSelectedTag())
			) {
			setSortMethod(search.getSortMethod());
			return true;
		}
		return false;
	}

	private boolean matchTag(List<String> selectedTag) {
		if (selectedTag == null)
			return true;
		if (getTags() == null)
			return false;
		return getTags().stream().anyMatch(t -> selectedTag.contains(t.getId().toString()));
	}

	private boolean matchPlay(Integer playCount) {
		return playCount == null || playCount < 0 || this.playCount == playCount;
	}

	private boolean matchRank(List<Integer> rankRange) {
		return rankRange.contains(rank);
	}

	private boolean matchActressList(List<String> selectedActress) {
		return selectedActress == null ? true : selectedActress.stream().anyMatch(s -> equalsActress(s));
	}

	private boolean equalsActress(String actressName) {
		return actressList.stream().anyMatch(a -> VideoUtils.equalsActress(a.getName(), actressName));
	}

	private boolean matchStudioList(List<String> selectedStudio) {
		return selectedStudio == null ? true : selectedStudio.contains(studio.getName());
	}

	private boolean matchExist(boolean existVideo, boolean existSubtitles, boolean existCover) {
		boolean matchVideo = false;
		boolean matchSubtitles = false;
		boolean matchCover = false;
		if (existVideo)
			matchVideo = isExistVideoFileList() && !isExistSubtitlesFileList(); // 비디오만 있는
		if (existSubtitles)
			matchSubtitles = isExistVideoFileList() && isExistSubtitlesFileList(); // 비디오와 자막이 있는
		if (existCover)
			matchCover = !isExistVideoFileList() && isExistCoverFile(); // 비디오 없이 커버만 있는, 자막은 고려안함
		return (existVideo && matchVideo) || (existSubtitles && matchSubtitles) || (existCover && matchCover);
	}

	private boolean matchRelease(String searchText) {
		return StringUtils.isBlank(searchText) || StringUtils.contains(releaseDate, searchText);
	}

	private boolean matchActress(String searchText) {
		return StringUtils.isBlank(searchText) || containsActress(searchText);
	}

	private boolean matchTitle(String searchText) {
		return StringUtils.isBlank(searchText) || StringUtils.containsIgnoreCase(title, searchText);
	}

	private boolean matchOpus(String searchText) {
		return StringUtils.isBlank(searchText) || StringUtils.containsIgnoreCase(opus, searchText);
	}

	private boolean matchStudio(String searchText) {
		return StringUtils.isBlank(searchText) || StringUtils.containsIgnoreCase(studio.getName(), searchText);
	}

	public void resetTorrents() {
		torrents.clear();
	}

	public void addTorrents(File file) {
		torrents.add(file);
	}

	public List<File> getTorrents() {
		return torrents;
	}

	public void setTorrents(List<File> torrents) {
		this.torrents = torrents;
	}

	public boolean isFavorite() {
		boolean favorite = false;
		for (Actress actress : getActressList()) {
			if (actress.getFavorite()) {
				favorite = true;
				break;
			}
		}
		return favorite;
	}

	/**
	 * opus, title, releaseDate, etcInfo 설정 
	 * @param titlePart
	 */
	public void setTitlePart(TitlePart titlePart) {
		this.setOpus(titlePart.getOpus());
		this.setTitle(titlePart.getTitle());
		this.setReleaseDate(titlePart.getReleaseDate());
		this.setEtcInfo(titlePart.getEtcInfo());
	}

	public void clearActress() {
		this.actressList.clear();
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Video other = (Video) obj;
		if (opus == null) {
			if (other.opus != null)
				return false;
		} else if (!opus.equals(other.opus))
			return false;
		return true;
	}
	
}
