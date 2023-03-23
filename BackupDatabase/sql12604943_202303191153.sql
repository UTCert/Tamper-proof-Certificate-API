﻿--
-- Script was generated by Devart dbForge Studio 2020 for MySQL, Version 9.0.338.0
-- Product home page: http://www.devart.com/dbforge/mysql/studio
-- Script date 3/19/2023 11:53:25 AM
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
USE sql12604943;

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
-- Drop procedure `Proc_Certificate_GetAllIssued`
--
DROP PROCEDURE IF EXISTS Proc_Certificate_GetAllIssued;

--
-- Drop procedure `Proc_Certificate_GetAllReceived`
--
DROP PROCEDURE IF EXISTS Proc_Certificate_GetAllReceived;

--
-- Drop procedure `proc_certificate_GetPagingIssued`
--
DROP PROCEDURE IF EXISTS proc_certificate_GetPagingIssued;

--
-- Drop procedure `proc_certificate_GetPagingReceived`
--
DROP PROCEDURE IF EXISTS proc_certificate_GetPagingReceived;

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
-- Drop procedure `proc_dashboard_GetInfor`
--
DROP PROCEDURE IF EXISTS proc_dashboard_GetInfor;

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
-- Drop procedure `Proc_Contact_GetAll`
--
DROP PROCEDURE IF EXISTS Proc_Contact_GetAll;

--
-- Drop procedure `proc_contact_GetPaging`
--
DROP PROCEDURE IF EXISTS proc_contact_GetPaging;

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
USE sql12604943;

