package jk.kamoru.flayon.crazy;

import org.springframework.beans.factory.annotation.Value;

import lombok.Getter;

@Getter
public class CrazyProperties {

    /* Local properties --------------------------------------------------------------------------- */

    @Value("${path.video.archive}")         String         ARCHIVE_PATH;
    @Value("${path.video.storage}")         String         STORAGE_PATH;
    @Value("${path.video.candidate}")       String[]     CANDIDATE_PATHS;
    @Value("${path.video.stage}")           String[]         STAGE_PATHS;
    @Value("${path.video.cover}")           String           COVER_PATH;
    @Value("${path.video.seed}")            String            SEED_PATH;
    @Value("${path.video.queue}")           String           QUEUE_PATH;

    @Value("${path.move.file}")             String[]     MOVE_FILE_PATHS;
    @Value("${path.sora.pictures}")         String[] SORA_PICTURES_PATHS;
    @Value("${path.image.storage}")         String[]         IMAGE_PATHS;
    @Value("${path.video.torrent}")         public String         TORRENT_PATH;
    @Value("${path.backup}")                String          BACKUP_PATH;

    @Value("${app.video-player}")           String   PLAYER;
    @Value("${app.subtitles-editor}")       String   EDITOR;

	@Value("${path.video.storage},${path.video.stage},${path.video.cover}") String[] INSTANCE_PATHS;
    
    /* Common Properties -------------------------------------------------------------------------- */
	                                        int  BASE_RANK = 0;
    @Value("${rank.minimum}")               int   MIN_RANK;
    @Value("${rank.maximum}")               int   MAX_RANK;

    @Value("${size.video.storage}")         int      MAX_ENTIRE_VIDEO;

    @Value("${parse.to.title.no_opus}")     String   NO_PARSE_OPUS_PREFIX;
    @Value("${parse.to.title.re_opus}")     String[] REPLACE_OPUS_INFO;

    @Value("${batch.watched.moveVideo}")    boolean        MOVE_WATCHED_VIDEO;
    @Value("${batch.rank.deleteVideo}")     boolean   DELETE_LOWER_RANK_VIDEO;
    @Value("${batch.score.deleteVideo}")    boolean  DELETE_LOWER_SCORE_VIDEO;

    @Value("${score.ratio.play}")           int      PLAY_RATIO;
    @Value("${score.ratio.rank}")           int      RANK_RATIO;
    @Value("${score.ratio.actress}")        int   ACTRESS_RATIO;
    @Value("${score.ratio.subtitles}")      int SUBTITLES_RATIO;

    @Value("${url.rss}")                    String urlRSS;
    @Value("${url.search.video}")           String urlSearchVideo;
    @Value("${url.search.actress}")         String urlSearchActress;
    @Value("${url.search.torrent}")         String urlSearchTorrent;

	public boolean setMOVE_WATCHED_VIDEO(boolean mOVE_WATCHED_VIDEO) {
		return MOVE_WATCHED_VIDEO = mOVE_WATCHED_VIDEO;
	}
	public boolean setDELETE_LOWER_RANK_VIDEO(boolean dELETE_LOWER_RANK_VIDEO) {
		return DELETE_LOWER_RANK_VIDEO = dELETE_LOWER_RANK_VIDEO;
	}
	public boolean setDELETE_LOWER_SCORE_VIDEO(boolean dELETE_LOWER_SCORE_VIDEO) {
		return DELETE_LOWER_SCORE_VIDEO = dELETE_LOWER_SCORE_VIDEO;
	}

    
}
