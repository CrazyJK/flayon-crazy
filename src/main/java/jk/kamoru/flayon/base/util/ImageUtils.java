package jk.kamoru.flayon.base.util;

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
import java.io.InputStream;

import javax.imageio.ImageIO;

import jk.kamoru.flayon.crazy.error.CrazyException;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class ImageUtils {

	public static byte[] mergeTextToImage(String text, File image) {
		return mergeTextToImage(image, text, "나눔고딕코딩", 32);
	}

	public static byte[] mergeTextToImage(File image, String text, String fontname, int fontsize) {
		try {
			BufferedImage bi = ImageIO.read(image);
			return mergeTextToImage(bi, text, fontname, fontsize);
		} catch (IOException e) {
			throw new CrazyException("ImageIO.read Error", e);
		}
	}
	
	public static byte[] mergeTextToImage(InputStream image, String text, String fontname, int fontsize) {
		try {
			BufferedImage bi = ImageIO.read(image);
			return mergeTextToImage(bi, text, fontname, fontsize);
		} catch (IOException e) {
			throw new CrazyException("ImageIO.read Error", e);
		}
	}
	
	public static byte[] mergeTextToImage(BufferedImage bi, final String TEXT, final String FONTNAME, final int FONTSIZE) {
		
		int imgWidth  = bi.getWidth();
		int imgHeight = bi.getHeight();
		log.debug("loadedImage width : {}, height : {}", imgWidth, imgHeight);

		Graphics2D g2 = bi.createGraphics();

		// 가운데 정렬하기 위해, text의 width구하기
		FontRenderContext frc = new FontRenderContext(null, true, true);
		Font font = new Font(FONTNAME, Font.PLAIN, FONTSIZE);
		Rectangle2D r2 = font.getStringBounds(TEXT, frc);
		int textWidth  = (int) r2.getWidth();
		int textHeight = (int) r2.getHeight();
		log.debug("Text width : {}, height : {}", textWidth, textHeight);
		
		// 입력하는 문자의 가용 넓이
		int textBound = imgWidth;
		int paddingleft = (textBound - textWidth) / 2;
		if (paddingleft < 0)
			paddingleft = 0;
		log.debug("paddingleft : " + paddingleft);

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
		g2.drawString(TEXT, paddingleft, rectY + textHeight);

		g2.dispose();
		
		try {
			ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
			ImageIO.setUseCache(false);
			ImageIO.write(bi, "jpg", outputStream);
			return outputStream.toByteArray();
		} catch (IOException e) {
			throw new CrazyException("ImageIO.write Error", e);
		}
	}
}
