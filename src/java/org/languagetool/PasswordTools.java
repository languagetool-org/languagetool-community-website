/*
 * Created on 06.04.2008
 */
package org.languagetool;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class PasswordTools {
  
  private static final String SALT_DELIMITER = "-";

  private PasswordTools() {
    // static tools, no public constructor
  }
  
  public static String hash(String password) {
    String randomSalt = Math.random() + "";
    randomSalt += "." + Math.random() + "";
    return hash(password, randomSalt);
  }
  
  public static String hash(String password, String salt) {
    if (password == null || password.equals("")) {
      throw new IllegalArgumentException("password may not be null or empty");
    }
    String hash = salt + SALT_DELIMITER + 
      hexMD5(salt + SALT_DELIMITER + password);
    return hash;
  }

  public static boolean checkPassword(String userPassword, String hashPassword) {
    String parts[] = hashPassword.split(SALT_DELIMITER);
    if (parts.length != 2) {
      throw new IllegalArgumentException("Invalid password format, missing salt delimiter: " + userPassword);
    }
    String salt = parts[0];
    String encPassword = hash(userPassword, salt);
    if (hashPassword.equals(encPassword)) {
      return true;
    }
    return false;
  }
  
  public static String hexMD5(String s) {
    try {
      MessageDigest md = MessageDigest.getInstance("MD5");
      return binaryToHex(md.digest(s.getBytes()));
    } catch (NoSuchAlgorithmException e) {
      throw new RuntimeException(e);
    }
  }

  public static String binaryToHex(byte[] array) {
    StringBuffer sb = new StringBuffer();
    for (int i = 0; i < array.length; ++i) {
        sb.append(Integer.toHexString((array[i] & 0xFF) | 0x100).substring(1,3));
    }
    return sb.toString();
  }  

}
