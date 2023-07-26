CREATE DATABASE sql12613779;
USE sql12613779;

CREATE TABLE User (
  ID varchar(255) NOT NULL COMMENT 'Khóa chính, là địa chỉ ví skate',
  Code mediumint UNSIGNED NOT NULL COMMENT 'Mã code, để hiển thị lên trang web',
  PolicyId varchar(255) DEFAULT NULL COMMENT 'PolicyId tổ chức',
  FullName varchar(255) NOT NULL COMMENT 'Tên tổ chức/cá nhân',
  Logo text DEFAULT NULL COMMENT 'Đường dẫn ảnh đại diện',
  IsVerified tinyint DEFAULT 0 COMMENT 'Đã được xác thực hay chưa (0-chưa; 1- rồi)',
  IsDeleted tinyint DEFAULT 0 COMMENT 'Bị xóa hay chưa (0-chưa xóa; 1-đã xóa)',
  CreateDate datetime DEFAULT NULL COMMENT 'Ngày giờ tạo',
  UpdatedDate datetime DEFAULT NULL COMMENT 'Ngày giờ cập nhật',
  PRIMARY KEY (UserID)
);

CREATE TABLE Contact (
  ID char(36) NOT NULL COMMENT 'Khóa chính, có kiểu GUID',
  IssuerID varchar(255) NOT NULL COMMENT 'Khóa ngoại, liên kết với bảng user(PolicyID)',
  ReceiverID varchar(255) NOT NULL COMMENT 'Khóa ngoại, liên kết với bảng user(PolicyID)',
  Code mediumint UNSIGNED NOT NULL COMMENT 'mã hiện thị trên website, có kiểu là số',
  Status tinyint DEFAULT 1 COMMENT 'Trạng thái kết nối (1-pending, 2-connected)',
  IsDeleted tinyint NOT NULL COMMENT 'xóa hay chưa (0-hiện/1-ẩn)',
  CreateDate datetime DEFAULT NULL COMMENT 'Ngày giờ tạo',
  UpdatedDate datetime DEFAULT NULL COMMENT 'Ngày giờ cập nhật',
  PRIMARY KEY (ID)
);

CREATE TABLE certificate (
  ID char(36) NOT NULL COMMENT 'Khóa chính, có kiểu GUID',
  IssuerID varchar(255) NOT NULL  COMMENT 'Khóa ngoại liên kết với ID của tổ chức bảng user',
  Name varchar(255) NOT NULL COMMENT 'Tên bằng cấp (Bằng kỹ sư, bằng cử nhân)',
  Description text DEFAULT NULL COMMENT 'Mô tả cho mẫu bằng',
  PRIMARY KEY (ID)
);

CREATE TABLE CertificateDetail(
  ID char(36) NOT NULL COMMENT 'Khóa chính, có kiểu GUID',
  CertificateID char(36) NOT NULL COMMENT 'Khóa ngoại liên kết với ID bảng certificate',
  ReceiverID varchar(255) NOT NULL COMMENT 'Khóa ngoại liên kết với ID của student bảng user',
  Code mediumint NOT NULL COMMENT 'Mã code, để hiển thị lên trang web',

  ReceiverAddressWallet varchar(255) NOT NULL COMMENT 'Địa chỉ ví người nhận',
  ReceiverIdentityNumber varchar(255) NOT NULL COMMENT 'số CCCD/CMND của người nhận',
  ReceiverName varchar(255) DEFAULT NULL COMMENT 'Tên người nhận bằng',
  ReceiverDoB date DEFAULT NULL COMMENT 'Ngày sinh người nhận bằng',
  ReceiverSex tinyint DEFAULT 1 COMMENT 'Giới tính người nhận bằng (1-Nam/2-Nữ/3-Khác)',

  YearOfGraduation smallint DEFAULT NULL,
  Classification varchar(50) NOT NULL DEFAULT '' COMMENT 'Loại bằng cấp',
  ModeOfStudy varchar(255) DEFAULT NULL COMMENT 'Hình thức đào tạo (Chính quy tập trung, Tại chức...)',
  Mark1 DECIMAL(5, 2) DEFAULT NULL COMMENT 'Đầu điểm thứ nhất',
  Mark1 DECIMAL(5, 2) DEFAULT NULL COMMENT 'Đầu điểm thứ hai',
  Mark1 DECIMAL(5, 2) DEFAULT NULL COMMENT 'Đầu điểm thứ ba',
  Mark1 DECIMAL(5, 2) DEFAULT NULL COMMENT 'Đầu điểm thứ tư',
  Description text DEFAULT NULL COMMENT 'Thông tin thêm cho chứng chỉ',
  TestDate date DEFAULT NULL COMMENT 'Ngày thi',
  ExpiredDate date DEFAULT NULL COMMENT 'Ngày hết hạn',

  IpfsLink varchar(255) DEFAULT NULL COMMENT 'Mã ipfs của ảnh bằng',
  ImageLink text DEFAULT NULL COMMENT 'Đường link ảnh trên cloudbinary',

  CertificateStatus tinyint DEFAULT 1 COMMENT 'Trạng thái của bằng cấp (1-Draft/2-Signed/3-Sent/4-Banned)',
  CreateDate datetime DEFAULT NULL COMMENT 'Ngày giờ tạo',
  UpdatedDate datetime DEFAULT NULL COMMENT 'Ngày giờ cập nhật',
  SignedDate datetime DEFAULT NULL COMMENT 'Ngày kí',
  SentDate datetime DEFAULT NULL COMMENT 'Ngày tháng xuất/nhận bằng',
  
  IsDeleted tinyint DEFAULT NULL,
  PRIMARY KEY (ID)
);

