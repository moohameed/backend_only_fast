-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 23, 2023 at 09:20 PM
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
	INSERT INTO person (firstName, lastName, phone, image) VALUE (firstName, lastName, phone, image);
	
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

CREATE TABLE `imageProduct` (
  `id` int NOT NULL,
  `picture` varchar(255) DEFAULT NULL,
  `product_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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
(10, 'Oninon', 4),
(11, 'Salade Mechouia', 4),
(12, 'Harissa arbi', 1),
(13, 'Harissa', 1),
(14, 'Sauce Algérienne', 1),
(15, 'Sauce barbecue', 1),
(16, 'Salade sautée', 4),
(17, 'Roquefort', 2),
(18, 'Gruyère', 2),
(19, 'Mozzarella', 2),
(20, 'Cordon bleu', 3),
(21, 'Jambon', 3),
(22, 'Champignon', 4),
(23, 'Frites', 5),
(24, 'Mini', 6),
(25, 'Moyenne', 6),
(26, 'Maxi', 6);

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
(4, 'Salade'),
(5, 'Suppléments'),
(6, 'Taille Pizza');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `orderId` int NOT NULL,
  `status` int NOT NULL DEFAULT '0',
  `price` double(11,3) DEFAULT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `accepted_date` datetime DEFAULT NULL,
  `onway_date` datetime DEFAULT NULL,
  `delivered_date` datetime DEFAULT NULL,
  `client_id` int DEFAULT NULL,
  `delivery_id` int DEFAULT NULL,
  `address_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `order_ingredients`
--

CREATE TABLE `order_ingredients` (
  `id` int NOT NULL,
  `ingredient_id` int DEFAULT NULL,
  `order_product_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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
(30, 'Baguette Farcie Jambon', 'Baguette Farcie Jambon', 8.50, 1, 'baguette-farcie-NO.jpg', 1, 3),
(31, 'Baguette Farcie Thon', 'Baguette Farcie Thon', 8.50, 1, 'baguette-farcie-NO.jpg', 1, 3),
(32, 'Baguette Farcie Escalope', 'Baguette Farcie Escalope', 9.00, 1, 'baguette-farcie-NO.jpg', 1, 3),
(33, 'Baguette Farcie Cordon Bleu', 'Baguette Farcie Cordon Bleu', 9.50, 1, 'baguette-farcie-NO.jpg', 1, 3),
(34, 'Baguette Farcie Escalope Pannée', 'Baguette Farcie Escalope Pannée', 9.50, 1, 'baguette-farcie-NO.jpg', 1, 3),
(35, 'Calzone Jambon', 'Calzone Jambon', 8.00, 1, 'calzone-NO.jpg', 1, 3),
(36, 'Calzone Thon', 'Calzone Thon', 8.00, 1, 'calzone-NO.jpg', 1, 3),
(37, 'Calzone Pepperoni', 'Calzone Pepperoni', 8.00, 1, 'calzone-NO.jpg', 1, 3),
(38, 'Calzone Escalope', 'Calzone Escalope', 8.50, 1, 'calzone-NO.jpg', 1, 3),
(39, 'Calzone Cordon Bleu', 'Calzone Cordon Bleu', 9.00, 1, 'calzone-NO.jpg', 1, 3),
(40, 'Calzone Escalope Pannée', 'Calzone Escalope Pannée', 9.00, 1, 'calzone-NO.jpg', 1, 3),
(41, 'Calzone Jambon Fumé', 'Calzone Jambon Fumé', 9.50, 1, 'calzone-NO.jpg', 1, 3),
(42, 'Calzone Number One', '(escalope, champignon, saucisse, jambon)', 12.00, 1, 'calzone-NO.jpg', 1, 3),
(43, 'Libanais Jambon', 'Libanais Jambon', 6.50, 1, 'libanais-NO.jpg', 1, 3),
(44, 'Libanais Jambon', 'Libanais Jambon', 6.50, 1, 'libanais-NO.jpg', 1, 3),
(45, 'Libanais thon', 'Libanais thon', 6.50, 1, 'libanais-NO.jpg', 1, 3),
(46, 'Libanais Jambon du poulet fumé', 'Libanais Jambon du poulet fumé', 7.00, 1, 'libanais-NO.jpg', 1, 3),
(47, 'Libanais cordon bleu', 'Libanais cordon bleu', 7.50, 1, 'libanais-NO.jpg', 1, 3),
(48, 'Libanais escalope pannée', 'Libanais escalope pannée', 7.50, 1, 'libanais-NO.jpg', 1, 3),
(49, 'Pain Special Jambon', 'Pain Special Jambon', 4.00, 1, 'pain-special-NO.jpg', 1, 3),
(50, 'Pain Special thon', 'Pain Special thon', 4.00, 1, 'pain-special-NO.jpg', 1, 3),
(51, 'Pain Special Jambon du poulet fumé', 'Pain Special Jambon du poulet fumé', 4.50, 1, 'pain-special-NO.jpg', 1, 3),
(52, 'Pain Special cordon bleu', 'Pain Special cordon bleu', 5.50, 1, 'pain-special-NO.jpg', 1, 3),
(53, 'Pain Special escalope pannée', 'Pain Special escalope pannée', 5.50, 1, 'pain-special-NO.jpg', 1, 3),
(54, 'Pain Special nuggets', 'Pain Special nuggets', 5.50, 1, 'pain-special-NO.jpg', 1, 3),
(55, 'Pain Special brochette de poulet', 'Pain Special brochette de poulet', 6.00, 1, 'pain-special-NO.jpg', 1, 3),
(56, 'Pain Special kebab', 'Pain Special kebab', 6.00, 1, 'pain-special-NO.jpg', 1, 3),
(57, 'Makloub Jambon', 'Makloub Jambon', 6.50, 1, 'makloub-NO.jpg', 1, 3),
(58, 'Makloub thon', 'Makloub thon', 6.50, 1, 'makloub-NO.jpg', 1, 3),
(59, 'Makloub Jambon', 'Makloub Jambon', 6.50, 1, 'makloub-NO.jpg', 1, 3),
(60, 'Makloub thon', 'Makloub thon', 6.50, 1, 'makloub-NO.jpg', 1, 3),
(61, 'Makloub Jambon du poulet fumé', 'Makloub Jambon du poulet fumé', 7.00, 1, 'makloub-NO.jpg', 1, 3),
(62, 'Makloub cordon bleu', 'Makloub cordon bleu', 7.50, 1, 'makloub-NO.jpg', 1, 3),
(63, 'Makloub escalope pannée', 'Makloub escalope pannée', 7.50, 1, 'makloub-NO.jpg', 1, 3),
(64, 'Tono e mais MINI', 'Creme Fraiche, Mozzarella, Oignon, Mais, Thon, Olive', 8.00, 1, 'tono-e-mais.jpg', 3, 3),
(65, 'Tonno e Mais', 'Creme Fraiche, Mozzarella, Oignon, Mais, Thon, Olive', 8.00, 1, 'tono-e-mais.jpg', 3, 3),
(66, 'Pavarotti', 'Creme Fraiche, Mozzarella, Oignon, Champignon, Roquette', 7.00, 1, 'pavarotti.jpg', 3, 3),
(67, 'Polo Pizza', 'Creme Fraiche, Mozzarella, Poulet Epicé, Oignon, Roquette', 8.00, 1, 'polo-pizza.jpg', 3, 3),
(68, 'Quattro Fromaggi', 'Creme Fraiche, Mozzarella, gruyère, Roquefort, Parmesan, Noix, Roquette', 10.00, 1, 'quattro-fromaggi.jpg', 3, 3),
(69, 'Tre Jambon', 'Creme Fraiche, Mozzarella, Pepperoni, Chorizo, Jambon, Roquette', 9.00, 1, 'tre-jambon.jpg', 3, 3),
(70, 'Mare e Monti', 'Creme Fraiche, Mozzarella, Chevrette, Champignon, Roquette', 16.00, 1, 'mare-e-monti.jpg', 3, 3),
(71, 'Norvegienne', 'Creme Fraiche, Mozzarella, Chevrette, Saumon Fumé, Roquette', 22.00, 1, 'norvegienne.jpg', 3, 3),
(72, 'Number one', 'Creme fraiche, Mozzarella, Escalope, Champignon, Jambon', 12.00, 1, 'number-one.jpg', 3, 3),
(73, 'Margherita', 'Sauce Tomate, Mozzarella, Basilic, Olive', 6.00, 1, 'margherita.jpg', 3, 3),
(74, 'Tonna', 'Sauce Tomate, Mozzarella, Oignon, Poviron, ilion, Basilic, Olive', 7.00, 1, 'tonna.jpg', 3, 3),
(75, 'Pepperoni', 'Sauce Tomate, Mozzarella, Basilic, Pepperoni', 7.00, 1, 'pepperoni.jpg', 3, 3),
(76, 'Salumi', 'Sauce Tomate, Mozzarella, Jambon Fumé, Bacon Du Beuf, Chorizo, Roquette', 10.00, 1, 'salumi.jpg', 3, 3),
(77, 'Cappericciosa', 'Sauce Tomate, Mozzarella, Champignon, Jambon, Saucisse, Basilic', 8.00, 1, 'cappericciosa.jpg', 3, 3),
(78, 'Vergitariana', 'Sauce Tomate, Mozzarella, Champignon, Artichaut, Oignon, Poviron, Tomates Cerise, Olive', 7.00, 1, 'vergitariana.jpg', 3, 3),
(79, 'Mexicana', 'Sauce Tomate, Mozzarella, Escalope Grillé, Oignon, Poivron, Tomates Cerise, Olive', 8.00, 1, 'mexicana.jpg', 3, 3),
(80, 'Bolognese', 'Sauce Tomate, Mozzarella, Viande Hachée, Poivron, Oignon, Basilic', 8.00, 1, 'bolognese.jpg', 3, 3),
(81, 'Frutti di Mare', 'Sauce Tomate, Mozzarella, Chevrette, Moule, Basilic', 16.00, 1, 'frutti-di-mare.jpg', 3, 3),
(82, 'Number One', 'Sauce Thmate, Mozzarella, Escalope, Champignon, Jambon, Basilic', 10.00, 1, 'number-one-rouge.jpg', 3, 3);

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
(26, -1, 1, 30),
(27, -1, 1, 31),
(28, -1, 1, 32),
(29, -1, 1, 33),
(30, -1, 1, 34),
(31, -1, 1, 35),
(32, -1, 1, 36),
(33, -1, 1, 37),
(34, -1, 1, 38),
(35, -1, 1, 39),
(36, -1, 1, 40),
(37, -1, 1, 41),
(38, -1, 1, 42),
(39, -1, 1, 43),
(40, -1, 1, 44),
(41, -1, 1, 45),
(42, -1, 1, 46),
(43, -1, 1, 47),
(44, -1, 1, 48),
(45, -1, 1, 49),
(46, -1, 1, 50),
(47, -1, 1, 51),
(48, -1, 1, 52),
(49, -1, 1, 53),
(50, -1, 1, 54),
(51, -1, 1, 55),
(52, -1, 1, 56),
(53, -1, 1, 57),
(54, -1, 1, 58),
(55, -1, 1, 59),
(56, -1, 1, 60),
(57, -1, 1, 61),
(58, -1, 1, 62),
(59, -1, 1, 63),
(60, -1, 4, 33),
(61, -1, 4, 30),
(62, -1, 4, 31),
(63, -1, 4, 32),
(64, -1, 4, 34),
(65, -1, 4, 35),
(66, -1, 4, 36),
(67, -1, 4, 37),
(68, -1, 4, 38),
(69, -1, 4, 39),
(70, -1, 4, 40),
(71, -1, 4, 41),
(72, -1, 4, 42),
(73, -1, 4, 43),
(74, -1, 4, 44),
(75, -1, 4, 45),
(76, -1, 4, 46),
(77, -1, 4, 47),
(78, -1, 4, 48),
(79, -1, 4, 49),
(80, -1, 4, 50),
(81, -1, 4, 51),
(82, -1, 4, 52),
(83, -1, 4, 53),
(84, -1, 4, 54),
(85, -1, 4, 55),
(86, -1, 4, 56),
(87, -1, 4, 57),
(88, -1, 4, 58),
(89, -1, 4, 59),
(90, -1, 4, 60),
(91, -1, 4, 61),
(92, -1, 4, 62),
(93, -1, 4, 63),
(94, -1, 2, 30),
(95, -1, 2, 31),
(96, -1, 2, 32),
(97, -1, 2, 34),
(98, -1, 2, 35),
(99, -1, 2, 36),
(100, -1, 2, 37),
(101, -1, 2, 38),
(102, -1, 2, 39),
(103, -1, 2, 40),
(104, -1, 2, 41),
(105, -1, 2, 42),
(106, -1, 2, 43),
(107, -1, 2, 44),
(108, -1, 2, 45),
(109, -1, 2, 46),
(110, -1, 2, 47),
(111, -1, 2, 48),
(112, -1, 2, 49),
(113, -1, 2, 50),
(114, -1, 2, 51),
(115, -1, 2, 52),
(116, -1, 2, 53),
(117, -1, 2, 54),
(118, -1, 2, 55),
(119, -1, 2, 56),
(120, -1, 2, 57),
(121, -1, 2, 58),
(122, -1, 2, 59),
(123, -1, 2, 60),
(124, -1, 2, 61),
(125, -1, 2, 62),
(126, -1, 2, 63),
(127, -1, 5, 30),
(128, -1, 5, 31),
(129, -1, 5, 32),
(130, -1, 5, 34),
(131, -1, 5, 35),
(132, -1, 5, 36),
(133, -1, 5, 37),
(134, -1, 5, 38),
(135, -1, 5, 39),
(136, -1, 5, 40),
(137, -1, 5, 41),
(138, -1, 5, 42),
(139, -1, 5, 43),
(140, -1, 5, 44),
(141, -1, 5, 45),
(142, -1, 5, 46),
(143, -1, 5, 47),
(144, -1, 5, 48),
(145, -1, 5, 49),
(146, -1, 5, 50),
(147, -1, 5, 51),
(148, -1, 5, 52),
(149, -1, 5, 53),
(150, -1, 5, 54),
(151, -1, 5, 55),
(152, -1, 5, 56),
(153, -1, 5, 57),
(154, -1, 5, 58),
(155, -1, 5, 59),
(156, -1, 5, 60),
(157, -1, 5, 61),
(158, -1, 5, 62),
(159, -1, 5, 63);

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
(1, 'NOIR ET BLANC', '20203333', 1, '2023-07-27 14:34:17', 'El Manzah 6, Tunis'),
(2, 'Weld El 7ay', '20203333', 1, '2023-07-31 15:19:39', 'El Manar 2'),
(3, 'Number One', '20251241', 1, '2023-10-23 17:56:53', 'P5CX+325, Béja'),
(4, 'Noir & Blanc', '96109550', 1, '2023-10-23 17:56:53', 'P5PH+4CV, Beja'),
(5, 'Zina', '88888888', 1, '2023-10-23 17:56:53', 'Beja'),
(6, 'Reppa', '88888888', 1, '2023-10-23 17:56:53', 'Beja'),
(7, '112', '88888888', 1, '2023-10-23 17:56:53', 'Beja');

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
(15, 3, 11, 1, 0.00),
(16, 3, 12, 1, 0.00),
(17, 3, 13, 1, 0.00),
(18, 3, 14, 1, 0.00),
(19, 3, 15, 1, 0.00),
(20, 3, 16, 1, 0.00),
(21, 3, 2, 1, 0.00),
(22, 3, 3, 1, 0.00),
(23, 3, 17, 1, 3.00),
(24, 3, 5, 1, 3.00),
(25, 3, 4, 1, 2.50),
(26, 3, 18, 1, 2.50),
(27, 3, 19, 1, 2.50),
(28, 3, 20, 1, 2.50),
(29, 3, 21, 1, 1.50),
(30, 3, 22, 1, 1.50),
(31, 3, 23, 1, 1.50);

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
(1, 'Frave', 'frave@frave.com', '$2b$10$loiXWqS2XD3Xa5rPwShlwu9tcX3QQYwMHtXNVU0yIrIDQiHigybUC', 1, NULL, 1, 'fS1B1jSoQWeRohCz0tE6i2:APA91bGIhX23bdKH0W8vuOSGvU1SwyTJCwdBBcf0jGl3hxE4NWYk3nfQp1sy78PBzshaLbcB2Dr35Az_00B_4oa-LHkNnapaLaLveqxt2Z6Vz6Lt__8hzr9vrUCBmwwqd7vlDwPX9A8S'),
(2, 'Fedi', 'mersnifedy@gmail.com', '$2b$10$ivaOvF4IoGNW4AoOom06L.Z0SGKctHrTn2ay84ZvSZyluJ3xqOaSm', 2, NULL, 3, 'fS1B1jSoQWeRohCz0tE6i2:APA91bGIhX23bdKH0W8vuOSGvU1SwyTJCwdBBcf0jGl3hxE4NWYk3nfQp1sy78PBzshaLbcB2Dr35Az_00B_4oa-LHkNnapaLaLveqxt2Z6Vz6Lt__8hzr9vrUCBmwwqd7vlDwPX9A8S'),
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
ALTER TABLE `imageProduct`
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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=67;

--
-- AUTO_INCREMENT for table `imageproduct`
--
ALTER TABLE `imageProduct`
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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `ingredient_type`
--
ALTER TABLE `ingredient_type`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `orderId` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=167;

--
-- AUTO_INCREMENT for table `order_ingredients`
--
ALTER TABLE `order_ingredients`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=116;

--
-- AUTO_INCREMENT for table `order_products`
--
ALTER TABLE `order_products`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=158;

--
-- AUTO_INCREMENT for table `person`
--
ALTER TABLE `person`
  MODIFY `uid` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=83;

--
-- AUTO_INCREMENT for table `product_ingredients`
--
ALTER TABLE `product_ingredients`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=160;

--
-- AUTO_INCREMENT for table `restaurants`
--
ALTER TABLE `restaurants`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `restaurant_ingredients`
--
ALTER TABLE `restaurant_ingredients`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

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
ALTER TABLE `imageProduct`
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
