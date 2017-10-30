package jk.kamoru.flayon.crazy;

import org.springframework.beans.factory.annotation.Value;

public class CrazyProperties {

    /* Local properties */

    /** video archive path */                    @Value("${path.video.archive}")         protected String         ARCHIVE_PATH;
    /** base video path in properties */         @Value("${path.video.storage}")         protected String         STORAGE_PATH;
    /** video path of downloaded file */         @Value("${path.video.candidate}")       protected String[]     CANDIDATE_PATHS;
    /** video Stage path */                      @Value("${path.video.stage}")           protected String[]         STAGE_PATHS;
    /** video cover path */                      @Value("${path.video.cover}")           protected String           COVER_PATH;
    /** Torrent seed path */                     @Value("${path.video.seed}")            protected String            SEED_PATH;
    /** queue path */                            @Value("${path.video.queue}")           protected String           QUEUE_PATH;

    /** specific file moving info */             @Value("${path.move.file}")             protected String[]     MOVE_FILE_PATHS;
    /** managed picture path */                  @Value("${path.sora.pictures}")         protected String[] SORA_PICTURES_PATHS;
    /** image file path */                       @Value("${path.image.storage}")         protected String[]         IMAGE_PATHS;
    /** torrent file path */                     @Value("${path.video.torrent}")         protected String         TORRENT_PATH;
    /** backup path */                           @Value("${path.backup}")                protected String          BACKUP_PATH;

    /** video player exec */                     @Value("${app.video-player}")           protected String   PLAYER;
    /** subtitles editer */                      @Value("${app.subtitles-editor}")       protected String   EDITOR;

    /* Common Properties */

    /** minimum rank in properties */            @Value("${rank.minimum}")               protected Integer  MIN_RANK;
    /** maximum rank in properties */            @Value("${rank.maximum}")               protected Integer  MAX_RANK;
    /** baseline rank */                                                                 protected int     BASE_RANK = 0;

    /** maximum size of entire video */          @Value("${size.video.storage}")         protected int      MAX_ENTIRE_VIDEO;

    /** specific opus of non studio */           @Value("${parse.to.title.no_opus}")     protected String   NO_PARSE_OPUS_PREFIX;
    /** replacement opus */                      @Value("${parse.to.title.re_opus}")     protected String[] REPLACE_OPUS_INFO;

    /** option for moving video */               @Value("${batch.watched.moveVideo}")    protected boolean        MOVE_WATCHED_VIDEO;
    /** option for deleting lower rank vidoe */  @Value("${batch.rank.deleteVideo}")     protected boolean   DELETE_LOWER_RANK_VIDEO;
    /** option for deleting lower score video */ @Value("${batch.score.deleteVideo}")    protected boolean  DELETE_LOWER_SCORE_VIDEO;

    /** play ratio for score */                  @Value("${score.ratio.play}")           protected int      PLAY_RATIO;
    /** rank ratio for score */                  @Value("${score.ratio.rank}")           protected int      RANK_RATIO;
    /** actress ratio for score */               @Value("${score.ratio.actress}")        protected int   ACTRESS_RATIO;
    /** subtitles  ratio for score */            @Value("${score.ratio.subtitles}")      protected int SUBTITLES_RATIO;

    /** new video RSS feed */                    @Value("${url.rss}")                    protected String urlRSS;

    /** video info finding url */                @Value("${url.search.video}")           protected String urlSearchVideo;
    /** actress info finding url */              @Value("${url.search.actress}")         protected String urlSearchActress;
    /** torrent info finding url*/               @Value("${url.search.torrent}")         protected String urlSearchTorrent;

}
