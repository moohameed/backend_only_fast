-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 08, 2023 at 04:07 PM
-- Server version: 8.1.0
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `frave_food`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ADD_CATEGORY` (IN `category` VARCHAR(50), IN `description` VARCHAR(100))   BEGIN
	INSERT INTO categories (category, description) VALUE (category, description);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ALL_DELIVERYS` ()   BEGIN
	SELECT p.uid AS person_id, CONCAT(p.firstName, ' ', p.lastName) AS nameDelivery, p.phone, p.image, u.notification_token FROM person p
	INNER JOIN users u ON p.uid = u.persona_id
	WHERE u.rol_id = 3 AND p.state = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ALL_ORDERS_STATUS` (IN `statuss` VARCHAR(30))   BEGIN
	SELECT o.id AS order_id, o.delivery_id, CONCAT(pe.firstName, " ", pe.lastName) AS delivery, pe.image AS deliveryImage, o.client_id, CONCAT(p.firstName, " ", p.lastName) AS cliente, p.image AS clientImage, p.phone AS clientPhone, o.address_id, a.street, a.reference, a.Latitude, a.Longitude, o.status, o.pay_type, o.amount, o.currentDate
	FROM orders o
	INNER JOIN person p ON o.client_id = p.uid
	INNER JOIN addresses a ON o.address_id = a.id
	LEFT JOIN person pe ON o.delivery_id = pe.uid
	WHERE o.`status` = statuss;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_PRODUCTS_CATEGORY` (IN `idRestaurant` INT, IN `idCategory` INT)   BEGIN
	SELECT pro.id, pro.restaurant_id, pro.nameProduct, pro.description, pro.price, pro.status, ip.picture, pro.restaurant_id, c.category, c.id AS category_id, c.icon as icon FROM products pro
	INNER JOIN categories c ON pro.category_id = c.id
	INNER JOIN imageProduct ip ON pro.id = ip.product_id
	INNER JOIN ( SELECT product_id, MIN(id) AS id_image FROM imageProduct GROUP BY product_id) p3 ON ip.product_id = p3.product_id AND ip.id = p3.id_image
    WHERE pro.restaurant_id = idRestaurant AND pro.category_id = idCategory;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_PRODUCTS_TOP` (IN `idRestaurant` INT)   BEGIN
	SELECT pro.id, pro.restaurant_id, pro.nameProduct, pro.description, pro.price, pro.status, ip.picture, pro.restaurant_id, c.category, c.id AS category_id, c.icon as icon FROM products pro
	INNER JOIN categories c ON pro.category_id = c.id
	INNER JOIN imageProduct ip ON pro.id = ip.product_id
	INNER JOIN ( SELECT product_id, MIN(id) AS id_image FROM imageProduct GROUP BY product_id) p3 ON ip.product_id = p3.product_id AND ip.id = p3.id_image
    WHERE pro.restaurant_id = idRestaurant
	LIMIT 10;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_RESTAURANTS` (IN `clientId` INT)   BEGIN

SELECT
    rest.id,
    rest.name,
    rest.phone,
    rest.address,
    rest.state,
    ir.picture,
    CASE WHEN CRF.ClientID IS NOT NULL THEN 1 ELSE 0 END AS Favorite
FROM
    restaurants rest
INNER JOIN imagerestaurant ir ON
    rest.id = ir.restaurant_id
INNER JOIN(
    SELECT restaurant_id,
        MIN(id) AS id_image
    FROM
        imagerestaurant
    GROUP BY
        restaurant_id
) p3
ON
    ir.restaurant_id = p3.restaurant_id AND ir.id = p3.id_image
    LEFT JOIN client_resto_fav AS CRF ON rest.id = CRF.restaurantID AND CRF.clientID = clientId
LIMIT 10;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_Restaurants_Admin` ()   BEGIN

SELECT
    rest.id,
    rest.name,
    rest.phone,
    rest.address,
    rest.state,
    ir.picture
    
FROM
    restaurants rest
INNER JOIN imagerestaurant ir ON
    rest.id = ir.restaurant_id
INNER JOIN(
    SELECT restaurant_id,
        MIN(id) AS id_image
    FROM
        imagerestaurant
    GROUP BY
        restaurant_id
) p3
ON
    ir.restaurant_id = p3.restaurant_id AND ir.id = p3.id_image
LIMIT 10;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_RESTAURANTS_CAT` (IN `categoryId` INT, IN `clientId` INT)   BEGIN

