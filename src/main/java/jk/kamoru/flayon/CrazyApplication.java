package jk.kamoru.flayon;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync
public class CrazyApplication {

	public static void main(String[] args) {
		SpringApplication.run(CrazyApplication.class, args);
	}

}
