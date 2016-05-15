package jk.kamoru.crazy.video.util;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.font.FontRenderContext;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;

import javax.imageio.ImageIO;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class CoverUtils {

	public static byte[] getCoverWithTitle(File coverFile, String title) {
		
		BufferedImage bi = null;
		try {
			bi = ImageIO.read(coverFile);
		} catch (IOException e) {
			log.error("ImageIO.read Error", e);
		}
		int imgWidth = bi.getWidth();
		int imgHeight = bi.getHeight();

		log.info("loadedImage width : {}, height : {}", imgWidth, imgHeight);

		Graphics2D g2 = bi.createGraphics();

		Font font = new Font("나눔고딕코딩", Font.PLAIN, 32);
		// 가운데 정렬하기 위해, text의 width구하기
		FontRenderContext frc = new FontRenderContext(null, true, true);
		Rectangle2D r2 = font.getStringBounds(title, frc);
		int textWidth = (int) r2.getWidth();
		int textHeight = (int) r2.getHeight();
		log.info("Text width : {}, height : {}", textWidth, textHeight);
		
		// 입력하는 문자의 가용 넓이
		int textBound = imgWidth;
		int paddingleft = (textBound - textWidth) / 2;
		if (paddingleft < 0)
			paddingleft = 0;

		log.info("paddingleft : " + paddingleft);

		// 라운드 사각형 채우기
		int rectY = 10;
		int margin = 5;
		int arcRound = 10;
		g2.setColor(new Color(255, 255, 255, 200));
		g2.fillRoundRect(paddingleft - margin, 10, textWidth + 2*margin, textHeight + 2*margin, arcRound, arcRound);
		
		// 이미지에 텍스트 사입. (text,x축,y축)
		g2.setFont(font);
		g2.setColor(Color.BLACK);
		g2.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
		g2.setRenderingHint(RenderingHints.KEY_TEXT_LCD_CONTRAST, new Integer(140));
		g2.drawString(title, paddingleft, rectY + textHeight);

		g2.dispose();

		ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
		ImageIO.setUseCache(false);
		try {
			ImageIO.write(bi, "jpg", outputStream);
		} catch (IOException e) {
			log.error("ImageIO.write Error", e);
		}
		return outputStream.toByteArray();
	}
}