SELECT
    rest.id,
    rest.name,
    rest.phone,
    rest.address,
    rest.state,
    ir.picture,
    CASE WHEN CRF.ClientID IS NOT NULL THEN 1 ELSE 0 END AS Favorite
FROM
    restaurants rest
INNER JOIN imagerestaurant ir ON
    rest.id = ir.restaurant_id
INNER JOIN(
    SELECT restaurant_id,
        MIN(id) AS id_image
    FROM
        imagerestaurant
    GROUP BY
        restaurant_id
) p3
ON
    ir.restaurant_id = p3.restaurant_id AND ir.id = p3.id_image
    INNER JOIN ( SELECT restaurant_id from products WHERE category_id = categoryId GROUP BY restaurant_id ) p4 on rest.id = p4.restaurant_id
    LEFT JOIN client_resto_fav AS CRF ON rest.id = CRF.restaurantID AND CRF.clientID = clientId
LIMIT 10;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GET_RESTAURANTS_FAV` (IN `clientId` INT)   BEGIN

SELECT
    rest.id,
    rest.name,
    rest.phone,
    rest.address,
    rest.state,
    ir.picture
    
FROM
	client_resto_fav fav,
    restaurants rest
    
INNER JOIN imagerestaurant ir ON
    rest.id = ir.restaurant_id
INNER JOIN(
    SELECT restaurant_id,
        MIN(id) AS id_image
    FROM
        imagerestaurant
    GROUP BY
        restaurant_id
) p3
ON
    ir.restaurant_id = p3.restaurant_id AND ir.id = p3.id_image
    WHERE ir.restaurant_id = fav.restaurantId and fav.clientId = clientId
LIMIT 10;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_LIST_PRODUCTS_ADMIN` ()   BEGIN
	SELECT pro.id, pro.nameProduct, pro.description, pro.price, pro.status, ip.picture, c.category, c.id AS category_id FROM products pro
	INNER JOIN categories c ON pro.category_id = c.id
	INNER JOIN imageProduct ip ON pro.id = ip.product_id
	INNER JOIN ( SELECT product_id, MIN(id) AS id_image FROM imageProduct GROUP BY product_id) p3 ON ip.product_id = p3.product_id AND ip.id = p3.id_image;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_LOGIN` (IN `email` VARCHAR(100))   BEGIN
	SELECT p.uid, p.firstName, p.lastName, p.image, u.email, u.passwordd, u.rol_id, u.notification_token FROM person p
	INNER JOIN users u ON p.uid = u.persona_id
	WHERE u.email = email AND p.state = TRUE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ORDERS_BY_DELIVERY` (IN `ID` INT, IN `statuss` VARCHAR(30))   BEGIN
	SELECT o.orderId AS order_id, o.delivery_id, o.client_id, CONCAT(p.firstName, " ", p.lastName) AS cliente, p.image AS clientImage, p.phone AS clientPhone, o.address_id, a.street, a.reference, a.Latitude, a.Longitude, o.status, o.date FROM orders o INNER JOIN person p ON o.client_id = p.uid INNER JOIN addresses a ON o.address_id = a.id WHERE o.status = statuss AND o.delivery_id = ID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ORDERS_FOR_CLIENT` (IN `ID` INT)   BEGIN
	SELECT o.id, o.client_id, o.delivery_id, ad.reference, ad.Latitude AS latClient, ad.Longitude AS lngClient ,CONCAT(p.firstName, ' ', p.lastName)AS delivery, p.phone AS deliveryPhone, p.image AS imageDelivery, o.address_id, o.latitude, o.longitude, o.`status`, o.amount, o.pay_type, o.currentDate 
	FROM orders o
	LEFT JOIN person p ON p.uid = o.delivery_id
	INNER JOIN addresses ad ON o.address_id = ad.id 
	WHERE o.client_id = ID
	ORDER BY o.id DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ORDER_DETAILS` (IN `IDORDER` INT)   BEGIN
	SELECT od.id, od.order_id, od.product_id, p.nameProduct, ip.picture, od.quantity, od.price AS total
	FROM orderdetails od
	INNER JOIN products p ON od.product_id = p.id
	INNER JOIN imageProduct ip ON p.id = ip.product_id
	INNER JOIN ( SELECT product_id, MIN(id) AS id_image FROM imageProduct GROUP BY product_id) p3 ON ip.product_id = p3.product_id AND ip.id = p3.id_image
	WHERE od.order_id = IDORDER;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_ORDER_DETAILSS` (IN `IDORDER` INT)   BEGIN
	SELECT od.id, od.order_id, od.product_id, p.nameProduct, ip.picture, od.quantity, od.price AS total
	FROM orderdetails od
	INNER JOIN products p ON od.product_id = p.id
	INNER JOIN imageProduct ip ON p.id = ip.product_id
	INNER JOIN ( SELECT product_id, MIN(id) AS id_image FROM imageProduct GROUP BY product_id) p3 ON ip.product_id = p3.product_id AND ip.id = p3.id_image
	WHERE od.order_id = IDORDER;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_REGISTER` (IN `firstName` VARCHAR(50), IN `lastName` VARCHAR(50), IN `phone` VARCHAR(11), IN `image` VARCHAR(250), IN `email` VARCHAR(100), IN `pass` VARCHAR(100), IN `rol` INT, IN `nToken` VARCHAR(255))   BEGIN
	INSERT INTO Person (firstName, lastName, phone, image) VALUE (firstName, lastName, phone, image);
	
	INSERT INTO users (users, email, passwordd, persona_id, rol_id, notification_token) VALUE (firstName, email, pass, LAST_INSERT_ID(), rol, nToken);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_RENEWTOKENLOGIN` (IN `uid` INT)   BEGIN
	SELECT p.uid, p.firstName, p.lastName, p.image, p.phone, u.email, u.rol_id, u.notification_token FROM person p
	INNER JOIN users u ON p.uid = u.persona_id
	WHERE p.uid = uid AND p.state = TRUE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEARCH_FOR_CATEGORY` (IN `IDCATEGORY` INT)   BEGIN
	SELECT pro.id, pro.nameProduct, pro.description, pro.price, pro.status, ip.picture, c.category, c.id AS category_id FROM products pro
	INNER JOIN categories c ON pro.category_id = c.id
	INNER JOIN imageProduct ip ON pro.id = ip.product_id
	INNER JOIN ( SELECT product_id, MIN(id) AS id_image FROM imageProduct GROUP BY product_id) p3 ON ip.product_id = p3.product_id AND ip.id = p3.id_image
	WHERE pro.category_id = IDCATEGORY;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEARCH_PRODUCT` (IN `nameProduct` VARCHAR(100))   BEGIN
	SELECT pro.id, pro.nameProduct, pro.description, pro.price, pro.status, ip.picture, c.category, c.id AS category_id FROM products pro
	INNER JOIN categories c ON pro.category_id = c.id
	INNER JOIN imageProduct ip ON pro.id = ip.product_id
	INNER JOIN ( SELECT product_id, MIN(id) AS id_image FROM imageProduct GROUP BY product_id) p3 ON ip.product_id = p3.product_id AND ip.id = p3.id_image
	WHERE pro.nameProduct LIKE CONCAT('%', nameProduct , '%');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_TEST` ()   BEGIN
	SELECT * from products;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPDATE_PROFILE` (IN `ID` INT, IN `firstName` VARCHAR(50), IN `lastName` VARCHAR(50), IN `phone` VARCHAR(11))   BEGIN
	UPDATE person
		SET firstName = firstName,
			 lastName = lastName,
			 phone = phone
	WHERE person.uid = ID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_USER_BY_ID` (IN `ID` INT)   BEGIN
	SELECT p.uid, p.firstName, p.lastName, p.phone, p.image, u.email, u.rol_id, u.notification_token FROM person p
	INNER JOIN users u ON p.uid = u.persona_id
	WHERE p.uid = 1 AND p.state = TRUE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_USER_UPDATED` (IN `ID` INT)   BEGIN
	SELECT p.firstName, p.lastName, p.image, u.email, u.rol_id FROM person p
	INNER JOIN users u ON p.uid = u.persona_id
	WHERE p.uid = 1 AND p.state = TRUE;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `addresses`
--

CREATE TABLE `addresses` (
  `id` int NOT NULL,
  `street` varchar(100) DEFAULT NULL,
  `Latitude` varchar(50) DEFAULT NULL,
  `Longitude` varchar(50) DEFAULT NULL,
  `default_address` int NOT NULL DEFAULT '0',
  `persona_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `addresses`