--
-- Create table `user`
--
CREATE TABLE user (
  UserID varchar(255) NOT NULL DEFAULT '' COMMENT 'Khóa chính, là địa chỉ ví skate',
  UserCode mediumint(8) UNSIGNED NOT NULL COMMENT 'Mã code, để hiển thị lên trang web',
  UserName varchar(255) DEFAULT NULL COMMENT 'Tên tổ chức',
  Logo text DEFAULT NULL,
  AddressWallet varchar(255) DEFAULT '' COMMENT 'PolicyID Của tài khoản',
  CreatedDate datetime DEFAULT NULL COMMENT 'Ngày tạo tài khoản',
  IsDeleted tinyint(4) DEFAULT 0 COMMENT 'Bị xóa hay chưa (0-chưa xóa; 1-đã xóa)',
  PRIMARY KEY (UserID)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 1170,
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
  ContactStatus tinyint(4) DEFAULT NULL COMMENT 'Trạng thái kết nối (0-pending, 1-connected)',
  CreatedDate datetime DEFAULT NULL COMMENT 'Ngày tạo',
  IsDeleted tinyint(4) NOT NULL COMMENT 'xóa hay chưa (0-hiện/1-ẩn)',
  PRIMARY KEY (ContactID)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 1260,
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
CREATE DEFINER = 'sql12604943'@'%'
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
      VALUES (UUID(), v_IssuedID, v_ReceivedID, CODE, 0,  -- ContactStatus (Pending)
      NOW(), 0);
  END IF;
END
$$

--
-- Create procedure `proc_contact_GetPaging`
--
CREATE DEFINER = 'sql12604943'@'%'
PROCEDURE proc_contact_GetPaging (IN v_UserID varchar(255),
IN v_PageSize int,
IN v_PageNumber int,
IN v_UserName varchar(255),
IN v_ContactStatus tinyint)
BEGIN

  DECLARE offset_page int;
  DECLARE no_results_error CONDITION FOR SQLSTATE '02000';

  -- v_PageSize and  v_PageNumber must be > 0
  IF v_PageSize <= 0 THEN
    SELECT
      'Invalid Page Size: Page Size must be greater than zero';
    SIGNAL no_results_error;
  END IF;

  IF v_PageNumber <= 0 THEN
    SELECT
      'Invalid Page Number: Page Number must be greater than zero';
    SIGNAL no_results_error;
  END IF;

  -- Offset_page is record number want to get
  SET offset_page = (v_PageNumber - 1) * v_PageSize;

  SELECT
    c.ContactID,
    c.ContactCode,
    u.UserName,
    c.CreatedDate,
    c.ContactStatus
  FROM user u
    JOIN contact c
      ON u.PolicyID = c.ReceivedID
      OR u.PolicyID = c.IssuedID

  -- Check conditions
  WHERE (
  (c.ReceivedID = v_UserID
  AND c.IssuedID = u.PolicyID)
  OR (c.IssuedID = v_UserID
  AND c.ReceivedID = u.PolicyID)
  )
  AND (u.UserName LIKE CONCAT('%', v_UserName, '%')
  OR v_UserName IS NULL)
  AND (c.ContactStatus = v_ContactStatus
  OR v_ContactStatus IS NULL)
  AND c.IsDeleted = 0

  -- Default sort by CreatedDate
  ORDER BY c.CreatedDate ASC
  LIMIT v_PageSize
  OFFSET offset_page;
END
$$

--
-- Create procedure `Proc_Contact_GetAll`
--
CREATE DEFINER = 'sql12604943'@'%'
PROCEDURE Proc_Contact_GetAll (IN v_UserID varchar(255))
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
CREATE DEFINER = 'sql12604943'@'%'
PROCEDURE proc_contact_delete (IN v_ContactID char(36))
COMMENT 'Xóa '
BEGIN
  UPDATE contact c
  SET c.IsDeleted = 1
  WHERE c.ContactID = v_ContactID;
END
$$

--
-- Create procedure `proc_contact_accept`
--
CREATE DEFINER = 'sql12604943'@'%'
PROCEDURE proc_contact_accept (IN v_ContactID char(36))
BEGIN
  UPDATE contact c
  SET c.ContactStatus = 1
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
  ReceivedAddressWallet varchar(255) DEFAULT NULL COMMENT 'Dia chi vi nguoi nhan',
  ReceivedName varchar(255) DEFAULT NULL COMMENT 'Tên người nhận bằng',
  ReceivedDoB date DEFAULT NULL COMMENT 'Ngày sinh người nhận bằng',
  YearOfGraduation smallint(6) DEFAULT NULL,
  Classification varchar(50) NOT NULL DEFAULT '' COMMENT 'Loại bằng cấp',
  ModeOfStudy varchar(255) DEFAULT NULL COMMENT 'Hình thức đào tạo (0-Chính quy tập trung, 1-Tại chức)',
  IpfsLink varchar(255) DEFAULT NULL COMMENT 'Mã ipfs của ảnh bằng',
  ImageLink text DEFAULT NULL,
  TransactionLink text DEFAULT NULL,
  CertificateStatus tinyint(4) DEFAULT NULL COMMENT 'Trạng thái của bằng cấp (0-Draft/1-Signed/2-Sent)',
  CreatedDate datetime DEFAULT NULL,
  IsSigned tinyint(4) DEFAULT 0 COMMENT 'Được kí hay chưa (0-chưa kí; 1-đã kí)',
  SignedDate datetime DEFAULT NULL COMMENT 'Ngày kí',
  IsSend tinyint(4) NOT NULL COMMENT 'Gửi bằng hay chưa (0-Chưa gửi/1-Đã gửi)',
  SentDate datetime DEFAULT NULL COMMENT 'Ngày tháng xuất/nhận bằng',
  IsDeleted tinyint(4) DEFAULT NULL,
  PRIMARY KEY (CertificateID)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 910,
CHARACTER SET latin1,
COLLATE latin1_swedish_ci;

--
-- Create foreign key
--
ALTER TABLE certificate
ADD CONSTRAINT FK_certificate_IssuedID FOREIGN KEY (IssuedID)
REFERENCES user (UserID) ON DELETE NO ACTION;

--
-- Create foreign key
--
ALTER TABLE certificate
ADD CONSTRAINT FK_certificate_ReceivedID FOREIGN KEY (ReceivedID)
REFERENCES user (UserID) ON DELETE NO ACTION;

DELIMITER $$

--
-- Create procedure `proc_dashboard_GetInfor`
--
CREATE DEFINER = 'sql12604943'@'%'
PROCEDURE proc_dashboard_GetInfor (IN v_UserID varchar(255),
OUT v_Username varchar(255),
OUT v_Logo varchar(255),
OUT v_Pending int,
OUT v_Connected int,
OUT v_Draft int,
OUT v_Signed int,
OUT v_Sent int,
OUT v_Received int)
BEGIN
  SELECT
    UserName INTO v_Username
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
  AND c.ContactStatus = 0;

  SELECT
    IFNULL(COUNT(c.ContactID), 0) INTO v_Connected
  FROM contact c
  WHERE (c.IssuedID = v_UserID
  OR c.ReceivedID = v_UserID)
  AND c.ContactStatus = 1;

  SELECT
    IFNULL(COUNT(c.IssuedID), 0) INTO v_Draft
  FROM certificate c
  WHERE (c.IssuedID = v_UserID)
  AND c.CertificateStatus = 0;

  SELECT
    IFNULL(COUNT(c.IssuedID), 0) INTO v_Signed
  FROM certificate c
  WHERE c.IssuedID = v_UserID
  AND c.CertificateStatus = 1;

  SELECT
    IFNULL(COUNT(c.IssuedID), 0) INTO v_Sent
  FROM certificate c
  WHERE c.IssuedID = v_UserID
  AND c.CertificateStatus = 2;

  SELECT
    IFNULL(COUNT(c.ReceivedID), 0) INTO v_Received
  FROM certificate c
  WHERE c.ReceivedID = v_UserID
  AND c.CertificateStatus = 2;
END
$$

--
-- Create procedure `proc_certificate_sign`
--
CREATE DEFINER = 'sql12604943'@'%'
PROCEDURE proc_certificate_sign (IN v_CertificateID char(36))
BEGIN
  UPDATE certificate c
  SET c.CertificateStatus = 1,
      c.IsSigned = 1,
      c.SignedDate = NOW()
  WHERE c.CertificateID = v_CertificateID;
END
$$

--
-- Create procedure `proc_certificate_send`
--
CREATE DEFINER = 'sql12604943'@'%'
PROCEDURE proc_certificate_send (IN v_CertificateID char(36))
BEGIN
  UPDATE certificate c
  SET c.CertificateStatus = 2,
      c.IsSend = 1,
      c.SentDate = NOW()
  WHERE c.CertificateID = v_CertificateID;
END
$$

--
-- Create procedure `proc_certificate_insert`
--
CREATE DEFINER = 'sql12604943'@'%'
PROCEDURE proc_certificate_insert (IN v_IssuedID varchar(255),
IN v_ReceivedID varchar(255),
IN v_CertificateName varchar(255),
IN v_ReceivedAddressWallet varchar(255),
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
    VALUES (UUID(), v_IssuedID, v_ReceivedID, CODE, 'UTC', v_CertificateName, v_ReceivedAddressWallet, v_ReceivedName, v_ReceivedDoB, v_YearOfGraduation, v_Classification, v_ModeOfStudy, '', -- ipfslink
    '', -- imagelink
    '', -- transactionlink
    0, -- CertificateStatus: Draft
    NOW(), -- CreatedDate: NOW
    0, -- IsSigned: Chua ki
    NULL, -- SignedDate: NULL
    0, -- IsSent: Chua gui
    NULL, -- SentDate: NULL
    0); -- IsDeleted: Chua xoa

  -- Them contact voi nguoi gui bang
  CALL proc_contact_insert(v_IssuedID, v_ReceivedID);
END
$$

--
-- Create procedure `proc_certificate_GetPagingReceived`
--
CREATE DEFINER = 'sql12604943'@'%'
PROCEDURE proc_certificate_GetPagingReceived (IN v_ReceivedID varchar(255),
IN v_PageSize int,
IN v_PageNumber int,
IN v_CertificateType varchar(255),
IN v_UserName varchar(255),
IN v_ReceivedDate int)
BEGIN
  DECLARE offset_page int;
  DECLARE no_results_error CONDITION FOR SQLSTATE '02000';

  -- v_PageSize and  v_PageNumber must be > 0
  IF v_PageSize <= 0 THEN
    SELECT
      'Invalid Page Size: Page Size must be greater than zero';
    SIGNAL no_results_error;
  END IF;

  IF v_PageNumber <= 0 THEN
    SELECT
      'Invalid Page Number: Page Number must be greater than zero';
    SIGNAL no_results_error;
  END IF;

  -- Offset_page is record number want to get
  SET offset_page = (v_PageNumber - 1) * v_PageSize;

  SELECT
    c.CertificateID,
    c.CertificateCode,
    c.CertificateType,
    u.UserName AS `IssuerName`,
    c.ReceivedName,
    c.ReceivedDoB,
    c.CertificateName,
    c.YearOfGraduation,
    c.Classification,
    c.ModeOfStudy,
    c.SentDate AS `ReceivedDate`
  FROM certificate c
    JOIN user u
      ON c.IssuedID = u.PolicyID
  -- Check conditions
  WHERE c.ReceivedID = v_ReceivedID
  AND (u.UserName LIKE CONCAT('%', v_UserName, '%')
  OR v_UserName IS NULL)
  AND (c.CertificateType = v_CertificateType
  OR v_CertificateType IS NULL)
  AND c.IsSend = 1
  AND c.IsDeleted = 0

  -- Default sort by SentDate = ReceivedDate
  ORDER BY IF(v_ReceivedDate = 0, c.SentDate, NULL) ASC,
  IF(v_ReceivedDate = 1, c.SentDate, NULL) DESC,
  IF(v_ReceivedDate NOT IN (0, 1), c.SentDate, NULL) ASC

  LIMIT v_PageSize
  OFFSET offset_page;
END
$$

--
-- Create procedure `proc_certificate_GetPagingIssued`
--
CREATE DEFINER = 'sql12604943'@'%'
PROCEDURE proc_certificate_GetPagingIssued (IN v_IssuerID varchar(255),
IN v_PageSize int,
IN v_PageNumber int,
IN v_CertType varchar(100),
IN v_ReceivedName varchar(255),
IN v_SignDate int, -- 0 la tu gan den xa, 1 la tu da den gan
IN v_ContactStatus tinyint,
IN v_CertStatus tinyint)
BEGIN
  DECLARE offset_page int;
  DECLARE no_results_error CONDITION FOR SQLSTATE '02000';

  -- v_PageSize and  v_PageNumber must be > 0
  IF v_PageSize <= 0 THEN
    SELECT
      'Invalid Page Size: Page Size must be greater than zero';
    SIGNAL no_results_error;
  END IF;

  IF v_PageNumber <= 0 THEN
    SELECT
      'Invalid Page Number: Page Number must be greater than zero';
    SIGNAL no_results_error;
  END IF;

  -- Offset_page is record number want to get
  SET offset_page = (v_PageNumber - 1) * v_PageSize;

  SELECT
    c.CertificateID,
    c1.ContactID,
    c.ReceivedAddressWallet,
    c.CertificateCode,
    c.CertificateName,
    c.ReceivedName,
    c.SignedDate,
    c1.ContactStatus,
    c.CertificateStatus

  FROM certificate c
    JOIN user u
      ON c.ReceivedID = u.PolicyID
    JOIN contact c1
      ON u.PolicyID = c1.ReceivedID

  -- Check conditions
  WHERE c.IssuedID = v_IssuerID
  AND (c.ReceivedName LIKE CONCAT('%', v_ReceivedName, '%')
  OR v_ReceivedName IS NULL)
  AND (c.CertificateType = v_CertType
  OR v_CertType IS NULL)
  AND (c1.ContactStatus = v_ContactStatus
  OR v_ContactStatus IS NULL)
  AND (c.CertificateStatus = v_CertStatus
  OR v_CertStatus IS NULL)
  AND c.IsDeleted = 0

  -- Default sort by CreatedDate
  ORDER BY c.CreatedDate DESC
  --  ORDER BY IF(v_SignDate = 0, c.SignedDate, NULL) ASC,
  --  IF(v_SignDate = 1, c.SignedDate, NULL) DESC,
  --  IF(v_SignDate NOT IN (0, 1), c.CreatedDate, NULL) ASC

  LIMIT v_PageSize
  OFFSET offset_page;
END
$$

--
-- Create procedure `Proc_Certificate_GetAllReceived`
--
CREATE DEFINER = 'sql12604943'@'%'
PROCEDURE Proc_Certificate_GetAllReceived (IN v_ReceivedID varchar(255))
BEGIN
  SELECT
    c.CertificateID,
    c.ImageLink,
    c.TransactionLink,
    c.CertificateCode,
    u.UserName AS `OganizationName`,
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
  AND c.IsSend = 1
  AND c.IsSigned = 1
  AND c.IsDeleted = 0

  ORDER BY c.CreatedDate;
END
$$

--
-- Create procedure `Proc_Certificate_GetAllIssued`
--
CREATE DEFINER = 'sql12604943'@'%'
PROCEDURE Proc_Certificate_GetAllIssued (IN v_IssuerID varchar(255))
BEGIN
  SELECT
    c.CertificateID,
    c.ImageLink,
    c.TransactionLink,
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
CREATE DEFINER = 'sql12604943'@'%'
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
CREATE DEFINER = 'sql12604943'@'%'
PROCEDURE proc_certificate_ban (IN v_CertificateID char(36))
BEGIN
  UPDATE certificate c
  SET c.CertificateStatus = 3
  WHERE c.CertificateID = v_CertificateID;
END
$$

--
-- Create procedure `proc_Certificate_AddTransactionLink`
--
CREATE DEFINER = 'sql12604943'@'%'
PROCEDURE proc_Certificate_AddTransactionLink (IN v_CertificateID char(36), IN v_TransactionLink text)
BEGIN
  UPDATE certificate c
  SET c.TransactionLink = v_TransactionLink
  WHERE c.CertificateID = v_CertificateID;
END
$$

--
-- Create procedure `proc_user_insert`
--
CREATE DEFINER = 'sql12604943'@'%'
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
    VALUES (v_UserID, CODE, v_UserName, v_Logo, '', NOW(), 0);
END
$$

--
-- Create procedure `proc_user_delete`
--
CREATE DEFINER = 'sql12604943'@'%'
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
CREATE DEFINER = 'sql12604943'@'%'
PROCEDURE Proc_Certificate_SignMultiple (IN v_CertificateIDs text)
BEGIN
  SET @v_CertificateIDs = REPLACE(v_CertificateIDs, ',', ''',''');

  SET @Query = CONCAT('UPDATE certificate SET IsSigned = 1, CertificateStatus = 1, SignedDate = NOW() WHERE CertificateID IN (''', @v_CertificateIDs, ''');');

  PREPARE deleteQueryStatement FROM @Query;
  EXECUTE deleteQueryStatement;

  DEALLOCATE PREPARE deleteQueryStatement;
END
$$

--
-- Create procedure `Proc_Certificate_SendMultiple`
--
CREATE DEFINER = 'sql12604943'@'%'
PROCEDURE Proc_Certificate_SendMultiple (IN v_CertificateIDs text)
BEGIN
  SET @v_CertificateIDs = REPLACE(v_CertificateIDs, ',', ''',''');

  SET @Query = CONCAT('UPDATE certificate SET certificateStatus = 2, IsSend = 1, SentDate = NOW() WHERE CertificateID IN (''', @v_CertificateIDs, ''');');

  PREPARE deleteQueryStatement FROM @Query;
  EXECUTE deleteQueryStatement;

  DEALLOCATE PREPARE deleteQueryStatement;
END
$$

--
-- Create procedure `proc_certificate_DeleteMultiple`
--
CREATE DEFINER = 'sql12604943'@'%'
PROCEDURE proc_certificate_DeleteMultiple (IN v_CertificateIDs text)
BEGIN
  SET @v_CertificateIDs = REPLACE(v_CertificateIDs, ',', ''',''');

  SET @Query = CONCAT('UPDATE certificate SET isDeleted = 1 WHERE CertificateID IN (''', @v_CertificateIDs, ''');');

  PREPARE deleteQueryStatement FROM @Query;
  EXECUTE deleteQueryStatement;

  DEALLOCATE PREPARE deleteQueryStatement;
END
$$

--
-- Create procedure `proc_certificate_BanMultiple`
--
CREATE DEFINER = 'sql12604943'@'%'
PROCEDURE proc_certificate_BanMultiple (IN v_CertificateIDs text)
BEGIN
  SET @v_CertificateIDs = REPLACE(v_CertificateIDs, ',', ''',''');

  SET @Query = CONCAT('UPDATE certificate SET certificatestatus = 3 WHERE CertificateID IN (''', @v_CertificateIDs, ''');');

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
('add_staktesasdasbflaflanflkasnflans', 100013, 'sv test', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679193712/Logo/8888764a-5c84-47a7-8cc6-45e55360c4e6.png', '', '2023-03-18 18:54:08', 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks1', 100003, 'Nguyen Van A', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '', '2023-03-18 07:47:41', 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks2', 100004, 'Nguyen Van B', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '', '2023-03-18 07:47:41', 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks3', 100005, 'Nguyen Van C', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '', '2023-03-18 07:47:41', 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks4', 100006, 'Nguyen Van D', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '', '2023-03-18 07:47:41', 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks5', 100007, 'Nguyen Van E', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '', '2023-03-18 07:47:41', 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks6', 100008, 'Nguyen Van F', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '', '2023-03-18 07:47:41', 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks7', 100009, 'Nguyen Van G', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '', '2023-03-18 07:47:41', 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks8', 100010, 'Nguyen Van H', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '', '2023-03-18 07:47:41', 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks9', 100011, 'Nguyen Van I', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '', '2023-03-18 07:47:41', 0),
('stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nksu', 100002, 'Trinh Xuan Bach', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '', '2023-03-18 07:47:40', 0),
('stake_test1uruq088hsj2jxxwgjhex6hkpfd2ap7jurhjnqhvfs8why2s0w4ltl', 100001, 'Tran Huy Hiep', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679064292/Logo/35999755-2230-4f91-a405-df5bec1c11f6.jpg', '', '2023-03-18 07:47:40', 0),
('stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 100000, 'University of Transport and Communications', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679067306/Logo/f513d3d1-faa5-404d-a3ae-08221608e764.jpg', '', '2023-03-18 07:47:36', 0),
('testid', 100012, 'testname', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679155064/Logo/a82e193e-378a-4458-8bc1-aab2220fb0ed.png', '', '2023-03-18 08:09:47', 0);

-- 
-- Dumping data for table contact
--
INSERT INTO contact VALUES
('6f88b2a8-c60e-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uruq088hsj2jxxwgjhex6hkpfd2ap7jurhjnqhvfs8why2s0w4ltl', 100000, 1, '2023-03-18 20:28:02', 0),
('6fc915d7-c60e-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nksu', 100001, 1, '2023-03-18 20:28:02', 0),
('70b6126b-c60e-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks3', 100002, 1, '2023-03-18 20:28:04', 0),
('72c11949-c60e-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks4', 100003, 0, '2023-03-18 20:28:07', 0),
('745c39b9-c60e-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks5', 100004, 0, '2023-03-18 20:28:10', 0),
('75a5f58c-c60e-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks6', 100005, 0, '2023-03-18 20:28:12', 0),
('776f54b5-c60e-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks7', 100006, 1, '2023-03-18 20:28:15', 0),
('79a29f0f-c60e-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks8', 100007, 0, '2023-03-18 20:28:19', 0),
('7a6379ff-c60e-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks9', 100008, 0, '2023-03-18 20:28:20', 0);

-- 
-- Dumping data for table certificate
--
INSERT INTO certificate VALUES
('6f865830-c60e-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uruq088hsj2jxxwgjhex6hkpfd2ap7jurhjnqhvfs8why2s0w4ltl', 100000, 'UTC', 'The Degree Of Engineer', 'addr_test1qr4fkykkejglg6fz7vydddvwezc4vr4rpecp8nc5psc27zhcq7w00py4yvvu390jd40vzj646ra9c809xpwcnqwawg4q0xgwj3', 'Hiep Tran', '2023-12-30', 2022, 'Good', 'Full-time', 'ipfs://QmNid5EKvVGfH4KMaEjUqU3W9VubVfYmaeUzjzf5zwY58M', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679199389/Degree/817b851a-93d2-4ac1-a72f-28c9feea88c9.png', '', 2, '2023-03-18 20:28:02', 1, '2023-03-18 20:48:04', 1, '2023-03-18 20:48:28', 0),
('6fc773f4-c60e-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nksu', 100001, 'UTC', 'The Degree Of Engineer', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h2', 'Bach Trinh', '2023-12-03', 2022, 'Good', 'Full-time', 'ipfs://QmNfzCFpCP2pdiEFhLEAodUjN8ZaJ43sB23uNXDvFuCN6q', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679199414/Degree/57456770-3417-4a87-ab94-4395da60a8c1.png', '', 3, '2023-03-18 20:28:02', 1, '2023-03-18 20:36:00', 1, '2023-03-18 20:36:17', 0),
('70b435ba-c60e-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks3', 100002, 'UTC', 'The Degree Of Engineer', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h3', 'Nguyen Van C', '2023-02-03', 2022, 'Good', 'Full-time', 'ipfs://QmUJHEC1FAZxYt5PyvuQjJwsoySWp41uv9r5Lwt85HEruZ', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679199427/Degree/a2ae7dce-472b-4b13-8e96-827625640c35.png', '', 2, '2023-03-18 20:28:04', 1, '2023-03-18 20:48:04', 1, '2023-03-18 20:48:28', 0),
('72bf3871-c60e-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks4', 100003, 'UTC', 'The Degree Of Engineer', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h4', 'Nguyen Van D', '2023-12-03', 2022, 'Good', 'Full-time', 'ipfs://QmdDQRFh8LpwoXGio5UwKLR4qcC8zhvHNwS1YgDx18xpQn', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679199433/Degree/d8bf9861-65b1-4e5d-8469-e51ada8bef82.png', '', 2, '2023-03-18 20:28:07', 1, '2023-03-18 20:48:04', 1, '2023-03-18 20:48:28', 0),
('745af1d8-c60e-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks5', 100004, 'UTC', 'The Degree Of Bachelor', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h5', 'Nguyen Van E', '2023-12-03', 2022, 'Good', 'Full-time', 'ipfs://QmQPQ4kNUQVKiHxLWB8Mv6b6sUDF5s38B6gMwQoPmhtsxQ', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679199478/Degree/8ce3ca77-a691-4c12-a318-5261f2696a2f.png', '', 2, '2023-03-18 20:28:10', 1, '2023-03-18 20:48:04', 1, '2023-03-18 20:48:28', 0),
('75a45ad8-c60e-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks6', 100005, 'UTC', 'The Degree Of Bachelor', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h6', 'Nguyen Van F', '2023-12-03', 2022, 'Excellent', 'Full-time', 'ipfs://QmW6jVvt9h3sbSRkpg2zmK89EHTuM46GTGNrGaVcgk3nkT', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679199489/Degree/5899396c-28e3-4f57-902d-677e073397e7.png', '', 1, '2023-03-18 20:28:12', 1, '2023-03-18 20:48:04', 0, NULL, 0),
('776d04b3-c60e-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks7', 100006, 'UTC', 'The Degree Of Bachelor', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h7', 'Nguyen Van G', '2023-12-03', 2022, 'Excellent', 'Full-time', 'ipfs://QmYZyaZKqf8bTAwm4xBQEnkAJ1PDx2LwJDWFqrirqpKm3b', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679199503/Degree/527622fd-68d3-4c2b-9224-b7abe0421197.png', '', 1, '2023-03-18 20:28:15', 1, '2023-03-18 20:48:04', 0, NULL, 0),
('79a0a627-c60e-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks8', 100007, 'UTC', 'The Degree Of Bachelor', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h8', 'Nguyen Van H', '2023-12-03', 2022, 'Excellent', 'Part-time', 'ipfs://QmfGo9vPgdWaYHwfU8MhEDjEiP43P2FpCs73YLik6WT54u', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679199549/Degree/2d0e1c72-4315-4c11-a87b-e7975f872884.png', '', 1, '2023-03-18 20:28:19', 1, '2023-03-18 20:48:04', 0, NULL, 0),
('7a61b170-c60e-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks9', 100008, 'UTC', 'The Degree Of Bachelor', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h9', 'Nguyen Van I', '2023-12-03', 2022, 'Excellent', 'Part-time', 'ipfs://QmNNmoT2xDWr4X1LQMDnKxtbYtYQQYArSH8xCBK8w6NoDC', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679199555/Degree/1d2ecd69-bd65-49b0-9f5f-b38cc750a223.png', '', 1, '2023-03-18 20:28:20', 1, '2023-03-18 20:48:04', 0, NULL, 0),
('f546f135-c60f-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uruq088hsj2jxxwgjhex6hkpfd2ap7jurhjnqhvfs8why2s0w4ltl', 100009, 'UTC', 'The Degree Of Engineer', 'addr_test1qr4fkykkejglg6fz7vydddvwezc4vr4rpecp8nc5psc27zhcq7w00py4yvvu390jd40vzj646ra9c809xpwcnqwawg4q0xgwj3', 'Hiep Tran', '2023-12-30', 2022, 'Good', 'Full-time', 'ipfs://Qmd6uec6zfzV3Lf3viJi1PHNsSTNYhGDKJd5wjbzD7fLQC', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679200030/Degree/4a176996-5f51-4501-ba3c-1053d7948f55.png', '', 0, '2023-03-18 20:38:56', 0, NULL, 0, NULL, 0),
('f58cc761-c60f-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nksu', 100010, 'UTC', 'The Degree Of Engineer', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h2', 'Bach Trinh', '2023-12-03', 2022, 'Good', 'Full-time', 'ipfs://QmPrs66uE2xrWGcvUVd7bWpNSZY99fBWoekc8TANwQucea', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679200035/Degree/ba85d8f4-6712-4e9f-a9cb-4e467b0cc77c.png', '', 0, '2023-03-18 20:38:56', 0, NULL, 0, NULL, 0),
('f5bd1dcb-c60f-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks3', 100011, 'UTC', 'The Degree Of Engineer', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h3', 'Nguyen Van C', '2023-02-03', 2022, 'Good', 'Full-time', 'ipfs://QmYnaj9uiYqmnGyZJvsrVR18hGgzctW3y8Ti58osdtu2zk', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679200052/Degree/cfee96a2-906a-41fa-973c-9bd593e9fe64.png', '', 0, '2023-03-18 20:38:56', 0, NULL, 0, NULL, 0),
('f5f6201f-c60f-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks4', 100012, 'UTC', 'The Degree Of Engineer', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h4', 'Nguyen Van D', '2023-12-03', 2022, 'Good', 'Full-time', 'ipfs://QmSvAVPx6HWhxTA8AB4bnerRVQNgnrE1zbEuVKn559bZny', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679200056/Degree/2787fbc7-d65a-4ffd-afad-88d556211a9c.png', '', 0, '2023-03-18 20:38:57', 0, NULL, 0, NULL, 0),
('f624160c-c60f-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks5', 100013, 'UTC', 'The Degree Of Bachelor', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h5', 'Nguyen Van E', '2023-12-03', 2022, 'Good', 'Full-time', 'ipfs://QmSatycQdpm8jsujqmLBH5JnWorgi4pTn4hVAeartTrmoS', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679200061/Degree/37d8cfc8-5c19-48e0-a318-50a1172cbc2c.png', '', 0, '2023-03-18 20:38:57', 0, NULL, 0, NULL, 0),
('f6530ec0-c60f-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks6', 100014, 'UTC', 'The Degree Of Bachelor', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h6', 'Nguyen Van F', '2023-12-03', 2022, 'Excellent', 'Full-time', 'ipfs://QmdqR2i2bV5uPTKS6oLPXDMYUTjrqNhjDjfsQUYEBuYFco', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679200066/Degree/9a50672a-a02d-44de-ab45-4b573a147d6c.png', '', 0, '2023-03-18 20:38:57', 0, NULL, 0, NULL, 0),
('f6908de2-c60f-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks7', 100015, 'UTC', 'The Degree Of Bachelor', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h7', 'Nguyen Van G', '2023-12-03', 2022, 'Excellent', 'Full-time', 'ipfs://QmSBHSxviefFuh5vqedGdQw7LfXZCGSRkMJxS4bpC8a9mb', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679200070/Degree/29274d13-e820-4b79-a8c7-1621a7db41f2.png', '', 0, '2023-03-18 20:38:58', 0, NULL, 0, NULL, 0),
('f6e19696-c60f-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks8', 100016, 'UTC', 'The Degree Of Bachelor', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h8', 'Nguyen Van H', '2023-12-03', 2022, 'Excellent', 'Part-time', 'ipfs://QmQjFdRpcfbEhHUu4kEeRLGXJumtTJjtsFjjerFTzsuE7U', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679200082/Degree/009937a7-098d-4ad1-bc8f-cabd894e2698.png', '', 0, '2023-03-18 20:38:58', 0, NULL, 0, NULL, 0),
('f70cdbca-c60f-11ed-ae9e-062bff1cb1bf', 'stake_test1uzjjsk25c6xc2ax57pvsvwdsncmta0nksfyvwdyq2ewlndqh9alfc', 'stake_test1uqmw4ydawakkjwasf94w5f5frcrkt3t56taafgydh2wdkwqw3nks9', 100017, 'UTC', 'The Degree Of Bachelor', 'addr_test1qq68a8hxmz6x295epvy5tluak0z3z9uxfk0yqsepnragz33ka2gm6amddyamqjt2agngj8s8vhzhf5hm6jsgmw5umvuqx9u8h9', 'Nguyen Van I', '2023-12-03', 2022, 'Excellent', 'Part-time', 'ipfs://QmW7Fg9DC4DMBTtBSkoVw8sjwbVmS5aCPnio2wBGi34fSo', 'https://res.cloudinary.com/dog4lwypp/image/upload/v1679200181/Degree/70aa9f8b-62d1-4de3-8e18-ebc399cf34d6.png', '', 0, '2023-03-18 20:38:58', 0, NULL, 0, NULL, 0);

-- 
-- Restore previous SQL mode
-- 
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;

-- 
-- Enable foreign keys
-- 
/*!40014 SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS */;