/*
 * Created on 06.04.2008
 */
package org.languagetool;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Utility methods for hashing passwords.
 * 
 * @author Daniel Naber
 */
public class PasswordTools {
  
  /**
   * Delimiter char between plain text salt and hashed password.
   */
  private static final String SALT_DELIMITER = "-";

  private PasswordTools() {
    // static tools, no public constructor
  }
  
  /**
   * Calculate a hash of the given string and prepend a
   * random salt.
   */
  public static String hash(String password) {
    // the salt hampers the use of attacks that use 
    // pre-computed hash values ("rainbow table"):
    String randomSalt = Math.random() + "";
    randomSalt += "." + Math.random() + "";
    return hash(password, randomSalt);
  }

  /**
   * Calculate a hash of the given string, using the given salt.
   */
  public static String hash(String password, String salt) {
    if (password == null || password.equals("")) {
      throw new IllegalArgumentException("password may not be null or empty");
    }
    String hash = salt + SALT_DELIMITER + 
      hexMD5(salt + SALT_DELIMITER + password);
    return hash;
  }

  /**
   * Checks of a user-provided password is the same as the stored
   * password (actually checks if the hashes of both are the same).
   * 
   * @param userPassword the plain test password
   * @param hashPassword the hashed password with a prepended salt
   * @return true if the password matches the hashed password
   */
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
  
  /**
   * Returns a hex-encoded MD5 sum of the givens string.
   */
  public static String hexMD5(String s) {
    try {
      MessageDigest md = MessageDigest.getInstance("MD5");
      return binaryToHex(md.digest(s.getBytes()));
    } catch (NoSuchAlgorithmException e) {
      throw new RuntimeException(e);
    }
  }

  /**
   * Returns a hex representation of the given binary input.
   */
  private static String binaryToHex(byte[] array) {
    StringBuffer sb = new StringBuffer();
    for (int i = 0; i < array.length; ++i) {
        sb.append(Integer.toHexString((array[i] & 0xFF) | 0x100).substring(1,3));
    }
    return sb.toString();
  }  

}
