﻿--
-- Script was generated by Devart dbForge Studio 2020 for MySQL, Version 9.0.338.0
-- Product home page: http://www.devart.com/dbforge/mysql/studio
-- Script date 4/7/2023 11:00:22 AM
-- Server version: 5.5.62
-- Client version: 4.1
--

-- 
-- Disable foreign keys
-- 
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

-- 
-- Set SQL mode
-- 
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE sql12612725;

--
-- Drop procedure `proc_certificate_BanMultiple`
--
DROP PROCEDURE IF EXISTS proc_certificate_BanMultiple;

--
-- Drop procedure `proc_certificate_DeleteMultiple`
--
DROP PROCEDURE IF EXISTS proc_certificate_DeleteMultiple;

--
-- Drop procedure `Proc_Certificate_SendMultiple`
--
DROP PROCEDURE IF EXISTS Proc_Certificate_SendMultiple;

--
-- Drop procedure `Proc_Certificate_SignMultiple`
--
DROP PROCEDURE IF EXISTS Proc_Certificate_SignMultiple;

--
-- Drop procedure `proc_user_delete`
--
DROP PROCEDURE IF EXISTS proc_user_delete;

--
-- Drop procedure `proc_user_insert`
--
DROP PROCEDURE IF EXISTS proc_user_insert;

--
-- Drop procedure `proc_Certificate_AddTransactionLink`
--
DROP PROCEDURE IF EXISTS proc_Certificate_AddTransactionLink;

--
-- Drop procedure `proc_certificate_ban`
--
DROP PROCEDURE IF EXISTS proc_certificate_ban;

--
-- Drop procedure `proc_certificate_delete`
--
DROP PROCEDURE IF EXISTS proc_certificate_delete;

--
-- Drop procedure `proc_certificate_getAllIssued`
--
DROP PROCEDURE IF EXISTS proc_certificate_getAllIssued;

--
-- Drop procedure `proc_certificate_getAllReceived`
--
DROP PROCEDURE IF EXISTS proc_certificate_getAllReceived;

--
-- Drop procedure `proc_certificate_insert`
--
DROP PROCEDURE IF EXISTS proc_certificate_insert;

--
-- Drop procedure `proc_certificate_send`
--
DROP PROCEDURE IF EXISTS proc_certificate_send;

--
-- Drop procedure `proc_certificate_sign`
--
DROP PROCEDURE IF EXISTS proc_certificate_sign;

--
-- Drop procedure `proc_dashboard_getInfor`
--
DROP PROCEDURE IF EXISTS proc_dashboard_getInfor;

--
-- Drop table `certificate`
--
DROP TABLE IF EXISTS certificate;

--
-- Drop procedure `proc_contact_accept`
--
DROP PROCEDURE IF EXISTS proc_contact_accept;

--
-- Drop procedure `proc_contact_delete`
--
DROP PROCEDURE IF EXISTS proc_contact_delete;

--
-- Drop procedure `proc_contact_getAll`
--
DROP PROCEDURE IF EXISTS proc_contact_getAll;

--
-- Drop procedure `proc_contact_insert`
--
DROP PROCEDURE IF EXISTS proc_contact_insert;

--
-- Drop table `contact`
--
DROP TABLE IF EXISTS contact;

--
-- Drop table `user`
--
DROP TABLE IF EXISTS user;

--
-- Set default database
--
USE sql12612725;