--

INSERT INTO `addresses` (`id`, `street`, `Latitude`, `Longitude`, `default_address`, `persona_id`) VALUES
(8, 'Google Building 1015, ', '37.41701238274689', '-122.08046939224003', 0, 2),
(10, 'Charleston & Google, ', '37.420888367376925', '-122.0823445916176', 0, 2),
(15, '24 Rue Khalij El Qamar, Ennasr', '36.863812846288766', '10.160929597914219', 0, 2),
(55, '1650 Amphitheatre Pkwy, ', '37.4219983', '-122.084', 0, 5),
(56, 'R52P+4Q9, Tunis Centre', '36.80012734878519', '10.186923891305922', 0, 6);

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` int NOT NULL,
  `category` varchar(50) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  `icon` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `category`, `description`, `icon`) VALUES
(1, 'Sandwich', 'sandwich', 'Assets/Icons/Sandwich.svg'),
(2, 'Plat', 'Plat Description', 'Assets/Icons/Plat.svg'),
(3, 'Pizza', 'Pizza', 'Assets/Icons/Pizza.svg'),
(4, 'Juices', 'Jucies description', 'Assets/Icons/JuiceIcon.svg');

-- --------------------------------------------------------

--
-- Table structure for table `client_resto_fav`
--

CREATE TABLE `client_resto_fav` (
  `id` int NOT NULL,
  `clientId` int DEFAULT NULL,
  `restaurantId` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `client_resto_fav`
--

INSERT INTO `client_resto_fav` (`id`, `clientId`, `restaurantId`) VALUES
(49, 1, 1),
(57, 5, 2);

-- --------------------------------------------------------

--
-- Table structure for table `imageproduct`
--

CREATE TABLE `imageproduct` (
  `id` int NOT NULL,
  `picture` varchar(255) DEFAULT NULL,
  `product_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `imageproduct`
