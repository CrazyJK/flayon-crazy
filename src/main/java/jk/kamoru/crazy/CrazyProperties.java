package jk.kamoru.crazy;

import org.springframework.beans.factory.annotation.Value;

public class CrazyProperties {

	/*
	 * Local properties
	 */

	/** 비디오 아카이브 경로 */ 					@Value("#{local['path.video.archive']}")		protected String	ARCHIVE_PATHS;

	/** base video path in properties */			@Value("#{local['path.video.storage']}") 		protected String[] 	STORAGE_PATHS;
	
	/** 다운받은 후보 비디오 경로 */				@Value("#{local['path.video.candidate']}") 		protected String[] 	CANDIDATE_PATHS;
	
	/** 비디오 Stage 경로 */						@Value("#{local['path.video.stage']}") 			protected String[] 	STAGE_PATHS;
	
	/** 비디오 플레이어 실행 파일 */				@Value("#{local['app.video-player']}") 			protected String   	PLAYER;

	/** 자막 편집 실행 파일 */						@Value("#{local['app.subtitles-editor']}") 		protected String   	EDITOR;

	/** 특정 파일 이동 정보 */ 						@Value("#{local['path.move.file']}")			protected String[] 	PATH_MOVE_FILE;

	/** 다운받은 이미지의 이름 바꿀 경로 */ 		@Value("#{local['path.sora.pictures']}")		protected String[] 	PATH_SORA_PICTURES;

	/** 이미지 파일 경로 */							@Value("#{local['path.image.storage']}") 		protected String[] 	IMAGE_PATHS;


	
	/*
	 * Common Properties
	 */
	
	/** minimum rank in properties */				@Value("#{prop['rank.minimum']}") 				protected Integer  	MIN_RANK;
	/** maximum rank in properties */				@Value("#{prop['rank.maximum']}") 				protected Integer  	MAX_RANK;
	/** baseline rank in properties */				@Value("#{prop['rank.baseline']}")  			protected int 	 	BASE_RANK;
	/** 전체 비디오의 크기 제한 */					@Value("#{prop['size.video.storage']}")  		protected int 	 	MAX_ENTIRE_VIDEO;

	/** 스튜디오를 찾지 않을 특정 품번 */			@Value("#{prop['parse.to.title.no_opus']}") 	protected String 	NO_PARSE_OPUS_PREFIX;
	/** 특정 패턴의 품번은 고정 스튜디오로 설정 */ 	@Value("#{prop['parse.to.title.re_opus']}") 	protected String[] 	REPLACE_OPUS_INFO;

	/** 본 비디오 이돌 */ 							@Value("#{prop['batch.watched.moveVideo']}")	protected boolean 	MOVE_WATCHED_VIDEO;
	/** rank가 낮은 비디오 삭제 */ 					@Value("#{prop['batch.rank.deleteVideo']}") 	protected boolean 	DELETE_LOWER_RANK_VIDEO;
	/** score가 낮은 비디오 삭제 */ 				@Value("#{prop['batch.score.deleteVideo']}") 	protected boolean 	DELETE_LOWER_SCORE_VIDEO;
	

	/** play 배점 */ 								@Value("#{prop['score.ratio.play']}")			protected int      	     PLAY_RATIO;
	/** rank 배점 */ 								@Value("#{prop['score.ratio.rank']}")			protected int      	     RANK_RATIO;
	/** 배우 배점 */ 								@Value("#{prop['score.ratio.actress']}")		protected int   	  ACTRESS_RATIO;
	/** 자막 배점 */ 								@Value("#{prop['score.ratio.subtitles']}")		protected int 		SUBTITLES_RATIO;
	
}
