-- ============================================
-- Hercules Database Initialization
-- Creates main and log databases
-- ============================================

-- Create log database if not exists
CREATE DATABASE IF NOT EXISTS `hercules_log` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant privileges to ragnarok user
GRANT ALL PRIVILEGES ON `hercules`.* TO 'ragnarok'@'%';
GRANT ALL PRIVILEGES ON `hercules_log`.* TO 'ragnarok'@'%';
FLUSH PRIVILEGES;

-- Use main database for initial setup
USE `hercules`;

-- Note: The main.sql from Hercules will be imported separately
-- This file just ensures the databases exist and permissions are set