--
-- Create table `user`
--
CREATE TABLE user (
  UserID varchar(255) NOT NULL DEFAULT '' COMMENT 'Khóa chính, là địa chỉ ví skate',
  UserCode mediumint(8) UNSIGNED NOT NULL COMMENT 'Mã code, để hiển thị lên trang web',
  UserName varchar(255) DEFAULT NULL COMMENT 'Tên tổ chức',
  Logo text DEFAULT NULL,
  CreatedDate datetime DEFAULT NULL COMMENT 'Ngày tạo tài khoản',
  IsVerified tinyint(4) DEFAULT 0 COMMENT 'Đã được xác thực hay chưa (0-chưa; 1- rồi)',
  IsDeleted tinyint(4) DEFAULT 0 COMMENT 'Bị xóa hay chưa (0-chưa xóa; 1-đã xóa)',
  PRIMARY KEY (UserID)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 963,
CHARACTER SET latin1,
COLLATE latin1_swedish_ci;

--
-- Create index `UserCode` on table `user`
--
ALTER TABLE user
ADD UNIQUE INDEX UserCode (UserCode);

--
-- Create table `contact`
--
CREATE TABLE contact (
  ContactID char(36) NOT NULL DEFAULT '' COMMENT 'Khóa chính, có kiểu GUID',
  IssuedID varchar(255) NOT NULL DEFAULT '' COMMENT 'Khóa ngoại, liên kết với bảng user(PolicyID)',
  ReceivedID varchar(255) NOT NULL DEFAULT '' COMMENT 'Khóa ngoại, liên kết với bảng user(PolicyID)',
  ContactCode mediumint(8) UNSIGNED NOT NULL COMMENT 'mã hiện thị trên website, có kiểu là số',
  ContactStatus tinyint(4) DEFAULT 1 COMMENT 'Trạng thái kết nối (1-pending, 2-connected)',
  CreatedDate datetime DEFAULT NULL COMMENT 'Ngày tạo',
  IsDeleted tinyint(4) NOT NULL COMMENT 'xóa hay chưa (0-hiện/1-ẩn)',
  PRIMARY KEY (ContactID)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 1092,
CHARACTER SET latin1,
COLLATE latin1_swedish_ci;

--
-- Create index `ContactCode` on table `contact`
--
ALTER TABLE contact
ADD UNIQUE INDEX ContactCode (ContactCode);

--
-- Create foreign key
--
ALTER TABLE contact
ADD CONSTRAINT FK_contact_ReceivedID FOREIGN KEY (ReceivedID)
REFERENCES user (UserID) ON DELETE NO ACTION;

--
-- Create foreign key
--
ALTER TABLE contact
ADD CONSTRAINT FK_contact_IssuedID FOREIGN KEY (IssuedID)
REFERENCES user (UserID) ON DELETE NO ACTION;

DELIMITER $$

--
-- Create procedure `proc_contact_insert`
--
CREATE DEFINER = 'sql12612725'@'%'
PROCEDURE proc_contact_insert (IN v_IssuedID varchar(255), IN v_ReceivedID varchar(255))
COMMENT 'Thêm mới một liên lạc'
BEGIN
  -- Lấy giá trị lớn nhất của user code
  DECLARE CODE mediumint;
  SELECT
    MAX(ContactCode) INTO CODE
  FROM contact;

  -- Check if the contact already exists
  IF (SELECT
        COUNT(*)
      FROM contact c
      WHERE c.IssuedID = v_IssuedID
      AND c.ReceivedID = v_ReceivedID) > 0 THEN
    -- Contact already exists, do nothing
    SELECT
      '';
  ELSE
    -- Nếu table xxx chưa có data sẽ mặc định CODE = 100000
    IF CODE IS NULL THEN
      SET CODE = 100000;
    ELSE
      SET CODE = CODE + 1;
    END IF;

    -- Thực hiện insert
    INSERT INTO contact
      VALUES (UUID(), v_IssuedID, v_ReceivedID, CODE, 1,  -- ContactStatus (Pending)
      NOW(), 0);
  END IF;
END
$$

--
-- Create procedure `proc_contact_getAll`
--
CREATE DEFINER = 'sql12612725'@'%'
PROCEDURE proc_contact_getAll (IN v_UserID varchar(255))
COMMENT 'Lấy tất cả liên hệ của 1 user bằng địa chỉ ví stake'
BEGIN
  SELECT
    c.ContactID,
    c.ContactCode,
    u.UserName AS `ContactName`,
    c.CreatedDate,
    c.ContactStatus
  FROM user u
    JOIN contact c
      ON u.UserID = c.ReceivedID
      OR u.UserID = c.IssuedID

  -- Check conditions
  WHERE c.IsDeleted = 0
  AND ((c.ReceivedID = v_UserID
  AND c.IssuedID = u.UserID)
  OR (c.IssuedID = v_UserID
  AND c.ReceivedID = u.UserID))


  ORDER BY c.CreatedDate ASC;
END
$$

--
-- Create procedure `proc_contact_delete`
--
CREATE DEFINER = 'sql12612725'@'%'
PROCEDURE proc_contact_delete (IN v_ContactID char(36))
COMMENT 'Ẩn 1 liên hệ'
BEGIN
  UPDATE contact c
  SET c.IsDeleted = 1
  WHERE c.ContactID = v_ContactID;
END
$$

--
-- Create procedure `proc_contact_accept`
--
CREATE DEFINER = 'sql12612725'@'%'
PROCEDURE proc_contact_accept (IN v_ContactID char(36))
BEGIN
  UPDATE contact c
  SET c.ContactStatus = 2
  WHERE c.ContactID = v_ContactID;
END
$$

DELIMITER ;

--
-- Create table `certificate`
--
CREATE TABLE certificate (
  CertificateID char(36) NOT NULL DEFAULT '' COMMENT 'Khóa ngoại, liên kết với bảng user(PolicyID)',
  IssuedID varchar(255) NOT NULL DEFAULT '' COMMENT 'Khóa ngoại, liên kết với bảng user(PolicyID)',
  ReceivedID varchar(255) NOT NULL DEFAULT '' COMMENT 'Khóa ngoại, liên kết với bảng user(PolicyID)',
  CertificateCode mediumint(9) NOT NULL COMMENT 'Mã code, để hiển thị lên trang web',
  CertificateType varchar(255) NOT NULL COMMENT 'Kiểu bằng cấp (0-Education Certificate)',
  CertificateName varchar(255) NOT NULL DEFAULT '' COMMENT 'Tên bằng cấp (Bằng kỹ sư, bằng cử nhân)',
  ReceivedAddressWallet varchar(255) DEFAULT NULL COMMENT 'Địa chỉ ví người nhận',
  ReceivedIdentityNumber varchar(255) DEFAULT '' COMMENT 'số CCCD/CMND của người nhận',
  ReceivedName varchar(255) DEFAULT NULL COMMENT 'Tên người nhận bằng',
  ReceivedDoB date DEFAULT NULL COMMENT 'Ngày sinh người nhận bằng',
  YearOfGraduation smallint(6) DEFAULT NULL,
  Classification varchar(50) NOT NULL DEFAULT '' COMMENT 'Loại bằng cấp',
  ModeOfStudy varchar(255) DEFAULT NULL COMMENT 'Hình thức đào tạo (0-Chính quy tập trung, 1-Tại chức)',
  IpfsLink varchar(255) DEFAULT NULL COMMENT 'Mã ipfs của ảnh bằng',
  ImageLink text DEFAULT NULL COMMENT 'Đường link ảnh trên cloudbinary',
  TransactionLink varchar(255) DEFAULT NULL COMMENT 'Mã hash của giao dịch cấp bằng',
  CertificateStatus tinyint(4) DEFAULT 1 COMMENT 'Trạng thái của bằng cấp (1-Draft/2-Signed/3-Sent/4-Banned)',
  CreatedDate datetime DEFAULT NULL,
  SignedDate datetime DEFAULT NULL COMMENT 'Ngày kí',
  SentDate datetime DEFAULT NULL COMMENT 'Ngày tháng xuất/nhận bằng',
  IsDeleted tinyint(4) DEFAULT NULL,
  PRIMARY KEY (CertificateID)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 1092,
CHARACTER SET latin1,
COLLATE latin1_swedish_ci;

--
-- Create index `CertificateCode` on table `certificate`
--
ALTER TABLE certificate
ADD UNIQUE INDEX CertificateCode (CertificateCode);

--
-- Create foreign key
--
ALTER TABLE certificate
ADD CONSTRAINT FK_certificate_ReceivedID FOREIGN KEY (ReceivedID)
REFERENCES user (UserID) ON DELETE NO ACTION;

--
-- Create foreign key
--
ALTER TABLE certificate
ADD CONSTRAINT FK_certificate_IssuedID FOREIGN KEY (IssuedID)
REFERENCES user (UserID) ON DELETE NO ACTION;

DELIMITER $$

--
-- Create procedure `proc_dashboard_getInfor`
--
CREATE DEFINER = 'sql12612725'@'%'
PROCEDURE proc_dashboard_getInfor (IN v_UserID varchar(255),
OUT v_Username varchar(255),
OUT v_IsVerified tinyint,
OUT v_Logo varchar(255),
OUT v_Pending int,
OUT v_Connected int,
OUT v_Draft int,
OUT v_Signed int,
OUT v_Sent int,
OUT v_Banned int,
OUT v_Received int)
COMMENT 'Lấy tất cả liên hệ của 1 user bằng địa chỉ ví stake'
BEGIN
  SELECT
    UserName INTO v_Username
  FROM user
  WHERE UserID = v_UserID;

  SELECT
    isVerified INTO v_IsVerified
  FROM user
  WHERE UserID = v_UserID;

  SELECT
    Logo INTO v_Logo
  FROM user
  WHERE UserID = v_UserID;

  SELECT
    IFNULL(COUNT(c.ContactID), 0) INTO v_Pending
  FROM contact c
  WHERE (c.IssuedID = v_UserID
  OR c.ReceivedID = v_UserID)
  AND c.ContactStatus = 1;

  SELECT
    IFNULL(COUNT(c.ContactID), 0) INTO v_Connected
  FROM contact c
  WHERE (c.IssuedID = v_UserID
  OR c.ReceivedID = v_UserID)
  AND c.ContactStatus = 2;

  SELECT
    IFNULL(COUNT(c.IssuedID), 0) INTO v_Draft
  FROM certificate c
  WHERE (c.IssuedID = v_UserID)
  AND c.CertificateStatus = 1;

  SELECT
    IFNULL(COUNT(c.IssuedID), 0) INTO v_Signed
  FROM certificate c
  WHERE c.IssuedID = v_UserID
  AND c.CertificateStatus = 2;

  SELECT
    IFNULL(COUNT(c.IssuedID), 0) INTO v_Sent
  FROM certificate c
  WHERE c.IssuedID = v_UserID
  AND c.CertificateStatus = 3;

  SELECT
    IFNULL(COUNT(c.IssuedID), 0) INTO v_Banned
  FROM certificate c
  WHERE c.IssuedID = v_UserID
  AND c.CertificateStatus = 4;

  SELECT
    IFNULL(COUNT(c.ReceivedID), 0) INTO v_Received
  FROM certificate c
  WHERE c.ReceivedID = v_UserID
  AND c.CertificateStatus = 3;
END
$$

--
-- Create procedure `proc_certificate_sign`
--
CREATE DEFINER = 'sql12612725'@'%'
PROCEDURE proc_certificate_sign (IN v_CertificateID char(36))
COMMENT 'Kí 1 bằng theo CertificateID'
BEGIN
  UPDATE certificate c
  SET c.CertificateStatus = 2,
      c.SignedDate = NOW()
  WHERE c.CertificateID = v_CertificateID;
END
$$

--
-- Create procedure `proc_certificate_send`
--
CREATE DEFINER = 'sql12612725'@'%'
PROCEDURE proc_certificate_send (IN v_CertificateID char(36))
COMMENT 'Gửi 1 bằng theo CertificateID'
BEGIN
  UPDATE certificate c
  SET c.CertificateStatus = 3,
      c.SentDate = NOW()
  WHERE c.CertificateID = v_CertificateID;
END
$$

--
-- Create procedure `proc_certificate_insert`
--
CREATE DEFINER = 'sql12612725'@'%'
PROCEDURE proc_certificate_insert (IN v_IssuedID varchar(255),
IN v_ReceivedID varchar(255),
IN v_ReceivedAddressWallet varchar(255),
IN v_ReceivedIdentityNumber varchar(255),
IN v_CertificateName varchar(255),
IN v_ReceivedName varchar(255),
IN v_ReceivedDoB date,
IN v_YearOfGraduation smallint,
IN v_Classification varchar(50),
IN v_ModeOfStudy varchar(255))
BEGIN
  -- Lấy giá trị lớn nhất của user code
  DECLARE CODE mediumint;
  SELECT
    MAX(certificatecode) INTO CODE
  FROM certificate;

  -- Nếu table xxx chưa có data sẽ mặc định CODE = 100000
  IF CODE IS NULL THEN
    SET CODE = 100000;
  ELSE
    SET CODE = CODE + 1;
  END IF;

  INSERT INTO certificate
    VALUES (UUID(), v_IssuedID, v_ReceivedID, CODE, 'UTC', v_CertificateName, v_ReceivedAddressWallet, v_ReceivedIdentityNumber, v_ReceivedName, v_ReceivedDoB, v_YearOfGraduation, v_Classification, v_ModeOfStudy, '', -- ipfslink
    '', -- imagelink
    '', -- transactionlink
    1, -- CertificateStatus: Draft
    NOW(), -- CreatedDate: NOW
    NULL, -- SignedDate: NULL
    NULL, -- SentDate: NULL
    0); -- IsDeleted: Chua xoa

  -- Them contact voi nguoi gui bang
  CALL proc_contact_insert(v_IssuedID, v_ReceivedID);
END
$$

--
-- Create procedure `proc_certificate_getAllReceived`
--
CREATE DEFINER = 'sql12612725'@'%'
PROCEDURE proc_certificate_getAllReceived (IN v_ReceivedID varchar(255))
BEGIN
  SELECT
    c.CertificateID,
    c.ImageLink,
    c.TransactionLink,
    c.CertificateCode,
    u.UserName AS `OganizationName`,
    u.IsVerified,
    c.ReceivedIdentityNumber,
    c.ReceivedName,
    c.ReceivedDoB,
    c.CertificateName,
    c.YearOfGraduation,
    c.Classification,
    c.ModeOfStudy,
    c.SentDate AS `ReceivedDate`
  FROM certificate c
    JOIN user u
      ON c.IssuedID = u.UserID
  -- Check conditions
  WHERE c.ReceivedID = v_ReceivedID
  AND c.CertificateStatus = 3
  AND c.IsDeleted = 0

  ORDER BY c.CreatedDate;
END
$$

--
-- Create procedure `proc_certificate_getAllIssued`
--
CREATE DEFINER = 'sql12612725'@'%'
PROCEDURE proc_certificate_getAllIssued (IN v_IssuerID varchar(255))
BEGIN
  SELECT
    c.CertificateID,
    c.ImageLink,
    c.TransactionLink,
    c.ReceivedIdentityNumber,
    c.ReceivedDoB,
    c.YearOfGraduation,
    c.Classification,
    c.ModeOfStudy,
    c.IpfsLink,
    c.SentDate,
    c.ReceivedAddressWallet,
    c.CertificateCode,
    c.CertificateType,
    c.CertificateName,
    c.ReceivedName,
    c.SignedDate,
    c1.ContactStatus,
    c.CertificateStatus

  FROM certificate c
    JOIN user u
      ON c.ReceivedID = u.UserID
    JOIN contact c1
      ON u.UserID = c1.ReceivedID

  WHERE c.IssuedID = v_IssuerID
  AND c1.IssuedID = v_IssuerID
  AND c.IsDeleted = 0
  ORDER BY c.CreatedDate DESC;

END
$$

--
-- Create procedure `proc_certificate_delete`
--
CREATE DEFINER = 'sql12612725'@'%'
PROCEDURE proc_certificate_delete (IN v_CertificateID char(36))
BEGIN
  UPDATE certificate c
  SET c.IsDeleted = 1
  WHERE c.CertificateID = v_CertificateID;
END
$$

--
-- Create procedure `proc_certificate_ban`
--
CREATE DEFINER = 'sql12612725'@'%'
PROCEDURE proc_certificate_ban (IN v_CertificateID char(36))
BEGIN
  UPDATE certificate c
  SET c.CertificateStatus = 4
  WHERE c.CertificateID = v_CertificateID;
END
$$

--
-- Create procedure `proc_Certificate_AddTransactionLink`
--
CREATE DEFINER = 'sql12612725'@'%'
PROCEDURE proc_Certificate_AddTransactionLink (IN v_CertificateIDs text, IN v_TransactionLink varchar(255))
BEGIN
  UPDATE certificate
  SET TransactionLink = v_TransactionLink
  WHERE FIND_IN_SET(CertificateID, v_CertificateIDs) > 0;
END
$$

--
-- Create procedure `proc_user_insert`
--
CREATE DEFINER = 'sql12612725'@'%'
PROCEDURE proc_user_insert (IN v_UserID varchar(255), IN v_UserName varchar(255), IN v_Logo varchar(255))
COMMENT 'Procedure thêm mới 1 nguoi dung'
BEGIN
  -- Lấy giá trị lớn nhất của user code
  DECLARE CODE mediumint;
  SELECT
    MAX(UserCode) INTO CODE
  FROM user;

  -- Nếu table xxx chưa có data sẽ mặc định CODE = 100000
  IF CODE IS NULL THEN
    SET CODE = 100000;
  ELSE
    SET CODE = CODE + 1;
  END IF;

  INSERT INTO user
    VALUES (v_UserID, CODE, v_UserName, v_Logo, NOW(), 0, 0);
END
$$

--
-- Create procedure `proc_user_delete`
--
CREATE DEFINER = 'sql12612725'@'%'
PROCEDURE proc_user_delete (IN v_UserID varchar(255))
COMMENT 'Xóa 1 người dùng'
BEGIN
  UPDATE user u
  SET u.IsDeleted = 1
  WHERE u.UserID = v_UserID;
END
$$

--
-- Create procedure `Proc_Certificate_SignMultiple`
--
CREATE DEFINER = 'sql12612725'@'%'
PROCEDURE Proc_Certificate_SignMultiple (IN v_CertificateIDs text)
BEGIN
  SET @v_CertificateIDs = REPLACE(v_CertificateIDs, ',', ''',''');

  SET @Query = CONCAT('UPDATE certificate SET CertificateStatus = 2, SignedDate = NOW() WHERE CertificateID IN (''', @v_CertificateIDs, ''');');

  PREPARE deleteQueryStatement FROM @Query;
  EXECUTE deleteQueryStatement;
END
$$

--
-- Create procedure `Proc_Certificate_SendMultiple`
--
CREATE DEFINER = 'sql12612725'@'%'
PROCEDURE Proc_Certificate_SendMultiple (IN v_CertificateIDs text)
BEGIN
  SET @v_CertificateIDs = REPLACE(v_CertificateIDs, ',', ''',''');

  SET @Query = CONCAT('UPDATE certificate SET certificateStatus = 3, SentDate = NOW() WHERE CertificateID IN (''', @v_CertificateIDs, ''');');

  PREPARE deleteQueryStatement FROM @Query;
  EXECUTE deleteQueryStatement;
END
$$

--
-- Create procedure `proc_certificate_DeleteMultiple`
--
CREATE DEFINER = 'sql12612725'@'%'
PROCEDURE proc_certificate_DeleteMultiple (IN v_CertificateIDs text)
BEGIN
  SET @v_CertificateIDs = REPLACE(v_CertificateIDs, ',', ''',''');

  SET @Query = CONCAT('UPDATE certificate SET isDeleted = 1 WHERE CertificateID IN (''', @v_CertificateIDs, ''');');

  PREPARE deleteQueryStatement FROM @Query;
  EXECUTE deleteQueryStatement;
END
$$

--
-- Create procedure `proc_certificate_BanMultiple`
--
CREATE DEFINER = 'sql12612725'@'%'
PROCEDURE proc_certificate_BanMultiple (IN v_CertificateIDs text)
BEGIN
  SET @v_CertificateIDs = REPLACE(v_CertificateIDs, ',', ''',''');

  SET @Query = CONCAT('UPDATE certificate SET certificatestatus = 4 WHERE CertificateID IN (''', @v_CertificateIDs, ''');');

  PREPARE deleteQueryStatement FROM @Query;
  EXECUTE deleteQueryStatement;

  DEALLOCATE PREPARE deleteQueryStatement;
END
$$

DELIMITER ;

-- 
-- Dumping data for table user
--
INSERT INTO user VALUES
('stake_test1upgyluuflvwk2kdjxlfzxgqrly3r72652aaa3sj0hdeqdyceq4f0h', 100006, 'Vu Truong Giang', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '2023-03-27 07:24:13', 0, 0),
('stake_test1upvadt5zw4t5uw8tzzwl0xp5kaks0svzqg6hsfekhjl0fzs7k42ll', 100004, 'Tran Lam Lien', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '2023-03-27 07:24:13', 0, 0),
('stake_test1upzlwwvcu2cfajnzdcvthqw7snp2w2vsp4yceqsph8rx8cqna2ker', 100005, 'Le Dinh Minh', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '2023-03-27 07:24:13', 0, 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka1', 100007, 'Nguyen Van A', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '2023-03-27 07:24:13', 0, 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka2', 100008, 'Nguyen Van B', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '2023-03-27 07:24:13', 0, 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka3', 100009, 'Nguyen Van C', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '2023-03-27 07:24:13', 0, 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka4', 100010, 'Nguyen Van D', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '2023-03-27 07:24:13', 0, 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka5', 100011, 'Nguyen Van E', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '2023-03-27 07:24:13', 0, 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka6', 100012, 'Nguyen Van F', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '2023-03-27 07:24:13', 0, 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka7', 100013, 'Nguyen Van G', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '2023-03-27 07:24:13', 0, 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka8', 100014, 'Nguyen Van H', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '2023-03-27 07:24:13', 0, 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka9', 100015, 'Nguyen Van I', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '2023-03-27 07:24:13', 0, 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks3', 100003, 'Bach 2', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '2023-03-27 07:24:12', 0, 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nksu', 100002, 'Trinh Xuan Bach', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '2023-03-27 07:24:12', 0, 0),
('stake_test1uruq088hsj2jxxwgjhex6hkpfd2ap7jurhjnqhvfs8why2s0w4ltl', 100001, 'Tran Huy Hiep', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '2023-03-27 07:24:12', 0, 0),
('stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 100000, 'University of Transport and Communications', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679067306/Logo/f513d3d1-faa5-404d-a3ae-08221608e764.jpg', '2023-03-27 07:24:12', 0, 0),
('ttesst', 100016, 'test', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679932773/Logo/9eaedb89-8d36-4bea-a433-a90d095f5ea1.jpg', '2023-03-27 08:11:36', 0, 0);

-- 
-- Dumping data for table contact
--
INSERT INTO contact VALUES
('a30e78c8-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uruq088hsj2jxxwgjhex6hkpfd2ap7jurhjnqhvfs8why2s0w4ltl', 100000, 1, '2023-04-06 20:06:56', 0),
('a334a345-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nksu', 100001, 1, '2023-04-06 20:06:56', 0),
('a35a01e9-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks3', 100002, 1, '2023-04-06 20:06:57', 0),
('a37fb582-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1upvadt5zw4t5uw8tzzwl0xp5kaks0svzqg6hsfekhjl0fzs7k42ll', 100003, 1, '2023-04-06 20:06:57', 0),
('a3a5d08f-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1upzlwwvcu2cfajnzdcvthqw7snp2w2vsp4yceqsph8rx8cqna2ker', 100004, 1, '2023-04-06 20:06:57', 0),
('a3cab0df-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1upgyluuflvwk2kdjxlfzxgqrly3r72652aaa3sj0hdeqdyceq4f0h', 100005, 1, '2023-04-06 20:06:57', 0),
('a3f144dd-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka1', 100006, 1, '2023-04-06 20:06:58', 0),
('a4169318-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka2', 100007, 1, '2023-04-06 20:06:58', 0),
('a43a9a10-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka3', 100008, 1, '2023-04-06 20:06:58', 0),
('a45e9d32-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka4', 100009, 1, '2023-04-06 20:06:58', 0),
('a483ed92-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka5', 100010, 1, '2023-04-06 20:06:59', 0),
('a4a7f8c3-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka6', 100011, 1, '2023-04-06 20:06:59', 0),
('a4cbf9c8-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka7', 100012, 1, '2023-04-06 20:06:59', 0),
('a4ef956f-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka8', 100013, 1, '2023-04-06 20:06:59', 0),
('a513a2e7-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka9', 100014, 1, '2023-04-06 20:06:59', 0);

-- 
-- Dumping data for table certificate
--
INSERT INTO certificate VALUES
('a306c8f9-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uruq088hsj2jxxwgjhex6hkpfd2ap7jurhjnqhvfs8why2s0w4ltl', 100000, 'UTC', 'The Degree Of Engineer', 'addr_test1qr4fkykkejglg6fz7vydddvwezc4vr4rpecp8nc5psc27zhcq7w00py4yvvu390jd40vzj646ra9c809xpwcnqwawg4q0xgwj3', '1234567891', 'Hiep Tran', '2023-12-30', 2022, 'Good', 'Full-time', 'ipfs://QmNid5EKvVGfH4KMaEjUqU3W9VubVfYmaeUzjzf5zwY58M', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1680839702/Degree/f2da6ffc-6cdf-4214-a19c-7acaf0467422.png', '', 1, '2023-04-06 20:06:56', NULL, NULL, 0),
('a33284f0-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nksu', 100001, 'UTC', 'The Degree Of Engineer', 'addr_test1qps5dtz389tm04qnt8nscmr2wc6tjhjwv3vx98j06ykgu23ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqxe3j55', '1234567892', 'Bach Trinh', '2023-12-03', 2022, 'Good', 'Part-time', 'ipfs://QmZgHTgyEtftMbMnWy3Ksjqm12cknCfqvAJ6PVavcPNmQq', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1680839704/Degree/37c37445-9972-4415-904f-046a0f3e30ea.png', '', 1, '2023-04-06 20:06:56', NULL, NULL, 0),
('a3577393-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks3', 100002, 'UTC', 'The Degree Of Engineer', 'addr_test1qrsttrn8t5rejhflggnckrrs3v6s537wqlftlswkh02kg2cejeeu3c39zpg5z4v3km30wr9vnu7txenw73gr0stq2cyqm9w6hz', '1234567893', 'Bach 2', '2023-02-03', 2022, 'Good', 'Full-time', 'ipfs://QmXJK7fA3nDKhbjsMDUgZHXDDU7nZawp9fuaRR1u5VbR8h', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1680839705/Degree/43870fc4-0654-4a3d-a414-a8f36b714ede.png', '', 1, '2023-04-06 20:06:57', NULL, NULL, 0),
('a37cb749-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1upvadt5zw4t5uw8tzzwl0xp5kaks0svzqg6hsfekhjl0fzs7k42ll', 100003, 'UTC', 'The Degree Of Engineer', 'addr_test1qqg57af80z9lh2p767mj4k3cjde07n0wnaquzhzzuypnz6ze66hgya2hfcuwkyya77vrfdmdqlqcyq340qnnd0977j9q38c89v', '1234567894', 'Tran Lam Lien', '2023-12-03', 2022, 'Good', 'Part-time', 'ipfs://QmdUZ7sTyiLqXMUnHuqwXsRPK3qnWPqd4bqKW8AjDnPi7A', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1680839707/Degree/918572b8-4b3e-4f26-bd4c-19c7c5b5af2c.png', '', 1, '2023-04-06 20:06:57', NULL, NULL, 0),
('a3a3edb7-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1upzlwwvcu2cfajnzdcvthqw7snp2w2vsp4yceqsph8rx8cqna2ker', 100004, 'UTC', 'The Degree Of Bachelor', 'addr_test1qqcvgpl7p7hh7zmcy59gv8yy84ttv4dajej3f06w2g300dz97uue3c4snm9xymschwqaapxz5u5eqr2f3jpqrwwxv0sq2e5xeg', '1234567895', 'Le Dinh Minh', '2023-12-03', 2022, 'Good', 'Full-time', 'ipfs://QmWj4m2wweHM2WTKhv4WYETASH1WpedQxowwhJeoc1RstA', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1680839709/Degree/ee491876-4912-4ece-b6cc-ca6f57c02e38.png', '', 1, '2023-04-06 20:06:57', NULL, NULL, 0),
('a3c8dbac-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1upgyluuflvwk2kdjxlfzxgqrly3r72652aaa3sj0hdeqdyceq4f0h', 100005, 'UTC', 'The Degree Of Bachelor', 'addr_test1qp04pc7smwdpmwgh72lsdr5k202y2ztssd6hzwnmexu230zsflecn7cav4vmyd7jyvsq87fz8u44g4mmmrpylwmjq6fswr9x6w', '1234567896', 'Vu Truong Giang', '2023-12-03', 2022, 'Excellent', 'Full-time', 'ipfs://QmcLPqHeX5so3C8At9o3yQ5MGvDpk7kem7bHYghdRsJyF6', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1680839712/Degree/ee258022-bb78-44c1-ad0e-823888ba198d.png', '', 1, '2023-04-06 20:06:57', NULL, NULL, 0),
('a3ef2c9e-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka1', 100006, 'UTC', 'The Degree Of Bachelor', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h7', '1234567897', 'Nguyen Van G', '2023-12-03', 2022, 'Excellent', 'Full-time', 'ipfs://QmYZyaZKqf8bTAwm4xBQEnkAJ1PDx2LwJDWFqrirqpKm3b', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1680839716/Degree/dd048853-f3e1-47a9-b9de-4a8c6b5e1136.png', '', 1, '2023-04-06 20:06:58', NULL, NULL, 0),
('a4141ee8-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka2', 100007, 'UTC', 'The Degree Of Bachelor', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h8', '1234567898', 'Nguyen Van H', '2023-12-03', 2022, 'Good', 'Part-time', 'ipfs://QmYPhHEZUenLWsxoeEj19TMjnMeiTbU7pYuvxoUT54HA8R', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1680839720/Degree/09bfbba9-438a-448e-8e17-8a6c16bec2a2.png', '', 1, '2023-04-06 20:06:58', NULL, NULL, 0),
('a4395e62-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka3', 100008, 'UTC', 'The Degree Of Bachelor', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h9', '1234567899', 'Nguyen Van I', '2023-12-03', 2022, 'Excellent', 'Part-time', 'ipfs://QmNNmoT2xDWr4X1LQMDnKxtbYtYQQYArSH8xCBK8w6NoDC', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1680839724/Degree/29db05f4-ba95-4ee8-aa6b-7a84b27cc7df.png', '', 1, '2023-04-06 20:06:58', NULL, NULL, 0),
('a45cf45c-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka4', 100009, 'UTC', 'The Degree Of Bachelor', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h7', '2234567891', 'Nguyen Van G', '2023-12-03', 2022, 'Good', 'Full-time', 'ipfs://QmQY3oZd2uLsaVsuaeoDejtw3gwp3bYyFuq61j9VUZoFgt', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1680839727/Degree/9059fc32-b217-4a51-bb09-ccd2a7d67e5e.png', '', 1, '2023-04-06 20:06:58', NULL, NULL, 0),
('a481ba6f-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka5', 100010, 'UTC', 'The Degree Of Bachelor', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h8', '3234567891', 'Nguyen Van H', '2023-12-03', 2022, 'Excellent', 'Part-time', 'ipfs://QmaHnrg5Txfd9FXwDCyeoqzUwnHZ6wm9LoR6fMv9ibvSAZ', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1680839732/Degree/2f9a2564-416f-430b-b096-86a2562979fa.png', '', 1, '2023-04-06 20:06:59', NULL, NULL, 0),
('a4a65aff-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka6', 100011, 'UTC', 'The Degree Of Bachelor', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h9', '4234567891', 'Nguyen Van I', '2023-12-03', 2022, 'Excellent', 'Part-time', 'ipfs://QmYeHS78QaXh9DwTojrK6DZ1FCc5KiQyv5Hh7Wr69Uf5NM', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1680839736/Degree/2e1068ba-6c17-40ec-8e39-5aef29b057a1.png', '', 1, '2023-04-06 20:06:59', NULL, NULL, 0),
('a4ca85f1-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka7', 100012, 'UTC', 'The Degree Of Bachelor', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h7', '5234567891', 'Nguyen Van G', '2023-12-03', 2022, 'Good', 'Full-time', 'ipfs://QmcBekyGnpsgiJkWEpafTeSMkgMfiNTZVoTBPzAsmeoRkb', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1680839740/Degree/47eb132e-8fd2-4be4-8db9-633928470255.png', '', 1, '2023-04-06 20:06:59', NULL, NULL, 0),
('a4ee3fbd-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka8', 100013, 'UTC', 'The Degree Of Bachelor', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h8', '6234567891', 'Nguyen Van H', '2023-12-03', 2022, 'Excellent', 'Part-time', 'ipfs://QmP81JgXVfTYREsfq6zeSQA4NjFXKXr5o9pr1T97Y9w3dr', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1680839744/Degree/4f8e09d8-ba30-4bf3-b9c9-ed01b595db14.png', '', 1, '2023-04-06 20:06:59', NULL, NULL, 0),
('a5121bd9-d4f9-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nka9', 100014, 'UTC', 'The Degree Of Bachelor', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h9', '7234567891', 'Nguyen Van I', '2023-12-03', 2022, 'Good', 'Part-time', 'ipfs://QmP2uBzSN4wMdaS8Ab11GKpuGRrU74h3jNrD6Y4BiWNYRx', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1680839748/Degree/15b1b248-8d56-4f2e-82ee-ffb89f06c447.png', '', 1, '2023-04-06 20:06:59', NULL, NULL, 0);

-- 
-- Restore previous SQL mode
-- 
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;

-- 
-- Enable foreign keys
-- 
/*!40014 SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS */;