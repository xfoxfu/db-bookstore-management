-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema bookstore
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `bookstore` ;

-- -----------------------------------------------------
-- Schema bookstore
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `bookstore` DEFAULT CHARACTER SET utf8mb4 ;
USE `bookstore` ;

-- -----------------------------------------------------
-- Table `bookstore`.`book`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bookstore`.`book` ;

CREATE TABLE IF NOT EXISTS `bookstore`.`book` (
  `book_id` INT NOT NULL AUTO_INCREMENT COMMENT '图书唯一标识符',
  `title` VARCHAR(45) NOT NULL COMMENT '图书名称',
  `author` VARCHAR(45) NOT NULL COMMENT '图书作者',
  `isbn` VARCHAR(45) NOT NULL COMMENT '图书的ISBN',
  `count` INT NOT NULL DEFAULT 0 COMMENT '图书在库数量',
  `price` DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '图书单价',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`book_id`),
  UNIQUE INDEX `isbn_UNIQUE` (`isbn` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`provider`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bookstore`.`provider` ;

CREATE TABLE IF NOT EXISTS `bookstore`.`provider` (
  `provider_id` INT NOT NULL AUTO_INCREMENT COMMENT '供应商ID',
  `name` VARCHAR(45) NOT NULL COMMENT '名字',
  `phone` VARCHAR(45) NOT NULL COMMENT '联系电话',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`provider_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`offer`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bookstore`.`offer` ;

CREATE TABLE IF NOT EXISTS `bookstore`.`offer` (
  `offer_id` INT NOT NULL AUTO_INCREMENT COMMENT '供货单（未成交）ID',
  `provider_id` INT NOT NULL COMMENT '供应商ID',
  `book_id` INT NOT NULL COMMENT '图书ID',
  `price` DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '供应图书单价',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`offer_id`),
  INDEX `book_id_idx` (`book_id` ASC) VISIBLE,
  INDEX `provider_id_idx` (`provider_id` ASC) VISIBLE,
  CONSTRAINT `book_id`
    FOREIGN KEY (`book_id`)
    REFERENCES `bookstore`.`book` (`book_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `provider_id`
    FOREIGN KEY (`provider_id`)
    REFERENCES `bookstore`.`provider` (`provider_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`purchase`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bookstore`.`purchase` ;

CREATE TABLE IF NOT EXISTS `bookstore`.`purchase` (
  `order_id` INT NOT NULL AUTO_INCREMENT COMMENT '购书订单（消费者）ID',
  `book_id` INT NOT NULL COMMENT '图书ID',
  `price` DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '购买时单价',
  `count` INT NOT NULL DEFAULT 0 COMMENT '购买数量',
  `customer_name` VARCHAR(45) NOT NULL COMMENT '消费者名称',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`order_id`),
  INDEX `order_book_id_idx` (`book_id` ASC) INVISIBLE,
  CONSTRAINT `order_book_id`
    FOREIGN KEY (`book_id`)
    REFERENCES `bookstore`.`book` (`book_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`refund`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bookstore`.`refund` ;

CREATE TABLE IF NOT EXISTS `bookstore`.`refund` (
  `refund_id` INT NOT NULL COMMENT '退款单ID',
  `order_id` INT NOT NULL COMMENT '对应的订单ID',
  `count` INT NOT NULL COMMENT '退货数量',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`refund_id`),
  INDEX `order_id_idx` (`order_id` ASC) VISIBLE,
  CONSTRAINT `order_id`
    FOREIGN KEY (`order_id`)
    REFERENCES `bookstore`.`purchase` (`order_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `bookstore`.`stock`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bookstore`.`stock` ;

CREATE TABLE IF NOT EXISTS `bookstore`.`stock` (
  `stock_id` INT NOT NULL AUTO_INCREMENT COMMENT '购入（入库）单ID',
  `offer_id` INT NOT NULL COMMENT '对应的供应单ID',
  `count` INT NOT NULL COMMENT '购入图书数量',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`stock_id`),
  INDEX `offer_id_idx` (`offer_id` ASC) VISIBLE,
  CONSTRAINT `offer_id`
    FOREIGN KEY (`offer_id`)
    REFERENCES `bookstore`.`offer` (`offer_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

DELIMITER $$
create PROCEDURE purchase(IN id INT, IN purchaseCnt INT, IN customer_name VARCHAR(45))
BEGIN
	DECLARE c INT;
    declare total_price decimal(10,2);
    start transaction;
    select count into c FROM book WHERE book_id=id;
    if (c>=purchaseCnt) then
        SELECT book.*,price*purchaseCnt as total_cost FROM book WHERE book_id=id;
        UPDATE book set count=count-purchaseCnt where book_id=id;
        insert into bookstore.purchase select null,id, price,purchaseCnt, customer_name,now(),now() FROM book WHERE book_id=id;
    else
		SELECT book.*,price*purchaseCnt as total_cost FROM book WHERE book_id=-1;
	end if;
    commit;
END$$
DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