--

INSERT INTO `imageproduct` (`id`, `picture`, `product_id`) VALUES
(19, 'image-1629870638120.jpg', 7),
(20, 'image-1629870638087.jpg', 7),
(21, 'image-1629870638103.jpg', 7),
(22, 'image-1629870722161.jpg', 8),
(23, 'image-1629870722097.jpg', 8),
(24, 'image-1629870722142.jpg', 8),
(34, 'makloub-1.jpg', 14),
(35, 'makloub-2.jpg', 14),
(41, 'kafteji.png', 15),
(42, 'kafteji2.jpg', 15),
(43, 'kafteji3.jpg', 15),
(44, 'panozzo2.jpg', 16),
(45, 'panozzo.jpg', 16);

-- --------------------------------------------------------

--
-- Table structure for table `imagerestaurant`
--

CREATE TABLE `imagerestaurant` (
  `id` int NOT NULL,
  `picture` varchar(255) DEFAULT NULL,
  `restaurant_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `imagerestaurant`
--

INSERT INTO `imagerestaurant` (`id`, `picture`, `restaurant_id`) VALUES
(1, 'noir-et-blansLogo.jpg', 1),
(2, 'noir-et-blanc0.png', 1),
(3, 'noir-et-blansLogo.jpg', 2),
(4, 'noir-et-blanc1.png', 1);

-- --------------------------------------------------------

--
-- Table structure for table `ingredients`
--

CREATE TABLE `ingredients` (
  `id` int NOT NULL,
  `label` varchar(100) DEFAULT NULL,
  `type_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `ingredients`
--

INSERT INTO `ingredients` (`id`, `label`, `type_id`) VALUES
(1, 'Pesto', 1),
(2, 'Mayonnaise', 1),
(3, 'Ketchup', 1),
(4, 'Cheddar', 2),
(5, 'Raclette', 2),
(6, 'Edam', 2),
(7, 'Escalope Pané', 3),
(8, 'Escalop Grillé', 3),
(9, 'Laitue', 4),
(10, 'Oninon', 4);

-- --------------------------------------------------------

--
-- Table structure for table `ingredient_type`
--

CREATE TABLE `ingredient_type` (
  `id` int NOT NULL,
  `label` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `ingredient_type`
--

INSERT INTO `ingredient_type` (`id`, `label`) VALUES
(1, 'sauces'),
(2, 'cheez'),
(3, 'Viande'),
(4, 'Salade');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `orderId` int NOT NULL,
  `status` int NOT NULL DEFAULT '0',
  `price` double(11,3) DEFAULT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `client_id` int DEFAULT NULL,
  `delivery_id` int DEFAULT NULL,
  `address_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`orderId`, `status`, `price`, `date`, `client_id`, `delivery_id`, `address_id`) VALUES
(159, 1, 12.000, '2023-10-05 13:13:55', 2, 2, 8),
(160, 3, 8.000, '2023-10-05 13:32:28', 2, 2, 8),
(161, 0, 12.000, '2023-10-05 15:17:11', 2, NULL, 8),
(162, 0, 8.000, '2023-10-05 21:14:21', 2, NULL, 8),
(163, 0, 12.000, '2023-10-05 21:18:31', 2, NULL, 15),
(164, 5, 12.000, '2023-10-05 21:48:31', 2, 2, 15);

-- --------------------------------------------------------

--
-- Table structure for table `order_ingredients`
--

CREATE TABLE `order_ingredients` (
  `id` int NOT NULL,
  `ingredient_id` int DEFAULT NULL,
  `order_product_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `order_ingredients`
--

INSERT INTO `order_ingredients` (`id`, `ingredient_id`, `order_product_id`) VALUES
(100, 10, 150),
(101, 2, 150),
(102, 7, 150),
(103, 2, 152),
(104, 1, 152),
(105, 7, 152),
(106, 4, 154),
(107, 9, 154),
(108, 1, 154),
(109, 7, 154),
(110, 9, 155),
(111, 4, 155),
(112, 1, 155),
(113, 7, 155);

-- --------------------------------------------------------

--
-- Table structure for table `order_products`
--

CREATE TABLE `order_products` (
  `id` int NOT NULL,
  `quantity` int NOT NULL,
  `price` double(11,3) DEFAULT NULL,
  `order_id` int DEFAULT NULL,
  `product_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `order_products`
--

INSERT INTO `order_products` (`id`, `quantity`, `price`, `order_id`, `product_id`) VALUES
(150, 1, 12.000, 159, 14),
(151, 1, 8.000, 160, 14),
(152, 1, 12.000, 161, 14),
(153, 1, 8.000, 162, 14),
(154, 1, 12.000, 163, 14),
(155, 1, 12.000, 164, 14);

-- --------------------------------------------------------

--
-- Table structure for table `person`
--

CREATE TABLE `person` (
  `uid` int NOT NULL,
  `firstName` varchar(50) DEFAULT NULL,
  `lastName` varchar(50) DEFAULT NULL,
  `phone` varchar(11) DEFAULT NULL,
  `image` varchar(250) DEFAULT NULL,
  `state` bit(1) DEFAULT b'1',
  `created` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `person`
--

INSERT INTO `person` (`uid`, `firstName`, `lastName`, `phone`, `image`, `state`, `created`) VALUES
(1, 'Fedi', 'Developer', '21629651545', 'without-image.png', b'1', '2023-07-21 23:27:04'),
(2, 'Fedi S', 'Mersin', '29651545', 'image-1690800550131.jpg', b'1', '2023-07-31 11:49:10'),
(3, 'fedi', '', '29651545', NULL, b'1', '2023-08-09 16:16:40'),
(4, 'aicha', '', '20732104', 'without-image.png', b'1', '2023-08-11 12:52:17'),
(5, 'fedi', '2', '29651545', NULL, b'1', '2023-09-11 01:58:39'),
(6, 'mersni', 'fedi', '29651545', NULL, b'1', '2023-09-16 14:26:36');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int NOT NULL,
  `nameProduct` varchar(50) NOT NULL,
  `description` varchar(200) DEFAULT NULL,
  `price` double(11,2) NOT NULL,
  `status` int DEFAULT '1',
  `picture` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'without-image.jpg',
  `category_id` int NOT NULL,
  `restaurant_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `nameProduct`, `description`, `price`, `status`, `picture`, `category_id`, `restaurant_id`) VALUES
(7, 'Hamburguesas', 'Hamburguesas description', 23.00, 1, 'image-1629870179668.jpg', 1, 2),
(8, 'Pizza', 'Pizza description', 8.50, 1, 'image-1629870179668.jpg', 3, 2),
(14, 'makloub', 'makloub', 8.00, 1, 'makloub-1.jpg', 1, 1),
(15, 'Kafteji', 'kafteji kairouan', 5.50, 1, 'kafteji2.jpg', 2, 2),
(16, 'Panozzo', 'Panozzo', 8.50, 1, 'panozzo2.jpg', 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `product_ingredients`
--

CREATE TABLE `product_ingredients` (
  `id` int NOT NULL,
  `possible_choices` int NOT NULL DEFAULT '-1',
  `ingredient_type` int NOT NULL,
  `product_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `product_ingredients`
--

INSERT INTO `product_ingredients` (`id`, `possible_choices`, `ingredient_type`, `product_id`) VALUES
(21, -1, 2, 14),
(22, -1, 4, 14),
(23, -1, 1, 14),
(24, 1, 3, 14),
(25, 1, 4, 15);

-- --------------------------------------------------------

--
-- Table structure for table `restaurants`
--

CREATE TABLE `restaurants` (
  `id` int NOT NULL,
  `Name` varchar(50) DEFAULT NULL,
  `phone` varchar(11) DEFAULT NULL,
  `state` int DEFAULT '4',
  `created` datetime DEFAULT CURRENT_TIMESTAMP,
  `address` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `restaurants`
--

INSERT INTO `restaurants` (`id`, `Name`, `phone`, `state`, `created`, `address`) VALUES
(1, 'NOIR ET BLANC', '20203333', 0, '2023-07-27 14:34:17', 'El Manzah 6, Tunis'),
(2, 'Weld El 7ay', '20203333', 1, '2023-07-31 15:19:39', 'El Manar 2');

-- --------------------------------------------------------

--
-- Table structure for table `restaurant_ingredients`
--

CREATE TABLE `restaurant_ingredients` (
  `id` int NOT NULL,
  `restaurant_id` int NOT NULL,
  `ingredient_id` int NOT NULL,
  `status` int DEFAULT '1',
  `price` double(11,2) DEFAULT '0.00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `restaurant_ingredients`
--

INSERT INTO `restaurant_ingredients` (`id`, `restaurant_id`, `ingredient_id`, `status`, `price`) VALUES
(1, 1, 1, 1, 0.00),
(2, 1, 2, 1, 0.00),
(3, 1, 4, 1, 0.00),
(4, 1, 5, 1, 0.00),
(5, 1, 7, 1, 4.00),
(6, 1, 9, 1, 0.00),
(7, 1, 10, 1, 0.00),
(8, 2, 2, 1, 0.00),
(9, 2, 3, 1, 0.00),
(10, 2, 4, 1, 0.00),
(11, 2, 5, 1, 0.00),
(12, 2, 7, 1, 0.00),
(13, 2, 9, 1, 0.00),
(14, 2, 10, 1, 0.00);

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` int NOT NULL,
  `rol` varchar(50) NOT NULL,
  `description` varchar(100) NOT NULL,
  `state` bit(1) DEFAULT b'1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `rol`, `description`, `state`) VALUES
(1, 'Admin', 'Admin', b'1'),
(2, 'Client', 'Client', b'1'),
(3, 'Delivery', 'Delivery', b'1'),
(4, 'Restaurant', 'Restaurant', b'1');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `users` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `passwordd` varchar(100) NOT NULL,
  `persona_id` int DEFAULT NULL,
  `restaurant_id` int DEFAULT NULL,
  `rol_id` int NOT NULL,
  `notification_token` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `users`, `email`, `passwordd`, `persona_id`, `restaurant_id`, `rol_id`, `notification_token`) VALUES
(1, 'Frave', 'frave@frave.com', '$2b$10$loiXWqS2XD3Xa5rPwShlwu9tcX3QQYwMHtXNVU0yIrIDQiHigybUC', 1, NULL, 1, 'fS1B1jSoQWeRohCz0tE6i2:APA91bEcLBtyw0bbArJmuBuo47l_G82VQuq0_vWINm7VNFuHPwNHvJkoyRhLYpf9583KRCcuhi8s-irwW2jGz_gp3CcUCwjHeT6nnb2lMdj5Du2ebdY0XkxzJgC7lGDnftRBOEuv4Y50'),
(2, 'Fedi', 'mersnifedy@gmail.com', '$2b$10$ivaOvF4IoGNW4AoOom06L.Z0SGKctHrTn2ay84ZvSZyluJ3xqOaSm', 2, NULL, 3, 'fuTv7tYSSzmbq187M-1VqK:APA91bFH1yz-hHupmNLVa4TljVR8Q7mlFZ_IlQp75CsqYL5hd_v8rJBI8NWEchwTerc2bLQmkAmQIgJmP8cOXbM0ZNXTvofVwt2YnGH5wEY81fiTUttSO14S3H70tixoSZE2r2-BoOJL'),
(3, 'fedi', 'fedi@fedi.com', '$2b$10$IldgQvAVoKBtXUn6dyAeIOfiVLrlkcvAC8I2U4RBQOv.HG6TK8Au2', 3, NULL, 2, 'dtr_LJ5XQ6SLh7nnCHDI3d:APA91bEA2BICWH4cP9DXTR7XwsQC2aROr3Z70V1-Iv7CSFzhwKpfFyy5LT_ztdCQup8kvVtxGYgPCKXdnsL4ifOr3gXu6gS21MwENiXTcFeAxQf-GYgFGX7e93Rf1V3SklnIlUZBidS2'),
(5, 'fedi', 'mersni@fedi.com', '$2b$10$JdYwxuzcWc953ZAq9R849ObYvHsO1/D/ELUlsi2R.44hYZFLj4YXi', 5, NULL, 2, 'dtr_LJ5XQ6SLh7nnCHDI3d:APA91bEA2BICWH4cP9DXTR7XwsQC2aROr3Z70V1-Iv7CSFzhwKpfFyy5LT_ztdCQup8kvVtxGYgPCKXdnsL4ifOr3gXu6gS21MwENiXTcFeAxQf-GYgFGX7e93Rf1V3SklnIlUZBidS2'),
(6, 'mersni', 'fedi@mersni.com', '$2b$10$gNAidyib2ArQQNe/yP0WouKsT3xjFqRCYiU32pWiUElrU0LhRLt7.', 6, NULL, 2, 'fuTv7tYSSzmbq187M-1VqK:APA91bFH1yz-hHupmNLVa4TljVR8Q7mlFZ_IlQp75CsqYL5hd_v8rJBI8NWEchwTerc2bLQmkAmQIgJmP8cOXbM0ZNXTvofVwt2YnGH5wEY81fiTUttSO14S3H70tixoSZE2r2-BoOJL');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `addresses`
--
ALTER TABLE `addresses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `persona_id` (`persona_id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `client_resto_fav`
--
ALTER TABLE `client_resto_fav`
  ADD PRIMARY KEY (`id`),
  ADD KEY `clientId` (`clientId`),
  ADD KEY `restaurantId` (`restaurantId`);

--
-- Indexes for table `imageproduct`
--
ALTER TABLE `imageproduct`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `imagerestaurant`
--
ALTER TABLE `imagerestaurant`
  ADD PRIMARY KEY (`id`),
  ADD KEY `restaurant_id` (`restaurant_id`);

--
-- Indexes for table `ingredients`
--
ALTER TABLE `ingredients`
  ADD PRIMARY KEY (`id`),
  ADD KEY `type_id` (`type_id`);

--
-- Indexes for table `ingredient_type`
--
ALTER TABLE `ingredient_type`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`orderId`),
  ADD KEY `client_id` (`client_id`),
  ADD KEY `addressId` (`address_id`),
  ADD KEY `fk_delivery` (`delivery_id`);

--
-- Indexes for table `order_ingredients`
--
ALTER TABLE `order_ingredients`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ingredient_id` (`ingredient_id`),
  ADD KEY `order_product_id` (`order_product_id`);

--
-- Indexes for table `order_products`
--
ALTER TABLE `order_products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `orderId` (`order_id`),
  ADD KEY `productId` (`product_id`);

--
-- Indexes for table `person`
--
ALTER TABLE `person`
  ADD PRIMARY KEY (`uid`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `restaurant_id` (`restaurant_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `product_ingredients`
--
ALTER TABLE `product_ingredients`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ingredient_type` (`ingredient_type`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `restaurants`
--
ALTER TABLE `restaurants`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `restaurant_ingredients`
--
ALTER TABLE `restaurant_ingredients`
  ADD PRIMARY KEY (`id`),
  ADD KEY `restaurant_id` (`restaurant_id`),
  ADD KEY `ingredient_id` (`ingredient_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `persona_id` (`persona_id`),
  ADD KEY `rol_id` (`rol_id`),
  ADD KEY `restaurant_id` (`restaurant_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `addresses`
--
ALTER TABLE `addresses`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `client_resto_fav`
--
ALTER TABLE `client_resto_fav`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

--
-- AUTO_INCREMENT for table `imageproduct`
--
ALTER TABLE `imageproduct`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- AUTO_INCREMENT for table `imagerestaurant`
--
ALTER TABLE `imagerestaurant`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `ingredients`
--
ALTER TABLE `ingredients`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `ingredient_type`
--
ALTER TABLE `ingredient_type`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `orderId` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=165;

--
-- AUTO_INCREMENT for table `order_ingredients`
--
ALTER TABLE `order_ingredients`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=114;

--
-- AUTO_INCREMENT for table `order_products`
--
ALTER TABLE `order_products`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=156;

--
-- AUTO_INCREMENT for table `person`
--
ALTER TABLE `person`
  MODIFY `uid` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `product_ingredients`
--
ALTER TABLE `product_ingredients`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `restaurants`
--
ALTER TABLE `restaurants`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `restaurant_ingredients`
--
ALTER TABLE `restaurant_ingredients`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `addresses`
--
ALTER TABLE `addresses`
  ADD CONSTRAINT `addresses_ibfk_1` FOREIGN KEY (`persona_id`) REFERENCES `person` (`uid`);

--
-- Constraints for table `client_resto_fav`
--
ALTER TABLE `client_resto_fav`
  ADD CONSTRAINT `client_resto_fav_ibfk_1` FOREIGN KEY (`clientId`) REFERENCES `person` (`uid`),
  ADD CONSTRAINT `client_resto_fav_ibfk_2` FOREIGN KEY (`restaurantId`) REFERENCES `restaurants` (`id`);

--
-- Constraints for table `imageproduct`
--
ALTER TABLE `imageproduct`
  ADD CONSTRAINT `imageproduct_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

--
-- Constraints for table `imagerestaurant`
--
ALTER TABLE `imagerestaurant`
  ADD CONSTRAINT `imagerestaurant_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`);

--
-- Constraints for table `ingredients`
--
ALTER TABLE `ingredients`
  ADD CONSTRAINT `ingredients_ibfk_1` FOREIGN KEY (`type_id`) REFERENCES `ingredient_type` (`id`);

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `fk_client` FOREIGN KEY (`client_id`) REFERENCES `person` (`uid`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_delivery` FOREIGN KEY (`delivery_id`) REFERENCES `person` (`uid`) ON DELETE CASCADE,
  ADD CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`address_id`) REFERENCES `addresses` (`id`);

--
-- Constraints for table `order_ingredients`
--
ALTER TABLE `order_ingredients`
  ADD CONSTRAINT `order_ingredients_ibfk_1` FOREIGN KEY (`ingredient_id`) REFERENCES `ingredients` (`id`),
  ADD CONSTRAINT `order_ingredients_ibfk_2` FOREIGN KEY (`order_product_id`) REFERENCES `order_products` (`id`);

--
-- Constraints for table `order_products`
--
ALTER TABLE `order_products`
  ADD CONSTRAINT `order_products_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`orderId`),
  ADD CONSTRAINT `order_products_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`),
  ADD CONSTRAINT `products_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`);

--
-- Constraints for table `product_ingredients`
--
ALTER TABLE `product_ingredients`
  ADD CONSTRAINT `product_ingredients_ibfk_1` FOREIGN KEY (`ingredient_type`) REFERENCES `ingredient_type` (`id`),
  ADD CONSTRAINT `product_ingredients_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

--
-- Constraints for table `restaurant_ingredients`
--
ALTER TABLE `restaurant_ingredients`
  ADD CONSTRAINT `restaurant_ingredients_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`),
  ADD CONSTRAINT `restaurant_ingredients_ibfk_2` FOREIGN KEY (`ingredient_id`) REFERENCES `ingredients` (`id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`persona_id`) REFERENCES `person` (`uid`),
  ADD CONSTRAINT `users_ibfk_2` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id`),
  ADD CONSTRAINT `users_ibfk_3` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurants` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
