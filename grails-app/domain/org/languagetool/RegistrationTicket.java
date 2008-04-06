package org.languagetool;

import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.OneToOne;

@Entity
public class RegistrationTicket {
  
  private Long id;
  private String ticketCode;
  private Date generationDate;
  private User user;
  
  public RegistrationTicket() {
  }
  
  public RegistrationTicket(User user) {
    // FIXME: take from config file:
    String secret = "hfsjkfdsfewjk23s";
    String key = Math.random() + "/" + secret;
    ticketCode = PasswordTools.hexMD5(key);
    this.generationDate = new Date();
    this.user = user;
  }
  
  @Id
  @GeneratedValue
  public Long getId() {
      return id;
  }
  public void setId(Long id) {
      this.id = id;
  }

  public String getTicketCode() {
    return ticketCode;
  }
  public void setTicketCode(String ticketCode) {
    this.ticketCode = ticketCode;
  }

  public Date getGenerationDate() {
    return generationDate;
  }
  public void setGenerationDate(Date generationDate) {
    this.generationDate = generationDate;
  }

  @OneToOne
  public User getUser() {
    return user;
  }
  public void setUser(User user) {
    this.user = user;
  }

}