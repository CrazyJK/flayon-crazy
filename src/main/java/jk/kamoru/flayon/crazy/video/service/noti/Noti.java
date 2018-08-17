package jk.kamoru.flayon.crazy.video.service.noti;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.validation.constraints.NotEmpty;
import javax.validation.constraints.NotNull;

import lombok.Data;

@Entity
@Data
public class Noti {

	@Id 
	@GeneratedValue(strategy = GenerationType.AUTO)
	Long id;
	
	@Column
	@NotNull
	Date date;
	
	@Column
	@NotEmpty
	String message;
	
	public Noti() {
		this(new Date(), "initial");
	}
	
	public Noti(Date date, String message) {
		this.date = date;
		this.message = message;
	}

}
