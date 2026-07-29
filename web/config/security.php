<?php
/**
 * Security Encryption Utility
 * AES-256-CBC Encryption Layer for API Keys
 * PHP 8.3 Native Compatible
 */

// Load database/env if not already loaded
if (!function_exists('getDatabaseConnection')) {
    require_once __DIR__ . '/database.php';
}

/**
 * Encrypt plain text API Key using AES-256-CBC
 */
function encrypt_key(string $plainText): string {
    $passphrase = getenv('SECURITY_SECRET_KEY') ?: 'NewVeg_mHealth_AES_256_Encryption_Salt_Secret_Key_2026';
    $cipher = "aes-256-cbc";
    
    $ivLength = openssl_cipher_iv_length($cipher);
    $iv = openssl_random_pseudo_bytes($ivLength);
    
    $ciphertextRaw = openssl_encrypt($plainText, $cipher, $passphrase, OPENSSL_RAW_DATA, $iv);
    
    // Combine IV and cipher text and encode in base64
    return base64_encode($iv . $ciphertextRaw);
}

/**
 * Decrypt cipher text API Key back to plain text
 */
function decrypt_key(string $cipherText): string {
    $passphrase = getenv('SECURITY_SECRET_KEY') ?: 'NewVeg_mHealth_AES_256_Encryption_Salt_Secret_Key_2026';
    $cipher = "aes-256-cbc";
    
    $raw = base64_decode($cipherText);
    $ivLength = openssl_cipher_iv_length($cipher);
    
    $iv = substr($raw, 0, $ivLength);
    $ciphertextRaw = substr($raw, $ivLength);
    
    $plainText = openssl_decrypt($ciphertextRaw, $cipher, $passphrase, OPENSSL_RAW_DATA, $iv);
    
    return $plainText ?: '';
}
